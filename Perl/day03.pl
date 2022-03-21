#!/usr/bin/env perl
#--- Day 3: Toboggan Trajectory ---

BEGIN {
    use Cwd;
    our $directory = cwd;
}

use lib $directory;

package ForestMap;
	use Moose;

	has 'map' => (is => 'rw', isa => 'ArrayRef[ArrayRef[Str]]');
	
	sub width {
		my $self = shift;
		return scalar @{$self->map->[0]};
	}
	
	sub height {
		my $self = shift;
		return scalar @{$self->map};
	}
	
	sub is_tree_at {
		my ($self, $row, $col) = @_;
		my $adjusted_col = $col % $self->width; #use modulus to repeat map in x direction
		return ($self->map->[$row][$adjusted_col] eq '#');
	}

	no Moose;
__PACKAGE__->meta->make_immutable;

package main;

use Modern::Perl;
use autodie;
use Data::Dumper;
use List::Util 'reduce';
use AOC::Geometry qw(Point2D);

my $INPUT_PATH = './input';
#my $INPUT_FILE = '03.test.txt';
my $INPUT_FILE = '03.challenge.txt';
my $forest = parse_input("$INPUT_PATH/$INPUT_FILE");

my $HEIGHT = $forest->height();

solve_part_one();
solve_part_two();

exit( 0 );

sub parse_input {
	my $input_file = shift;
	
	open my $input, '<', $input_file or die "Failed to open input: $!";
	
	my $forest = ForestMap->new('map' => []);
	
	my $r = 0;
	while (my $row = <$input>) {
		chomp $row;
		my @letters = split('', $row);
		for (my $c = 0; $c <= $#letters; $c++) {
			$forest->map->[$r][$c] = $letters[$c];
		}
		$r++;
	}
	
	close $input;
	return $forest;
}

sub solve_part_one {
	my $dx = 3;
	my $dy = 1;
	
	my $tree_count = traverse($dx, $dy);
	say 'Part One';
	say "Impacted $tree_count trees.";
}

sub solve_part_two {
	my @tree_counts;
	for my $d ([1,1], [3,1], [5,1], [7,1], [1,2]) {
		push(@tree_counts, traverse(@$d));
	}
	say 'Part Two';
	say 'Impacted ' . join(', ', @tree_counts) . ' trees.';
	my $product = reduce { $a * $b } 1, @tree_counts;
	say "Product is $product";
}

sub traverse {
	my ($dx, $dy) = @_;
	
	my $pos = Point2D->new('px' => 0, 'py' => 0);
	
	my $tree_count = 0;
	while ($pos->py < $HEIGHT) {
		$tree_count++ if $forest->is_tree_at($pos->py, $pos->px);
		$pos->px($pos->px + $dx);
		$pos->py($pos->py + $dy);
	}
	return $tree_count;	
}
