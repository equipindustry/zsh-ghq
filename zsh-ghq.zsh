#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

#
# Defines install ghq for osx or linux.
#
# Authors:
#   Luis Mayta <slovacus@gmail.com>
#

ZSH_GHQ_PATH=$(dirname "${0}")

# shellcheck source=/dev/null
source "${ZSH_GHQ_PATH}"/config/main.zsh

# shellcheck source=/dev/null
source "${ZSH_GHQ_PATH}"/internal/main.zsh

# shellcheck source=/dev/null
source "${ZSH_GHQ_PATH}"/pkg/main.zsh


zle -N ghq::find::project
bindkey '^Xp' ghq::find::project

ghq::dependences::check
