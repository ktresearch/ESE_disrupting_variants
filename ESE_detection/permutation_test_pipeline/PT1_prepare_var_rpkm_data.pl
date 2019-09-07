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

	my $datadir = "$workdir/$cancertype[1]/analysis_type1/skip_data";
	opendir (DIR, "$datadir");
	my @files = readdir(DIR);
	closedir (DIR);

	mkdir "$workdir/$cancertype[1]/permutationtest";
	my $outputfile = "$workdir/$cancertype[1]/permutationtest/var_rpkm_merge.txt";
	my $outputfile2 = "$workdir/$cancertype[1]/permutationtest/samplelist.txt";
	open (OUTPUT, ">$outputfile");
	open (LIST, ">$outputfile2");

	foreach my $file (@files) {
		if ($file =~ m/^\./) {
			next;
		}		
		if ($file =~ m/\_skip\.txt$/) {
			my $sampleid = $`;
			open (IN, "$datadir/${sampleid}_skip.txt") || die $!;
			print LIST "$sampleid\n";
			my $lineid = 0;
			while (my $line = <IN>) {
				chomp $line;
				$lineid += 1;
				my @vals = split(/\t/, $line);
				if ($vals[5] =~ m/\w+/) {
					print OUTPUT "$sampleid\t$lineid\t$vals[5]\t$vals[6]\t$vals[9]\t$vals[12]\t$vals[15]\t$vals[16]\n";
				}
				else {
					next;
				}
			}
			close (IN);
		}
		else {
			next;
		}
	}
}

