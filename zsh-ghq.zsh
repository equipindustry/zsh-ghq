#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

#
# Defines install ghq for osx or linux.
#
# Authors:
#   Luis Mayta <slovacus@gmail.com>
#

plugin_dir=$(dirname "${0}":A)

# shellcheck source=/dev/null
source "${plugin_dir}"/src/helpers/messages.zsh

package_name='ghq'

die(){
    message_error "$1";
}

function ghq::install {
    message_info "Installing ${package_name}"
    if [ -x "$(command which brew)" ]; then
        brew install ${package_name}
    fi
    ghq::post_install
}

function ghq::post_install {

    if [ -x "$(command which git)" ]; then
        git config --global ghq.root "${PROJECTS}"
    fi
}

function ghq::new {
    local REPONAME=$1

    if [ -z "${REPONAME}" ]; then
        message_error "Repository name must be specified."
    fi
    ghq get "${REPONAME}"
}

function ghq::find::project {
    if [[ -x "$(command which fzf)" ]]; then
        local buffer
        buffer=$(ghq list | \
                     fzf)
        # shellcheck disable=SC2164
        cd "$(ghq root)/${buffer}"
    fi
}

zle -N ghq::find::project
bindkey '^P' ghq::find::project

alias ghn=ghq::new

if [ ! -x "$(command which ghq)" ]; then
    ghq::install
fi
