#!/bin/bash

set -e
# setting colors
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
GRAY="$(tput setaf 7)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
BOLD="$(tput bold)"
NORMAL="$(tput sgr0)"


# Function to draw progress bar
progressBar () {

  # Calculate number of fill/empty slots in the bar
  progress=$(echo "$progressBarWidth/$taskCount*$tasksDone" | bc -l)
  fill=$(printf "%.0f\n" $progress)
  if [ $fill -gt $progressBarWidth ]; then
    fill=$progressBarWidth
  fi
  empty=$(($fill-$progressBarWidth))

  # Percentage Calculation
  percent=$(echo "100/$taskCount*$tasksDone" | bc -l)
  percent=$(printf "%0.2f\n" $percent)
  if [ $(echo "$percent>100" | bc) -gt 0 ]; then
    percent="100.00"
  fi

  # Output to screen
  printf "\r["
  printf "%${fill}s" "" | sed 's/ /\xE2\x96\x89/g'
  printf "%${empty}s" "" | sed 's/ /\xE2\x96\x91/g'
  printf "] $percent%% - $text "
}


checkDirectories() {
    local_dirs=("$@")
    echo $local_dirs

    for (( i = 0 ; i < ${#local_dirs[@]} ; i++ ))
        do
            if [ ! -d "$i" ]; then
                mkdir ${local_dirs[$i]}
            fi
    done
}
promptConfirm() {
  while true; do
    read -r -n 1 -p "${1}" REPLY
    case $REPLY in
      [yY]) echo; return 0 ;;
      [nN]) echo; return 1 ;;
      *) printf "\n ${RED}${BOLD}Dude! ${NORMAL}${RED}Do you have a problem?
       Answer 'y' or 'n' (without single quotation marks)!${NORMAL}\n"
    esac
  done
}

checkSymlink() {
    if [ ! -L $2 ] || [ ! -e $2 ] ; then
        ln -s $1 $2
    else
        printf "\n\t${BOLD}${RED}$2${NORMAL}${BOLD} already exists!\n\t"

        promptConfirm "${NORMAL}Do you want backup it and continue with the installation? (y/n):" || exit 0
        printf "\t${BOLD}Backup done: ${NORMAL}$2-old\n\n"
        mv $2 $2-old
    fi
}


loaderSpinner()
{
    local pid=$!
    local delay=0.5
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "\t [%c%c] $1" "$spinstr" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf '\b%.0s' {1..60}
    done
    printf "\t${BOLD}${GREEN} [OK] ${NORMAL}$1\n"
}


main() {
    printf "\n${BOLD}[INSTALLING] ${NORMAL}\n"
    # vars
    DOTFILES=$HOME/.server-dotfiles

    (git clone -q https://github.com/moraisaugusto/server-dotfiles.git $HOME/.server-dotfiles) & loaderSpinner "
    Clonning server dotfiles..."

    # creating symlinks
    linkables=$( find -H "$DOTFILES" -name '*.symlink' )
    for file in $linkables ; do
        target="$HOME/.$( basename $file ".symlink" )"
        checkSymlink $file $target
    done

    echo "$DOTFILES/scripts/server-status-2.sh" >> $HOME/.bashrc

    printf "${BOLD}${GREEN}\t [OK] ${NORMAL} Creating symlinks...${NORMAL}\n"
}


suggestionMessage() {
    printf "\n"
    printf "\n${BOLD}${BLUE}[SUGGESTIONS] \n"
    printf "${NORMAL}\t\xE2\x97\x86 ${NORMAL} Some scripts use ${BOLD}'Python 3 '${NORMAL}, be sure that it is installed\n"
    printf "${NORMAL}\t\xE2\x97\x86 ${NORMAL} Some scripts use ${BOLD}'lsb-release'${NORMAL} command, be sure that it is installed\n"
    printf "${NORMAL}\n"
}


splash() {
    printf "${BLUE}"
    echo '·▄▄ · ▄▄▄ .▄▄▄   ▌ ▐·▄▄▄ .▄▄▄                  '
    echo '▐█ ▀. ▀▄.▀·▀▄ █·▪█·█▌▀▄.▀·▀▄ █·                '
    echo '▄▀▀▀█▄▐▀▀▪▄▐▀▀▄ ▐█▐█•▐▀▀▪▄▐▀▀▄                 '
    echo '▐█▄▪▐█▐█▄▄▌▐█•█▌ ███ ▐█▄▄▌▐█•█▌                '
    echo ' ▀▀▀▀  ▀▀▀ .▀  ▀. ▀   ▀▀▀ .▀  ▀                '
    echo '·▄▄▄▄        ▄▄▄▄▄·▄▄▄▪  ▄▄▌  ▄▄▄ ..▄▄ ·       '
    echo '██▪ ██ ▪     •██  ▐▄▄·██ ██•  ▀▄.▀·▐█ ▀.       '
    echo '▐█· ▐█▌ ▄█▀▄  ▐█.▪██▪ ▐█·██▪  ▐▀▀▪▄▄▀▀▀█▄      '
    echo '██. ██ ▐█▌.▐▌ ▐█▌·██▌.▐█▌▐█▌▐▌▐█▄▄▌▐█▄▪▐█      '
    echo '▀▀▀▀▀•  ▀█▄▀▪ ▀▀▀ ▀▀▀ ▀▀▀.▀▀▀  ▀▀▀  ▀▀▀▀       '
    echo '                                               '
    printf "${NORMAL}"
    printf "${BOLD}Welcome to Server dotfiles installation${NORMAL}\n\n"
}


bye() {
    printf "\n${BOLD}${GREEN}[SUCCESS]\n\t${NORMAL} ${BOLD}Now you have the dotfiles configured!${NORMAL}\n"
    printf "${BLUE}${BOLD}\t Thanks for installing Server Dotfiles\n"
    printf "${BOLD}\t Contact: ${NORMAL}${BOLD}aflavio at gmail.com${NORMAL}\n\n"
}


clear
splash
promptConfirm "Continue ? (y/n): " || exit 0
suggestionMessage
main
bye
