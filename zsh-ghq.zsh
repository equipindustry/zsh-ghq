#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

#
# Defines install ghq for osx or linux.
#
# Authors:
#   Luis Mayta <slovacus@gmail.com>
#

# shellcheck disable=SC2034  # Unused variables left for readability
GHQ_ROOT=$(ghq root)
GHQ_ROOT_DIR=$(dirname "$0")
GHQ_SRC_DIR="${GHQ_ROOT_DIR}"/src
GHQ_CACHE_DIR="${HOME}/.cache/ghq"
GHQ_CACHE_NAME="ghq.txt"
GHQ_CACHE_PROJECT="${GHQ_CACHE_DIR}/${GHQ_CACHE_NAME}"
GHQ_REGEX_IS_REPOSITORY="^(git:|git@|ssh://|http://|https://)"
GITHUB_USER="$(git config github.user)"
GHQ_ASYNC_NAME="ghq_worker"

ghq_package_name='ghq'

# shellcheck source=/dev/null
source "${GHQ_SRC_DIR}"/base.zsh

# shellcheck source=/dev/null
source "${GHQ_SRC_DIR}"/utils.zsh

# shellcheck source=/dev/null
source "${GHQ_SRC_DIR}"/cache.zsh

# shellcheck source=/dev/null
source "${GHQ_SRC_DIR}"/migrate.zsh

# shellcheck source=/dev/null
source "${GHQ_SRC_DIR}"/cookiecutter.zsh

# shellcheck source=/dev/null
source "${GHQ_SRC_DIR}"/async.zsh



function ghq::dependences::check {
    if ! type async_init > /dev/null; then
        message_warning "is neccesary implement async_init."
    fi
    if [ -z "${GITHUB_USER}" ]; then
        message_warning "You should set 'git config --global github.user'."
    fi
}

function ghq::install {
    message_info "Installing ${ghq_package_name}"
    if type -p brew > /dev/null; then
        brew install "${ghq_package_name}"
    fi

    ghq::post_install
}

function ghq::post_install {
    if type -p git > /dev/null; then
        git config --global ghq.root "${PROJECTS}"
    fi
}


function ghq::projects::list {
    if [ ! -e "${GHQ_CACHE_PROJECT}" ]; then
        ghq::cache::create::factory
        ghq::cache::list
        return
    fi
    ghq::cache::list
}

function ghq::new::template {
    local template repository_path
    repository_path="$(ghq root)/github.com/${GITHUB_USER}/"
    template="$(cookiecutter::find)"
    if [ -z "${template}" ]; then
        message_warning "Please Select one Project"
        return
    fi
    cd "${repository_path}" || cd - &&  \
            eval "cookiecutter ${template}" && \
            ghq::cache::clear
}


# reponame
function ghq::new {
    local repository repository_path
    repository="${1}"
    repository_path="$(ghq root)/github.com/${GITHUB_USER}/${repository}"
    ghq create "${repository}"
    ghq::cache::clear
    cd "${repository_path}" || cd - && git flow init -d
}

function ghq::factory {
    local repository repository_path is_repository
    repository="${1}"
    is_repository=$(echo "${repository}" | grep -cE "${GHQ_REGEX_IS_REPOSITORY}")

    if [ -z "${repository}" ]; then
        ghq::new::template
        return
    fi

    if [ "${is_repository}" -eq 1 ]; then
        ghq get "${repository}"
        ghq::cache::clear
        return
    fi

    ghq::new "${repository}"

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
bindkey '^Xp' ghq::find::project

alias ghn=ghq::factory

if ! type -p ghq > /dev/null; then
    ghq::install
fi

ghq::dependences::check
