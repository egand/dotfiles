# ~/.dotfiles/zsh/.zshrc

# ... (tutta la tua altra configurazione zsh: sheldon, spaceship, alias, etc.) ...

transcribe() {
    input_file="$1"

    # Ottieni la directory del file e il nome senza estensione
    dir_name=$(dirname "$input_file")
    base_name=$(basename "$input_file" .${input_file##*.})

    # Verifica l'estensione del file
    file_extension="${input_file##*.}"

    # Controlla se il file è un video (mp4, mov, avi, ecc.)
    if [[ "$file_extension" == "mp4" || "$file_extension" == "mov" || "$file_extension" == "avi" ]]; then
        # Converti il video in file audio .wav con ffmpeg
        audio_file="$dir_name/$base_name.wav"
        echo "Convertendo il file video in audio .wav..."
        ffmpeg -i "$input_file" -vn -acodec pcm_s16le -ar 16000 -ac 2 "$audio_file"
    else
        # Usa direttamente il file di input come audio
        audio_file="$input_file"
    fi

    # Costruisci il nome del file di output con suffisso .txt
    output_file="$dir_name/$base_name"

    # Esegui il comando principale di trascrizione
    echo "Eseguendo la trascrizione..."
    /Users/egand/Projects/Repos/whisper.cpp/main -m /Users/egand/Projects/Repos/whisper.cpp/models/ggml-large-v2.bin -l it -nt -otxt -t 5 -p 1 -et 2.80 -f "$audio_file" -of "$output_file" -pp 2>&1

    echo "Trascrizione completata. Output salvato in: $output_file.txt"

    # Elimina il file audio temporaneo se è stato generato da un video
    if [[ "$audio_file" != "$input_file" ]]; then
        echo "Eliminazione del file audio temporaneo: $audio_file"
        rm "$audio_file"
    fi
}

# --- Version Manager Configurations ---

# Note on commands:
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # is a common idiom to source a script only if it exists.
# [ -s "$NVM_DIR/nvm.sh" ] = "if the nvm.sh script exists and is not empty", -s checks for existence and non-zero size.
# \. "$NVM_DIR/nvm.sh" = "source the nvm.sh script in the current shell session". The use of \ is to prevent alias expansion in some shells. . is a synonym for source in POSIX shells.

# nvm (Node)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# sdkman (JVM)
export SDKMAN_DIR="$HOME/.sdkman"
[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# pyenv (Python)
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"

eval "$(starship init zsh)"

# Aggiunge i completamenti installati via Homebrew al path delle funzioni di Zsh
# Questo deve venire PRIMA di 'compinit'
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh-completions:${FPATH}"
fi

# Inizializza il sistema di autocompletamento di Zsh
autoload -U compinit
compinit

# if zsh compinit: insecure directories
# run this commands:
# compaudit -> view which directories have insecure permissions
# compaudit | xargs sudo chmod g-w,o-w -> correct the permissions

# Plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
