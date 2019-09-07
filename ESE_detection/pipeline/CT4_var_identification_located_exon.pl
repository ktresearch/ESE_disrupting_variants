#!/usr/bin/perl

use strict;

my $workdir = shift @ARGV;
my $cancertypefile = shift @ARGV;
my $reffile = shift @ARGV;


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

	my %varexist = ();
	my %varinfo = ();
	my @sampleid = ();
	my $integrated_maf_files = "$workdir/$cancertype[1]/analysis_type1/integrated_all_maf_files.txt";
	open (IN, "$integrated_maf_files") || die $!;
	my $mafheader = <IN>;
	chomp $mafheader;
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);
		my @barcode = split(/\-/, $vals[15]);
		my $sampleid = $barcode[2];
		push @sampleid, $sampleid;
		$varexist{$vals[0]} = 1;
		$varinfo{$sampleid}->{$vals[0]} .= "$vals[4]:$vals[5],$vals[8],$vals[10],$vals[12],$sampleid|";
	}
	close (IN);

	my %seen = ();
	foreach my $i (@sampleid) {
		$seen{$i} = 1;
	}
	my @sampleid = ();
	foreach my $i (sort keys %seen) {
		push @sampleid, $i;
	}

	my $outputfile = "$workdir/$cancertype[1]/analysis_type1/exon_annotation_and_variants.txt";
	open (OUTPUT, ">$outputfile");
	open (IN, "$reffile") || die $!;
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);

		my @exoninfo = split(/\:/, $vals[0]);
		my @posinfo = split(/\-/, $exoninfo[1]);
		my $exon_chr = $exoninfo[0];
		my $exon_st = $posinfo[0];
		my $exon_en = $posinfo[1];

		my @transcript = split(/\|/, $vals[1]);
		my $output_tmp = "";
		foreach my $transcript (@transcript) {
			my @geneinfo = split(/,/, $transcript);
			my $symbol = $geneinfo[0];		
			if ($varexist{$symbol} != 1) {
				next;
			}
			foreach my $sampleid (@sampleid) {
				if (!($varinfo{$sampleid}->{$symbol} =~ m/\w+/)) {
					next;
				}
				my @variants = split(/\|/, $varinfo{$sampleid}->{$symbol});
				foreach my $variant (@variants) {
					my @variant_tmp = split(/,/, $variant);
					my @var_pos = split(/\:/, $variant_tmp[0]);
					if ($exon_chr eq "chr${var_pos[0]}") {				
						if ($var_pos[1] >= $exon_st && $var_pos[1] <= $exon_en) {
							$output_tmp .= "$variant|";
						}
						else {
							next;
						}
					}	
					else {
						next;
					}
				}
			}
		}
	
		my @output_tmp = split(/\|/, $output_tmp);
		my %seen = ();
		foreach my $i (@output_tmp) {
			$seen{$i} = 1;
		}
		my @output_tmp = ();
		foreach my $i (keys %seen) {
			push @output_tmp, $i;
		}

		print OUTPUT "$line\t$output_tmp\n";
	}
	close (IN);
	close (OUTPUT);
}


