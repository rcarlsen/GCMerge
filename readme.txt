GCMerge

this utility takes two separate GoldenCheetah (.gc) formatted files and
merges geolocation data from the second (slave) into the first (master).
it was designed to expect a PowerTap file as the "master" and a
MobileLogger file as the "slave".

the comparison is very naive, simply looking at the seconds attribute for
each sample - stepping through the slave samples until the first sample
past the current master sample's time.

a time offset in seconds is calculated using each file's start time,
which can be modified using the provided slider. this is helpful
when the log files were not begun at the same time, or if the
onboard clocks differ.

enjoy!
-robert carlsen
robertcarlsen.net

Released under the GPLv3.

---
GoldenCheetah: http://goldencheetah.org
MobileLogger: http://robertcarlsen.net/dev/mobile-logger
