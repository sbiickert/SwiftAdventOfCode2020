#!/usr/bin/env perl
# --- Day 4: Passport Processing ---

package Passport;
	use Moose;
	
	has 'byr' => (is => 'ro', isa => 'Int'); # (Birth Year)
	has 'iyr' => (is => 'ro', isa => 'Int'); # (Issue Year)
	has 'eyr' => (is => 'ro', isa => 'Int'); # (Expiration Year)
	has 'hgt' => (is => 'ro', isa => 'Str'); # (Height)
	has 'hcl' => (is => 'ro', isa => 'Str'); # (Hair Color)
	has 'ecl' => (is => 'ro', isa => 'Str'); # (Eye Color)
	has 'pid' => (is => 'ro', isa => 'Str'); # (Passport ID)
	has 'cid' => (is => 'ro', isa => 'Int'); # (Country ID)
	
	sub is_complete {
		my $self = shift;
		return $self->byr != -1 && $self->iyr != -1 && $self->eyr != -1 &&
				$self->hgt ne '' && $self->hcl ne '' && $self->ecl ne '' &&
				$self->pid ne '';
	}
	
	no Moose;
__PACKAGE__->meta->make_immutable;

package main;

use Modern::Perl;
use autodie;
use Data::Dumper;

my $INPUT_PATH = './input';
my $INPUT_FILE = '04.challenge.txt';
my @passports = parse_input("$INPUT_PATH/$INPUT_FILE");

solve_part_one(@passports);
solve_part_two(@passports);


exit( 0 );

sub solve_part_one {
	my $complete_count = 0;
	
	for my $passport (@passports) {
		$complete_count++ if $passport->is_complete();
	}
	
	say 'Part One';
	say "The number of complete passports is $complete_count";
}

sub solve_part_two {
}

sub parse_input {
	my $input_file = shift;
	
	open my $input, '<', $input_file or die "Failed to open input: $!";
	
	my @passports;
	my %values;
	
	while ( my $line = <$input> ) {
		chomp $line;
		if (!$line) {
			# empty line, passport is done
			push(@passports, hash_to_passport(\%values));
			%values = ();
			next;
		}
		while ($line =~ m/([a-z]{3}):(\S+)/g) {
			$values{$1} = $2;
		}
	}
	
	if (scalar(keys(%values)) > 0) {
		push(@passports, hash_to_passport(\%values));
	}
	
	close $input;
	
	return @passports;
}

sub hash_to_passport {
	my $vref = shift;
	my $passport = Passport->new('byr' => ($vref->{'byr'} or -1),
								 'iyr' => ($vref->{'iyr'} or -1),
								 'eyr' => ($vref->{'eyr'} or -1),
								 'hgt' => ($vref->{'hgt'} or ''),
								 'hcl' => ($vref->{'hcl'} or ''),
								 'ecl' => ($vref->{'ecl'} or ''),
								 'pid' => ($vref->{'pid'} or ''),
								 'cid' => ($vref->{'cid'} or -1));
	return $passport;
}
