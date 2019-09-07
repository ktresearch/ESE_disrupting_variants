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

	my $datafile = "$workdir/$cancertype[1]/permutationtest/ese_judge_pval_ks.txt";
	my $outputfile = "$workdir/$cancertype[1]/permutationtest/ese_judge_validation_ks.txt";
	open (OUTPUT, ">$outputfile");
	open (IN, "$datafile") || die $!;
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);
		my $status = "";
		if ($vals[2] =~ m/^chrX/ || $vals[2] =~ m/^chrY/) {
			print OUTPUT "$line\tsexchromosome\n";
			next;
		}
		elsif ($vals[10] < 10) {
			print OUTPUT "$line\tlowexpression\n";
			next;
		}
		elsif ($vals[24] > 0.05) {
			print OUTPUT "$line\tNotValidated\n";
			next;
		}
		else {
			print OUTPUT "$line\tValidated\n";
		}
	}
	close (IN);
	close (OUTPUT);
}



