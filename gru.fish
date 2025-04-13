## -*- mode: fish -*- ##

set -g HELP "
Usage: $(status basename) [OPTIONS] [FILE]
Options:
  -h, --help      Show this help message and exit
  -v, --version   Show version information and exit
    other docs later
"
set -g PROGRAM (status basename)
set -g VERSION "1.2"

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
    argparse --name $PROGRAM debug h/help version test= -- $argv
    or begin
        echo $HELP
        exit 1
    end

    if set -q _flag_help
        echo $HELP
        exit 0
    end

    if set -q _flag_version
        echo $PROGRAM v$VERSION
        exit 0
    end

    if test (uname) != Linux
        panic "Only for linux yet."
    end

    if test (uname -m) != x86_64
        panic "Only for x86_64 yet."
    end

    if test $_flag_test
        echo "test: $argv"
        exit 0
    end

    # todo section
    echo "todo: check minimum version requirement - v4.0"
    echo "todo: set pragma to remove ? from globbing"

    # Do stuff here

end

# Call main
main $argv
