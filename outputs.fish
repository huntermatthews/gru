## -*- mode: fish -*- ##

function output_dots
    trace (status function) begin

    for key in (string collect (dict keys ATTRS) | sort )
        set value (dict get ATTRS $key)
        echo "$key: $value"
    end

    trace (status function) end
end

function output_shell
    trace (status function) begin

    for key in (string collect (dict keys ATTRS) | sort )
        set value (dict get ATTRS $key)
        set key_var (string upper $key)
        set key_var (string replace --all '.' '_' $key_var)
        echo "$key_var='$value'"
    end

    trace (status function) end
end

function output_json
    trace (status function) begin

    set json (string collect (dict keys ATTRS) | sort )
    set json (string replace --all ' ' ':' $json)
    set json (string replace --all '.' '_' $json)
    set json (string replace --all '\n' ',' $json)
    set json (string replace --all ',' ',\n' $json)
    set json (string replace --all ':' ': ' $json)
    set json (string replace --all '{' '{\n' $json)
    set json (string replace --all '}' '\n}' $json)

    echo "$json"

    trace (status function) end
end


