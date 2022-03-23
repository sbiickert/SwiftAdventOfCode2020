#!/usr/bin/env perl
BEGIN {
    use Cwd;
    our $directory = cwd;
}

use lib $directory;

package Instruction;
	use Moose;
	
	has 'op' => 	(is => 'ro', isa => 'Str');
	has 'val' =>	(is => 'ro', isa => 'Int');
	
	no Moose;
__PACKAGE__->meta->make_immutable;

package main;

use Modern::Perl;
use autodie;
use Data::Dumper;
use Set::Scalar;
#use AOC::Geometry qw(Point2D Line2D);

my $INPUT_PATH = './input';
my $INPUT_FILE = '08.test.txt';
#my $INPUT_FILE = '08.challenge.txt';
my @program = parse_input("$INPUT_PATH/$INPUT_FILE");

solve_part_one();
#solve_part_two();


exit( 0 );

sub solve_part_one {
	my ($ptr, $acc) = run(@program);
	say 'Part One';
	say "Program was going to repeat instr at $ptr. acc is $acc.";
}

sub solve_part_two {
}

sub run {
	my @program = @_;
	my $acc = 0;
	my $ptr = 0;
	my $visited = Set::Scalar->new();
	
	while (1) {
		last if $visited->contains($ptr);
		last if $ptr > $#program;
		$visited->insert($ptr);
		my $instr = $program[$ptr];
		if ($instr->op eq 'nop') {
			$ptr++;
		}
		elsif ($instr->op eq 'jmp') {
			$ptr += $instr->val;
		}
		else {
			$acc += $instr->val;
			$ptr++;
		}
	}
	
	return ($ptr, $acc);
}

sub parse_input {
	my $input_file = shift;
	
	open my $input, '<', $input_file or die "Failed to open input: $!";
	
	my @content;
	
	while (my $line = <$input>) {
		chomp $line;
		if ( $line =~ m/(\w+) \+?(-?\d+)/ ) {
			my $instr = Instruction->new('op' => $1, 'val' => $2);
			push(@content, $instr);
		}
	}
	
	close $input;
	
	return @content;
}
