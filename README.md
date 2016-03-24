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
medy provides the following additional features as compared to the [originals](https://github.com/nobuyo/medy#official):

- showing infomation and status of package
- upgrade(remove and install) packages
- suggest subcommand if there were a typo

## Operations
about subcommands and options

~~~ bash
$ medy <SUBCOMMAND> <OPTION> <ARGS>
~~~

### Subcommand
~~~
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
  Search given package from local and server.
  support an option --local to search from only local.

upgrade
  Upgrade(remove and reinstall) package(s).
  If no packages given as argument, medy upgrades all packages which has a update.

upgrade-self
  Get medy of the latest version.

doctor
  Check all packages available.

help
  Show usage and exit.

version
  Show logo and version info.
~~~

### Options
~~~
--force
  Force install/remove.

--mirror
  Set mirror server.

--view
  Show process infomation.

--local
  Find package from local.

--dry-run
  Run without remove or install(only upgrade support).

--help
  Show help.

--version
  Show version. 
~~~

## Quick start
please get it, deploy it, and make it executable.
~~~ bash
$ mv medy /bin/medy
$ chmod +x /bin/medy
~~~

For example,
~~~ bash
$ medy install nano
~~~

## for contributors

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

#### file description
filename(assumed dir) ... desc
- setup.ini(Cygwin packages folder each Machine) ... provide packages infomation
- installed.db(/etc/setup/installed.db) ... list of installed package on each Cygwin
- setup.rc(/etc/setup/setup.rc) ... infomation of mirror, last mirror, and cache directory

#### build medy

On our terminal:
~~~ bash
path/to/medy$ make
~~~

#### Implementation plan
- [TODO](https://github.com/nobuyo/medy/blob/master/TODO.md)

## Official
This script heavy based on these scripts:
- [apt-cyg](https://github.com/transcode-open/apt-cyg)
- [cyg-fast](https://github.com/tmshn/cyg-fast/)

