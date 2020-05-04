#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

# shellcheck source=/dev/null
[ -e "${HOME}/.zsh-async/async.zsh" ] && source "${HOME}/.zsh-async/async.zsh"

# Define a function to process the result of the job
function ghq::async::completed::callback {
    message_success "${@}"
    async_stop_worker "${GHQ_ASYNC_NAME}" -u
}

function ghq::async::init {
    if ! ghq::utils::callable "async_init" && ! ghq::utils::callable "async_start_worker"; then
        message_warning "not found library async"
        return
    fi

    async_init
    ghq::async::register_worker
}

function ghq::async::register_worker {
    # Start a worker that will report job completion
    async_start_worker "${GHQ_ASYNC_NAME}" -u
    async_register_callback "${GHQ_ASYNC_NAME}" ghq::async::completed::callback
}

ghq::async::init