#!/usr/bin/perl

use strict;

my $workdir = shift @ARGV;
my $cancertypefile = shift @ARGV;
my $exonskipfile = shift @ARGV;


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

	system "mkdir $workdir/$cancertype[1]/analysis_type1/skip_data";
	my %varexon = ();
	my %varpos = ();
	my $variantfile = "$workdir/$cancertype[1]/analysis_type1/exon_annotation_and_variants.txt";
	open (IN, "$variantfile") || die $!;
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);
		if (!($vals[3] =~ m/\w+/)) {
			next;
		}
		my @exon = split(/\|/, $vals[1]);
		foreach my $exon (@exon) {
			my @exon_tmp = split(/,/, $exon);
			my $key = "$exon_tmp[1]:$exon_tmp[2]";
			$varexon{$key} = $vals[3];
			$varpos{$key} = $vals[0];
		}
	}
	close (IN);


	my $datadir = "$workdir/$cancertype[1]/analysis_type1/normalized_data";
	opendir (DIR, "$datadir");
	my @files = readdir(DIR);
	closedir (DIR);

	foreach my $file (@files) {
		if ($file =~ m/^\./) {
			next;
		}
		my $sampleid = "";
		if ($file =~ m/\_T\_normalize$/) {
			$sampleid = $`;
		}
		else {
			next;
		}

		my %rpkm = ();
		open (IN, "$datadir/$file") || die $!;
		my $header = <IN>;
		chomp $header;
		while (my $line = <IN>) {
			chomp $line;
			my @vals = split(/\t/, $line);
			$rpkm{$vals[0]} = $vals[1];
		}
		close (IN);
	
		my $outputfile = "${sampleid}_skip.txt";		
		open (OUTPUT, ">$workdir/$cancertype[1]/analysis_type1/skip_data/$outputfile");	
		open (IN, "$exonskipfile") || die $!;
		while (my $line = <IN>) {
			chomp $line;
			my @vals = split(/\t/, $line);
			print OUTPUT "$vals[0]\t$vals[1]\t$vals[2]\t$vals[3]\t$vals[4]\t";
			my @skipexoninfo = split(/\:/, $vals[7]);
			my $skipexonid = "$skipexoninfo[0]:$skipexoninfo[2]";
			my $variant_output = "";
			my $position_output = "";
			if ($varexon{$skipexonid} =~ m/\w+/) {
				my @variants = split(/\|/, $varexon{$skipexonid});
				foreach my $variant (@variants) {
					my @variant_info = split(/,/, $variant);
					if ($sampleid eq $variant_info[4]) {
						$variant_output .= "$variant|";
						$position_output .= "$varpos{$skipexonid}|";
					}
					else {
						next;
					}
				}
			}

			#remove redundant information
			my @variant_output = split(/\|/, $variant_output);
			my %seen = ();
			foreach my $i (@variant_output) {
				$seen{$i} = 1;
			}
			my $variant_output = "";
			foreach my $i (keys %seen) {
				$variant_output .= "$i|";
			}
			my @position_output = split(/\|/, $position_output);
			my %seen = ();
			foreach my $i (@position_output) {
				$seen{$i} = 1;
			}
			my $position_output = "";
			foreach my $i (keys %seen) {
				$position_output .= "$i|";
			}

			print OUTPUT "$variant_output\t$position_output\t";
			print OUTPUT "$vals[5]\t$vals[6]\t$rpkm{$vals[6]}\t";
			print OUTPUT "$vals[7]\t$vals[8]\t$rpkm{$vals[8]}\t";
			print OUTPUT "$vals[9]\t$vals[10]\t$rpkm{$vals[10]}\t";
			if ($vals[11] =~ m/\w+/) {
				my @knownjunction = split(/\|/, $vals[11]);
				my $knownjunction_output = "";
				foreach my $knownjunction (@knownjunction) {
					my @knownjunction_info = split(/\;/, $knownjunction);
					$knownjunction_output .= "${knownjunction};$rpkm{$knownjunction_info[1]}|";
				}
				print OUTPUT "$knownjunction_output\n";
			}
			else {
				print OUTPUT "\n";
			}
		}
		close (IN);
		close (OUTPUT);
	}
}
