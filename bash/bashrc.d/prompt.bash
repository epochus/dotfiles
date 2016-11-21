#/bin/bash
####################################################################
# prompt.bash
# -----------
# Function for cusotmizing and controlling prompt.
#
####################################################################

prompt() {

    # Execute according to first argument of function.
    case $1 in
        # Turn complex, colored prompt on.
        on)
            # Set up pre-prompt command and prompt format.
            PROMPT_COMMAND='declare -i PROMPT_RETURN=$? ; history -a'
            # If Bash 4.0 is available, trim very long paths in prompt.
            if ((BASH_VERSINFO[0] >= 4)) ; then
                PROMPT_DIRTRIM=4
            fi

            PS1='[\u@\h:\w\]]$(prompt git)$(prompt job)$ '
            ;;

        # Revert to simple inexpensive prompt.
        off)
            unset -v PROMPT_COMMAND PROMPT_DIRTRIM
            PS1='[[\u@\h:\w\]]$ '
            ;;

        git)
            # Check for git(1).
            if ! hash git 2>/dev/null ; then
                return 1
            fi

            # Attempt to determine git branch.
            local branch
            branch=$( {
                git symbolic-ref --quiet HEAD \
                || git rev-parse --short HEAD
            } 2>/dev/null )
            if [[ ! $branch ]] ; then
                return 1
            fi
            branch=${branch##*/}

            # Safely read status with -z --porcelain.
            local line
            local -i ready modified untracked
            while IFS= read -d $'\0' -r line ; do
                if [[ $line == [MADRCT]* ]] ; then
                    ready=1
                fi
                if [[ $line == ?[MADRCT]* ]] ; then
                    modified=1
                fi
                if [[ $line == '??'* ]] ; then
                    untracked=1
                fi
            done < <(git status -z --porcelain 2>/dev/null)

            # Build state array from status output flags.
            local -a state
            if [[ $ready ]] ; then
                state=("${state[@]}" '+')
            fi
            if [[ $modified ]] ; then
                state=("${state[@]}" '!')
            fi
            if [[ $untracked ]] ; then
                state=("${state[@]}" '?')
            fi

            # Add another indicator if we have stashed changes.
            if git rev-parse --verify refs/stash >/dev/null 2>&1 ; then
                state=("${state[@]}" '^')
            fi

            # Print the status in brackets with a git: prefix.
            local IFS=
            printf '(git:%s%s)' "${branch:-unknown}" "${state[*]}"
            ;;

        # Show the count of background jobs in curly brackets, if not zero.
        job)
            local -i jobc=0
            while read -r _ ; do
                ((jobc++))
            done < <(jobs -p)
            if ((jobc > 0)) ; then
                printf '{%d}' "$jobc"
            fi
            ;;
    esac
}

# Complete words.
complete -W 'on off git job' prompt

# Start with full-fledged prompt.
prompt on

