FPATH=<SOMEWHERE>/zinfo_line/src:$FPATH
autoload -Uz zinfo_line

# Prepare for using add-zsh-hook
#builtin autoload -U add-zsh-hook

# Add hook to preexec
add-zsh-hook preexec zinfo_line
