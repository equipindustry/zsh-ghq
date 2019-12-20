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

function ghq::dependences::check {
    if ! type -p async_init > /dev/null; then
        message_error "is neccesary implement async_init"
    fi
}

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
    ghq::cache::create::factory
}

function ghq::cache::list {
    [ -e "${GHQ_CACHE_PROJECT}" ] && cat "${GHQ_CACHE_PROJECT}"
}

function ghq::cache::create {
    [ -e "${GHQ_CACHE_DIR}" ] || mkdir -p "${GHQ_CACHE_DIR}"
    ghq list > "${GHQ_CACHE_PROJECT}"
}

function ghq::cache::create::async {
    async_init
    # Start a worker that will report job completion
    async_start_worker ghq_worker_cache_make -n
    # Register our callback function to run when the job completes
    async_register_callback ghq_worker_cache_make ghq::completed::callback
    # Start the job
    async_job ghq_worker_cache_make ghq::cache::create
}

# Define a function to process the result of the job
function ghq::completed::callback {
    async_job ghq_worker_cache_make ghq::cache::create
}

function ghq::cache::create::factory {
    if type -p async_init > /dev/null; then
        ghq::cache::create::async
    else
        ghq::cache::create
    fi
}


function ghq::projects::list {
    if [ ! -e "${GHQ_CACHE_PROJECT}" ]; then
        ghq::cache::create::factory
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
    ghq::cache::clear
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
