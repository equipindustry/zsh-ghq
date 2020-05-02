#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

# shellcheck source=/dev/null
[ -e "${HOME}/.zsh-async/async.zsh" ] && source "${HOME}/.zsh-async/async.zsh"

# Define a function to process the result of the job
function ghq::async::completed::callback {
    message_success "${1}" "${2}"
    # async_job "${GHQ_ASYNC_NAME}" ghq::cache::create
}

function ghq::async::init {
    if type async_init > /dev/null; then
        async_init
        # Start a worker that will report job completion
        async_start_worker "${GHQ_ASYNC_NAME}" -u
        async_process_results "${GHQ_ASYNC_NAME}" ghq::async::completed::callback
        return
    fi
}

ghq::async::init