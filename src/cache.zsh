#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

function ghq::cache::clear {
    [ -e "${GHQ_CACHE_PROJECT}" ] && rm -rf "${GHQ_CACHE_PROJECT}"
    ghq::cache::create::factory
}

function ghq::cache::list {
    [ -e "${GHQ_CACHE_PROJECT}" ] && cat "${GHQ_CACHE_PROJECT}"
}

function ghq::cache::create {
    [ -e "${GHQ_CACHE_DIR}" ] || mkdir -p "${GHQ_CACHE_DIR}"
    ghq list > "${GHQ_CACHE_PROJECT}"
}

function ghq::cache::create::async {
    async_init
    # Start a worker that will report job completion
    async_start_worker ghq_worker_cache_make -u
    # Register our callback function to run when the job completes
    async_register_callback ghq_worker_cache_make ghq::completed::callback
    # Start the job
    async_job ghq_worker_cache_make ghq::cache::create
}

# Define a function to process the result of the job
function ghq::completed::callback {
    message_success "task ghq::cache::create done!"
}

function ghq::cache::create::factory {
    if type async_init > /dev/null; then
        ghq::cache::create::async
        return
    fi
    ghq::cache::create
}
