## -*- mode: fish -*- ##

function read_file -a fname
    if set -q TEST
        set fname $TEST_DIR/$function 
    end

    if not test -d $fname
        panic "File not found: $fname"
    end

    cat $fname
end
