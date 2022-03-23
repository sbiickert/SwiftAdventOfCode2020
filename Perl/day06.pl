#!/usr/bin/env perl
#--- Day 6: Custom Customs ---

package Claim;
	use Moose;
	use Set::Scalar;
	
	has 'answers' => (is => 'ro', isa => 'ArrayRef[Str]');
	
	sub affirmatives {
		my $self = shift;
		my %uniques;
		for my $ans (@{$self->answers}) {
			for my $letter (split('', $ans)) {
				$uniques{$letter} = 1;
			}
		}
		return keys %uniques;
	}
	
	sub consensus {
		my $self = shift;
		my @answers = @{$self->answers};
		my @answer = sort split('', shift @answers);
		my $result = Set::Scalar->new(@answer);
		while (scalar @answers > 0) {
			@answer = sort split('', shift @answers);
			my $comp = Set::Scalar->new(@answer);
			$result = $result->intersection($comp);
		}
		return sort $result->elements;
	}
	
	no Moose;
__PACKAGE__->meta->make_immutable;

package main;

use Modern::Perl;
use autodie;
use Data::Dumper;
use Storable 'dclone';

my $INPUT_PATH = './input';
my $INPUT_FILE = '06.challenge.txt';
my @claims = parse_input("$INPUT_PATH/$INPUT_FILE");

solve_part_one();
solve_part_two();

exit( 0 );

sub parse_input {
	my $input_file = shift;
	
	open my $input, '<', $input_file or die "Failed to open input: $!";
	
	my @content;
	
	my @answers;
	
	while (my $line = <$input>) {
		chomp $line;
		if (!$line) {
			# Empty line, end of group's claim
			my $claim = Claim->new('answers' => dclone(\@answers));
			push(@content, $claim);
			@answers = ();
			next;
		}
		push(@answers, $line);
	}
	if (scalar(@answers) > 0) {
		my $claim = Claim->new('answers' => dclone(\@answers));
		push(@content, $claim);
	}
	
	close $input;
	
	return @content;
}

sub solve_part_one {
	my $count = 0;
	
	for my $claim (@claims) {
		$count += scalar $claim->affirmatives;
	}
	
	say 'Part One';
	say "There were $count total answers.";
}

sub solve_part_two {
	my $count = 0;
	
	for my $claim (@claims) {
		my @c = sort $claim->consensus;
		if (@c) {
			$count += scalar @c;
		}
	}
	
	say 'Part Two';
	say "There were $count questions where everyone in the group answered.";
}
