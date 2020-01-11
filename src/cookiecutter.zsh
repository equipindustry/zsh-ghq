#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

function cookiecutter::install {
    message_info "Installing cookiecutter for ${ghq_package_name}"
    if type -p pip > /dev/null; then
        pip install --user cookiecutter
        message_success "Installed cookiecutter for ${ghq_package_name}"
    fi
}

function cookiecutter::list {
    # shellcheck disable=SC2002
    cat "${GHQ_SRC_DIR}"/data.json | jq '.projects[] | "\(.name) | \(.author) | \(.type) | \(.description) | \(.repository)"'
}

function cookiecutter::find {
    local command_value
    command_value=$(cookiecutter::list \
                    | fzf \
                    | awk '{print $(NF -0)}' \
                    | perl -pe 'chomp' \
                    | sed 's/\"//g'
                )
    if [ -n "${command_value}" ]; then
        echo "${command_value}"
    fi
}

if ! type -p cookiecutter > /dev/null; then cookiecutter::install; fi