#!/usr/bin/env bash
# ==============================================================================
# Antigravity CLI Custom Status Bar (statusline.sh)
#
# Receives real-time agent state JSON payload via STDIN and renders a sleek,
# information-dense status bar matching the Catppuccin / Nerd Font aesthetic.
#
# Telemetry Segments:
#  1. Active AI Model (with robot icon & Catppuccin Mauve accent)
#  2. Context Window Usage (visual meter, used/capacity tokens, dynamic color alerts)
#  3. Working Directory (compact path representation)
#  4. Git Telemetry (branch + uncommitted modifications count)
#  5. Quota / Rate-limit alert (when remaining capacity is low)
#  6. Current Time
# ==============================================================================

set -f # disable globbing for safety

# --- Color Definitions (Catppuccin Frappe / Modern ANSI 256) ---
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

# Segment Accents
CLR_MUTED="\033[38;5;243m"     # Subdued gray
CLR_SEP="\033[38;5;239m"       # Dim divider
CLR_MODEL="\033[1;38;5;141m"   # Catppuccin Mauve
CLR_DIR="\033[38;5;110m"       # Catppuccin Blue
CLR_GIT="\033[38;5;149m"       # Sage Green
CLR_GIT_DIRTY="\033[38;5;215m" # Amber / Peach
CLR_TIME="\033[38;5;246m"      # Cool Gray

# Context Health Gradients
CLR_OK="\033[38;5;114m"        # Soft Green (<50%)
CLR_WARN="\033[38;5;221m"      # Warm Yellow (50-75%)
CLR_ALERT="\033[38;5;209m"     # Peach / Orange (75-90%)
CLR_CRIT="\033[1;38;5;203m"    # Bold Coral Red (>90%)

# --- Read Stdin Payload ---
INPUT="$(cat)"

# Fallback if no input was passed
if [[ -z "$INPUT" ]]; then
  echo -e "${CLR_MODEL}󰚩 Antigravity${RESET}"
  exit 0
fi

# --- Helper: Format Token Numbers (e.g. 35000 -> 35k, 35400 -> 35.4k, 1000000 -> 1M) ---
format_tokens() {
  local num="$1"
  if [[ -z "$num" || "$num" == "null" || "$num" -le 0 ]] 2>/dev/null; then
    echo "0"
    return
  fi

  if (( num >= 1000000 )); then
    awk -v n="$num" 'BEGIN {
      val = n / 1000000;
      if (val == int(val)) printf "%dM", val;
      else printf "%.1fM", val;
    }'
  elif (( num >= 1000 )); then
    awk -v n="$num" 'BEGIN {
      val = n / 1000;
      if (val == int(val)) printf "%dk", val;
      else printf "%.1fk", val;
    }'
  else
    echo "$num"
  fi
}

# --- Helper: Render Visual Progress Bar (6-block meter) ---
render_bar() {
  local pct="$1"
  local width=6
  local filled=$(( (pct * width + 50) / 100 ))
  if (( filled > width )); then filled=$width; fi
  if (( filled < 0 )); then filled=0; fi
  local empty=$(( width - filled ))

  local bar=""
  for ((i=0; i<filled; i++)); do bar+="■"; done
  for ((i=0; i<empty; i++)); do bar+="□"; done
  echo "$bar"
}

