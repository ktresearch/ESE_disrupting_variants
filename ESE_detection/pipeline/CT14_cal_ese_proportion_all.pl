#!/usr/bin/perl

use strict;

my $workdir = shift @ARGV;
my $cancertypefile = shift @ARGV;

my $outputfile = "$workdir/var_ESE_proportion.txt";


my @cancertypelist = ();
open (IN, "$cancertypefile") || die $!;
while (my $line = <IN>) {
	chomp $line;
	my @vals = split(/\t/, $line);
	push @cancertypelist, "$vals[0]|$vals[1]";
}
close (IN);


open (OUTPUT, ">$outputfile");
print OUTPUT "Cancertype\tTotal_var\tTotal_ESE\tFrame_Shift_ESE\tFrame_Shift_NonESE\tNonFrame_Shift_ESE\tNonFrame_Shift_NonESE\n";

foreach my $cancertype (@cancertypelist) {
	my @cancertype = split(/\|/, $cancertype);
	my %var_all = ();
        my %ese = ();
	open (IN, "$workdir/$cancertype[1]/analysis_type1/ese_judge_all.txt") || die $!;
        while (my $line = <IN>) {
        	chomp $line;
                my @vals = split(/\t/, $line);
                my @var = split(/\|/, $vals[6]);
                foreach my $var (@var) {
                	$var_all{$var} = 1;
                }
        }
        close (IN);
        open (IN, "$workdir/$cancertype[1]/analysis_type1/ese_judge_validation_ks.txt") || die $!;
        while (my $line = <IN>) {
        	chomp $line;
                my @vals = split(/\t/, $line);
                if ($vals[25] ne "Validated") {
                	next;
                }
                my @var = split(/\|/, $vals[6]);
                foreach my $var (@var) {
                	$ese{$var} = 1;
                }
	}
        close (IN);
        my $total = 0;
        my $ese = 0;
        my $fs_ese = 0;
        my $fs_nonese = 0;
        my $nonfs_ese = 0;
        my $nonfs_nonese = 0;
        foreach my $var (keys %var_all) {
        	my @var_info = split(/,/, $var);
		if ($var_info[1] eq "Splice_Site") {
			$total += 1;
			next;
		}
                $total += 1;
                if ($var_info[1] eq "Frame_Shift_Del" || $var_info[1] eq "Frame_Shift_Ins") {
                	if ($ese{$var} == 1) {
                        	$fs_ese += 1;
                                $ese += 1;
                        }
                        else {
                        	$fs_nonese += 1;
                        }
                }
                else {
                	if ($ese{$var} == 1) {
                        	$nonfs_ese += 1;
                                $ese += 1;
                        }
                        else {
                        	$nonfs_nonese += 1;
                        }
                }
        }
        print OUTPUT "$cancertype[1]\t$total\t$ese\t$fs_ese\t$fs_nonese\t$nonfs_ese\t$nonfs_nonese\n";
}
