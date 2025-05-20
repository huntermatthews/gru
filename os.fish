## -*- mode: fish -*- ##

function os_darwin
    trace (status function) begin

    # there's no command or file that explicitly tells us "Apple"
    dict set ATTRS sys.vendor Apple

    input_uname
    input_sw_vers
    input_macos_name
    input_gru

end

function os_linux
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
    input_gru

end

function os_test
    trace (status function) begin

    collector

end

function os_unsupported
    trace (status function) begin

    panic "Unsupported OS"

end
