#!/usr/bin/perl

use strict;

my $workdir = shift @ARGV;
my $cancertypefile = shift @ARGV;
my $outputsummary = "totalreads_summary.txt";


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
	my $datadir = "$workdir/$cancertype[1]/analysis_type1/data_type1";
	system "mkdir $workdir/$cancertype[1]/analysis_type1/normalized_data";	
	my $outputdir = "$workdir/$cancertype[1]/analysis_type1/normalized_data";

	opendir (DIR, "$datadir");
	my @files = readdir(DIR);
	closedir (DIR);

	open (SUMMARY, ">$workdir/$cancertype[1]/analysis_type1/$outputsummary");
	foreach my $file (@files) {
		if ($file =~ m/^\./) {
			next;
		}
		my $sampleid = "";
		if ($file =~ m/\_T/) {
			$sampleid = $`;
		}
		else {
			next;
		}
		my $totalreads = 0;
		open (IN, "$datadir/$file") || die $!;
		my $header = <IN>;
		while (my $line = <IN>) {
			chomp $line;
			my @vals = split(/\t/, $line);
			$totalreads += $vals[1];
		}
		print SUMMARY "$sampleid\t$totalreads\n";
	
		my $outputfile = "${sampleid}_T_normalize";
		open (OUTPUT, ">$outputdir/$outputfile");
		open (IN, "$datadir/$file") || die $!;
		my $header = <IN>;
		print OUTPUT "junction\tnormalized_count\n";
		while (my $line = <IN>) {
			chomp $line;
			my @vals = split(/\t/, $line);
			my $normalize = ($vals[1] * 20000000) / $totalreads;
			$normalize = sprintf("%.0f", $normalize);
			print OUTPUT "$vals[0]\t$normalize\n";
		}
		close (IN);
		close (OUTPUT);
	}
	close (SUMMARY);
}







