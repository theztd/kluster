#!/bin/bash

alias k="k0s kubectl"
alias psa="ps aux"

complete -o default -F __start_kubectl k


if ((${EUID:-0} || "$(id -u)")); then
    export PS1="\[\e[34m\]\[\e[1m\]__ENV__\[\e[m\] \[\e[32m\]\u@\h:\[\e[m\]\[\e[34m\]\w\[\e[m\] \[\e[m\]\[\e[32m\]\\$\[\e[m\] "

else
    # root
    export PS1="\[\e[34m\]\[\e[1m\]__ENV__\[\e[m\] \[\e[31m\]\h:\[\e[m\]\[\e[34m\]\w\[\e[m\] \[\e[m\]\[\e[31m\]\\$\[\e[m\] "

fi
