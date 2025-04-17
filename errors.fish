## -*- mode: fish -*- ##

# This function, if defined, will be called when a command is not found.
# This is fish's equivalent of sh's "set -e " [it might not be exactly the same, but...]
function fish_command_not_found
    echo "FATAL: Command not found: $argv"
    exit 12
end

function panic
    if test (debug_state status) = trace
        status stack-trace
    end

    echo "FATAL: $argv"
    exit 1
end
