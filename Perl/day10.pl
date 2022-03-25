#!/usr/bin/env perl
#--- Day 10: Adapter Array ---

package main;

use Modern::Perl;
use autodie;
#use Data::Dumper;

my $INPUT_PATH = './input';
#my $INPUT_FILE = '10.test.txt';
my $INPUT_FILE = '10.challenge.txt';
my @joltages = parse_input("$INPUT_PATH/$INPUT_FILE");

my @LIMITS = (1,3); # Min, max delta J

push(@joltages, $joltages[-1] + $LIMITS[1]);

solve_part_one(@joltages);
solve_part_two(@joltages);

exit( 0 );

sub solve_part_one {
	my @input = @_;
	my @diffs;
	my $last_joltage = 0; # the seat outlet
	for my $joltage (@input) {
		my $diff = $joltage - $last_joltage;
		if ($diff >= $LIMITS[0] && $diff <= $LIMITS[1]) {
			push(@diffs, $diff);
		}
		$last_joltage = $joltage;
	}
	my %counts;
	for my $diff (@diffs) {
		$counts{$diff}++;
	}
	my $product = $counts{1} * $counts{3};
	
	say 'Part One';
	say "There are $counts{1} diffs of 1 and $counts{3} diffs of 3. Product: $product";
}

sub solve_part_two {
	my @input = @_;
	my %sol = (0 => 1);
	for my $joltage (@input) {
		$sol{$joltage} = 0;
		
		if (exists($sol{$joltage-1})) {
			$sol{$joltage} += $sol{$joltage-1};
		}
		if (exists($sol{$joltage-2})) {
			$sol{$joltage} += $sol{$joltage-2};
		}
		if (exists($sol{$joltage-3})) {
			$sol{$joltage} += $sol{$joltage-3}
		}
	}
	
	say 'Part Two';
	say "Found $sol{$input[-1]} possible adapter combinations";
}

sub parse_input {
	my $input_file = shift;
	
	open my $input, '<', $input_file or die "Failed to open input: $!";
	
	my @content;
	
	while (my $line = <$input>) {
		chomp $line;
		push(@content, $line + 0);
	}
	
	close $input;
	
	return sort { $a <=> $b } @content;
}
