#!/usr/bin/perl

use strict;
use warnings;

our $target_file = "setup.ini";

sub usage {
	my $script_name = $0;
	print "$script_name: perser to read setup.int\n";
	print "Usage:\n";
	print "  perl $script_name <package>         to show package info\n";
	print "  perl $script_name <package> <tag>   to show tagged content on package info\n";
	print "<tag>:\n";
	print "  sdesc  ldesc  category  requires  version  install\n";
	exit;
}

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
	
	unless (defined $tag) {
		show_pkg_all_info(\%$pkg_info);
		return;
	}

	if (ref $pkg_info->{$tag} eq 'ARRAY') {
		foreach (@{$pkg_info->{$tag}}) {
			print;
		}
		print "\n";
	} else {
		print "$pkg_info->{$tag}\n";
	}
}

usage() if ( $#ARGV == -1 );

my $pkg_name = $ARGV[0];
my $tag_name = $ARGV[1];
# use for loop
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
# use for extracting ldesc
my $on_ldesc = 0; # false

# check if the tag name is valid
if (defined $tag_name) {
	if ( !(exists $pkg_info{$tag_name}) ) {
		print "no such a tag: $tag_name\n";
		exit -1;
	}
}


open(SETUP_INIT_FILE, "< $target_file") or die("could not open file \"$target_file\"");

while (<SETUP_INIT_FILE>) {
	# find package name
	if (/^@ $pkg_name$/) {
		$found_pkg = 1; # true
		next;
	}

	next unless ($found_pkg);

	# if package is found, tries matching as follows:

	# sdesc
	if (/^sdesc: "([^"]*+)"$/) {
		$pkg_info{'sdesc'} = $1;
		next;
	}

	# ldesc
	if (/^ldesc: /) {
		$on_ldesc = 1; # true
	}
	if (/^ldesc: "([^"]*+)("?)$/) {
		push(@{$pkg_info{'ldesc'}}, $1);
		# when double quote is on end of line, on_ldesc is false.
		$on_ldesc = 0 if ($2);
		next;
	}
	if ($on_ldesc && /^([^"]*+)("?)$/) {
		push(@{$pkg_info{'ldesc'}}, $1);
		# when double quote is on end of line, on_ldesc is false.
		$on_ldesc = 0 if ($2);
		next;
	}

	# category, requires, version, install
	if (/^(category|requires|version|install): ([^\n]*+)$/) {
		$pkg_info{$1} = $2;
		next;
	}

	# ignore [prev] info
	last if (/^\[prev\]$/);
	# ignore next package
	last if (/^@ /);
}

unless ($found_pkg) {
	exit -1;
}

if (defined $tag_name) {
	show_pkg_info(\%pkg_info, "$tag_name");
} else {
	show_pkg_info(\%pkg_info);
}




