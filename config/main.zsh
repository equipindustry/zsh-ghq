#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

function ghq::config::main::factory {
    # shellcheck source=/dev/null
    source "${ZSH_GHQ_PATH}"/config/base.zsh
    case "${OSTYPE}" in
    darwin*)
        # shellcheck source=/dev/null
        source "${ZSH_GHQ_PATH}"/config/osx.zsh
        ;;
    linux*)
        # shellcheck source=/dev/null
        source "${ZSH_GHQ_PATH}"/config/linux.zsh
      ;;
    esac
}

ghq::config::main::factory
