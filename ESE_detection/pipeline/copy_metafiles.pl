#!/usr/bin/perl

use strict;

my $workdir = shift @ARGV;
my $cancertypefile = shift @ARGV;

my @cancertypelist = ();
open (IN, "$cancertypefile") || die $!;
while (my $line = <IN>) {
	chomp $line;
	my @vals = split(/\t/, $line);
	push @cancertypelist, "$vals[0]|$vals[1]";
}
close (IN);

my %check;
foreach my $cancertype (@cancertypelist) {
	my @cancertype = split(/\|/, $cancertype);
	
	if ($check{$cancertype[0]} == 1) {
		next;
	}
	$check{$cancertype[0]} = 1;

	my $datadir = "$workdir/$cancertype[0]/RNAseq_downloaded_data";
	my $outputdir = "$workdir/$cancertype[0]/metadatafiles_type1";
	system "mkdir $workdir/$cancertype[0]/metadatafiles_type1";

	opendir (DIR, "$datadir");
	my @dirs = readdir(DIR);
	closedir (DIR);

	foreach my $dir (@dirs) {
		if ($dir =~ m/^\./) {
			next;
		}
		if ($dir eq "gdc-client.exe") {
			next;
		}
		if ($dir =~ m/^gdc_manifest/) {
			next;
		}
		if ($dir eq "command.txt") {
			next;
		}
		opendir (DIR, "$datadir/$dir");
		my @files = readdir(DIR);
		closedir (DIR);
		my $typecheck = 0;
		foreach my $file (@files) {
			if ($file =~ m/\.junction_quantification\.txt$/ || $file =~ m/spljxn\.quantification\.txt$/) {
				$typecheck = 1;
			}
			else {
				next;
			}
		}
		if ($typecheck == 1) {
			foreach my $file (@files) {
				if ($file =~ m/\.tar\.gz$/) {
					system "cp -f $datadir/$dir/$file $outputdir/$file";	
				}
				else {
					next;
				}
			}
		}
		else {
			next;
		}
	}
}
