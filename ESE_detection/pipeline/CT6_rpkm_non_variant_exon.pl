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


	open (IN, "$exonskipfile") || die $!;
	my %variant_samples = ();
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);
		my @skipexoninfo = split(/\:/, $vals[7]);
		my $skipexonid = "$skipexoninfo[0]:$skipexoninfo[2]";
		my @variants = split(/\|/, $varexon{$skipexonid});
		foreach my $variant (@variants) {
			my @variant_info = split(/,/, $variant);
			$variant_samples{$vals[1]} .= "$variant_info[4],";
		}
	}
	close (IN);


	my $datadir = "$workdir/$cancertype[1]/analysis_type1/normalized_data";
	opendir (DIR, "$datadir");
	my @files = readdir(DIR);
	closedir (DIR);

	my %rpkm_non_var_samples = ();
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

		foreach my $junction_pos (keys %variant_samples) {
			my @variant_samples = split(/,/, $variant_samples{$junction_pos});
			my $variant_check = 0;
			foreach my $variant_sample (@variant_samples) {
				if ($sampleid eq $variant_sample) {
					$variant_check = 1;
				}
				else {
					next;
				}
			}
			if ($variant_check == 1) {
				next;
			}
			$rpkm_non_var_samples{$junction_pos} .= "$sampleid,$rpkm{$junction_pos}|";
		}
	}


	my $outputfile = "$workdir/$cancertype[1]/analysis_type1/rpkm_non_variant_exon.txt";
	open (OUTPUT, ">$outputfile");
	foreach my $junction_pos (sort keys %rpkm_non_var_samples) {
		print OUTPUT "$junction_pos\t$rpkm_non_var_samples{$junction_pos}\n";
	}
	close (IN);
}

