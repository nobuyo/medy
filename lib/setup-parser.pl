#!/usr/bin/perl
# 
#   setup-parser.pl -- perser to read setup.int
# 
# args:
#   $package_name <- $ARGV[0]
#   $tag_name     <- $ARGV[1]
#     where $tag_name = 'sdesc', 'ldesc', 'category', 'requires', 'version', 'install', undef
# 
# input:
#   if a enviroment variable 'SETUP_INI_FILE_PATH' is exported, input from its file.
#   otherwise, input from stdin.
#   how output the requirements of Vim is as follows:
#   
#       cat /path/to/setup.ini | perl setup-parser.pl vim requires
#   or
#       export SETUP_INI_FILE_PATH=/path/to/setup.ini
#       perl setup-parser.pl vim requires
# 
# return:
#   return -1 if package name is not found in input.
#   return -1 if tag name is invalid.
#   if $tag_name is not specified, print $package_name's info.
#   otherwise, print the tagged content of $package_name.
# 

use strict;
use warnings;

package SetupParser;

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

sub format_pkg_all_info {
	my ($pkg_info) = @_;
	my @each_lines = (
		"sdesc: $pkg_info->{'sdesc'}",
		"ldesc: \n" . join('', @{$pkg_info->{'ldesc'}}),
		"category: $pkg_info->{'category'}",
		"requires: $pkg_info->{'requires'}",
		"version: $pkg_info->{'version'}",
		"install: $pkg_info->{'install'}",
		"" # ends with \n
	);
	return join("\n", @each_lines);
}

sub format_pkg_info {
	my ($pkg_info, $tag) = @_;
	
	unless (defined $tag) {
		return format_pkg_all_info(\%$pkg_info);
	}

	if (ref $pkg_info->{$tag} eq 'ARRAY') {
		return join('', @{$pkg_info->{$tag}})
	} else {
		return "$pkg_info->{$tag}\n";
	}
}

# check if the tag name is valid
sub validate_tag_name {
	$_[0] =~ /^(?:requires|sdesc|ldesc|category|version|install)$/;
}

sub extract_from_setup_init {
	my ($pkg_name) = @_;
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

	# select input (file or stdin)
	my $in;
	my $target_file = $ENV{'SETUP_INI_FILE_PATH'};
	if ($target_file) {
		open($in, "< $target_file") or die("could not open file \"$target_file\"");
	} else {
		$in = *STDIN
	}

	while (<$in>) {
		# find package name
		if (/^@ \Q$pkg_name\E$/) {
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
		if (/^ldesc: "/) {
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
		print STDERR "no such a package: $pkg_name\n";
		exit -1;
	}

	\%pkg_info;
}

sub extract {
	extract_from_setup_init @_;
}


if (__FILE__ eq $0) {
	usage() if ( $#ARGV == -1 );
	my $pkg_name = $ARGV[0];
	my $tag_name = $ARGV[1];
	my $pkg_info = extract_from_setup_init($pkg_name, $tag_name);

	unless (validate_tag_name($tag_name)) {
		print STDERR "no such a tag: $tag_name\n";
	}

	if (defined $tag_name) {
		print format_pkg_info(\%$pkg_info, "$tag_name");
	} else {
		print format_pkg_info(\%$pkg_info);
	}
} else {
	1;
}

