#!/usr/bin/env raku

constant TEMPLATE = 'aoc_template.swift';
constant TARGET = 'AoC2020/MyTool/Solutions/';
my $tag := '<##>';

sub MAIN(Int $day, Str $challenge_name) {
	my $filename = createSwiftFile($day, $challenge_name);
}

sub pad_day(Int $day) {
    '%02s'.sprintf($day);
}

sub createSwiftFile(Int $day, Str $challenge_name) {
	my $padded_day = pad_day($day);
	
	my $filename = "Day$padded_day.swift";
	!$filename.IO.e or die "File $filename already exists. Exiting.";

	my @lines = TEMPLATE.IO.lines;
	@lines = @lines.map(-> $line {
		my $temp = $line.subst("\"$tag\"", "\"$challenge_name\"", :g);
		$temp = $temp.subst($tag, $padded_day);
	});
	
	my $fh = open TARGET ~ $filename, :w;
	for @lines -> $line {
		$fh.say($line);
	}
	$fh.close;

    $filename
}
