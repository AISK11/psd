#!/usr/bin/env dash
#!/usr/bin/env sh


preload() {
    tabs 4
}


help() {
    printf 'NAME\n'
    printf '\tpsd - powershell deobfuscator\n'
    printf '\nSYNOPSIS\n'
    printf '\tpsd -h\n'
    printf '\tpsd [-q] [-l] [-o OUTFILE] -i INFILE\n'
    printf '\nDESCRIPTION (WIP)\n'
    printf '\t-h        \tDisplay this help message and exit.\n'
    printf '\t-i INFILE \tInput file (obfuscated script).\n'
    printf '\t-l        \tAssume legacy PowerShell version (older than PowerShell 6).\n'
    printf '\t-o OUTFILE\tOutput file (deobfuscated script).\n'
    printf '\t-q        \tQuiet output.\n'
    printf '\nEXAMPLES (TODO)\n'
    printf '\nEXIT STATUS (TODO)\n'
}


argparse() {
    INFILE=''
    OUTFILE=''
    VERBOSE='1'
    LEGACY='0'

    if [ "${#}" -lt 1 ]
    then
        help
        exit 0
    fi

    while getopts ':hi:lo:q' OPTION
    do
        case "${OPTION}" in
            h)
                help
                exit 0
                ;;
            i)
                INFILE="${OPTARG}"
                ;;
            l)
                LEGACY='1'
                ;;
            o)
                OUTFILE="${OPTARG}"
                ;;
            q)
                VERBOSE='0'
                ;;
            *)
                printf '[!] Option "-%s" is unknown or is missing an argument!\n' "${OPTARG}" 1>&2
                exit 1
                ;;
         esac
    done

    if [ -z "${INFILE}" ]
    then
        printf '[!] No input file specified!\n' 1>&2
        exit 1
    elif [ ! -r "${INFILE}" ]
    then
        printf '[!] File "%s" is not readable!\n' "${INFILE}" 1>&2
        exit 1
    fi

    if [ -e "${OUTFILE}" ]
    then
        printf '[!] File "%s" could not be created because it already exists!\n' "${OUTFILE}" 1>&2
        exit 1
    fi
}


deobfuscation() {
    IFS="$(printf '\n')" CONTENT="$(cat "${INFILE}")"

    if [ "${LEGACY}" -ne 0 ]
    then
        CONTENT="$(echo "${CONTENT}" | sed 's/`[^0abfnrtv]//g')"
    else
        CONTENT="$(echo "${CONTENT}" | sed 's/`[^0abefnrtuv]//g')"
    fi
    if [ "${VERBOSE}" -ne 0 ]
    then
        printf '[+] Removed redundant escape characters.\n'
        ## https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_special_characters?view=powershell-7.3
    fi

    CONTENT="$(echo "${CONTENT}" | tr ';' '\n')"
    if [ "${VERBOSE}" -ne 0 ]
    then
        printf '[+] Replaced semicolons by new lines.\n'
    fi

    CONTENT="$(echo "${CONTENT}" | sed '/^[[:space:]]*$/d')"
    if [ "${VERBOSE}" -ne 0 ]
    then
        printf '[+] Removed empty lines.\n'
    fi

    CONTENT="$(echo "${CONTENT}" | sed "s/['\"]\ *+\ *['\"]//g")"
    if [ "${VERBOSE}" -ne 0 ]
    then
        printf '[+] Removed string concatenation.\n'
    fi



    ## Replace ';' to '\n'.
    #CONTENT="$(echo "${CONTENT}" | tr ';' '\n')"



    echo "${CONTENT}"
}


main() {
    preload
    argparse "${@}"
    deobfuscation
    return 0
}


main "${@}"
