# medy
package installer/remover (and builder) for cygwin

- medy install <package names> to install packages
- medy resume-install          to resume interrupted installing
- medy remove <package names>  to remove packages
- medy update                  to update setup.ini
- medy list                    to show installed packages
- medy search <patterns>       to find packages
- medy info <package name>     to show package infomation
- medy upgrade-self            to upgrade medy


## requires
medy requires requires the cygwin default environment and optional packages below.

- wget

## To start using medy
Please Please run following command your terminal

~~~ bash
$ mv medy /bin/medy
$ chmod +x /bin/medy
~~~

and for example:

~~~ bash
$ medy install nano
~~~

## for contributors
####file description
filename(assumed dir) -> desc
- setup.ini(Cygwin packages folder each Machine) -> provide packages infomation
- installed.db(/etc/setup/installed.db) -> list of installed package on each Cygwin
- setup.rc(/etc/setup/setup.rc) -> infomation of mirror, last mirror, and cache directory


## Official
This script heavy based on these scripts:
- [apt-cyg](https://github.com/transcode-open/apt-cyg)
- [cyg-fast](https://github.com/tmshn/cyg-fast/)

