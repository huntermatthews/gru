## -*- mode: fish -*- ##

set -g _HELP "
Usage: $(status basename) [OPTIONS] [FILE]
Options:
  -h, --help      Show this help message and exit
  -v, --version   Show version information and exit
    other docs later
"
set -g _PROGRAM (status basename)
set -g _VERSION "1.2"
set -g ATTRS

function main
    argparse --name $_PROGRAM h/help version debug mock= -- $argv
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

        # TODO: we might want the fully qualified path here
        set -g MOCK (status dirname)/mock_data/$_flag_mock
        if not test -d $MOCK
            panic "$_flag_mock directory $MOCK does not exist"
        end
        debug_var MOCK
    else
        if test (uname) != Linux
            debug "uname: $(uname)"
            panic "Only for Linux yet."
        end

        if test (uname -m) != x86_64
            debug "uname -m: $(uname -m)"
            panic "Only for x86_64 yet."
        end
    end

    # todo section
    # "todo: check minimum version requirement - v4.0"
    # "todo: set pragma to remove ? from globbing"

    # Call upon our sources to gather information
    input_uname
    input_virt_what
    input_os_release
    if test (dict get ATTRS phy.platform) = physical
        # DMI is basically useless for non-physical systems
        input_sys_dmi
    end
    input_udevadm_ram
    input_lscpu

    for key in (string collect (dict keys ATTRS) | sort )
        set value (dict get ATTRS $key)
        echo "$key: $value"
    end

end

# Call main
main $argv
