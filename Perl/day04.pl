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
	
	sub is_valid {
		my $self = shift;
		return $self->is_complete() && $self->byr_is_valid() && $self->iyr_is_valid()
			&& $self->eyr_is_valid() && $self->hgt_is_valid() && $self->hcl_is_valid()
		 	&& $self->ecl_is_valid() && $self->pid_is_valid();
	}
	
	sub byr_is_valid {
		my $self = shift;
		return (1920 <= $self->byr && $self->byr <= 2002);
	}
	
	sub iyr_is_valid {
		my $self = shift;
		return (2010 <= $self->iyr && $self->iyr <= 2020);
	}
	
	sub eyr_is_valid {
		my $self = shift;
		return (2020 <= $self->eyr && $self->eyr <= 2030);
	}
	
	sub hgt_is_valid {
		my $self = shift;
		if ($self->hgt =~ m/(\d+)cm/) {
			return (150 <= $1 && $1 <= 193);
		}
		elsif ($self->hgt =~ m/(\d+)in/) {
			return (59 <= $1 && $1 <= 76);
		}
		return 0;
	}
	
	sub hcl_is_valid {
		my $self = shift;
		return $self->hcl =~ m/#[a-f0-9]{6}/;
	}
	
	sub ecl_is_valid {
		my $self = shift;
		my @valid_ecl = qw(amb blu brn gry grn hzl oth);
		return grep { $_ eq $self->ecl } @valid_ecl;
	}
	
	sub pid_is_valid {
		my $self = shift;
		return $self->pid =~ m/^\d{9}$/;
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

solve_part_one();
solve_part_two();


exit( 0 );

sub solve_part_one {
	my @complete_passports = grep { $_->is_complete() } @passports;
	my $complete_count = scalar @complete_passports;
	
	say 'Part One';
	say "The number of complete passports is $complete_count";
}

sub solve_part_two {
	my @valid_passports = grep { $_->is_valid() } @passports;
	my $valid_count = scalar @valid_passports;
	
	say 'Part Two';
	say "The number of valid passports is $valid_count";
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
		# Find key:value pairs on the line and push into hash
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
