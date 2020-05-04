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

function ghq::cache::create::factory {
    ghq::cache::create
}

function ghq::cache::create::async {
    # Start the job
    async_job "${GHQ_ASYNC_NAME}" ghq::cache::create
}