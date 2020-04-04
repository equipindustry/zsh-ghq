#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

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

function ghq::is_dir {
    local target_dir
    target_dir="${1}"
    if [ ! -d "${target_dir}" ]; then
        echo 0
        return
    fi
    echo 1
}

function ghq::git::get_origin_path {
    local target_dir origin_path
    target_dir="${1}"
    origin_path=$(cd "${target_dir}" || exit; git config --get-regexp remote.origin.url | cut -d ' ' -f 2)
    echo "${origin_path}"
}
