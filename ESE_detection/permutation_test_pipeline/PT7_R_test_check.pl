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

	my $outputfile = "$workdir/TCGA_cancertype_list_for_permutationtest.txt";
	open (OUTPUT, ">$outputfile");

foreach my $cancertype (@cancertypelist) {
	my @cancertype = split(/\|/, $cancertype);

	my $inputfile = "$workdir/$cancertype[1]/permutationtest/ese_judge_for_Rtest.txt";

	open (IN, "$inputfile") || die $!;
	while (my $line = <IN>) {
		chomp $line;
		if ($line =~ m/\w+/) {
			print OUTPUT "$cancertype[0]\t$cancertype[1]\n";
			last;
		}
		else {
			next;
		}
	}
	close (IN);
}
close (OUTPUT);

