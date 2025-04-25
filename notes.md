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
