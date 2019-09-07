#!/usr/bin/perl

use strict;

my $workdir = shift @ARGV;
my $genomedir = shift @ARGV;

my $inputfile = "$workdir/All_validated_ese_ks.txt";
my $outputfile = "$workdir/All_validated_ese_Seq_ks.txt";

my @chrid = qw(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y);

foreach my $chrid (@chrid) {
	&seq($inputfile, $genomedir, $chrid, $outputfile);
}


sub seq {
	my ($inputfile, $genomedir, $chrid, $outputfile) = @_;
	open (SEQ, "$genomedir/chr${chrid}.seq") || die $!;	
	open (IN, "$inputfile") || die $!;
	open (OUTPUT, ">>$outputfile");
	while (my $line = <IN>) {
		chomp $line;
		my $seq_line = "";
		my @vals = split(/\t/, $line);
		my @chrinfo = split(/\:/, $vals[3]);
		if ($chrinfo[0] ne "chr${chrid}") {
			next;
		}	
		my @mut = split(/\|/, $vals[7]);
		my $seq_output = "";
		foreach my $mut (@mut) {
			my @info = split(/,/, $mut);
			my @pos = split(/\:/, $info[0]);		
			if ($pos[0] ne $chrid) {
				next;
			}
			my $startpos = $pos[1] - 21;
			my $seq = "";
			my $length = 40;
			seek (SEQ, $startpos, 0);
			read (SEQ, $seq, $length);
			$seq =~ tr/atgc/ATGC/;
			$seq_output .= "$seq|";
		}
		print OUTPUT "$line\t$seq_output\n";		
	}	
	close (SEQ);
	close (IN);
	close (OUTPUT);
}
