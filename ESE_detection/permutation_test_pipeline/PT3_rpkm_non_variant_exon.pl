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

	my %shuffle;
	my $shufflefile = "$workdir/$cancertype[1]/permutationtest/shuffle.txt";
	open (IN, "$shufflefile") || die $!;
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);
		$shuffle{$vals[0]} = $vals[1];
	}
	close (IN);

	my $inputfile = "$workdir/$cancertype[1]/permutationtest/rpkm_non_variant_exon_ALL.txt";
	my $outputfile = "$workdir/$cancertype[1]/permutationtest/rpkm_non_variant_exon.txt";
	open (OUTPUT, ">$outputfile");
	open (IN, "$inputfile") || die $!;
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);
		my @variant_samples = split(/,/, $vals[1]);
		my @samples = split(/\|/, $vals[2]);
		my %var_sample;
		foreach my $variant_sample (@variant_samples) {
			$var_sample{$variant_sample} = 1;
		}
		my $output_rpkm = "";
		foreach my $sample (@samples) {
			my @sampleinfo = split(/,/, $sample);
			my $changed_name = $shuffle{$sampleinfo[0]};
			if ($var_sample{$changed_name} == 1) {
				next;
			}
			else {
				$output_rpkm .= "${sample}|";
			}
		}
		print OUTPUT "$vals[0]\t$output_rpkm\n";
	}
}


