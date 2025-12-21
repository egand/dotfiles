# ~/.dotfiles/zsh/.zshrc

# --- 1. Global Variables & Paths ---
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Cache Homebrew prefix to speed up shell load
if type brew &>/dev/null; then
  export BREW_PREFIX="$(brew --prefix)"
else
  # Fallback per Apple Silicon se brew non è nel path
  export BREW_PREFIX="/opt/homebrew"
fi

# Go Path
export GOPATH="$HOME/go"
export PATH="$PATH:$BREW_PREFIX/go/bin:$GOPATH/bin"

# Local Bin (per uv tools, rust, etc)
export PATH="$HOME/.local/bin:$PATH"

# --- 2. Custom Functions ---

transcribe() {
    input_file="$1"

    # Aggiornato per la nuova struttura cartelle (~/Developer/repos)
    # Assicurati di aver clonato whisper.cpp qui!
    WHISPER_DIR="$HOME/Developer/repos/whisper.cpp"
    MODEL_PATH="$WHISPER_DIR/models/ggml-large-v2.bin"

    if [ ! -f "$WHISPER_DIR/main" ]; then
        echo "❌ Errore: Eseguibile whisper non trovato in $WHISPER_DIR"
        return 1
    fi

    # Ottieni directory e nome base
    dir_name=$(dirname "$input_file")
    base_name=$(basename "$input_file" .${input_file##*.})
    file_extension="${input_file##*.}"

    # Conversione Video -> Audio
    if [[ "$file_extension" == "mp4" || "$file_extension" == "mov" || "$file_extension" == "avi" ]]; then
        audio_file="$dir_name/$base_name.wav"
        echo "🎥 Convertendo video in audio .wav..."
        ffmpeg -i "$input_file" -vn -acodec pcm_s16le -ar 16000 -ac 2 "$audio_file" -loglevel error
    else
        audio_file="$input_file"
    fi

    output_file="$dir_name/$base_name"

    echo "🎙️  Eseguendo la trascrizione con Whisper..."
    "$WHISPER_DIR/main" -m "$MODEL_PATH" -l it -nt -otxt -t 8 -p 1 -et 2.80 -f "$audio_file" -of "$output_file" 2>/dev/null

    echo "✅ Trascrizione completata: $output_file.txt"

    # Pulizia file temporanei
    if [[ "$audio_file" != "$input_file" ]]; then
        rm "$audio_file"
    fi
}

# --- 3. Version Managers ---

# nvm (Node)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# sdkman (Java/Kotlin)
export SDKMAN_DIR="$HOME/.sdkman"
[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# --- 4. Autocompletion & Plugins ---

# Aggiunge completamenti di Homebrew
if type brew &>/dev/null; then
  FPATH="$BREW_PREFIX/share/zsh-completions:${FPATH}"
fi

# Inizializza compinit
autoload -U compinit
# Il controllo -C serve per non rifare il check di sicurezza ogni volta (velocizza avvio)
compinit 

# Load Plugins (using cached prefix)
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$BREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Angular CLI (Carica solo se ng esiste, evita errori se non è installato)
if command -v ng &> /dev/null; then
    source <(ng completion script)
fi

# --- 5. Modern Tools (2025 Stack) ---

# UV (Python Manager - Sostituisce Pyenv)
if command -v uv &> /dev/null; then
    eval "$(uv generate-shell-completion zsh)"
fi

# ZOXIDE (Smarter cd - Sostituisce autojump)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# --- 6. Prompt ---
# Starship (Deve essere l'ultima cosa)
eval "$(starship init zsh)"