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
#use Data::Dumper;
#use List::MoreUtils qw(uniq);
use bigint;

use AOC::Util;
#use AOC::SpatialUtil;

my $INPUT_PATH = './input';
#my $INPUT_FILE = '14.test1.txt';
#my $INPUT_FILE = '14.test2.txt';
my $INPUT_FILE = '14.challenge.txt';
my @input = read_input("$INPUT_PATH/$INPUT_FILE");

say "Advent of Code 2020, Day 14: Docking Data";

solve(@input);

exit( 0 );

sub solve {
	my @input = @_;
	my %memory1 = ();
	my %memory2 = ();
	my @mask;
	
	for my $line (@input) {
		if ( $line =~ m/^mask = ([X01]+)/ ) {
			my $pattern = $1;
			@mask = ();
			for my $char (split('', $pattern)) {
				unshift(@mask, $char);
			}
		}
		elsif ( $line =~ m/^mem\[(\d+)\] = (\d+)/ ) {
			my $addr = $1;
			my $val = $2;
			
			# Part 1
			my $decoded = decode_version_1($val, @mask);
			$memory1{$addr} = $decoded;
			
			# Part 2
			my @addresses = decode_version_2($addr, @mask);
			for my $a (@addresses) {
				$memory2{$a} = $val;
			}
		}
	}
	
	my $sum = 0;
	for my $key ( keys %memory1 ) {
		$sum += $memory1{$key};
	}
	say "Part 1: The sum of the memory values is $sum";
	
	$sum = 0;
	for my $key ( keys %memory2 ) {
		$sum += $memory2{$key};
	}
	say "Part 2: The sum of the memory values is $sum";
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

sub decode_version_2 {
	# value is an int
	# mask is an array of 1's, 0's and X's, but reversed
	# so the least significant bit is first
	my ($value, @mask) = @_;
	my @results = ();
	
	# Set the 1's
	for (my $i = 0; $i <= $#mask; $i++) {
		if ($mask[$i] == 1) {
			$value |= 2 ** $i;	
		}
	}
	
	# Going to convert value into array, with least sig bit first
	my @value_array = reverse split('', sprintf('%036b', $value));
	
	# Get the floating bits
	my @x_indexes = ();
	for (my $i = 0; $i <= $#mask; $i++) {
		if ($mask[$i] eq 'X') { push( @x_indexes, $i ); }
	}
	my $count = scalar grep(/X/, @mask);
	
	# Get the ones and zeros to substitute
	my @nums = ();
	for (my $n = 0; $n < 2 ** $count; $n++) {
		my @bits = reverse split('', sprintf('%0'.$count.'b', $n));
		push(@nums, \@bits);
	}
	
	my @value_array_copy;
	for my $b_ref (@nums) {
		@value_array_copy = @value_array;
		for (my $i = 0; $i <= $#x_indexes; $i++) {
			my $x_index = $x_indexes[$i];
			$value_array_copy[$x_index] = $b_ref->[$i];
		}
		my $result = oct('0b' . join('', reverse(@value_array_copy)));
		push( @results, $result );
	}
	
	return @results;
}