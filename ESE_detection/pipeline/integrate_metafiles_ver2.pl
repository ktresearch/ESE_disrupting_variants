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
	my $outputfile = "$workdir/$cancertype[0]/integrated_metadata.txt";

	opendir (DIR, "$datadir");
	my @files = readdir(DIR);
	closedir (DIR);

	my $firstfile = 0;
	open (OUTPUT, ">$outputfile");
	foreach my $file (@files) {
		if ($file =~ m/^\./) {
			next;
		}
		if ($file =~ m/\.tar\.gz/) {
			next;
		}
		opendir (DIR, "$datadir/$file");
		my @files2 = readdir(DIR);
		closedir (DIR);
		foreach my $file2 (@files2) {
			if ($file2 =~ m/^\./) {
				next;
			}
			if ($file2 =~ m/sdrf\.txt$/) {
				open (IN, "$datadir/$file/$file2") || die $!;
				my $header = <IN>;
				chomp $header;
				if ($firstfile == 0) {
					print OUTPUT "$header\n";
					$firstfile = 1;
				}
				while (my $line = <IN>) {
					chomp $line;
					my @vals = split(/\t/, $line);
					if ($vals[2] ne "Total RNA") {
						next;
					}
					else {
						print OUTPUT "$line\n";
					}
				}			
			}
			else {
				next;
			}
		}
	}
	close (OUTPUT); 
}
