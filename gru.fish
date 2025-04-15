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

# For all of dots, this is correct - my code, my rules.
function fish_command_not_found
    exit 12
end

function panic
    if set -q FLAG_DEBUG; and test "$FLAG_DEBUG" = true
        status stack-trace
    end

    echo "FATAL: $argv"
    exit 1
end

function main
    argparse --name $_PROGRAM debug h/help version mock= -- $argv
    or begin
        echo $_HELP
        exit 1
    end

    if set -q _flag_help
        echo $_HELP
        exit 0
    end

    if set -q _flag_version
        echo $_PROGRAM v$_VERSION
        exit 0
    end

    if test (uname) != Linux
        panic "Only for linux yet."
    end

    if test (uname -m) != x86_64
        panic "Only for x86_64 yet."
    end

    if set -q $_flag_mock
        # we're mocking, so there better be a mock data dir around somewhere
        set -g MOCK (status dirname)/mock_data/$_flag_mock
        if not test -d $MOCK
            panic "$_flag_mock directory $MOCK does not exist"
        end
    end

    # todo section
    echo "todo: check minimum version requirement - v4.0"
    echo "todo: set pragma to remove ? from globbing"

end

# Call main
main $argv
