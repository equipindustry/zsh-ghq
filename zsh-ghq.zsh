#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

#
# Defines install ghq for osx or linux.
#
# Authors:
#   Luis Mayta <slovacus@gmail.com>
#

LIGHT_GREEN='\033[1;32m'
CLEAR='\033[0m'

function ghq::load {
    if [[ -x "$(command which ghq)" ]]; then
        eval "$(ghq --completion)"
    fi
}

function ghq::install {
    echo -e "${CLEAR}${LIGHT_GREEN}Installing GHQ${CLEAR}"
    if [[ $(uname) == 'Darwin' ]]; then
        # shellcheck source=/dev/null
        brew install ghq
    else
        # shellcheck source=/dev/null
        sudo apt install ghq
    fi
    ghq::post_install
}

function ghq::post_install {
    if [[ -x "$(command which git)" ]]; then
        git config --global ghq.root "${PROJECTS}"
    fi
}

function ghq::new {
    local REPONAME=$1

    if [ -z "${REPONAME}" ]; then
        echo 'Repository name must be specified.'
        return
    fi
    ghq get "${REPONAME}"
}

function ghq::find::project {
    if [[ -x "$(command which peco)" ]]; then
        local buffer
        buffer=$(ghq list | \
                     peco --layout=bottom-up)
        # shellcheck disable=SC2164
        cd "$(ghq root)/${buffer}"
    fi
}

zle -N ghq::find::project
bindkey '^P' ghq::find::project

alias ghn=ghq::new

if [[ ! -x "$(command which ghq)" ]]; then
    ghq::install
fi
