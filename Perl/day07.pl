#!/usr/bin/env perl
#--- Day 7: Handy Haversacks ---

package main;

use Modern::Perl;
use autodie;
use Data::Dumper;
use Set::Scalar;

my $INPUT_PATH = './input';
#my $INPUT_FILE = '07.test1.txt';
#my $INPUT_FILE = '07.test2.txt';
my $INPUT_FILE = '07.challenge.txt';

my $SHINY_GOLD = 'shiny gold';

my %content_of;
my %containers_of;
parse_input("$INPUT_PATH/$INPUT_FILE");

solve_part_one();
solve_part_two();


exit( 0 );

sub solve_part_one {
	my $color_set = Set::Scalar->new();
	count_containers($SHINY_GOLD, $color_set);
	my $count = $color_set->size;
	
	say 'Part One';
	say "$SHINY_GOLD bags can be contained by $count bag colors";
}

sub count_containers {
	my ($color, $color_set) = @_;
	return if (!exists $containers_of{$color});
	my @c = @{$containers_of{$color}};
	for my $container (@c) {
		#say "$color contained by $container";
		$color_set->insert($container);
		count_containers($container, $color_set);
	}
}

sub solve_part_two {
	my $count = count_bags($SHINY_GOLD);
	
	say 'Part Two';
	say "$SHINY_GOLD bags contain $count bags";
	
}

sub count_bags {
	my $color = shift;
	
	# %contents has color names as keys and the number of bags as values
	my %contents = %{$content_of{$color}};	
	my $count = 0;
	for my $content (keys %contents) {
		$count += $contents{$content};
		$count += (count_bags($content) * $contents{$content});
	}
	return $count;
}

sub parse_input {
	my $input_file = shift;
	
	open my $input, '<', $input_file or die "Failed to open input: $!";
	
	while (my $line = <$input>) {
		chomp $line;
		my ($container, $content_str) = split(' bags contain ', $line, 2);
		my %contents;
		while ($content_str =~ m/(\d+) ([a-z ]+) bag/g) {
			$containers_of{$2} = [] if (!exists $containers_of{$2});
			push(@{$containers_of{$2}}, $container);
			$contents{$2} = $1;
		}
		$content_of{$container} = \%contents;
	}
	
	close $input;
	
	return %content_of;
}
