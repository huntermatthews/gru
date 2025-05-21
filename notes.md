# Notes

## Code Notes

- Fish DOES require all functions to be defined before they are called.

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

### FreeBSD

- uname -a FreeBSD freebsd 14.2-RELEASE FreeBSD 14.2-RELEASE releng/14.2-n269506-c8918d6c7412 GENERIC amd64
- uname -b 881d8d7f1313038d6c104b9d978cdb7ce2ed50a3
- uname -i GENERIC
- uname -K 1402000
- uname -m amd64
- uname -n testfreebsd01.localdomain
- uname -o FreeBSD
- uname -p amd64
- uname -r 14.2-RELEASE
- uname -s FreeBSD
- uname -U 1402000
- uname -v FreeBSD 14.2-RELEASE releng/14.2-n269506-c8918d6c7412 GENERIC

### Linux

- uname -a Linux itbshell01.nhgri.nih.gov 5.14.0-547.el9.x86_64 #1 SMP PREEMPT_DYNAMIC Mon Dec 30 20:10:38 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
- uname -s Linux
- uname -n itbshell01.nhgri.nih.gov
- uname -r 5.14.0-547.el9.x86_64
- uname -v #1 SMP PREEMPT_DYNAMIC Mon Dec 30 20:10:38 UTC 2024
- uname -m x86_64
- uname -p x86_64
- uname -i x86_64
- uname -o GNU/Linux

### MacOS

- uname -a Darwin HG-02254242-LM 23.6.0 Darwin Kernel Version 23.6.0: Fri Nov 15 15:13:15 PST 2024; root:xnu-10063.141.1.702.7~1/RELEASE_ARM64_T6000 arm64
- uname -m arm64
- uname -n HG-02254242-LM
- uname -o Darwin
- uname -p arm
- uname -r 23.6.0
- uname -s Darwin
- uname -v Darwin Kernel Version 23.6.0: Fri Nov 15 15:13:15 PST 2024; root:xnu-10063.141.1.702.7~1/RELEASE_ARM64_T6000

```shell
if [[ ! -f /usr/bin/salt-minion ]] ; then
 /bin/echo "CRITICAL - salt-minion not installed"
 exit 2
elif [[ -f /no_salt ]]; then
 /bin/echo "WARNING - SaltStack disabled since at least $(stat --format %y /no_salt)"
 exit 1
elif [[ $(stat --format %y /var/cache/salt/minion/highstate.cache.p | date -f - +%s) -lt $(date -d "24 hours ago" +%s) ]]; then
    # FIXME: possibly explore salt-run or salt.modules.state methods to review when salt last ran
 /bin/echo "WARNING - SaltStack has not run for at least 24 hours - last run $(stat /var/cache/salt/minion/highstate.cache.p --format %y)"
 exit 1
elif [[ $(stat --format %y /var/cache/salt/minion/highstate.cache.p | date -f - +%s) -gt $(date -d "24 hours ago" +%s) ]]; then
 /bin/echo "OK - SaltStack running"
 exit 0
fi
```

## Version comparisons

### Go version tool

<https://github.com/iv-one/version>

### Bash

<https://github.com/Ariel-Rodriguez/sh-semversion-2>

```shell
#!/bin/bash
vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if ((10#${ver1[i]:=0} > 10#${ver2[i]:=0}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

testvercomp () {
    vercomp $1 $2
    case $? in
        0) op='=';;
        1) op='>';;
        2) op='<';;
    esac
    if [[ $op != $3 ]]
    then
        echo "FAIL: Expected '$3', Actual '$op', Arg1 '$1', Arg2 '$2'"
    else
        echo "Pass: '$1 $op $2'"
    fi
}

# Run tests
# argument table format:
# testarg1   testarg2     expected_relationship
echo "The following tests should pass"
while read -r test
do
    testvercomp $test
done << EOF
1            1            =
2.1          2.2          <
3.0.4.10     3.0.4.2      >
4.08         4.08.01      <
3.2.1.9.8144 3.2          >
3.2          3.2.1.9.8144 <
1.2          2.1          <
2.1          1.2          >
5.6.7        5.6.7        =
1.01.1       1.1.1        =
1.1.1        1.01.1       =
1            1.0          =
1.0          1            =
1.0.2.0      1.0.2        =
1..0         1.0          =
1.0          1..0         =
EOF

echo "The following test should fail (test the tester)"
testvercomp 1 1 '>'
```

