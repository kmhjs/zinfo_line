# Source script
#source <somewhere>/zinfo_line.zsh

# Prepare for using add-zsh-hook
#builtin autoload -U add-zsh-hook

# Add hook to preexec
add-zsh-hook preexec zinfo_line
