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

my $pkg_name = $ARGV[0];
my $tag_name = $ARGV[1];

open(SETUP_INIT, "< ../setup.ini") or die("could not open file");

while (<SETUP_INIT>) {
	if (/^@ /) {
		print;
	}
}