## Get Version number of application on a Mac

```shell
 mdls -raw -name kMDItemVersion /Applications/Firefox.app/
```

## x86_64 version checking

```shell
#!/bin/sh -eu

flags=$(cat /proc/cpuinfo | grep flags | head -n 1 | cut -d: -f2)

supports_v2='awk "/cx16/&&/lahf/&&/popcnt/&&/sse4_1/&&/sse4_2/&&/ssse3/ {found=1} END {exit !found}"'
supports_v3='awk "/avx/&&/avx2/&&/bmi1/&&/bmi2/&&/f16c/&&/fma/&&/abm/&&/movbe/&&/xsave/ {found=1} END {exit !found}"'
supports_v4='awk "/avx512f/&&/avx512bw/&&/avx512cd/&&/avx512dq/&&/avx512vl/ {found=1} END {exit !found}"'

echo "$flags" | eval $supports_v2 || exit 2 && echo "CPU supports x86-64-v2"
echo "$flags" | eval $supports_v3 || exit 3 && echo "CPU supports x86-64-v3"
echo "$flags" | eval $supports_v4 || exit 4 && echo "CPU supports x86-64-v4"
```

### or

```shell
#!/bin/sh
set -e

verbose=
while getopts v OPTLET; do
  case "$OPTLET" in
    v) verbose=1;;
    \?) exit 2;;
  esac
done

flags=$(grep '^flags\b' </proc/cpuinfo | head -n 1)
flags=" ${flags#*:} "

has_flags () {
  for flag; do
    case "$flags" in
      *" $flag "*) :;;
      *)
        if [ -n "$verbose" ]; then
          echo >&2 "Missing $flag for the next level"
        fi
        return 1;;
    esac
  done
}

determine_level () {
  level=0
  has_flags lm cmov cx8 fpu fxsr mmx syscall sse2 || return 0
  level=1
  has_flags cx16 lahf_lm popcnt sse4_1 sse4_2 ssse3 || return 0
  level=2
  has_flags avx avx2 bmi1 bmi2 f16c fma abm movbe xsave || return 0
  level=3
  has_flags avx512f avx512bw avx512cd avx512dq avx512vl || return 0
  level=4
}

determine_level
echo "$level"
```

```shell
#!/usr/bin/awk -f

BEGIN {
    # Collect CPU features from lscpu
    cmd = "lscpu | grep 'Flags:' | awk '{for (i=2; i<=NF; i++) print $i}'"
    while (cmd | getline) {
        features = features " " $0
    }
    close(cmd)

    # Define required features for each x86-64-v level
    levels[1] = "lm cmov cx8 fpu fxsr mmx syscall sse2"
    levels[2] = "cx16 lahf_lm popcnt sse4_1 sse4_2 ssse3"
    levels[3] = "avx avx2 bmi1 bmi2 f16c fma abm movbe xsave"
    levels[4] = "avx512f avx512bw avx512cd avx512dq avx512vl"

    level = 0
    missing = ""

    # Check features for each level
    for (i = 1; i <= 4; i++) {
        level_met = 1
        split(levels[i], flags, " ")
        missing = ""
        for (j in flags) {
            if (features !~ flags[j]) {
                missing = missing flags[j] " "
                level_met = 0
            }
        }
        if (level_met == 1) {
            level = i
        } else {
            print "Current level: x86-64-v" level
            print "Missing for x86-64-v" i ": " missing
            exit i
        }
    }

    # Report the highest supported level
    print "Current level: x86-64-v" level
    exit level + 1
}
```

```shell
/usr/lib/ld-linux-x86-64.so.2 --help
'''
