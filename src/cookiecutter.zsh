#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

# shellcheck disable=SC2154  # Unused variables left for readability

function cookiecutter::install {
    message_info "Installing cookiecutter for ${ghq_package_name}"
    if type -p pip > /dev/null; then
        python -m pip install --user cookiecutter
        message_success "Installed cookiecutter for ${ghq_package_name}"
    fi
}

function cookiecutter::list {
    # shellcheck disable=SC2002
    cat "${GHQ_SRC_DIR}"/data.json \
        | jq -r '.projects[] | [.name, .type, .description, .repository] | @csv' \
        | sed 's/"//g' \
        | awk 'BEGIN{FS=","; OFS="\t"} {print $1,$2,$3,$4,$5}'
}

function cookiecutter::find {
    local command_value
    command_value=$(cookiecutter::list \
                    | fzf \
                    | awk '{print $(NF -0)}' \
                    | perl -pe 'chomp' \
                )
    echo "${tag}" && echo -e "${tag}" | ghead -c -1 | pbcopy
    if [ -n "${command_value}" ]; then
        echo "${command_value}"
    fi
}

if ! type -p cookiecutter > /dev/null; then cookiecutter::install; fi