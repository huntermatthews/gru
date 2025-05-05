## -*- mode: fish -*- ##

function os_darwin
    trace (status function) begin

    # there's no command or file that explicitly tells us "Apple"
    dict set ATTRS sys.vendor Apple

    input_uname
    input_sw_vers
    input_macos_name
    input_gru

    trace (status function) end
end

function os_linux
    trace (status function) begin

    dict set ATTRS os.name Linux
    input_uname
    input_virt_what
    input_os_release
    if test (dict get ATTRS phy.platform) = physical
        # DMI is meaningless for non-physical systems
        input_sys_dmi
    end
    input_udevadm_ram
    input_lscpu
    input_selinux
    input_no_salt
    input_gru

    trace (status function) end
end

function os_test
    trace (status function) begin

    input_udevadm_ram
    input_lscpu

    trace (status function) end
end

function os_unsupported
    trace (status function) begin

    panic "Unsupported OS"

    trace (status function) end
end
