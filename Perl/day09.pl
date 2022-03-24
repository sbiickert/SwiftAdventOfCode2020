#!/usr/bin/env perl

package main;

use Modern::Perl;
use autodie;
use Data::Dumper;
use Algorithm::Combinatorics 'combinations';
use List::Util 'reduce';

my $INPUT_PATH = './input';
#my $INPUT_FILE = '09.test.txt';
my $INPUT_FILE = '09.challenge.txt';
my @input = parse_input("$INPUT_PATH/$INPUT_FILE");

my $PREAMBLE_SIZE = 25;

my $invalid_number = solve_part_one(@input);
solve_part_two($invalid_number, @input);

exit( 0 );

sub solve_part_one {
	my @input = @_;
	my @numbers = splice(@input, 0, $PREAMBLE_SIZE);
	for my $n (@input) {
		if (!find_two_numbers_adding_to($n, \@numbers)) {
			say 'Part One';
			say "$n is an invalid number.";
			return $n;
		}
		shift @numbers;
		push(@numbers, $n);
	}
	return -1;
}

sub solve_part_two {
	my ($invalid_number, @input) = @_;
	my @range = find_range_adding_to($invalid_number, \@input);
	#say join(',', @range);
	my @slice = sort {$a <=> $b} @input[$range[0]..$range[1]];
	#say join(',', @slice);
	my $weakness = $slice[0] + $slice[-1];
	
	say 'Part Two';
	say "The encryption weakness is $weakness.";
}

sub find_two_numbers_adding_to {
	my ($sum, $numbers_ref) = @_;
	#say "looking for 2 numbers adding to $sum in " . join(',', @{$numbers_ref});
	my $iter = combinations($numbers_ref, 2);
	while (my $combo = $iter->next) {
		return 1 if (($combo->[0] + $combo->[1] == $sum) and ($combo->[0] != $combo->[1]));
	}
	say 'failed to find 2 numbers';
	return 0;
}

sub find_range_adding_to {
	my ($sum, $numbers_ref) = @_;
	my @numbers = @$numbers_ref;
	
	for my $i (0..$#numbers) {
		for my $j ($i+1..$#numbers) {
			my @range = @numbers[$i..$j];
			my $sum_of_range = reduce {$a + $b} @range;
			last if $sum_of_range > $sum;
			return ($i, $j) if ($sum_of_range == $sum);
		}
	}
	say 'failed to find range';
	return (0,0);
}

sub parse_input {
	my $input_file = shift;
	
	open my $input, '<', $input_file or die "Failed to open input: $!";
	
	my @content;
	
	while (my $line = <$input>) {
		chomp $line;
		push(@content, $line+0);
	}
	
	close $input;
	
	return @content;
}
