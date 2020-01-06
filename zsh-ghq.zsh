#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

#
# Defines install ghq for osx or linux.
#
# Authors:
#   Luis Mayta <slovacus@gmail.com>
#

GHQ_ROOT=$(ghq root)
GHQ_CACHE_DIR="${HOME}/.cache/ghq"
GHQ_CACHE_NAME="ghq.txt"
GHQ_CACHE_PROJECT="${GHQ_CACHE_DIR}/${GHQ_CACHE_NAME}"
GHQ_REGEX_IS_REPOSITORY="^(git:|git@|ssh://|http://|https://)"
GITHUB_USER="$(git config github.user)"

ghq_package_name='ghq'

function ghq::is_dir {
    local target_dir
    target_dir="${1}"
    if [ ! -d "${target_dir}" ]; then
        return 0
    fi
    return 1
}

function ghq::git::get_origin_path {
    local target_dir
    local origin_path
    target_dir="${1}"
    origin_path=$(cd "${target_dir}" || exit; git config --get-regexp remote.origin.url | cut -d ' ' -f 2)
    echo "${origin_path}"
}

function ghq::get_remote_path_from_url {
    # git remote url may be
    # ssh://git@hoge.host:22/var/git/projects/Project
    # git@github.com:motemen/ghq.git
    # (normally considering only github is enough?)
    # remove ^.*://
    # => remove ^hoge@ (usually git@ ?)
    #  => replace : => /
    #   => remove .git$
    local remote_path
    remote_path=$(echo "${1}" | sed -e 's!^.*://!!; s!^.*@!!; s!:!/!; s!\.git$!!;')
    echo "${remote_path}"
}

function ghq::migrate::move {
    local target_dir
    local remote_path
    local new_repo_dir
    target_dir="${1}"
    remote_path="${2}"

    message_info "move this repository to ${GHQ_ROOT}/${remote_path}"

    new_repo_dir="${GHQ_ROOT}/${remote_path}"

    if [ -e "${new_repo_dir}" ]; then
        message_error "${new_repo_dir} already exists!!!!"
    fi
    mkdir -p "${new_repo_dir%/*}"
    mv "${target_dir%/}" "${new_repo_dir}"
    message_success "${new_repo_dir} migrate!!!!"
}

# migrate repository path to root path
function ghq::migrate {
    local target_dir
    local origin_path
    local migrate_path

    target_dir=$1
    if [ ! "$(ghq::is_dir "${target_dir}")" ]; then
        message_info "${target_dir} not is directory"
    fi

    origin_path=$(ghq::git::get_origin_path "${target_dir}")

    if [ -z "${origin_path}" ]; then
        message_info "not found repository remote"
    fi

    migrate_path="$(ghq::get_remote_path_from_url "${origin_path}")"

    ghq::migrate::move "${target_dir}" "${migrate_path}"
}

function ghq::dependences::check {
    if ! type -p async_init > /dev/null; then
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

# reponame
function ghq::new {
    local repository
    local repository_path
    local is_repository
    repository="${1}"
    is_repository=$(echo "${repository}" | grep -cE "${GHQ_REGEX_IS_REPOSITORY}")

    if [ -z "${repository}" ]; then
        message_error "Repository name must be specified."
    fi

    if [ "${is_repository}" -eq 1 ]; then
        ghq get "${repository}"
        ghq::cache::clear
    else
        repository_path="$(ghq root)/github.com/${GITHUB_USER}/${repository}"
        ghq create "${repository}"
        ghq::cache::clear
        cd "${repository_path}" || cd - && git flow init -d
    fi

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

if ! type -p ghq > /dev/null; then
    ghq::install
fi

ghq::dependences::check
