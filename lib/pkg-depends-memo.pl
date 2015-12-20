#!/usr/bin/perl
# 
#   pkg-depends-memo.pl -- show the depended packages of given package name
# 
# args:
#   $package_name <- $ARGV[0]
# 
# input:
#   if a enviroment variable 'SETUP_INI_FILE_PATH' is exported, input from its file.
#   otherwise, input from stdin.
#   how output the nested all requirements of Vim is as follows:
# 
#       cat /path/to/setup.ini | perl pkg-depends-memo.pl vim
#   or
#       export SETUP_INI_FILE_PATH=/path/to/setup.ini
#       perl pkg-depends.pl vim
# 
# return:
#   print the depended packages of given package name.
#   return -1 if package name is not found in file $ENV{'SETUP_INI_FILE_PATH'}.
# 

use strict;
use warnings;
use File::Basename;
require '' . dirname(__FILE__) . '/setup-parser.pl';

package PkgDependsMemo;

sub usage {
	my $script_name = $0;
	print "Usage\n";
	print "  \"perl $script_name <package>\"   to show dependencies of package\n";
	exit;
}

# create requirements table
# return the structure like:
# 
#     (
#         '4ti2-debuginfo' => ['cygwin-debuginfo'],
#         'a2ps'           => ['bash', 'libiconv2', 'libintl8', 'libpaper1', ..., 'cygwin'],
#           :
#         'zsh'            => ['cygwin', 'libncursesw10', 'libpcre1', 'libiconv2', 'libgdbm4', '_update-info-dir']
#     )
# 
sub create_requirements_table {
	my %pkg_requirements_table = ();

	# select input (file or stdin)
	my $in;
	my $target_file = $ENV{'SETUP_INI_FILE_PATH'};
	if ($target_file) {
		open($in, "< $target_file") or die("could not open file \"$target_file\"");
	} else {
		$in = *STDIN
	}

	my $pkg_name;
	my @pkg_requires;
	while (<$in>) {
		if (/^@ (.*)$/) {
			$pkg_name = $1;
		}

		if (/^requires: (.*)$/) {
			@pkg_requires = split(/\s+/, $1);
			@{$pkg_requirements_table{$pkg_name}} = @pkg_requires;
		}
	}
	\%pkg_requirements_table;
}

# fetch the package all nested dependency
# 
# args:
#   $pkg_requirements_table - requirements table, see create_requirements_table().
#   $require_pkgs           - empty hash, this function stores the required packages to the hash.
#   $pkg_name               - package name, to fetch its dependent packages.
#   $nest                   - nest level, starts with 0
# 
# return:
#   nothing
# 
sub fetch_pkg_depends {
	my ($pkg_requirements_table, $require_pkgs, $pkg_name, $nest) = @_;
	my @requires = @{ $pkg_requirements_table->{$pkg_name} || [] };

	# print "begin: $nest\n";
	# print join(' ', keys %require_pkgs) . "\n";

	foreach (@requires) {
		my $require_pkg = $_;
		my $marked_pkg  = \$require_pkgs->{$_};
		next if (defined $$marked_pkg && $$marked_pkg == 1); # already marked
		$$marked_pkg = 1; # mark
		fetch_pkg_depends(\%$pkg_requirements_table, \%$require_pkgs, $require_pkg, $nest + 1); # recursion
	}

	# print "end: $nest\n";
}

if (__FILE__ eq $0) {
	usage() if ($#ARGV == -1);
	my $pkg_name = $ARGV[0];
	my %pkg_requirements_table = %{ create_requirements_table() };
	my %require_pkgs = ();

	fetch_pkg_depends(\%pkg_requirements_table, \%require_pkgs, $pkg_name, 0);

	# print "---\n";
	print join("\n", keys %require_pkgs) . "\n";
} else {
	1;
}



