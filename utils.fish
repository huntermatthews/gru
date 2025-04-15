## -*- mode: fish -*- ##

# rename a key in a dict
# var: renames is itself a dict mapping old key name -> new key name
# var: data is the dict potentially needing renames
function key_rename -a renames data

    # get this as a simple list so we don't need to run this query repeatedly
    data_keys = (dict keys $data)

    # For all the entries in the renames
    for old_key in (dict keys $renames)

        # if our data contains that key
        if contains $old_key $data_keys
            # Find its location (by index) in the data
            set index (dict contains --key --index data $old_key)

            # set the key name to the new name via lookup in the renames dict.
            set $data[$index] (dict get renames $old_key)
        end
    end
end
