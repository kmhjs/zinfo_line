function zinfo_line()
{
    #
    # show mid line
    #

    # RESPONSIVE?
    # || > 2014/07/13-11:22:58 : ls ---------- (0.07, 0.05, 0.05 / 79% 03:22:16)
    # - (> )  s_sep_head,
    # -       s_date
    # - ( : ) s_sep_date_cmd,
    # -       s_cmd,
    # - ( )   s_sep_cmd_line,
    # - (---) s_line,
    # - ( ()  s_sep_line_sub,
    # - ( / ) s_sep_top_batt,
    # -       s_batt,
    # - ())   s_sep_batt_end

    # Values to be shown
    local s_date s_cmd s_line s_acpi

    # Separators
    local s_sep_head s_sep_date_cmd s_sep_line_sub s_sep_top_batt s_sep_batt_end s_sep_cmd_line

    # Mid line length
    local i_line_length

    # Flags. Show element or not
    local b_flags

    # Final result
    local s_status_line  

    # Colors
    local s_color_green s_color_blue s_color_gray s_color_init

    # Commands to be ignored
    local a_exceptions

    # Array for calculation
    local a_calc

    # Exceptions
    a_exceptions=($(echo $ZMIDLINE_IGN_COMMAND | tr ':' ' '))

    # Colors
    s_color_green='\e[0;32m'
    s_color_blue='\e[0;34m'
    s_color_gray='\e[0;37m'
    s_color_init='\e[0;0m'

    # Separators
    s_sep_head="> "
    s_sep_date_cmd=" : "
    s_sep_cmd_line=" "
    s_sep_line_sub=" ("
    s_sep_top_batt=" / "
    s_sep_batt_end=")"
    s_sep_cmd_line=" "

    # Init flags
    b_flags=(0 0 0 0 0 0 0)

    # Get values
    ## Sent command
    s_cmd=$(
        echo ${(s: :)${1}} |
        sed 's/\([^ ]*\)[ ]*.*/\1/g'
    )
    ## Date string
    [ -x `builtin which date` ] && s_date=$(
        date +%Y/%m/%d-%H:%M:%S
    )
    ## Load value
    [ -x `builtin which uptime` ] && s_load=$(
        uptime             |
        sed 's/.*load //g' |
        cut -d ':' -f 2    |
        sed 's/^ //g'
    )

    case ${OSTYPE} in
        darwin*) # Mac OS
            [[ -x `builtin which pmset` ]] && s_acpi=$(
                pmset -g ps  |
                grep Battery |
                grep %       |
                sed 's/^[^0-9]*[0-9]*[^0-9]*\([0-9%]*\)[^0-9]*\([0-9:]*\)[^0-9]*$/\1, \2/g'
            )
            ;;
        *) # Others
            # Load acpi battery info
            [[ -x `builtin which acpi` ]] && s_acpi=$(
                acpi -b      |
                grep Battery |
                head -1      |
                sed 's/[^,]*[^0-9]*\([0-9]*%\)[^0-9]*\([0-9:]*\).*/\1 \2/g'
            )
            ;;
    esac

    # Intialize whole line length
    i_line_length=$COLUMNS

    # Main
    if [ ${a_exceptions[(I)$s_cmd]} = 0 ]; then
        # Calculate size of each lines
        [ $(($i_line_length - $#s_cmd - $#s_sep_head)) -ge 0 ]         &&
            i_line_length=$(($i_line_length - $#s_cmd - $#s_sep_head)) &&
            b_flags[1]=1

        [ $(($i_line_length - $#s_date - $#s_sep_date_cmd)) -ge 0 ]         &&
            i_line_length=$(($i_line_length - $#s_date - $#s_sep_date_cmd)) &&
            b_flags[2]=1

        [ $s_acpi ]                                      &&
            [ $(($i_line_length - $#s_acpi)) -ge 0 ]     &&
            i_line_length=$(($i_line_length - $#s_acpi)) &&
            b_flags[3]=1

        [ $(($i_line_length - $#s_load)) -ge 0 ]         &&
            i_line_length=$(($i_line_length - $#s_load)) &&
            b_flags[4]=1

        [ $b_flags[3] = 1 -o $b_flags[4] = 1 ] &&
            i_line_length=$(($i_line_length - $#s_sep_line_sub - $#s_sep_batt_end)) &&
            b_flags[6]=1

        [ $b_flags[3] = 1 -a $b_flags[4] = 1 ]                   &&
            i_line_length=$(($i_line_length - $#s_sep_top_batt)) &&
            b_flags[7]=1

        [ $i_line_length -ge 1 ]                                 &&
            i_line_length=$(($i_line_length - $#s_sep_cmd_line)) &&
            b_flags[5]=1

        ## Create separator line
        s_line=${(l.$i_line_length..-.)}

        ## Create status bar
        s_status_line=""
        [ $b_flags[1] = 1 ] && s_status_line=${s_status_line}${s_sep_head}
        [ $b_flags[2] = 1 ] && s_status_line=${s_status_line}${s_color_gray}${s_date}${s_color_init}${s_sep_date_cmd}
        [ $b_flags[1] = 1 ] && s_status_line=${s_status_line}${s_color_green}${s_cmd}${s_color_init}
        [ $b_flags[5] = 1 ] && s_status_line=${s_status_line}${s_sep_cmd_line}${s_color_blue}${s_line}${s_color_init}
        [ $b_flags[6] = 1 ] && s_status_line=${s_status_line}${s_sep_line_sub}
        [ $b_flags[4] = 1 ] && s_status_line=${s_status_line}${s_color_gray}${s_load}${s_color_init}
        [ $b_flags[7] = 1 ] && s_status_line=${s_status_line}${s_sep_top_batt}
        [ $b_flags[3] = 1 ] && s_status_line=${s_status_line}${s_color_gray}${s_acpi}${s_color_init}
        [ $b_flags[6] = 1 ] && s_status_line=${s_status_line}${s_sep_batt_end}

        ## Show
        builtin echo $s_status_line
    fi
}