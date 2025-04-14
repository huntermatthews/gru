## -*- mode: fish -*- ##

function parse_shell_kv -a data

    set result 
    for line in $data
        set -l key (string split --fields 1 --max 1 "=" $line | string trim --chars '"')
        set -l value (string split --fields 2 --max 1 "=" $line | string trim --chars '"')
        dict set result $key $value
    end
    
    echo $result
end

