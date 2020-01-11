#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

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

    target_dir="${1}"
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
