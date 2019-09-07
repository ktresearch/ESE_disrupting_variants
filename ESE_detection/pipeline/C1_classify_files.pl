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

	system "mkdir $workdir/$cancertype[0]/analysis_type1";
	system "mkdir $workdir/$cancertype[0]/analysis_type1/data_type1";
	system "mkdir $workdir/$cancertype[0]/analysis_type1/data_type2";
	system "mkdir $workdir/$cancertype[0]/analysis_type1/data_maf";
	my $dir_type1 = "$workdir/$cancertype[0]/analysis_type1/data_type1";
	my $dir_type2 = "$workdir/$cancertype[0]/analysis_type1/data_type2";
	my $dir_maf = "$workdir/$cancertype[0]/analysis_type1/data_maf";

	opendir (DIR, "$datadir");
	my @names = readdir (DIR);
	closedir (DIR);

	foreach my $name (@names) {
		opendir (DIR, "$datadir/$name");
		my @files = readdir(DIR);
		closedir (DIR);
		foreach my $file (@files) {
			if ($file =~ m/\.junction_quantification\.txt$/) {
				system "cp $datadir/$name/$file $dir_type1/$file";
				last;
			}
			elsif ($file =~ m/\.trimmed\.annotated\.translated_to_genomic\.spljxn\.quantification\.txt$/) {
				system "cp $datadir/$name/$file $dir_type2/$file";
				last;
			}
			elsif ($file =~ m/\.maf$/) {
				system "cp $datadir/$name/$file $dir_maf/$file";
				last;
			}
			else {
				next;
			}
		}
	}
}
