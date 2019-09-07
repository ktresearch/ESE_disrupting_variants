#!/usr/bin/perl

use strict;

my $workdir = shift @ARGV;
my $cancertypefile = shift @ARGV;
my $excludefile = "excluded_cases.txt";


my @cancertypelist = ();
open (IN, "$cancertypefile") || die $!;
while (my $line = <IN>) {
	chomp $line;
	my @vals = split(/\t/, $line);
	push @cancertypelist, "$vals[0]|$vals[1]";
}
close (IN);


open (EXCLUDE, ">$workdir/$excludefile");
foreach my $cancertype (@cancertypelist) {
	my @cancertype = split(/\|/, $cancertype);
	my $tissuedatadir = "$workdir/$cancertype[0]/analysis_type1/data_type1";
	opendir (DIR, "$tissuedatadir");
	my @files = readdir(DIR);
	closedir (DIR);
	my %files;
	foreach my $file (@files) {
		$files{$file} = 1;
	}

	system "mkdir $workdir/$cancertype[1]";
	system "mkdir $workdir/$cancertype[1]/analysis_type1";
	system "mkdir $workdir/$cancertype[1]/analysis_type1/data_type1";
	my %Tid;
	my %Nid;
	my $metadatafile = "$workdir/$cancertype[0]/integrated_metadata.txt";
	print "$metadatafile\n";
	open (IN, "$metadatafile") || die $!;
	while (my $line = <IN>) {
		chomp $line;
		my @vals = split(/\t/, $line);
		my @projectinfo = split(/\_/, $vals[25]);
		my @cancertypeinfo = split(/\./, $projectinfo[1]);
		my $projecttype = "";
		if ($cancertype[1] eq "ESCA" || $cancertype[1] eq "OV" || $cancertype[1] eq "STAD") {
			$projecttype = "RNASeq";
		}
		else {
			$projecttype = "RNASeqV2";
		}
		if ($cancertypeinfo[0] eq $cancertype[1] && $projectinfo[2] =~ m/$projecttype/) {
			my @barcode = split(/\-/, $vals[1]);
			if ($barcode[3] =~ m/^1[01]/) {
				$Nid{$barcode[2]} = 1;
			}
			elsif ($barcode[3] =~ m/^01/) {
				$Tid{$barcode[2]} = 1;
			}	
		}
		else {
			next;
		}
	}
	close (IN);
	foreach my $Tid (keys %Tid) {
		my $filename = "${Tid}_T";
		if ($files{$filename} != 1) {
			print EXCLUDE "$cancertype[0]\t$cancertype[1]\t$filename\n";
			next;
		}
		system "cp $tissuedatadir/${Tid}_T $workdir/$cancertype[1]/analysis_type1/data_type1/${Tid}_T";
	}
}

close (EXCLUDE);
