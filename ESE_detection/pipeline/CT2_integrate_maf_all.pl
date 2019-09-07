#!/usr/bin/perl

use strict;

my $workdir = shift @ARGV;
my $cancertypefile = shift @ARGV;
my $outputfile = "integrated_all_maf_files.txt";
my $omitfile = "omit_variants.txt";


my @cancertypelist = ();
open (IN, "$cancertypefile") || die $!;
while (my $line = <IN>) {
	chomp $line;
	my @vals = split(/\t/, $line);
	push @cancertypelist, "$vals[0]|$vals[1]";
}
close (IN);

open (OMIT, ">../$omitfile");

foreach my $cancertype (@cancertypelist) {
	my @cancertype = split(/\|/, $cancertype);	
	my $mafdir = "$workdir/$cancertype[0]/analysis_type1/data_maf";

	opendir (DIR, "$mafdir");
	my @files = readdir(DIR);
	closedir (DIR);

	my %var = ();
	my @id = ();
	my @pos = ();
	my $header = "";
	foreach my $file (@files) {
		if ($file =~ m/^\./) {
			next;
		}
		open (IN, "$mafdir/$file") || die $!;
		my $headercheck = 0;
		while (my $line = <IN>) {
			chomp $line;
			if ($line =~ m/^\#/) {
				next;
			}
			if ($headercheck == 0) {
				$header = $line;
				$headercheck = 1;
				next;
			}
			my @vals = split(/\t/, $line);
			if ($vals[3] == "37" || $vals[3] eq "GRCh37") {
				my $pos = "$vals[4]|$vals[5]|$vals[6]";
				my @sampleinfo = split(/\-/, $vals[15]);
				my $id = $sampleinfo[2];
				$var{$id}->{$pos} = $line;
				push @id, $id;
				push @pos, $pos;
			}
			else {
				print OMIT "Omit\t$file\n$line\n";
				last;
			}
		}
		close (IN);
	}

	my %seen = ();
	foreach my $i (@id) {
		$seen{$i} = 1;
	}
	my @id = ();
	foreach my $i (keys %seen) {
		push @id, $i;
	}

	my %seen = ();
	foreach my $i (@pos) {
		$seen{$i} = 1;
	}
	my @pos = ();
	foreach my $i (keys %seen) {
		push @pos, $i;
	}

	open (OUTPUT, ">$workdir/$cancertype[1]/analysis_type1/$outputfile");
	print OUTPUT "$header\n";
	foreach my $id (@id) {
		foreach my $pos (@pos) {
			if ($var{$id}->{$pos} =~ m/\w+/) {
				print OUTPUT "$var{$id}->{$pos}\n";
			}
			else {
				next;
			}
		}
	}
	close (OUTPUT);
}

close (OMIT);



