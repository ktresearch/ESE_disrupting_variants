#!/usr/bin/perl

use strict;
use List::Util qw(shuffle);

my $cancertypefile = shift @ARGV;
my $workdir = shift @ARGV;
my $exonskipfile = shift @ARGV;

my @cancertypelist = ();
open (IN, "$cancertypefile") || die $!;
while (my $line = <IN>) {
	chomp $line;
	my @vals = split(/\t/, $line);
	push @cancertypelist, "$vals[0]|$vals[1]";
}
close (IN);

my @exonskipdata = ();
open (IN, "$exonskipfile") || die $!;
while (my $line = <IN>) {
	chomp $line;
	push @exonskipdata, $line;
}
close (IN);

foreach my $cancertype (@cancertypelist) {
	my @cancertype = split(/\|/, $cancertype);
	
	system "mkdir $workdir/$cancertype[1]/permutationtest/skip_data";

	my $datadir = "$workdir/$cancertype[1]/permutationtest";
	my $samplelistfile = "$datadir/samplelist.txt";
	my $datafile = "$datadir/var_rpkm_merge.txt";	

	my @samplelist = ();
	my %var;
	my %rpkm1;
	my %rpkm2;
	my %rpkm3;
	my %rpkm4;
	my %define;

	open (IN, "$samplelistfile") || die $!;
	while (my $line = <IN>) {
		chomp $line;
		push @samplelist, $line;
	}
	close (IN);

	open (IN, "$datafile") || die $!;
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);
		$var{$vals[0]}->{$vals[1]} = "$vals[2]\t$vals[3]";
		$rpkm1{$vals[0]}->{$vals[1]} = $vals[4];
		$rpkm2{$vals[0]}->{$vals[1]} = $vals[5];
		$rpkm3{$vals[0]}->{$vals[1]} = $vals[6];
		$rpkm4{$vals[0]}->{$vals[1]} = $vals[7];
		$define{$vals[0]}->{$vals[1]} = 1;
	}

	my @rand_samplelist = shuffle(@samplelist);
	my $samplenum = @samplelist;
	my $outputdir = "$workdir/$cancertype[1]/permutationtest/skip_data";

	my $shufflefile = "$datadir/shuffle.txt";
	open (OUTPUT, ">$shufflefile");
	for (my $i = 0; $i < $samplenum; $i += 1) {
		print OUTPUT "$samplelist[$i]\t$rand_samplelist[$i]\n";
	}
	close (OUTPUT);

	for (my $i = 0; $i < $samplenum; $i += 1) {
		my $outputfile = "${samplelist[$i]}_skip.txt";
		open (OUTPUT, ">$outputdir/$outputfile");
		my $lineid = 0;
		foreach my $line (@exonskipdata) {
			$lineid += 1;
			my @vals = split(/\t/, $line);
			if ($define{$samplelist[$i]}->{$lineid} == 1) {
				print OUTPUT "$vals[0]\t$vals[1]\t$vals[2]\t$vals[3]\t$vals[4]\t";
				print OUTPUT "$var{$samplelist[$i]}->{$lineid}\t";
				print OUTPUT "$vals[5]\t$vals[6]\t$rpkm1{$rand_samplelist[$i]}->{$lineid}\t";
				print OUTPUT "$vals[7]\t$vals[8]\t$rpkm2{$rand_samplelist[$i]}->{$lineid}\t";
				print OUTPUT "$vals[9]\t$vals[10]\t$rpkm3{$rand_samplelist[$i]}->{$lineid}\t";
				print OUTPUT "$rpkm4{$rand_samplelist[$i]}->{$lineid}\n";
			}
			else {
				next;
			}
		}
		close (OUTPUT);
	}
}
			


	

