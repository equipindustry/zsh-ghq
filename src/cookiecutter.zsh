#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

# shellcheck disable=SC2154  # Unused variables left for readability

function cookiecutter::install {
    if ! type -p pip > /dev/null; then
        message_warning "PLease install pip for continue"
        return
    fi
    message_info "Installing cookiecutter for ${ghq_package_name}"
    python -m pip install --user cookiecutter
    message_success "Installed cookiecutter for ${ghq_package_name}"
}

function cookiecutter::list {
    # shellcheck disable=SC2002
    cat "${GHQ_SRC_DIR}"/data.json \
        | jq -r '.projects[] | [.name, .type, .description, .repository] | @tsv' \
        | sed 's/"//g'
}

function cookiecutter::find {
    local command_value
    command_value=$(cookiecutter::list \
                        | fzf \
                        | awk 'BEGIN{FS="\t"; OFS=""} {print $4}' \
                        | ghead -c -1
                 )

if [ -n "${command_value}" ]; then
    echo -e "${command_value}"
fi
}

if ! type -p cookiecutter > /dev/null; then cookiecutter::install; fi