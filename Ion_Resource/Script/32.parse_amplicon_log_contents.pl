#!/usr/bin/perl 

use strict;
use warnings;

if (@ARGV != 2) {
    printUsage();
}

my $in_general_config = $ARGV[0];
my $in_sample_config = $ARGV[1];

my %info;
read_general_config ( $in_general_config, \%info );


sub read_general_config {
    my ($file, $hash_ref) = @_;
    open $fh, '<:encoding(UTF-8)', $file or die;
    while (my $row = <$fh>) {
        chomp $row; 
        



sub printUsage {
    print "Usage: perl $0 <in_config> <in.sample> \n";
    print "Example: perl $0 /BiO/BioProjects/Ion_Torrent/RIKEN_Human_Ion-2016-01-TBO150146/Ion_Config.txt /BiO/BioProjects/Ion_Torrent/RIKEN_Human_Ion-2016-01-TBO150146/Ion_Sample.txt \n";
    exit;
}
