## -*- mode: fish -*- ##

function input_os_release
    trace (status function) begin

    set data (read_file "/etc/os-release")
    debug_var_list data

    for line in $data
        set key (string split --fields 1 --max 1 "=" $line | string trim --chars '"')
        set value (string split --fields 2 --max 1 "=" $line | string trim --chars '"')
        debug_var key
        debug_var value

        switch $key
            case ID
                dict set ATTRS os.distro.name $value
            case VERSION_ID
                dict set ATTRS os.distro.version $value
        end

    end

    trace (status function) end
end

function input_uname
    trace (status function) begin

    set keys os.kernel.name os.hostname os.kernel.version phy.arch.name phy.arch.family
    set data (read_program "uname" "-snrmp" | string split -- ' ' )
    debug_var_list data

    # The order back from uname is fixed (at least on Linux and MacOS) so this is safe
    if test (count $keys) -ne (count $data)
        panic "$(status function): keys and data length don't match: You can't count"
    end

    for idx in (seq (count $data))
        debug_var keys[$idx]
        debug_var data[$idx]
        dict set ATTRS $keys[$idx] $data[$idx]
    end

    trace (status function) end
end

function input_sys_dmi
    trace (status function) begin

    set keys dmi.vendor dmi.model.family dmi.product.name dmi.product.serial dmi.product.uuid
    set entries sys_vendor product_family product_name product_serial product_uuid

    if test (count $keys) -ne (count $entries)
        panic "$(status function): keys and data length don't match: You can't count"
    end

    for idx in (seq (count $keys))
        set key $keys[$idx]
        set entry $entries[$idx]
        set data (read_file /sys/devices/virtual/dmi/id/$entry)
        debug_var_list data
        debug_var key
        dict set ATTRS $key $data
    end

    trace (status function) end
end

function input_udevadm_ram
    trace (status function) begin

    set data (read_program "udevadm" "info" "-e" )
    debug_var_list data

    set sizes (string match --regex --groups-only 'MEMORY_DEVICE_\d+_SIZE=(\d+)' $data)
    debug_var sizes

    set total (math (string join '+' $sizes ))
    debug_var total

    set bytes (bytes_to_si $total)
    debug_var bytes

    dict set ATTRS phy.ram.size $bytes

    trace (status function) end
end

function input_virt_what
    trace (status function) begin

    set data (read_program "virt-what" )
    debug_var_list data

    if test -z "$data"
        # no output generally means bare-metal HOWEVER
        # BUG: we aren't checking the rc like we should!
        set data physical
    end

    dict set ATTRS phy.platform $data

    trace (status function) end
end

function input_lscpu
    trace (status function) begin

    # map the regex to the field name
    # the regex is the key, the field name is the value
    set regexes \
        '^ *Model name: *(.+)' model \
        '^ *Vendor ID: *(.+)' vendor \
        '^ *Core\(s\) per socket: *(\d+)' cores_per_socket \
        '^ *Thread\(s\) per core: *(\d+)' threads_per_core \
        '^ *Socket\(s\): *(\d+)' sockets \
        '^ *CPU\(s\): *(\d+)' cpus

    # stores the data we get back from the regex matching, using the field names above
    set fields

    # these are the attributes we want to set
    # order is irrelevant, but we have to do math to get the cores and threads
    set attr_keys \
        model \
        vendor \
        cores \
        threads \
        sockets

    set data (read_program "lscpu" )
    #    debug_var_list data

    for regex in (dict keys regexes)
        set value (string match --regex --groups-only $regex $data)
        debug_var value

        dict set fields (dict get regexes $regex) $value
    end

    # math the ones we need to calculate
    debug_var fields
    dict set fields cores (math (dict get fields cores_per_socket) x (dict get fields sockets))
    dict set fields threads (math (dict get fields threads_per_core) x (dict get fields cores))
    debug_var fields

    # now we need to set the attributes in the ATTRS dict
    # note there is two extra keys in "fields" that we ignore - not an issue
    for key in $attr_keys
        set value (dict get fields $key)
        debug_var key
        debug_var value
        dict set ATTRS phy.cpu.$key $value
    end

    trace (status function) end
end

function input_selinux
    trace (status function) begin

    set data (read_program "getenforce")
    debug_var_list data

    dict set ATTRS os.selinux.enable UNKNOWN
    dict set ATTRS os.selinux.mode $data

    trace (status function) end
end

# Data about gru itself (metadata)
function input_gru
    trace (status function) begin

    dict set ATTRS gru.binary (path resolve (status current-filename))
    dict set ATTRS gru.version $_VERSION
    dict set ATTRS gru.version_info (string replace '.' ' ' $_VERSION)
    dict set ATTRS gru.fish.binary (status fish-path)
    dict set ATTRS gru.fish.version $version
    dict set ATTRS gru.debug_mode (debug_state status)
    dict set ATTRS gru.path $PATH

    trace (status function) end
end
