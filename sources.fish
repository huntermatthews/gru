## -*- mode: fish -*- ##

function source_os_release
    set data (read_file /etc/os-release)

    set data (echo $data | grep -e '^ID=' -e '^VERSION_ID=')

    set data (parse_shell_kv $data)

    set data (key_rename $renames $data)

    for line in $data
        set key (echo $line | cut -d= -f1)
        set value (echo $line | cut -d= -f2)
        dict set $ATTRS $key $value
    end
end

