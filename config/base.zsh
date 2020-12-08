#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

export GHQ_MESSAGE_BREW="Please install brew or use antibody bundle luismayta/zsh-brew branch:develop"
export GHQ_MESSAGE_RVM="Please install rvm or use antibody bundle luismayta/zsh-rvm branch:develop"
export GHQ_PACKAGE_NAME=ghq
export GHQ_ROOT=$(ghq root)
export GHQ_CACHE_DIR="${HOME}/.cache/ghq"
export GHQ_CACHE_NAME="ghq.txt"
export GHQ_FILE_COOKIECUTTER="${ZSH_GHQ_PATH}/resources/data.json"
export GHQ_CACHE_PROJECT="${GHQ_CACHE_DIR}/${GHQ_CACHE_NAME}"
export GHQ_REGEX_IS_REPOSITORY="^(git:|git@|ssh://|http://|https://)"
export GITHUB_USER="$(git config github.user)"

[ -z "${EDITOR}" ] && export EDITOR="vim"