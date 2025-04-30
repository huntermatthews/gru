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
set -g _CMDLINE $argv      # save this for gru.cmdline later

function main
    argparse --name $_PROGRAM h/help version debug mock= output= -- $argv
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
    
    # todo section
    # "todo: check minimum version requirement - v4.0"
    # "todo: set pragma to remove ? from globbing"

    # Call upon our sources to gather information
    input_uname

    
    os.kernel.name
    input_virt_what
    input_os_release
    if test (dict get ATTRS phy.platform) = physical
        # DMI is basically meaningless for non-physical systems
        input_sys_dmi
    end
    input_udevadm_ram
    input_lscpu
    input_selinux
    input_gru

    switch $_flag_output
        case 'dots'
            output_dots
        # case 'json'
        #     output_json
        case 'shell'
            output_shell
        case '*'
            # default to dots
            output_dots
    end

end

# Call main
main $argv
