#!/usr/bin/perl

use strict;
use List::Util qw(shuffle);

my $cancertypefile = shift @ARGV;
my $workdir = shift @ARGV;


my @cancertypelist = ();
open (IN, "$cancertypefile") || die $!;
while (my $line = <IN>) {
	chomp $line;
	my @vals = split(/\t/, $line);
	push @cancertypelist, "$vals[0]|$vals[1]";
}
close (IN);

foreach my $cancertype (@cancertypelist) {
	my @cancertype = split(/\|/, $cancertype);

	my $shufflefile = "$workdir/$cancertype[1]/permutationtest/shuffle.txt";
	my %filename;
	open (IN, "$shufflefile") || die $!;
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);
		my $ori = "TMP_${vals[0]}_T_normalize";
		my $change = "${vals[1]}_T_normalize";
		$filename{$ori} = $change;
	}
	close (IN);	

	my $datadir = "$workdir/$cancertype[1]/permutationtest/normalized_data";
	opendir (DIR, "$datadir");
	my @files = readdir(DIR);
	closedir (DIR);

	foreach my $file (@files) {
		if ($file =~ m/^\./) {
			next;
		}
		else {
			system "mv $workdir/$cancertype[1]/permutationtest/normalized_data/$file $workdir/$cancertype[1]/permutationtest/normalized_data/TMP_${file}"; 	
		}
	}

	foreach my $file (keys %filename) {
		system "mv $workdir/$cancertype[1]/permutationtest/normalized_data/$file $workdir/$cancertype[1]/permutationtest/normalized_data/$filename{$file}";
	}
}


