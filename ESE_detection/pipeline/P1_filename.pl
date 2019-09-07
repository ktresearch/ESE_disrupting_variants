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


foreach my $cancertype (@cancertypelist) {
	my @cancertype = split(/\|/, $cancertype);

	my $metafile = "$workdir/$cancertype[0]/integrated_metadata.txt";
	my $datadir = "$workdir/$cancertype[0]/analysis_type1/data_type1";

	my %id = ();
	open (META, "$metafile") || die $!;
	my $metaheader = <META>;
	chomp $metaheader;
	while (my $line = <META>) {
		chomp $line;
        	my @vals = split(/\t/, $line);
       		my @barcode = split(/\-/, $vals[1]);
        	$id{$barcode[2]} = 1;
	}
	close (META);
	my %Tinfo = ();
	my %Ninfo = ();
	open (META, "$metafile") || die $!;
	my $metaheader = <META>;
	chomp $metaheader;
	while (my $line = <META>) {
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
        		foreach my $id (keys %id) {
        			if ($id eq $barcode[2] && $barcode[3] =~ m/^01/) { #01
                			$Tinfo{$vals[0]} = $id;
                        		last;
                		}
                		elsif ($id eq $barcode[2] && $barcode[3] =~ m/^1[01]/) { #11
                			$Ninfo{$vals[0]} = $id;
                        		last;
                		}
                		else {
                			next;
                		}
        		}
		}
	}
	close (META);

	opendir (DIR, "$datadir");
	my @files = readdir(DIR);
	closedir (DIR);

	foreach my $file (@files) {
		my @exname = split(/\./, $file);
		my $exname = $exname[2];
		my $id = $Tinfo{$exname};
		if ($id =~ m/\w+/) {
			system "mv $datadir/$file $datadir/${id}_T";
		}
		my $id = $Ninfo{$exname};
		if ($id =~ m/\w+/) {
			system "mv $datadir/$file $datadir/${id}_N";
		}
	}
}

