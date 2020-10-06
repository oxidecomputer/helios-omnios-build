#
# Define default prompt to <username>@<hostname>:<path><"($|#) ">
# and print '#' for user "root" and '$' for normal users.
#

typeset +x PS1="\u@\h:\w\\$ "

[ -f /usr/share/bash-completion/bash_completion ] && \
    . /usr/share/bash-completion/bash_completion

