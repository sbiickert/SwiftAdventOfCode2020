#!/usr/bin/env perl

package Instruction;
	use Moose;
	
	has 'op' => 	(is => 'rw', isa => 'Str');
	has 'val' =>	(is => 'ro', isa => 'Int');
	
	sub flip_op {
		my $self = shift;
		if ($self->op eq 'nop') {
			$self->op('jmp');
		}
		elsif ($self->op eq 'jmp') {
			$self->op('nop');
		}
	}
	
	no Moose;
__PACKAGE__->meta->make_immutable;

package main;

use Modern::Perl;
use autodie;
use Data::Dumper;
use Storable 'dclone';

my $INPUT_PATH = './input';
#my $INPUT_FILE = '08.test.txt';
my $INPUT_FILE = '08.challenge.txt';
my @program = parse_input("$INPUT_PATH/$INPUT_FILE");

solve_part_one();
solve_part_two();

exit( 0 );

sub solve_part_one {
	my ($acc, @code_path) = run(@program);
	say 'Part One';
	say "Program was going to repeat instr at $code_path[-1]. acc is $acc.";
}

sub solve_part_two {
	my $step;
	my $ptr;
	my $instr;
	
	my ($acc, @code_path) = run(@program);
	$step = $#code_path; # the last run instruction, will use to count back along code path
	
	while ($code_path[-1] <= $#program) {
		# did not "go past the last instruction" and end successfully
		#say "Ended at $code_path[-1], trying again.";
		do {
			$step--;
			$ptr = $code_path[$step];
			$instr = $program[$ptr];
		} until ($instr->op eq 'nop' or $instr->op eq 'jmp');
		
		my @program_copy = @{dclone(\@program)};
		$instr->flip_op();
		($acc, @code_path) = run(@program_copy);
	}
	say 'Part Two';
	say "acc is $acc";
}

sub run {
	my @program = @_;
	my $acc = 0;
	my $ptr = 0;
	my @visited;
	
	while (1) {
		if (grep { $_ == $ptr } @visited or $ptr > $#program or $ptr < 0) {
			push(@visited, $ptr);
			last;
		}
		push(@visited, $ptr);
		
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
	
	return ($acc, @visited);
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
