#!/usr/bin/perl

use strict;

my $workdir = shift @ARGV;
my $cancertypefile = shift @ARGV;

my $outputfile = "$workdir/count_used_samples.txt";


my @cancertypelist = ();
open (IN, "$cancertypefile") || die $!;
while (my $line = <IN>) {
	chomp $line;
	my @vals = split(/\t/, $line);
	push @cancertypelist, "$vals[0]|$vals[1]";
}
close (IN);


open (OUTPUT, ">$outputfile");
print OUTPUT "cancertype\tnumber_of_used_samples\n";
foreach my $cancertype (@cancertypelist) {
	my @cancertype = split(/\|/, $cancertype);
	print "$workdir/$cancertype[1]/analysis_type1/totalreads_summary.txt\n";
	open (IN, "$workdir/$cancertype[1]/analysis_type1/totalreads_summary.txt") || die $!;
	my $count = 0;
	while (my $line = <IN>) {
		chomp $line;
		$count += 1;
	}
	print OUTPUT "$cancertype[1]\t$count\n";
	close (IN);
}
close (OUTPUT);
	

	



