#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

function ghq::is_dir {
    local target_dir
    target_dir="${1}"
    if [ ! -d "${target_dir}" ]; then
        echo 0
        return
    fi
    echo 1
    return
}

function ghq::git::get_origin_path {
    local target_dir
    local origin_path
    target_dir="${1}"
    origin_path=$(cd "${target_dir}" || exit; git config --get-regexp remote.origin.url | cut -d ' ' -f 2)
    echo "${origin_path}"
}
