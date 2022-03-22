#!/usr/bin/env perl
#--- Day 5: Binary Boarding ---

package BoardingPass;
	use Moose;
	
	has 'row' => (is => 'ro', isa => 'Int');
	has 'seat' => (is => 'ro', isa => 'Int');
	
	sub to_string {
		my $self = shift;
		return 'Row: ' . $self->row . ', Seat: ' . $self->seat . ', Seat ID: ' . $self->seat_id();
	}
	
	sub seat_id {
		my $self = shift;
		return $self->row * 8 + $self->seat;
	}
	
	no Moose;
__PACKAGE__->meta->make_immutable;

package main;

use Modern::Perl;
use autodie;
use Data::Dumper;
use List::Util 'max';

my $INPUT_PATH = './input';
my $INPUT_FILE = '05.challenge.txt';

my @passes = parse_input("$INPUT_PATH/$INPUT_FILE");

solve_part_one();
solve_part_two();

exit( 0 );

sub solve_part_one {
	my @seat_ids = map { $_->seat_id() } @passes;
	my $highest = max(@seat_ids);
	
	say 'Part One';
	say "The highest seat ID is $highest";
}

sub solve_part_two {
	my @seat_ids = sort map { $_->seat_id() } @passes;
	for (my $i = 0; $i < $#seat_ids; $i++) {
	
		if ($seat_ids[$i+1] - $seat_ids[$i] != 1) {
			say 'Part Two';
			say "My seat ID is " . ($seat_ids[$i]+1);
			return;
		}
	}
	say "fail.";
}

sub parse_input {
	my $input_file = shift;
	
	open my $input, '<', $input_file or die "Failed to open input: $!";
	
	my @content;
	
	while (my $line = <$input>) {
		chomp $line;
		my $pass = input_to_boarding_pass($line);
		push(@content, $pass);
	}
	
	close $input;
	
	return @content;
}

sub input_to_boarding_pass {
	my $line = shift;
	my $row_data = substr($line, 0, 7);
	my $seat_data = substr($line, -3, 3);
	#say "$row_data - $seat_data";
	$row_data = join('', map { $_ eq 'B' ? 1 : 0 } split('', $row_data));
	$seat_data = join('', map { $_ eq 'R' ? 1 : 0 } split('', $seat_data));
	#say "$row_data - $seat_data";
	my $pass = BoardingPass->new('row' => oct('0b'.$row_data), 'seat' => oct('0b'.$seat_data));
	return $pass;
}
