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

	my $datadir = "$workdir/$cancertype[0]/metadatafiles_type1";

	opendir (DIR, "$datadir");
	my @files = readdir(DIR);
	closedir (DIR);


	foreach my $file (@files) {
		if ($file =~ m/^\./) {
			next;
		}
		system "tar zxvf $datadir/$file";
		my $filename = $file; 
		$filename =~ s/\.tar\.gz//;
		system "mv $filename $datadir/$filename";
	}
} 
