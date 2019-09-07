#!/usr/bin/perl

use strict;
use warnings;
#use List::Util qw(shuffle);

my $cancertypefile = "../TCGA_cancertype_list.txt";
my $dir = "../permutation_results";
my $outputfile = "../permutation_test_results_summary.txt";

my @cancertypelist = ();
open (IN, "$cancertypefile") || die $!;
while (my $line = <IN>) {
	chomp $line;
	my @vals = split(/\t/, $line);
	push @cancertypelist, $vals[1];
}
close (IN);

opendir (DIR, "$dir");
my @files = readdir(DIR);
closedir (DIR);

open (OUTPUT, ">$outputfile");
print OUTPUT "iteration\ttotal_number_of_detected_ese\t";
foreach my $cancertype (@cancertypelist) {
	print OUTPUT "$cancertype\t";
}
print OUTPUT "\n";

foreach my $file (@files) {
	if ($file =~ m/^\./) {
		next;
	}	
	open (IN, "$dir/$file");
	my %esevar;
	my %cancertype;
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);
		my @vars = split(/\|/, $vals[7]);
		foreach my $var (@vars) {
			$esevar{$var} = 1;
			$cancertype{$var} = $vals[0];
		}
	}
	close (IN);
	my $total = 0;
	my %count;
	foreach my $var (keys %esevar) {
		$total += 1;
		$count{$cancertype{$var}} += 1;
	}
	my @name = split(/\_/, $file);
	my $iteration = $name[5];
	$iteration =~ s/\.txt//;
	print OUTPUT "$iteration\t$total\t";
	foreach my $cancertype (@cancertypelist) {
		print OUTPUT "$count{$cancertype}\t";
	}
	print OUTPUT "\n";
}
close (OUTPUT);


		
