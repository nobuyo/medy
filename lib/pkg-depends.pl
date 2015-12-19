#!/usr/bin/perl
# 
#   pkg-depends.pl -- show the depended packages of given package name
# 
# args:
#   $package_name <- $ARGV[0]
# 
# require:
#   before this run, export variable 'SETUP_INI_FILE_PATH'.
#   how output the depended packages of Vim is as follows:
#   
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

package PkgDepends;

unless ($ENV{'SETUP_INI_FILE_PATH'}) {
	$ENV{'SETUP_INI_FILE_PATH'} = "./setup.ini";
}

sub usage {
	my $script_name = $0;
	print "Usage\n";
	print "  \"perl $script_name <package>\"   to show dependencies of package\n";
	exit;
}

sub fetch_pkg_depends {
	my ($require_pkgs, $pkg_name, $nest) = @_;
	my $requires_str = SetupParser::extract_from_setup_init($pkg_name, 'requires');
	my @requires     = split(/\s+/, $requires_str);

	# print "begin: $nest\n";
	# print join(' ', keys %require_pkgs) . "\n";

	foreach (@requires) {
		my $require_pkg = $_;
		my $marked_pkg  = \$require_pkgs->{$_};
		next if (defined $$marked_pkg && $$marked_pkg == 1); # already marked
		$$marked_pkg = 1; # mark
		fetch_pkg_depends(\%$require_pkgs, $require_pkg, $nest + 1); # recursion
	}

	# print "end: $nest\n";
}


usage() if ($#ARGV == -1);
my $pkg_name = $ARGV[0];
my %require_pkgs = ();
fetch_pkg_depends(\%require_pkgs, $pkg_name, 0);

# print "---\n";
print join("\n", keys %require_pkgs) . "\n";


