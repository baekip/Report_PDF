#!/usr/bin/perl

use strict;
use warnings;

if (@ARGV != 2) {
    printUsage();
}

my $in_sample_config = $ARGV[0];
my $in_pipeline_config = $ARGV[1];

my %info;
read_sample_config($in_sample_config, \%info);

my $project_path = $info{project_path};
my $alignment_xls = "$project_path/report/alignment.statistics.xls";
#print `cat $alignment_xls`;

my $sample_list = $info{delivery_tbi_id};
my @sample_tbi_list = split /\,/, $sample_list;

print "[[11],[],[],[100]]\n";
print "Sample ID\tSequence\\nRead\tClean\\nRead\tDe-Duplicated\\nRead\tMapping\\nRead\tUnique\\nRead\tOn-Target\\nRead\n";

foreach (@sample_tbi_list){
    my ($delivery_id, $tbi_id, $type) = split /\:/, $_;
    
    my $sequence_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 2 `;
    chomp $sequence_read;
    $sequence_read = num($sequence_read);

    my $clean_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 3 `;
    chomp $clean_read;
    $clean_read = num($clean_read);
    
    my $deduplicated_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 8 `;
    chomp $deduplicated_read;
    $deduplicated_read = num($deduplicated_read);

    my $mapping_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 10 `;
    chomp $mapping_read;
    $mapping_read = num($mapping_read);

    my $unique_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 17 `;
    chomp $unique_read;
    $unique_read = num($unique_read);

    my $on_target_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 19`;
    chomp $on_target_read;
    $on_target_read = num($on_target_read);


    print "$delivery_id\t$sequence_read\t$clean_read\t$deduplicated_read\t$mapping_read\t$unique_read\t$on_target_read\n";}

sub num {
    my $cnum = shift;
    if ($cnum =~ /\d\./){
        return $cnum;
    }
    while ( $cnum =~ s/(\d+)(\d{3})\b/$1,$2/){
        1;
    }
    my $result = sprintf "%s", $cnum;
    return $result;
}

sub read_sample_config {
    my ($file, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while (my $row = <$fh>){
        chomp $row;
        if ($row =~ /^#/){next;}
        if (length $row == 0) {next;}

        my ($key, $value) = split /\=/, $row;
        $key = trim ($key);
        $value = trim ($value);
        $hash_ref->{$key} = $value;
    }
}

sub trim { 
    my @result = @_;

    foreach (@result) {
        s/^\s+//;
        s/\s+$//;
        # print @result;
        # print "\n";
    }

    return wantarray ? @result : $result[0];
}

sub printUsage {
    print "Usage: perl $0 <in.sample.config> <in.pipeline.config> \n";
}
