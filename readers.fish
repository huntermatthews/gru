## -*- mode: fish -*- ##

function read_file -a fname
    trace (status function) begin

    if set -q MOCK
        set fname $MOCK/$fname
        debug_var fname
    end

    if not test -f $fname
        panic "File not found: $fname"
    else
        debug "File found: $fname"
    end

    debug "Reading file: $fname"

    cat $fname

end

function read_file2 -a fname
    trace (status function) begin

    if set -q MOCK
        set fname $MOCK/$fname
        debug_var fname
    end

    if not test -f $fname
        return 1
    else
        debug "File found: $fname"
    end

    debug "Reading file: $fname"

    cat $fname

end

function read_program
    trace (status function) begin

    set p_name $argv[1]
    set p_args $argv[2..]

    set arg_string (string join -- ' ' $p_args)
    debug_var p_name
    debug_var p_args
    debug_var arg_string

    if set -q MOCK
        set fname $MOCK/_programs/$p_name
        debug_var fname

        if not test -f $fname
            panic "File not found: $fname"
        else
            debug "File found: $fname"
        end

        debug "Reading file: $fname"

        cat $fname
    else

        if not command -v $p_name >/dev/null
            panic "program `$p_name` not found in PATH"
        end

        $p_name $p_args

    end

end

function read_program2
    trace (status function) begin

    set p_name $argv[1]
    set p_args $argv[2..]

    set arg_string (string join -- ' ' $p_args)
    debug_var p_name
    debug_var p_args
    debug_var arg_string

    if set -q MOCK
        set fname $MOCK/_programs/$p_name
        debug_var fname

        if not test -f $fname
            panic "File not found: $fname"
        else
            debug "File found: $fname"
        end

        debug "Reading file: $fname"

        cat $fname
        if test -f {$fname}_rc
            return (cat {$fname}_rc)
        else
            return 0
        end
    else
        if not command -v $p_name >/dev/null
            panic "program `$p_name` not found in PATH"
        end

        $p_name $p_args
        set rc $status
    end

    return $rc
end
