#!/usr/bin/perl

use strict;

my $workdir = shift @ARGV;
my $cancertypefile = shift @ARGV;

my $outputfile = "$workdir/All_validated_ese_ks.txt";


my @cancertypelist = ();
open (IN, "$cancertypefile") || die $!;
while (my $line = <IN>) {
	chomp $line;
	my @vals = split(/\t/, $line);
	push @cancertypelist, "$vals[0]|$vals[1]";
}
close (IN);


open (OUTPUT, ">$outputfile");
foreach my $cancertype (@cancertypelist) {
	my @cancertype = split(/\|/, $cancertype);
	open (IN, "$workdir/$cancertype[1]/analysis_type1/ese_judge_validation_ks.txt") || die $!;
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);
		if ($vals[25] eq "Validated") {
			print OUTPUT "$cancertype[1]\t$line\n";
		}
		else {
			next;
		}
	}
	close (IN);
}
close (OUTPUT);
	

	



