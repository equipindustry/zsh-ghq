#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

function ghq::internal::cookiecutter::install {
    if ! type -p pip > /dev/null; then
        message_warning "PLease install pip for continue"
        return
    fi
    message_info "Installing cookiecutter for ${GHQ_PACKAGE_NAME}"
    python -m pip install --user cookiecutter
    message_success "Installed cookiecutter for ${GHQ_PACKAGE_NAME}"
}

function ghq::internal::ghq::install {
    message_info "Installing ${GHQ_PACKAGE_NAME}"
    if ! type -p brew > /dev/null; then
        message_warning "${GHQ_MESSAGE_BREW}"
        return
    fi
    brew install ghq
    message_success "Installed ${GHQ_PACKAGE_NAME}"
}

function ghq::internal::rsync::install {
    if ! type -p brew > /dev/null; then
        message_warning "${GHQ_MESSAGE_BREW}"
        return
    fi
    message_info "Installing rsync for ${GHQ_PACKAGE_NAME}"
    brew install rsync
    message_success "Installed rsync ${GHQ_PACKAGE_NAME}"
}
