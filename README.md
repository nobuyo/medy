# medy
package manager for cygwin(beta version)

## requires
medy requires the cygwin default environment and optional packages below.

- aria2
- tar
- bzip2
- xz
- gawk
- wget

## How differ?
medy provides the following additional features as compared to the originals:

- showing infomation and status of package
- upgrade(remove and install) packages
- suggest subcommand if there were a typo

## Operations
~~~ bash
install
  Install package.

remove|uninstall
  Remove package from the system.

update
  Download a copy of the master package list from the mirror server.

list
  Show package list on the system.

info
  Display information on given package.

find|search
  search given package from local and server.
  support an option --local to search from only local.

upgrade
  upgrade(remove and reinstall) all packages which has a update.

upgrade-self
  get medy of the latest version.

doctor
  checking all packages available.

help
  show usage and exit.

version
  show logo and version info.
~~~

## for contributors
####file description
filename(assumed dir) ... desc
- setup.ini(Cygwin packages folder each Machine) ... provide packages infomation
- installed.db(/etc/setup/installed.db) ... list of installed package on each Cygwin
- setup.rc(/etc/setup/setup.rc) ... infomation of mirror, last mirror, and cache directory

#### Implementation plan
- [TODO](https://github.com/nobuyo/medy/blob/master/TODO.md)

## Official
This script heavy based on these scripts:
- [apt-cyg](https://github.com/transcode-open/apt-cyg)
- [cyg-fast](https://github.com/tmshn/cyg-fast/)

