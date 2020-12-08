#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

function ghq::internal::main::factory {
    # shellcheck source=/dev/null
    source "${ZSH_GHQ_PATH}"/internal/base.zsh
    case "${OSTYPE}" in
    darwin*)
        # shellcheck source=/dev/null
        source "${ZSH_GHQ_PATH}"/internal/osx.zsh
        ;;
    linux*)
        # shellcheck source=/dev/null
        source "${ZSH_GHQ_PATH}"/internal/linux.zsh
      ;;
    esac
}

ghq::internal::main::factory

if ! type -p rsync > /dev/null; then ghq::internal::rync::install; fi
if ! type -p cookiecutter > /dev/null; then ghq::internal::cookiecutter::install; fi
if ! type -p ghq > /dev/null; then ghq::internal::ghq::install; fi