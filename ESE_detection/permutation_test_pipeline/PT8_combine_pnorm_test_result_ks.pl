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

	my @mean = ();
	my @sd = ();
	my @pval = ();
	my $pvalfile = "$workdir/$cancertype[1]/permutationtest/Rtest_result_ks.txt";
	open (IN, "$pvalfile") || die $!;
	my $lineid = 0;
	while (my $line = <IN>) {
		chomp $line;
		$lineid += 1;
		my @vals = split(/\t/, $line);
		push @mean, $vals[4];
		push @sd, $vals[5];
		push @pval, $vals[6];
	}
	close (IN);

	my $datafile = "$workdir/$cancertype[1]/permutationtest/ese_judge.txt";
	my $outputfile = "$workdir/$cancertype[1]/permutationtest/ese_judge_pval_ks.txt";
	open (OUTPUT, ">$outputfile");
	open (IN, "$datafile") || die $!;
	my $lineid = -1;
	while (my $line = <IN>) {
		chomp $line;
		$lineid += 1;
		print OUTPUT "$line\t$mean[$lineid]\t$sd[$lineid]\t$pval[$lineid]\n";
	}
	close (OUTPUT);
	close (IN);
}

