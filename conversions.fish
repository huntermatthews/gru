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
        printf "%.0f %s\n" $size $unit
    else
        printf "%.02f %s\n" $size $unit
    end
end

# for https://stackoverflow.com/questions/4399475/unformat-disk-size-strings
# written by Dennis Williamson 2010-12-09
# ported (fish) by Hunter Matthews 2025-04-22
function si_to_bytes -a size

    set units K M G T P E # kilo, mega, giga, tera, peta, exa
    set size (string upper $size)
    set parts (string match --regex --groups-only '(?<number>[0-9]*[.]?[0-9]+) *(?<unit>[KMGTPE]?)B?' $size) # match the number, unit, and B
    # set number $parts[1]                                      # get the number
    # set unit $parts[2]                                        # get the unit
    debug_var parts
    debug_var number
    debug_var unit

    set exponent (contains --index $unit $units) 
    debug_var exponent

    if test -z "$exponent"
        set exponent 0
    # else
    #     set exponent (math "$exponent - 1") # adjust for 0-based index
    end
    debug_var exponent

    printf "%u\n" (math "$number * 1024 ^ $exponent")
end

