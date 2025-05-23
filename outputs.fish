## -*- mode: fish -*- ##

function output_dots
    trace (status function) begin

    for key in (string collect (dict keys ATTRS) | sort )
        set value (dict get ATTRS $key)
        echo "$key: $value"
    end

end

function output_shell
    trace (status function) begin

    for key in (string collect (dict keys ATTRS) | sort )
        set value (dict get ATTRS $key)
        set key_var (string upper $key)
        set key_var (string replace --all '.' '_' $key_var)
        echo "$key_var='$value'"
    end

end

function output_json
    trace (status function) begin

    #    https://stackoverflow.com/questions/48470049/build-a-json-string-with-bash-variables

end
