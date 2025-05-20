## -*- mode: fish -*- ##

set -g _COLLECTOR_FILES /etc/os-release \
    /proc/cpuinfo \
    /proc/meminfo \
    /proc/mounts \
    /sys/devices/virtual/dmi/id

set -g _COLLECTOR_PROGRAMS \
    "dmidecode -t memory" \
    lsblk \
    "lsmem --summary --bytes" \
    lscpu \
    lspci \
    "ip addr" \
    "udevadm info -e | grep MEMORY" \
    "uname -snrmp"

function __collector_cleanup_workdir --on-event fish_exit
    rm -rf "$WORK_DIR"
end

function __collector_setup_workdir
    set -g WORK_DIR (mktemp -d "/tmp/(hostname).XXXXXX")
    if not test -d "$WORK_DIR"
        echo "ERROR: Could not create temp dir"
        exit 1
    end
end

function __collector_create_archive
    tar czf "/tmp/(hostname).tgz" -C "$WORK_DIR" .
    chmod ugo+r "/tmp/(hostname).tgz"
end

function __collector_collect_files
    for file in $FILES
        if test -f $file
            set dir (dirname $file)
            mkdir -p "$WORK_DIR/$dir"
            cp -aH $file "$WORK_DIR/$file"
        end
    end
end

function __collector_collect_programs
    mkdir -p "$WORK_DIR/_programs"
    for prog in $PROGRAMS
        set cmd (string split " " -- $prog)[1]
        set args (string split " " -- $prog)[2..-1]
        set path (which $cmd)
        if test -x "$path"
            eval $prog >"$WORK_DIR/_programs/$cmd"
        else
            echo "$cmd not found" >"$WORK_DIR/_programs/$cmd"
        end
    end
end

function __collector_collect_uname
    # snrmp are the only ones compat across linux+macos AND that we care about.
    for opt in s n r m p
        echo "uname -$opt "(uname -$opt ^/dev/null 2>&1) >>"$WORK_DIR/_programs/uname-opts"
    end
end

function __collector_collect_metadata
    mkdir -p "$WORK_DIR/_meta"
    echo (hostname) >"$WORK_DIR/_meta/hostname"
    echo $PATH >"$WORK_DIR/_meta/path"
    date -Iseconds >"$WORK_DIR/_meta/date"
end

function collector
    trace (status function) begin

    debug_var_list _COLLECTOR_FILES
    debug files_count (count $_COLLECTOR_FILES)

    debug_var_list _COLLECTOR_PROGRAMS
    debug programs_count (count $_COLLECTOR_PROGRAMS)

    # main
    #  __collector_setup_workdir
    #  __collector_collect_metadata
    #  __collector_collect_files
    #  __collector_collect_programs
    #  __collector_collect_uname
    #  __collector_create_archive
    #  __collector_cleanup_workdir
end
