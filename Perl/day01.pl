#!/usr/bin/env perl
# --- Day 1: Report Repair ---

BEGIN {
    use Cwd;
    our $directory = cwd;
}

use lib $directory;

use Modern::Perl;
use autodie;
use Algorithm::Combinatorics 'combinations';

my $INPUT_PATH = './input';
my $INPUT_FILE = '01.challenge.txt';
my @input = parse_input("$INPUT_PATH/$INPUT_FILE");

solve_part_one(@input);

solve_part_two(@input);


exit( 0 );

sub parse_input {
	my $input_file = shift;
	
	open my $input, '<', $input_file or die "Failed to open input: $!";
	
	my @content;
	
	while ( my $line = <$input> ) {
		chomp $line;
		push( @content, $line );
	}
	
	close $input;
	
	return @content;
}

sub solve_part_one {
	# Find two numbers that add to 2020
	my @input = @_;
	
	my $iter = combinations(\@input, 2);
	
	while (my $combo = $iter->next) {
		if ($combo->[0] + $combo->[1] == 2020) {
			my $answer = $combo->[0] * $combo->[1];
			say 'Part One';
			say "The two numbers are $combo->[0] and $combo->[1], multiplying to $answer";
			return;
		}
	}
	say 'Could not find two numbers that add to 2020';
}

sub solve_part_two {
	# Find three numbers that add to 2020
	my @input = @_;
	
	my $iter = combinations(\@input, 3);
	
	while (my $combo = $iter->next) {
		if ($combo->[0] + $combo->[1] + $combo->[2] == 2020) {
			my $answer = $combo->[0] * $combo->[1] * $combo->[2];
			say 'Part Two';
			say "The three numbers are $combo->[0], $combo->[1] and $combo->[2], multiplying to $answer";
			return;
		}
	}
	say 'Could not find three numbers that add to 2020';
}
