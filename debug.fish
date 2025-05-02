## -*- mode: fish -*- ##

# This file should have NO dependencies on other files.

# This is a global variable that is used to control the debug state. off|debug|trace
set -g _debug off

function debug_state
    # This function is used to set the debug state.
    # Fake is fake argument to let this be compatible with fish v3.3
    argparse --name (status basename) --min-args 1 --max-args 1 fake -- $argv
    or begin
        exit 1
    end

    # single argument is our subcommand
    switch $argv[1]
        case debug trace off
            set _debug $argv[1]
        case status
            echo $_debug
        case print_status
            echo "DEBUG: status is $_debug"
        case '*'
            echo "ERROR: Unknown arg $argv[1]"
            echo "Usage: debug_state off|debug|trace|status|print_status"
    end
end

function debug
    if test "$_debug" != off
        echo "DEBUG: $argv" 1>&2
    end
end

function debug_var -S
    # The -S is magic that allows this debug function to peer into other functions private variables...

    # Its NOT all powerful - note that debugging "argv" from other functions WILL fail if you attempt to use it here.
    # Instead >> debug "argv == '$argv'" << is required. Sorry.
    if test $argv[1] = argv
        echo "ERROR: You are a moron. You can't debug_var argv itself..." 1>&2
        exit 11
    end
    if test "$_debug" != off
        echo "DEBUG: variable $argv[1] == '$$argv[1]'" 1>&2
    end
end

# PATH and other vars that are typically (longer) lists are hard to read with just debug_var
# This function will print out the variable name, and then each index of the variable on a new line.
function debug_var_list -S
    # The -S is magic that allows this debug function to peer into other functions private variables...
    if test "$_debug" != off
        set -l count (count $$argv[1])
        if test $count -eq 0
            echo "DEBUG: variable `$argv[1]` of length $count == '$$argv[1]'" 1>&2
        else
            echo "DEBUG: variable `$argv[1]` of length $count:" 1>&2
            for i in (seq (count $$argv[1]))
                echo "     debug: index: $i, Value: $$argv[1][$i]" 1>&2
            end
        end
    end
end

# FIXME: yeah, there's a macos program named "trace" -- I don't care at the moment.
function trace
    if test "$_debug" = trace
        echo "TRACE: $argv" 1>&2
    end
end
