## -*- mode: fish -*- ##

set -g _PROGRAM (status basename)

set -g _HELP "
Usage: $_PROGRAM [OPTIONS] [FILE]
Options:
  -h, --help      Show this help message and exit
  -v, --version   Show version information and exit
    other docs later
"

set -g _VERSION "1.2"
set -g ATTRS
set -g _CMDLINE $argv # save this for gru.cmdline later

# Outside of main - so that really old argparse's don't bomb us out.
set vers_info (string split -- '.' $FISH_VERSION)
if test $vers_info[1] -lt 3 -o \( $vers_info[1] = 3 -a $vers_info[2] -lt 3 \)
    panic "Fish Version '$FISH_VERSION' is too old - please upgrade"
end

function main
    argparse --name $_PROGRAM h/help version debug mock= output= R/check-requires L/list-requires collector -- $argv
    or begin
        echo $_HELP
        exit 1
    end

    if set -q _flag_debug
        if test (count $_flag_debug) -gt 1
            set -g _debug trace
        else
            set -g _debug debug
        end
    end

    if set -q _flag_help
        echo $_HELP
        exit 0
    end

    if set -q _flag_version
        echo $_PROGRAM v$_VERSION
        exit 0
    end

    if set -q _flag_mock
        # we're mocking, so there better be a mock data dir around somewhere
        set -g MOCK (status dirname)/mock_data/$_flag_mock
        if not test -d $MOCK
            panic "$_flag_mock directory $MOCK does not exist"
        end
        debug_var MOCK
    end

    if set -q _flag_collector
        trace "Calling Collector..."
        collector
        exit 0
    end

    # yeah, we run uname twice - the split is in case we're in --mock mode
    set kernel_name (read_program "uname" | string split --fields 1 ' ' )
    debug_var kernel_name

    if set -q _flag_check_requires
        trace "Calling check_requires..."
        check_requires
        exit 0
    end

    if set -q _flag_list_requires
        trace "Calling list_requires..."
        list_requires
        exit 0
    end

    switch $kernel_name
        case Darwin
            os_darwin_parse
        case Linux
            # os_linux_parse
            os_test_parse
        case *
            os_unsupported_parse
    end

    switch $_flag_output
        case dots
            output_dots
            # case 'json'
            #     output_json
        case shell
            output_shell
        case '*'
            # default to dots
            output_dots
    end

end

# Call main
main $argv
