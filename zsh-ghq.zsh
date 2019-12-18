#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

#
# Defines install ghq for osx or linux.
#
# Authors:
#   Luis Mayta <slovacus@gmail.com>
#

GHQ_CACHE_DIR="${HOME}/.cache/ghq"
GHQ_CACHE_NAME="ghq.txt"
GHQ_CACHE_PROJECT="${GHQ_CACHE_DIR}/${GHQ_CACHE_NAME}"

ghq_package_name='ghq'

function ghq::install {
    message_info "Installing ${ghq_package_name}"
    if type -p brew > /dev/null; then
        brew install ${ghq_package_name}
    fi

    ghq::post_install
}

function ghq::post_install {
    if type -p git > /dev/null; then
        git config --global ghq.root "${PROJECTS}"
    fi
}

function ghq::cache::clear {
    [ -e "${GHQ_CACHE_PROJECT}" ] && rm -rf "${GHQ_CACHE_PROJECT}"
}

function ghq::cache::list {
    [ -e "${GHQ_CACHE_PROJECT}" ] && cat "${GHQ_CACHE_PROJECT}"
}

function ghq::cache::create {
    [ -e "${GHQ_CACHE_DIR}" ] || mkdir -p "${GHQ_CACHE_DIR}"
    ghq list > "${GHQ_CACHE_PROJECT}"
}

function ghq::projects::list {
    if [ ! -e "${GHQ_CACHE_PROJECT}" ]; then
        ghq::cache::create
        ghq::cache::list
    else
        ghq::cache::list
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
    if type -p fzf > /dev/null; then
        local buffer
        buffer=$(ghq::projects::list | fzf )
        if [ -n "${buffer}" ]; then
            # shellcheck disable=SC2164
            cd "$(ghq root)/${buffer}"
        fi
    fi
}

zle -N ghq::find::project
bindkey '^P' ghq::find::project

alias ghn=ghq::new

if [ ! -x "$(command which ghq)" ]; then
    ghq::install
fi
