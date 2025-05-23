## -*- mode: fish -*- ##

function os_darwin_requires
    trace (status function) begin

    requires_uname
    requires_sw_vers
    requires_macos_name
    requires_uptime
    requires_gru
end

function os_darwin_parse
    trace (status function) begin

    # weirdly, there's no command or file that explicitly tells us "Apple"
    dict set ATTRS sys.vendor Apple

    input_uname
    input_sw_vers
    input_macos_name
    input_uptime
    input_gru

end

function os_linux_requires
    trace (status function) begin
    requires_uname
    requires_virt_what
    requires_os_release

    # BUG: only do this on physical hardware
    requires_sys_dmi

    # BUG: only do this on x86_64/amd64 systems
    requires_cpuinfo_flags

    requires_udevadm_ram
    requires_lscpu
    requires_selinux
    requires_no_salt
    requires_uptime
    requires_gru
end

function os_linux_parse
    trace (status function) begin

    # If we get "Linux" as as the kernel name, then by defn the os.name is Linux
    dict set ATTRS os.name Linux

    input_uname
    input_virt_what
    input_os_release
    if test (dict get ATTRS phy.platform) = physical
        # DMI is meaningless for non-physical systems
        input_sys_dmi
    end
    if contains (dict get ATTRS phy.arch.name) x86_64 amd64
        # x86_64 is the same as amd64
        input_cpuinfo_flags
    end
    input_udevadm_ram
    input_lscpu
    input_selinux
    input_no_salt
    input_uptime
    input_gru

end

function os_test_requires
    trace (status function) begin

    echo "not implemented"

end
function os_test_parse
    trace (status function) begin

    input_ip_addr_show

end

function os_unsupported_requires
    trace (status function) begin

    panic "Unsupported OS"

end
function os_unsupported_parse
    trace (status function) begin

    panic "Unsupported OS"

end
