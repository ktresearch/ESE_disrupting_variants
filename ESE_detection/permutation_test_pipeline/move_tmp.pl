#!/usr/bin/perl

use strict;

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
	#system "cp -r $workdir/junction_cancertype/$cancertype[1]/analysis_type1/normalized_data $workdir/junction_cancertype/$cancertype[1]/permutationtest";
	#system "mkdir $workdir/junction_cancertype/$cancertype[1]/permutationtest/ese_candidate";
	system "rm $workdir/junction_cancertype/$cancertype[1]/permutationtest/shuffle/shuffle_1.txt";
	system "rm $workdir/junction_cancertype/$cancertype[1]/permutationtest/shuffle/shuffle_2.txt";
	system "rm $workdir/junction_cancertype/$cancertype[1]/permutationtest/shuffle/shuffle_3.txt";	
#system "rm $workdir/junction_cancertype/$cancertype[1]/permutationtest/shuffle/shuffle_2.txt";
	#system "rm $workdir/junction_cancertype/$cancertype[1]/permutationtest/samplelist.txt";
}



