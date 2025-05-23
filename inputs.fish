## -*- mode: fish -*- ##

function requires_os_release
    echo file:/etc/os-release
end
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

end

function requires_uname
    echo prog:uname
end
function input_uname
    trace (status function) begin

    set keys os.kernel.name os.hostname os.kernel.version phy.arch.name phy.arch.family
    set data (read_program "uname" "-snrmp" | string split -- ' ' )
    debug_var_list data

    # The order back from uname is fixed (at least on Linux and MacOS) so this is safe
    if test (count $keys) -ne (count $data)
        debug count keys (count $keys)
        debug count data (count $data)
        debug_var keys
        debug_var data
        panic (status function): keys and data length don't match: You can't count
    end

    for idx in (seq (count $data))
        debug_var keys[$idx]
        debug_var data[$idx]
        dict set ATTRS $keys[$idx] $data[$idx]
    end

end

function requires_sys_dmi
    echo dir:/sys/devices/virtual/dmi/id

end
function input_sys_dmi
    trace (status function) begin

    set keys sys.vendor sys.model.family sys.model.name sys.serial_no sys.uuid sys.oem sys.asset_no
    set entries sys_vendor product_family product_name product_serial product_uuid chassis_vendor chassis_asset_tag

    if test (count $keys) -ne (count $entries)
        debug count keys (count $keys)
        debug count data (count $entries)
        debug_var keys
        debug_var entries
        panic (status function): keys and entries length don't match: You can't count
    end

    for idx in (seq (count $keys))
        set key $keys[$idx]
        set entry $entries[$idx]
        set data (read_file /sys/devices/virtual/dmi/id/$entry)
        debug_var_list data
        debug_var key
        dict set ATTRS $key $data
    end

end

function requires_udevadm_ram
    echo prog:udevadm
end
function input_udevadm_ram
    trace (status function) begin

    set data (read_program "udevadm" "info" "-e" )
    trace_var_list data

    # FIXME: this is much easier with --groups-only, but we don't have that in fish v3.3
    set raw_sizes (string match --regex 'MEMORY_DEVICE_\d+_SIZE=(\d+)' $data)
    # raw_sizes == '17179869184 17179869184 17179869184 17179869184' with --groups-only
    # raw_sizes == 'MEMORY_DEVICE_0_SIZE=17179869184 17179869184 MEMORY_DEVICE_1_SIZE=17179869184 17179869184 MEMORY_DEVICE_8_SIZE=17179869184 17179869184 MEMORY_DEVICE_9_SIZE=17179869184 17179869184'
    debug_var_list raw_sizes
    set max (count $raw_sizes)
    for i in (seq 2 2 $max)
        set --append sizes $raw_sizes[$i]
    end
    debug_var_list sizes

    set total (math (string join '+' $sizes ))
    debug_var total

    set bytes (bytes_to_si $total)
    debug_var bytes

    dict set ATTRS phy.ram.size $bytes

end

function requires_virt_what
    echo prog:virt-what
end
function input_virt_what
    trace (status function) begin

    set data (read_program "virt-what" )
    if test $status -eq 1
        # error running virt-what, so we can't assume anything
        dict set ATTRS phy.platform UNKNOWN
        return 1
    end
    debug_var_list data

    if test -z "$data"
        # no output generally means bare-metal
        set data physical
    end

    dict set ATTRS phy.platform $data

end

function requires_lscpu
    echo prog:lscpu
end
function input_lscpu
    trace (status function) begin

    # map the regex to the field name
    # the regex is the key, the field name is the value
    set regexes \
        '^ *Model name: *(?<value>.+)' model \
        '^ *Vendor ID: *(?<value>.+)' vendor \
        '^ *Core\(s\) per socket: *(?<value>\d+)' cores_per_socket \
        '^ *Thread\(s\) per core: *(?<value>\d+)' threads_per_core \
        '^ *Socket\(s\): *(?<value>\d+)' sockets \
        '^ *CPU\(s\): *(?<value>\d+)' cpus

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
        # FIXME: this is much easier with --groups-only, but we don't have that in fish v3.3
        # Cheat -these regex only yield one value, so we can use the named capture groups.
        set rvalue (string match --regex $regex $data)
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

end

function __has_flags
    trace (status function) begin
    set check_flags (string split --no-empty ' ' $argv[1])
    set all_flags (string split --no-empty ' ' $argv[2])
    debug count is (count $argv)
    debug_var check_flags
    debug_var all_flags

    for flag in $check_flags
        if not contains $flag $all_flags
            # we don't have all the flags we need
            return 1
        end
    end

    trace (status function) end
    return 0

end

function requires_cpuinfo_flags
    echo file:/proc/cpuinfo
