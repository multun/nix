# please configure your env inside ~/.pam_environment

export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export EDITOR=emacs
export CLICOLOR_FORCE=1
export FZF_DEFAULT_OPTS="--preview 'bat --style=numbers --color=always {} | head -500'"

shescape () {
    printf '%q ' "$@"
}

i3-start () {
    i3-msg -q -t command exec "cd $(shescape "$PWD") && $(shescape "$@")"
}

cne () {
    emacsclient -nw "$@"
}

ne () {
    i3-start emacsclient -n -c "$@"
}

alias sc='systemctl'
alias scu='systemctl --user'
alias mpv='mpv --no-audio-display'

retry () {
  while ! "$@"; do
    sleep 1
  done
}

moche () {
    local port="${2:-22}"
    local host="${1:?missing host}"
    mosh --ssh="ssh -p $port" "$host"
}

setclip () {
    xclip -selection c
}

getclip () {
    xclip -selection c -o
}

export EPICFLAGS="-Wall -Wextra -std=c99 -pedantic \
  -Wfloat-equal -Wundef -Wshadow -Wpointer-arith \
  -Wbad-function-cast -Wcast-qual -Wcast-align \
  -Waggregate-return -Wstrict-prototypes -Wmissing-prototypes \
  -Wmissing-declarations -Wnested-externs \
  -Wunreachable-code -Wwrite-strings"

EPICXXFLAGS=( -std=c++17 -pedantic -Wall -Wextra -Werror )

export CFLAGS="$EPICFLAGS"

ecc () {
    gcc $EPICFLAGS "$@"
}

ecc++ () {
    g++  ${EPICXXFLAGS[@]} "$@"
}

ivalgrind () {
  valgrind --leak-check=full        \
           --show-leak-kinds=all    \
	   --track-origins=yes "$@"
}

gecc () {
  ecc -g -ggdb -gdwarf-3 "$@"
}

upload () {
  curl -sSLT "$1" chunk.io
}

dig () {
  echo ">> Please update your brain to drill <<" >&2
  drill "$@"
}

rep () {
  local times="$1"
  local char="${2:-A}"
  printf "%${times}s" | tr ' ' "${char}" 
}

alias pad=rep

bruijn_gen () {
  ragg2 -P "${1:-1024}" | rax2 -s -
}

bruijn_anal () {
   r2 -qc "wopO ${1:?missing de bruijn offset}" --
}

meh () {
  echo '¯\_(ツ)_/¯'
}

alias pgg='systemctl --user restart zerauth'

mc () {
  mkdir -p -- "$1"
  cd "$1"
}

alias gs='git status --short'

title () {
      echo -ne "\033]0;$*\007"
}

update_title () {
      title "$PWD"
}

my_cd () {
      \cd "$@"
      update_title
}

alias cd=my_cd

filter_escapes () {
    sed 's/[\x01-\x1F\x7F].*m//g' -- "$@"
}

xml_minify () {
    # piece of junk that may work
    sed -r 's/^[ ]*//g; s/[ ]*$//g; s/ \/>/\/>/g' | \
        tr $'\n' ' ' | \
        sed 's/> </></g'
}

pretty_html () {
    tidy -q -i | bat -p
}

nth () {
    local n=$1
    shift $(( n + 1))
    echo "$1"
}

format () {
     bat -p -l "${1:-json}"
}

alias ssh='TERM=xterm-256color \ssh'

alias lock='i3lock'
alias sus='systemctl suspend'

dodo () {
     lock & sus
}

nixpkgs-shell () {
    local shell_name="$1"
    shift
    nix-shell -E "(import <nixpkgs> {}).${shell_name}" "$@"
}

acu-shell () {
    nixpkgs-shell acu-shell "$@"
}

nixpkgs-commit() {
    nix eval --raw '(import <nixpkgs> {}).lib.version' | cut -d. -f3
}
