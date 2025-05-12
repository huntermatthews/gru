## -*- mode: fish -*- ##

function read_file -a fname
    trace (status function) begin

    if set -q MOCK
        set fname $MOCK/$fname
        debug_var fname
    end

    if not test -f $fname
        debug "File not found: $fname"
        return 1
    end

    debug "Reading file: $fname"
    cat $fname
    return $status # make the return of cat explicit

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
            debug "Program (mocked) not found $fname"
            return 1
        end

        debug "Reading program (mocked): $fname"
        cat $fname

        # we ALSO have to mock the return code
        set fname_rc {$fname}_rc
        if test -f $fname_rc
            debug "Reading RC (mocked): $fname_rc"
            return (cat $fname_rc)
        else
            return 0
        end
    else
        if not command -v $p_name >/dev/null
            debug "program `$p_name` not found in PATH"
            return 1
        end

        $p_name $p_args
        return $status # make the return of $program explicit
    end

end
