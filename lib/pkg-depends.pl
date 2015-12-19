#!/usr/bin/perl

use strict;
use warnings;
require 'lib/setup-parser.pl';

package PkgDepends;

$ENV{'SETUP_INIT_FILE_PATH'}   = "./setup.ini";
$ENV{'SETUP_PARSER_FILE_PATH'} = "./lib/setup-parser.pl";

sub usage {
	my $script_name = $0;
	print "Usage\n";
	print "  \"perl $script_name <package>\"   to show dependencies of package\n";
	exit;
}

usage() if ($#ARGV == -1);

my $pkg_name = $ARGV[0];
my %require_pkgs = ();

sub fetch_pkg_depends {
	my ($require_pkgs, $pkg_name, $nest) = @_;
	my $requires_str = SetupParser::extract_from_setup_init($pkg_name, 'requires');
	my @requires     = split(/\s+/, $requires_str);

	print "begin: $nest\n";
	print join(' ', keys %require_pkgs) . "\n";
	# print "requires_str: $requires_str\n";

	foreach (@requires) {
		my $require_pkg = $_;
		my $require_pkg_key = \$require_pkgs->{$_};
		next if (defined $$require_pkg_key && $$require_pkg_key == 1); # already marked
		$require_pkgs->{$_} = 1;
		fetch_pkg_depends(\%require_pkgs, $require_pkg, $nest + 1);
	}

	print "end: $nest\n";
}

fetch_pkg_depends(\%require_pkgs, $pkg_name, 0);

print "---\n";
foreach (keys %require_pkgs) {
	print "$_\n";
}


