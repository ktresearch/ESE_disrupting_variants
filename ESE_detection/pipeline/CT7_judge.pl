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

foreach my $cancertype (@cancertypelist) {
	my @cancertype = split(/\|/, $cancertype);


	my %rpkm_non_var_exon = ();
	my $rpkm_non_variant_file = "$workdir/$cancertype[1]/analysis_type1/rpkm_non_variant_exon.txt";
	open (IN, "$rpkm_non_variant_file") || die $!;
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);
		$rpkm_non_var_exon{$vals[0]} = $vals[1];
	}
	close (IN);


	my $datadir = "$workdir/$cancertype[1]/analysis_type1/skip_data";
	opendir (DIR, "$datadir");
	my @files = readdir(DIR);
	closedir (DIR);

	my $outputall = "$workdir/$cancertype[1]/analysis_type1/ese_judge_all.txt";
	my $outputese = "$workdir/$cancertype[1]/analysis_type1/ese_judge.txt";
	open (ALL, ">$outputall");
	open (ESE, ">$outputese");
	foreach my $file (@files) {
		if ($file =~ m/^\./) {
			next;
		}
		my $sampleid = "";
		if ($file =~ m/\_skip\.txt/) {
			$sampleid = $`;
		}
		open (IN, "$datadir/$file") || die $!;
		while (my $line = <IN>) {
			chomp $line;
			my @vals = split(/\t/, $line);
			if (!($vals[5] =~ m/\w+/)) {
				next;
			}
			if ($vals[9] =~ m/\d+/ && $vals[12] =~ m/\d+/ && $vals[15] =~ m/\d+/) {
			}
			else {
				next;
			}
			my $ratio1 = "";
			my $ratio2 = "";
			my $judge = "";
			if ($vals[12] == 0) {
				$ratio1 = "NotSkip";
			}
			else {
				$ratio1 = $vals[9] / $vals[12];
			}
			if ($vals[15] == 0) {
				$ratio2 = "NotSkip";
			}
			else {
				$ratio2 = $vals[9] / $vals[15];
			}
			if ($ratio1 >= 0.5 && $ratio1 <= 2) {
				if ($ratio2 >= 0.5 && $ratio2 <= 2) {
					$judge = "ESE";
				}
				else {
					$judge = "NoEffect";
				}
			}
			else {
					$judge = "NoEffect";
			}
			print ALL "$sampleid\t$line\t$ratio1\t$ratio2\t$judge\n";
			if ($judge eq "ESE") {
				print ESE "$sampleid\t$line\t$ratio1\t$ratio2\t$judge\t$rpkm_non_var_exon{$vals[1]}\n";
			}
		}
		close (IN);
	}
	close (ALL);
}






