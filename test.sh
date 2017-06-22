#!/usr/bin/bash

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
        printf '\b%.0s' {1..80}
    done
    printf "\t${BOLD}${GREEN} [OK] ${NORMAL}$1\n"
}


    (sleep 2) & loaderSpinner "Clonning server dotfiles... "
