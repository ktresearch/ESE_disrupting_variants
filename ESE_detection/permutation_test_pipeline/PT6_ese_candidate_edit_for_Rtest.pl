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


	my $inputfile = "$workdir/$cancertype[1]/permutationtest/ese_judge.txt";
	my $outputfile = "$workdir/$cancertype[1]/permutationtest/ese_judge_for_Rtest.txt";
	open (IN, "$inputfile") || die $!;
	open (OUTPUT, ">$outputfile") || die $!;
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);
		print OUTPUT "$vals[0]\t$vals[1]\t$vals[2]\t$vals[10]\t";
		my @samples = split(/\|/, $vals[21]);
		my $outputline = "";
		foreach my $sample (@samples) {
			my @info = split(/,/, $sample);
			$outputline .= "$info[1],";
		}
		$outputline =~ s/,$//;
 		print OUTPUT "$outputline\n";
	}
	close (IN);
	close (OUTPUT);
}

