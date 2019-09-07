#!/usr/bin/perl

use strict;

my $cancertypefile = shift @ARGV;
my $workdir = shift @ARGV;
my $iter = shift @ARGV;

system "mv $workdir/permutation_results/All_validated_ese_ks.txt $workdir/permutation_results/All_validated_ese_ks_PT_${iter}.txt";
system "rm $workdir/TCGA_cancertype_list_for_permutationtest.txt";

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

	system "mv $workdir/$cancertype[1]/permutationtest/shuffle.txt $workdir/junction_cancertype/$cancertype[1]/permutationtest/shuffle/shuffle_${iter}.txt";
	system "mv $workdir/$cancertype[1]/permutationtest/ese_judge_validation_ks.txt $workdir/junction_cancertype/$cancertype[1]/permutationtest/ese_candidate/ese_judge_validation_ks_${iter}.txt";
	system "rm -r $workdir/$cancertype[1]/permutationtest/skip_data";
	system "rm $workdir/$cancertype[1]/permutationtest/ese_judge.txt";
	system "rm $workdir/$cancertype[1]/permutationtest/ese_judge_all.txt";
	system "rm $workdir/$cancertype[1]/permutationtest/ese_judge_for_Rtest.txt";
	system "rm $workdir/$cancertype[1]/permutationtest/ese_judge_pval_ks.txt";
	system "rm $workdir/$cancertype[1]/permutationtest/rpkm_non_variant_exon.txt";
	system "rm $workdir/$cancertype[1]/permutationtest/Rtest_result_ks.txt";
}


