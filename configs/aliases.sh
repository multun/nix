# please configure your env inside ~/.pam_environment

escape_shell () {
    printf '%q ' "$@"
}

wm_spawn () {
    local i3msg='i3-msg'
    if ! [ -z "${SWAYSOCK+x}" ]; then
        local i3msg='swaymsg'
    fi
    "$i3msg" -q -t command exec "cd $(escape_shell "$PWD") && $(escape_shell "$@")"
}

ne () {
    wm_spawn emacsclient -n -c "$@"
}

ivalgrind () {
  valgrind --leak-check=full        \
           --show-leak-kinds=all    \
           --track-origins=yes "$@"
}

mc () {
  mkdir -p -- "$1"
  cd "$1"
}

title () {
      echo -ne "\033]0;$*\007"
}

my_cd () {
      \cd "$@"
      title "$PWD"
}

alias cd=my_cd

alias sus='systemctl suspend'

nixpkgs-commit() {
    nix eval --raw '(import <nixpkgs> {}).lib.version' | cut -d. -f3
}

git-ublame() {
    git blame "$@" | awk '
        $1 == "author" {
            author=substr($0,length($1)+2)
        }

        /^\t/ {
            print author,$0
        }'
}

top_cpu() {
    ps -w -eo %cpu,pid,comm --sort=-%cpu | head
}

most_recent_download() {
    find ~/Downloads -maxdepth 1 -type f -printf "%T@\t%p\n" | sort -n | cut -f 2- | tail -n 1
}

flash_ergodox() {
    local last_download="$(most_recent_download)"
    echo "last download: $last_download"
    case "${last_download##*/}" in
        ergodox_ez_*.hex) ;;
        *)
            echo "the last download isn't an ergodox rom"
            return 1
            ;;
    esac

    teensy-loader-cli -v -mmcu=atmega32u4 -w "$last_download"
}


upload() {
    scp "$1" multun.net:/srv/www/dl.multun.net/ \
        && printf '%s\n' "https://dl.multun.net/${1##*/}"
}