# --- Parse JSON Payload ---
PARSED=$(echo "$INPUT" | jq -r '
  [
    # [0] Model Display Name or ID (safely handle object or string)
    ((.model | if type == "object" then (.display_name // .id // "Gemini") else tostring end) // "Gemini"),
    # [1] Used Percentage
    (.context_window.used_percentage // 0),
    # [2] Total Consumed Tokens
    (.context_window.total_input_tokens // .context_window.current_usage.input_tokens // 0),
    # [3] Context Window Size
    (.context_window.context_window_size // 0),
    # [4] Working Directory
    (.cwd // .workspace.current // ""),
    # [5] Quota alert (minimum remaining fraction across buckets)
    ([.quota[]?.remaining_fraction? // 1] | min // 1)
  ] | @tsv
' 2>/dev/null)

if [[ -z "$PARSED" ]]; then
  echo -e "${CLR_MODEL}󰚩 Antigravity${RESET}"
  exit 0
fi

IFS=$'\t' read -r MODEL_NAME USED_PCT_RAW TOKENS_USED TOKENS_MAX CWD_PATH MIN_QUOTA <<< "$PARSED"

# Normalize percentage to integer
USED_PCT=$(awk -v p="$USED_PCT_RAW" 'BEGIN {
  if (p > 0 && p <= 1.0) p = p * 100;
  printf "%.0f", p
}' 2>/dev/null || echo "0")

# --- Segment 1: Model Badge ---
SHORT_MODEL="$MODEL_NAME"
SHORT_MODEL="${SHORT_MODEL/Gemini /}"
SHORT_MODEL="${SHORT_MODEL/Google /}"
SEG_MODEL="${CLR_MODEL}󰚩 ${SHORT_MODEL}${RESET}"

# --- Segment 2: Context Window Meter & Token Counts ---
CTX_COLOR="$CLR_OK"
if (( USED_PCT >= 90 )); then
  CTX_COLOR="$CLR_CRIT"
elif (( USED_PCT >= 75 )); then
  CTX_COLOR="$CLR_ALERT"
elif (( USED_PCT >= 50 )); then
  CTX_COLOR="$CLR_WARN"
fi

BAR="$(render_bar "$USED_PCT")"
FMT_USED="$(format_tokens "$TOKENS_USED")"

if (( TOKENS_MAX > 0 )); then
  FMT_MAX="$(format_tokens "$TOKENS_MAX")"
  SEG_CTX="${CTX_COLOR}${BAR} ${USED_PCT}%${RESET} ${CLR_MUTED}(${FMT_USED}/${FMT_MAX})${RESET}"
else
  SEG_CTX="${CTX_COLOR}${BAR} ${USED_PCT}%${RESET} ${CLR_MUTED}(${FMT_USED})${RESET}"
fi

# --- Segment 3: Working Directory ---
TARGET_DIR="${CWD_PATH:-$PWD}"
if [[ "$TARGET_DIR" == "$HOME"* ]]; then
  DISPLAY_DIR="~${TARGET_DIR#$HOME}"
else
  DISPLAY_DIR="$(basename "$TARGET_DIR")"
fi
SEG_DIR="${CLR_DIR} ${DISPLAY_DIR}${RESET}"

# --- Segment 4: Git Status ---
SEG_GIT=""
if [[ -d "$TARGET_DIR" ]] && git -C "$TARGET_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
  BRANCH="$(git -C "$TARGET_DIR" branch --show-current 2>/dev/null || git -C "$TARGET_DIR" rev-parse --short HEAD 2>/dev/null)"
  if [[ -n "$BRANCH" ]]; then
    DIRTY_COUNT="$(git -C "$TARGET_DIR" status --porcelain=v1 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "$DIRTY_COUNT" -gt 0 ]]; then
      SEG_GIT="${CLR_GIT} ${BRANCH}${RESET} ${CLR_GIT_DIRTY}*${DIRTY_COUNT}${RESET}"
    else
      SEG_GIT="${CLR_GIT} ${BRANCH}${RESET} ${CLR_MUTED}✓${RESET}"
    fi
  fi
fi

# --- Segment 5: Quota Warning ---
SEG_QUOTA=""
IS_LOW_QUOTA=$(awk -v q="$MIN_QUOTA" 'BEGIN { if (q < 0.30) print "yes"; else print "no" }' 2>/dev/null || echo "no")
if [[ "$IS_LOW_QUOTA" == "yes" ]]; then
  QUOTA_PCT=$(awk -v q="$MIN_QUOTA" 'BEGIN { printf "%.0f%%", q * 100 }')
  SEG_QUOTA="${CLR_ALERT}󰔛 Quota: ${QUOTA_PCT}${RESET}"
fi

# --- Segment 6: Local Clock ---
TIME_STR="$(date +'%H:%M')"
SEG_TIME="${CLR_TIME}󱑂 ${TIME_STR}${RESET}"

# --- Assemble Status Line ---
SEP=" ${CLR_SEP}│${RESET} "
OUTPUT="${SEG_MODEL}${SEP}${SEG_CTX}${SEP}${SEG_DIR}"

if [[ -n "$SEG_GIT" ]]; then
  OUTPUT+="${SEP}${SEG_GIT}"
fi

if [[ -n "$SEG_QUOTA" ]]; then
  OUTPUT+="${SEP}${SEG_QUOTA}"
fi

OUTPUT+="${SEP}${SEG_TIME}"

echo -e "$OUTPUT"
