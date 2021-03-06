#!/bin/bash
####################################################################
# aliases.bash
# ------------
# Global bash alias definitions.
#
####################################################################

# Aliases for ls.
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Prompt before overwriting/removing file.
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Use a unified format for diff(1) by default.
alias diff='diff -u'
