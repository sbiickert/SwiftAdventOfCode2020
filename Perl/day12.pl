#!/usr/bin/env perl

BEGIN {
    use Cwd;
    our $directory = cwd;
}

use lib $directory;
use Modern::Perl;
use autodie;
use Data::Dumper;
#use Storable 'dclone';
use AOC::Geometry qw(Point2D Line2D);

package Ferry;
	use Moose;
	
	has 'pos' =>		(is => 'rw', isa => 'Point2D');
	has 'dir' =>		(is => 'rw', isa => 'Str');
	has 'waypoint' =>	(is => 'rw', isa => 'Point2D');
	
	sub drive {
		my $self = shift;
		my $instruction = shift;
		my ($dir, $val) = ($instruction =~ m/([NSEWLRF])(\d+)/);
		#say "$dir $val";
		if ($dir eq 'N')	{	$self->pos->move(0,  $val);	}
		elsif ($dir eq 'S')	{	$self->pos->move(0, -$val);	}
		elsif ($dir eq 'E')	{	$self->pos->move( $val, 0);	}
		elsif ($dir eq 'W')	{	$self->pos->move(-$val, 0);	}
		elsif ($dir eq 'F')	{	$self->drive($self->dir . $val);	}
		elsif ($dir eq 'L')	{	$self->turn( $val);	}
		elsif ($dir eq 'R')	{	$self->turn(-$val);	}
		#say $self->debugStr();
	}
	
	sub turn {
		my ($self, $val) = @_;
		my %dir_to_head = ('E' => 0, 'N' => 90, 'W' => 180, 'S' => 270);
		my %head_to_dir = (0 => 'E', 90 => 'N', 180 => 'W', 270 => 'S');
		my $heading = $dir_to_head{$self->dir};
		$heading += $val;
		while ($heading >= 360) { $heading -= 360; }
		while ($heading < 0)	{ $heading += 360; }
		$self->dir($head_to_dir{$heading});
	}
	
	sub navigate {
		my ($self, $instruction) = @_;
		my ($dir, $val) = ($instruction =~ m/([NSEWLRF])(\d+)/);
		#say "$dir $val";
		if ($dir eq 'N')	{	$self->waypoint->move(0,  $val);	}
		elsif ($dir eq 'S')	{	$self->waypoint->move(0, -$val);	}
		elsif ($dir eq 'E')	{	$self->waypoint->move( $val, 0);	}
		elsif ($dir eq 'W')	{	$self->waypoint->move(-$val, 0);	}
		elsif ($dir eq 'L')	{	$self->rotate_waypoint( $val);	}
		elsif ($dir eq 'R')	{	$self->rotate_waypoint(-$val);	}
		elsif ($dir eq 'F')	{
			for (my $i = 0; $i < $val; $i++) {
				$self->pos->move($self->waypoint->px, $self->waypoint->py);
			}
		}
		#say $self->debugStr();
	}
	
	sub rotate_waypoint {
		my ($self, $val) = @_;
		while ($val < 0)	{ $val += 360; }
		if ($val == 90)		{ 	my $tempx = $self->waypoint->px; 
								$self->waypoint->px(-$self->waypoint->py);
								$self->waypoint->py( $tempx);	}
		elsif ($val == 180)	{ 	$self->waypoint->px(-$self->waypoint->px);
								$self->waypoint->py(-$self->waypoint->py);	}
		elsif ($val == 270) { 	my $tempx = $self->waypoint->px; 
								$self->waypoint->px( $self->waypoint->py);
								$self->waypoint->py(-$tempx);	}
	}
	
	sub debugStr {
		my $self = shift;
		return "Ferry dir: " . $self->dir . " pos: " . $self->pos->debugStr();
	}
	
	no Moose;
__PACKAGE__->meta->make_immutable;


package main;

my $INPUT_PATH = './input';
my $INPUT_FILE = '12.challenge.txt';
my @input = parse_input("$INPUT_PATH/$INPUT_FILE");

solve_part_one(@input);
solve_part_two(@input);


exit( 0 );

sub parse_input {
	my $input_file = shift;
	
	open my $input, '<', $input_file or die "Failed to open input: $!";
	
	my @content;
	
	while (my $line = <$input>) {
		chomp $line;
		push(@content, $line);
	}
	
	close $input;
	
	return @content;
}

sub solve_part_one {
	my @input = @_;
	my $start = Point2D->new('px' => 0, 'py' => 0);
	my $ferry = Ferry->new('pos' => Point2D->new('px' => 0, 'py' => 0),
							'dir' => 'E');
	for my $instruction (@input) {
		$ferry->drive($instruction);
	}
	say $ferry->debugStr();
	
	my $line = Line2D->new('from' => $start, 'to' => $ferry->pos);
	say "The Manhattan distance from the start is " . $line->manhattan_distance();
}

sub solve_part_two {
	my @input = @_;
	my $start = Point2D->new('px' => 0, 'py' => 0);
	my $ferry = Ferry->new('pos' => Point2D->new('px' => 0, 'py' => 0),
							'dir' => 'E',
							'waypoint' => Point2D->new('px' => 10, 'py' => 1));
	for my $instruction (@input) {
		$ferry->navigate($instruction);
	}
	say $ferry->debugStr();
	
	my $line = Line2D->new('from' => $start, 'to' => $ferry->pos);
	say "The Manhattan distance from the start is " . $line->manhattan_distance();
}

