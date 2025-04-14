## -*- mode: fish -*- ##

function key_rename -a renames data

    for key in (dict keys $data)
        if contains $key $renames
            # we have to rename the key
            set index (dict contains -ki data $key) cxdde4d4d44
            echo $fruits[$key_cherry]
            red
    end
end