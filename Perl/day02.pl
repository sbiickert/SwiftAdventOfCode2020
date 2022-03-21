#!/usr/bin/env perl
#--- Day 2: Password Philosophy ---

BEGIN {
    use Cwd;
    our $directory = cwd;
}
use lib $directory;

# Trivial OO solution to what can be done non-OO, just for giggles
package PwdPolicy;
	use Moose;
	
	has 'val1' => 	(is => 'ro', isa => 'Int');
	has 'val2' => 	(is => 'ro', isa => 'Int');
	has 'letter' =>	(is => 'ro', isa => 'Str');
	has 'pwd' => 	(is => 'ro', isa => 'Str');
	
	sub isValid {
		my ($self, $part) = @_;
		if ($part == 1) {
			# letter must be in the pwd between val1 and val2 times
			my @matches = grep { $_ eq $self->letter } split('', $self->pwd);
			my $count = scalar @matches;
			return 1 if ($self->val1 <= $count && $count <= $self->val2);
		}
		else {
			# exactly one letter in pwd at positions val1 and val2 can match letter
			my @letters = split('', $self->pwd);
			# indexes in val1 and val2 are 1-based
			unshift(@letters, '');
			return 1 if ($letters[$self->val1] eq $self->letter xor $letters[$self->val2] eq $self->letter);
		}
		return 0;
	}
	
	no Moose;
__PACKAGE__->meta->make_immutable;
	
	
package main;

use Modern::Perl;
use autodie;
use Data::Dumper;
#use Storable 'dclone';

my $INPUT_PATH = './input';
my $INPUT_FILE = '02.challenge.txt';
my @input = parse_input("$INPUT_PATH/$INPUT_FILE");

solve_part(1, @input);
solve_part(2, @input);

exit( 0 );

sub parse_input {
	my $input_file = shift;
	
	open my $input, '<', $input_file or die "Failed to open input: $!";
	
	my @content;
	while (my $line = <$input>) {
		if ( $line =~ m/(\d+)-(\d+) (\w): (\w+)/ ) {
			my $pp = PwdPolicy->new('val1' => $1, 'val2' => $2, 'letter' => $3, 'pwd' => $4);
			push( @content, $pp );
		}
		else {
			die "Could not parse $line";
		}
	}
	
	close $input;
	
	return @content;
}

sub solve_part {
	my $part = shift;
	my @input = @_;
	
	my $valid_count = 0;
	for my $pp (@input) {
		if ($pp->isValid($part)) {
			#say "Password $pp->pwd is valid.";
			$valid_count++;
		}
	}
	say "Part $part";
	say "The number of valid passwords is $valid_count";
}