end
function input_cpuinfo_flags
    trace (status function) begin

    set vers[1] "lm cmov cx8 fpu fxsr mmx syscall sse2"
    set vers[2] "cx16 lahf_lm popcnt sse4_1 sse4_2 ssse3"
    set vers[3] "avx avx2 bmi1 bmi2 f16c fma abm movbe xsave"
    set vers[4] "avx512f avx512bw avx512cd avx512dq avx512vl"

    set data (read_file "/proc/cpuinfo")
    trace_var_list data

    set cpu_flags (string match --entire --max-matches 1 'flags' $data \
        | string split --fields 2 ':')
    debug_var_list cpu_flags

    # all x86_64 cpus are at least version 0
    set cpu_version 0

    for idx in (seq (count $vers))
        if __has_flags $vers[$idx] $cpu_flags
            # we have all the flags for this version
            set cpu_version (math $cpu_version + 1)
        else
            break
        end
    end

    debug_var idx
    dict set ATTRS phy.cpu.arch_version x86_64_v$cpu_version

end

function requires_selinux
    echo prog:selinuxenabled prog:getenforce
end
function input_selinux
    trace (status function) begin

    if read_program selinuxenabled # selinuxenabled ONLY sets RC - there's no output to capture
        dict set ATTRS os.selinux.enable true
    else
        dict set ATTRS os.selinux.enable false
    end

    set data (read_program "getenforce")
    debug_var_list data

    dict set ATTRS os.selinux.mode $data

end

function requires_gru
    echo
end
function input_gru
    trace (status function) begin

    # FIXME: was "path resolve", but we don't have that in fish v3.3
    dict set ATTRS gru.binary (realpath (status current-filename))
    dict set ATTRS gru.version $_VERSION
    dict set ATTRS gru.version_info (string replace '.' ' ' $_VERSION)
    dict set ATTRS gru.fish.binary (status fish-path)
    dict set ATTRS gru.fish.version $version
    dict set ATTRS gru.debug_mode (debug_state status)
    dict set ATTRS gru.path $PATH
    dict set ATTRS gru.cmdline $_CMDLINE

end

function requires_sw_vers
    echo prog:sw_vers
end
function input_sw_vers
    # ProductName:		macOS
    # ProductVersion:	15.3.2
    # BuildVersion:		24D81

    trace (status function) begin

    set data (read_program "sw_vers")
    debug_var_list data

    for line in $data
        set key (string split --fields 1 --max 1 ":" $line | string trim)
        set value (string split --fields 2 --max 1 ":" $line | string trim)
        debug_var key
        debug_var value

        switch $key
            case ProductName
                dict set ATTRS os.name $value
            case ProductVersion
                dict set ATTRS os.version $value
            case BuildVersion
                dict set ATTRS os.build $value
        end

    end

end

function requires_macos_name
    echo
end
function input_macos_name
    trace (status function) begin

    set major_ver (dict get ATTRS os.version | string split --fields 1 '.' | string trim)
    debug_var major_ver

    switch $major_ver
        case 15
            set code_name Sequoia
        case 14
            set code_name Sonoma
        case 13
            set code_name Ventura
        case 12
            set code_name Monterey
        case 11
            set code_name "Big Sur"
            # Before that, we have to deal with more complicated veersion parsing - and its old.
    end

    dict set ATTRS os.code_name $code_name

end

function requires_no_salt
    echo file:/no_salt
end
function input_no_salt
    trace (status function) begin

    set data (read_file "/no_salt" )
    if test $status -eq 1
        # no_salt file doesn't exist, so we get any data
        dict set ATTRS salt.no_salt.exists false
        return 0
    else
        debug_var_list data
        dict set ATTRS salt.no_salt.exists true
    end

    if test -z "$data"
        # no data generally means a screw up
        set data UNKNOWN
    end

    # we have data, so we can set the reason
    dict set ATTRS salt.no_salt.reason $data

end

function requires_uptime
    echo prog:uptime
end
function input_uptime
    # 09:06:29 up 1 day, 5 hours, 28 minutes 1 user load average: 0.00, 0.00, 0.00
    # caution: linux has args to JUST give us the uptime, but we don't have that in macos
    trace (status function) begin

    set data (read_program "uptime" )
    debug_var data

    # FIXME: this is much easier with --groups-only, but we don't have that in fish v3.3
    string match --regex '.* up (?<uptime>.*) \d+ user.*' $data >/dev/null
    set uptime (string trim  --right --chars , $uptime)
    debug_var uptime

    dict set ATTRS run.uptime $uptime

end

function requires_proc_uptime
    echo file:/proc/uptime
end
function input_proc_uptime
    # 350735.47 234388.90
    trace (status function) begin

    set data (read_file "/proc/uptime" )
    debug_var data

    set uptime_secs (string split --fields 1 --max 1 " " $data)
    debug_var uptime_secs

    dict set ATTRS run.uptime $uptime_secs

end

function requires_ip_addr
    echo prog:ip prog:jq
end
function input_ip_addr
    trace (status function) begin

    set data (read_program "ip" "addr" )
    debug_var_list data

end
