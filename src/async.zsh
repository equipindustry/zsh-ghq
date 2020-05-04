#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

# shellcheck source=/dev/null
[ -e "${HOME}/.zsh-async/async.zsh" ] && source "${HOME}/.zsh-async/async.zsh"

# Define a function to process the result of the job
function ghq::async::completed::callback {
    message_success "${@}"
}

function ghq::async::init {
    if ! type async_init > /dev/null; then
        return
    fi
    async_init
    # Start a worker that will report job completion
    async_start_worker "${GHQ_ASYNC_NAME}" -u
    async_register_callback "${GHQ_ASYNC_NAME}" ghq::async::completed::callback
}

ghq::async::init