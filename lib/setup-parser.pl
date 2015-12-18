#!/usr/bin/perl

use strict;
use warnings;

sub usage {
	my $script_name = $0;
	print "$script_name: perser to read setup.int\n";
	print "Usage:\n";
	print "  ./$script_name <package>         to show package info\n";
	print "  ./$script_name <package> <tag>   to show tagged content on package info\n";
	exit;
}

usage() if ( $#ARGV == -1 );

sub show_pkg_all_info {
	my ($pkg_info) = @_;
	print "sdesc: $pkg_info->{'sdesc'}\n";
	print "ldesc: \n";
	foreach (@{$pkg_info->{'ldesc'}}) {
		print;
	}
	print "\n";
	print "category: $pkg_info->{'category'}\n";
	print "requires: $pkg_info->{'requires'}\n";
	print "version: $pkg_info->{'version'}\n";
	print "install: $pkg_info->{'install'}\n";
}

sub show_pkg_info {
	my ($pkg_info, $tag) = @_;
	unless ($tag) {
		show_pkg_all_info(\%$pkg_info);
	} else {
		print "$pkg_info->{$tag}\n" or die("tag \"$tag\" is not found.");
	}
}

my $pkg_name = $ARGV[0];
my $tag_name = $ARGV[1];
my $found_pkg = 0; # false
my %pkg_info = (
	'sdesc' => '',
	'ldesc' => [
		# each lines
	],
	'category' => '',
	'requires' => '',
	'version' => '',
	'install' => ''
);
my $on_ldesc = 0; # false

if ( !(exists $pkg_info{$tag_name}) ) {
	print "no such a tag: $tag_name\n";
	exit -1;
}


open(SETUP_INIT, "< ../setup.ini") or die("could not open file");

while (<SETUP_INIT>) {
	if (/^@ $pkg_name$/) {
		$found_pkg = 1; # true
		next;
	}

	next unless ($found_pkg);

	# if package is found, tries matching as follows:

	# sdesc
	if (/^sdesc: "([^\\"]++|\\.)*+"$/) {
		$pkg_info{'sdesc'} = $1;
		next;
	}

	# ldesc
	if (/^ldesc: /) {
		$on_ldesc = 1; # true
	}
	if (/^ldesc: "([^\\"]++|\\.)*+("?)$/) {
		push(@{$pkg_info{'ldesc'}}, $1);
		# when double quote is on end of line, on_ldesc is false.
		$on_ldesc = 0 if ($2);
		next;
	}
	if ($on_ldesc && /^([^\\"]++|\\.)*("?)$/) {
		push(@{$pkg_info{'ldesc'}}, $1);
		# when double quote is on end of line, on_ldesc is false.
		$on_ldesc = 0 if ($2);
		next;
	}

	# category
	if (/^category: ([^\n]*+)$/) {
		$pkg_info{'category'} = $1;
		next;
	}

	# requires
	if (/^requires: ([^\n]*+)$/) {
		$pkg_info{'requires'} = $1;
		next;
	}

	# version
	if (/^version: ([^\n]*+)$/) {
		$pkg_info{'version'} = $1;
		next;
	}

	# install
	if (/^install: ([^\n]*+)$/) {
		$pkg_info{'install'} = $1;
		next;
	}

	# ignore [prev] info
	last if (/^\[prev\]$/);
	# next package
	last if (/^@ /);
}

unless ($found_pkg) {
	exit -1;
}


show_pkg_info(\%pkg_info, "$tag_name");



