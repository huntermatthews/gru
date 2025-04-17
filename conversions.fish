## -*- mode: fish -*- ##

# https://unix.stackexchange.com/a/220470
# Written (bash) by Geoffrey 2015-08-06
# Ported (fish) by Hunter Matthews 2025-04-16
function bytes_to_si -a size

    set units B KB MB GB TB PB EB
    for unit in $units
        if test $size -lt 1024
            break
        end
        set size (math $size / 1024)
    end

    if test $unit = B
        printf "%.0f    %s\n" $size $unit
    else
        printf "%.02f %s\n" $size $unit
    end
end
