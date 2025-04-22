# Notes

## Code Notes

- Fish DOES require all functions to be defined before they are called.

## Future Code

```shell
# Converts bytes value to human-readable string [$1: bytes value]
bytesToHumanReadable() {
    local i=${1:-0} d="" s=0 S=("Bytes" "KiB" "MiB" "GiB" "TiB" "PiB" "EiB" "YiB" "ZiB")
    while ((i > 1024 && s < ${#S[@]}-1)); do
        printf -v d ".%02d" $((i % 1024 * 100 / 1024))
        i=$((i / 1024))
        s=$((s + 1))
    done
    echo "$i$d ${S[$s]}"
}

to_bytes() {
    value=$(echo "$1" | sed 's/[^0123456789].*$//g')
    units=$(echo "$1" | sed 's/^[0123456789]*//g' | tr '[:upper:]' '[:lower:]')

    case "$units" in
        t|tb)   let 'value *= 1024 * 1024 * 1024 * 1024'    ;;
        g|gb)   let 'value *= 1024 * 1024 * 1024'   ;;
        m|mb)   let 'value *= 1024 * 1024'  ;;
        k|kb)   let 'value *= 1024' ;;
        b|'')   let 'value += 0'    ;;
        *)
                value=
                echo "Unsupported units '$units'" >&2
        ;;
    esac

    echo "$value"
}
```

```shell
#
# written by Dennis Williamson 2010-12-09
# for https://stackoverflow.com/questions/4399475/unformat-disk-size-strings
si_to_bytes() {
    # CODE: This function requires bash v4 or better for ${b^^}  (at least)

    # set k to 1000 if that's your preference, p is a pattern to match unit chars
    local k=1024
    local p='E|P|T|G|M|K| '          # exa, peta, tera, giga, mega, kilo, bytes
    local b=$1
    local s=${p//|}                  # s is the list of units
    local c
    local e

    b=${b^^}                         # toupper for case insensitivity
    b=${b%B*}                        # strip any trailing B from the input
    c=${b: -1}                       # get the unit character
    c=${c/%!($p)/ }                  # add a space if there's no unit char
    b=${b%@($p)*}                    # remove the unit character
    e=${s#*${c:0:1}}                 # index into the list of units

    # do the math, add single quote (%'u\n) to include the thousands separator
    printf "%u\n" $((b * k**${#e}))
}
```

```shell
# written by Geoffrey 2015-08-06
# https://unix.stackexchange.com/a/220470
function bytes_to_si() {

        local SIZE=$1
        local UNITS="B KiB MiB GiB TiB PiB"
        for F in $UNITS; do
                local UNIT=$F
                test ${SIZE%.*} -lt 1024 && break;
                SIZE=$(echo "$SIZE / 1024" | bc -l)
        done

    if [ "$UNIT" == "B" ]; then
        printf "%.0f    %s\n" $SIZE $UNIT
    else
        printf "%.02f %s\n" $SIZE $UNIT
    fi
}
```

## DMIdecode Notes

```shell
get_phy_ram() {

    # Everyone confuses this with free or /proc/meminfo
    # thats the amount of _memory_ -IE, how much ram MINUS what the kernel eats.
    # ram will always be an integer number (and these days in Gigabytes)
    # memory will be something like 7.8GB on an 8GB system...
    dmidecode -t 17 | grep "Size.*MB" | awk '{s+=$2} END {print s / 1024}'

    ## Gillian gets this:
    #    OTHER_USER@LINUX_LAPTOP> sudo dmidecode -t 17 | egrep "Size.*B"
    #        Size: 8 GB
```

## Uname data notes

```shell
% uname --help
Usage: uname [OPTION]...
Print certain system information.  With no OPTION, same as -s.

  -a, --all                print all information, in the following order,
                             except omit -p and -i if unknown:
  -s, --kernel-name        print the kernel name
  -n, --nodename           print the network node hostname
  -r, --kernel-release     print the kernel release
  -v, --kernel-version     print the kernel version
  -m, --machine            print the machine hardware name
  -p, --processor          print the processor type (non-portable)
  -i, --hardware-platform  print the hardware platform (non-portable)
  -o, --operating-system   print the operating system
      --help     display this help and exit
      --version  output version information and exit

GNU coreutils online help: <https://www.gnu.org/software/coreutils/>
Full documentation <https://www.gnu.org/software/coreutils/uname>
or available locally via: info '(coreutils) uname invocation'

[USERNAME@<host1>]~% uname -a
Linux <host1> 5.14.0-578.el9.x86_64 #1 SMP PREEMPT_DYNAMIC Mon Apr 7 19:22:46 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
[USERNAME@<host1>]~% uname -s
Linux
[USERNAME@<host1>]~% uname -n
<host1>
[USERNAME@<host1>]~% uname -r
5.14.0-578.el9.x86_64
[USERNAME@<host1>]~% uname -v
#1 SMP PREEMPT_DYNAMIC Mon Apr 7 19:22:46 UTC 2025
[USERNAME@<host1>]~% uname -m
x86_64
[USERNAME@<host1>]~% uname -p
x86_64
[USERNAME@<host1>]~% uname -i
x86_64
[USERNAME@<host1>]~% uname -o
GNU/Linux
```

```shell
dehumanise() {
  for v in "${@:-$(</dev/stdin)}"
  do  
    echo $v | awk \
      'BEGIN{IGNORECASE = 1}
       function printpower(n,b,p) {printf "%u\n", n*b^p; next}
       /[0-9]$/{print $1;next};
       /K(iB)?$/{printpower($1,  2, 10)};
       /M(iB)?$/{printpower($1,  2, 20)};
       /G(iB)?$/{printpower($1,  2, 30)};
       /T(iB)?$/{printpower($1,  2, 40)};
       /KB$/{    printpower($1, 10,  3)};
       /MB$/{    printpower($1, 10,  6)};
       /GB$/{    printpower($1, 10,  9)};
       /TB$/{    printpower($1, 10, 12)}'
  done
} 

```

```shell
#!/bin/bash

declare -A s=([Y]=24 [Z]=21 [E]=18 [P]=15 [T]=12 [G]=9 [M]=6 [K]=3)

input="$1"
suffix="${input: -1}"
number="${input:0: -1}"

printf "%.0f bytes\n" "${number}e+${s[$suffix]}"

#!/bin/bash

declare -A s=([P]=50 [T]=40 [G]=30 [M]=20 [K]=10)

input="$1"
suffix="${input: -1}"
number="${input:0: -1}"
d=$(printf "%.0f" "${number}e+2")

printf "%d bytes\n" "$(( d * 2 ** s["$suffix"] / 100 ))"
```

```shell
awk 'function human(x) {
         s=" B   KiB MiB GiB TiB EiB PiB YiB ZiB"
         while (x>=1024 && length(s)>1) 
               {x/=1024; s=substr(s,5)}
         s=substr(s,1,4)
         xf=(s==" B  ")?"%5d   ":"%8.2f"
         return sprintf( xf"%s\n", x, s)
      }
      {gsub(/^[0-9]+/, human($1)); print}'

 awk '
    function human(x) {
        if (x<1000) {return x} else {x/=1024}
        s="kMGTEPZY";
        while (x>=1000 && length(s)>1)
            {x/=1024; s=substr(s,2)}
        return int(x+0.5) substr(s,1,1)
    }
    {sub(/^[0-9]+/, human($1)); print}'

```

