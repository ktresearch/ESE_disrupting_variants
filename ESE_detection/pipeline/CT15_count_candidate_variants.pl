#!/usr/bin/perl

use strict;

my $workdir = shift @ARGV;
my $cancertypefile = shift @ARGV;
my $outputfile = "$workdir/count_candidate_variants.txt";


my @cancertypelist = ();
open (IN, "$cancertypefile") || die $!;
while (my $line = <IN>) {
	chomp $line;
	my @vals = split(/\t/, $line);
	push @cancertypelist, "$vals[0]|$vals[1]";
}
close (IN);


open (OUTPUT, ">$outputfile");
print OUTPUT "cancertype\tnumber_of_candidate_variants\n";
foreach my $cancertype (@cancertypelist) {
	my @cancertype = split(/\|/, $cancertype);
	open (IN, "$workdir/$cancertype[1]/analysis_type1/ese_judge_all.txt") || die $!;
	my %var = ();
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);
		my @variants = split(/\|/, $vals[6]);
		foreach my $variant (@variants) {
			$var{$variant} = 1;
		}
	}
	my $count = 0;
	foreach my $i (keys %var) {
		$count += 1;
	}
	print OUTPUT "$cancertype[1]\t$count\n";
	close (IN);
}
close (OUTPUT);
	

	



