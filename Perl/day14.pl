#!/usr/bin/env perl
BEGIN {
    use Cwd;
    our $directory = cwd;
    our $local_lib = $ENV{"HOME"} . '/perl5/lib/perl5';
}

use lib $directory;
use lib $local_lib;

use Modern::Perl 2018;
use autodie;
use Data::Dumper;
#use Storable 'dclone';
use bigint;

use AOC::Util;
#use AOC::SpatialUtil;

my $INPUT_PATH = './input';
#my $INPUT_FILE = '14.test1.txt';
my $INPUT_FILE = '14.challenge.txt';
my @input = read_input("$INPUT_PATH/$INPUT_FILE");

say "Advent of Code 2020, Day 14: Docking Data";

solve_part_one(@input);
#solve_part_two(@input);

exit( 0 );

sub solve_part_one {
	my @input = @_;
	my %memory = ();
	my @mask;
	
	for my $line (@input) {
		if ( $line =~ m/^mask = ([X01]+)/ ) {
			my $pattern = $1;
			#say $pattern;
			@mask = ();
			for my $char (split('', $pattern)) {
				unshift(@mask, $char);
			}
			#say join(' ', @mask);
		}
		elsif ( $line =~ m/^mem\[(\d+)\] = (\d+)/ ) {
			my $addr = $1;
			my $val = $2;
			my $decoded = decode_version_1($val, @mask);
			#say "Set mem[$addr] to $decoded (was: $val)";
			$memory{$addr} = $decoded;
		}
	}
	
	my $sum = 0;
	for my $key ( keys %memory ) {
		$sum += $memory{$key};
	}
	say "Part 1: The sum of the memory values is $sum";
}

sub solve_part_two {
	my @input = @_;
}

sub decode_version_1 {
	my ($value, @mask) = @_;
	
	for (my $i = 0; $i <= $#mask; $i++) {
		if ($mask[$i] eq 'X') {
			# do nothing
		}
		elsif ($mask[$i] == 1) {
			$value |= 2 ** $i;	
		}
		else {
			$value &= ~ 2 ** $i;	
		}
	}
	
	return $value;
}