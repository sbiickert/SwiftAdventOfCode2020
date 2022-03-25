#!/usr/bin/env perl
BEGIN {
    use Cwd;
    our $directory = cwd;
}

use lib $directory;

package main;

use Modern::Perl;
use autodie;
use Data::Dumper;
use Storable 'dclone';
use AOC::Grid qw(Grid2D);
$AOC::Grid::neighbor_rule = 'queen';

my $INPUT_PATH = './input';
#my $INPUT_FILE = '11.test.txt';
my $INPUT_FILE = '11.challenge.txt';
my $grid = parse_input("$INPUT_PATH/$INPUT_FILE");
#$grid->draw();

solve_part_one($grid);
solve_part_two($grid);


exit( 0 );

sub solve_part_one {
	my $grid = dclone(shift);
	my $gcopy = Grid2D->new('width' => $grid->width, 'height' => $grid->height,
						    'default' => '.', 'data' => []);
	
	my $iter_count = 0;
	while (1) {
		$iter_count++;
		for my $cref ($grid->coords()) {
			my @coord = @$cref;
			my $val = $grid->get(@coord);
			next if $val eq '.';
			if ($val eq 'L') {
				if ($grid->count_neighbors_with('#', @coord) == 0) {
					$gcopy->set('#', @coord);
				}
			}
			elsif ($val eq '#') {
				if ($grid->count_neighbors_with('#', @coord) >= 4) {
					$gcopy->set('L', @coord);
				}
			}
		}
		#$gcopy->draw();
		last if ($grid->equals($gcopy));
		$grid = dclone($gcopy);
	}
	
	say 'Part One';
	say "The seating stopped changing at iteration $iter_count";
	say $grid->count_with('#') . ' seats are filled.';
}

sub solve_part_two {
	my $grid = dclone(shift);
	my $gcopy = Grid2D->new('width' => $grid->width, 'height' => $grid->height,
						    'default' => '.', 'data' => []);
	
	my $iter_count = 0;
	while (1) {
		$iter_count++;
		for my $cref ($grid->coords()) {
			my @coord = @$cref;
			my $val = $grid->get(@coord);
			next if $val eq '.';
			if ($val eq 'L') {
				if (count_line_of_sight_with($grid, '#', @coord) == 0) {
					$gcopy->set('#', @coord);
				}
			}
			elsif ($val eq '#') {
				if (count_line_of_sight_with($grid, '#', @coord) >= 5) {
					$gcopy->set('L', @coord);
				}
			}
		}
		#$gcopy->draw();
		last if ($grid->equals($gcopy));
		$grid = dclone($gcopy);
	}
	
	say 'Part One';
	say "The seating stopped changing at iteration $iter_count";
	say $grid->count_with('#') . ' seats are filled.';
}

	
sub count_line_of_sight_with {
	my ($grid, $value, $row, $col) = @_;
	my $count = 0;
	for my $o ($grid->neighbor_offsets($row, $col)) {
		my @offset;
		$offset[0] = $$o[0];
		$offset[1] = $$o[1];
		my $v = $grid->get($row+$offset[0], $col+$offset[1]);
		while ($v eq '.' and $row+$offset[0] >= 0 and $col+$offset[1] >= 0 
			and $row+$offset[0] < $grid->height and $col+$offset[1] < $grid->width) {
			$offset[0] += $$o[0];
			$offset[1] += $$o[1];
			$v = $grid->get($row+$offset[0], $col+$offset[1]);
		}
		$count++ if ($v eq $value);
	}
	return $count;
}


sub parse_input {
	my $input_file = shift;
	
	open my $input, '<', $input_file or die "Failed to open input: $!";
	my @content = <$input>;
	close $input;
	
	my $grid = Grid2D->new('width' => length($content[0])-1, 'height' => scalar(@content),
						   'default' => '.', 'data' => []);
	
	for (my $r = 0; $r <= $#content; $r++) {
		my $row = $content[$r];
		chomp $row;
		my @row_values = split('', $row);
		for (my $c = 0; $c <= $#row_values; $c++) {
			$grid->set($row_values[$c], $r, $c);
		}
	}
	return $grid;
}
