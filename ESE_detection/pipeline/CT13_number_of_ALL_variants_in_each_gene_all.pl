#!/usr/bin/perl

use strict;

my $workdir = shift @ARGV;
my $cancertypefile = shift @ARGV;

my $outputfile = "$workdir/number_of_ALL_variants_in_each_gene.txt";
my $outputfile2 = "$workdir/number_of_ALL_variants_in_each_gene_redundant.txt";


my @cancertypelist = ();
open (IN, "$cancertypefile") || die $!;
while (my $line = <IN>) {
	chomp $line;
	my @vals = split(/\t/, $line);
	push @cancertypelist, "$vals[0]|$vals[1]";
}
close (IN);


my %var_genes = ();
my %samples = ();
foreach my $cancertype (@cancertypelist) {
	my @cancertype = split(/\|/, $cancertype);
	open (IN, "$workdir/$cancertype[1]/analysis_type1/ese_judge_all.txt") || die $!;
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);
		my @variants = split(/\|/, $vals[6]);
                my @refseq_info = split(/\:/, $vals[8]);
        	my $refseqid = $refseq_info[0];
                my @symbol_left = split(/\|/, $vals[4]);
		foreach my $variant (@variants) {
                	foreach my $symbol_left (@symbol_left) {
                        	my @symbol_info = split(/,/, $symbol_left);
                		if ($symbol_info[1] eq $refseqid) {
                                	$var_genes{$symbol_info[0]} .= "$variant|";
                                        last;
                                }
                                else {
                                	next;
                                }
                        }
		}
	}
        close (IN);
}

my %count = ();
my %redundant = ();
foreach my $symbol (keys %var_genes) {
	my @var_genes = split(/\|/, $var_genes{$symbol});
        my %seen = ();
        foreach my $i (@var_genes) {
        	$seen{$i} = 1;
	}
        foreach my $var (keys %seen) {
        	$count{$symbol} += 1;
                $redundant{$var} += 1;
        }
}

open (OUTPUT, ">$outputfile");
foreach my $symbol (keys %count) {
	if ($count{$symbol} >= 1) {
        	print OUTPUT "$symbol\t$count{$symbol}\n";
        }
        else {
        	print "$symbol\t$count{$symbol}\n";
        }
}
close (OUTPUT);

open (OUTPUT2, ">$outputfile2");
foreach my $var (keys %redundant) {
	if ($redundant{$var} >= 2) {
        	print OUTPUT2 "$var\t$redundant{$var}\n";
        }
}
close (OUTPUT2);
