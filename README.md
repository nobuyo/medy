# medy
package manager for cygwin(developing, not yet available)

## requires
medy requires requires the cygwin default environment and optional packages below.

- aria2
- tar
- bzip2
- xz

## for contributors
####file description
filename(assumed dir) ... desc
- setup.ini(Cygwin packages folder each Machine) ... provide packages infomation
- installed.db(/etc/setup/installed.db) ... list of installed package on each Cygwin
- setup.rc(/etc/setup/setup.rc) ... infomation of mirror, last mirror, and cache directory

#### todo
- [TODO](https://github.com/nobuyo/medy/blob/master/TODO.md)

## Official
This script heavy based on these scripts:
- [apt-cyg](https://github.com/transcode-open/apt-cyg)
- [cyg-fast](https://github.com/tmshn/cyg-fast/)

