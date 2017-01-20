#!/usr/bin/perl

use strict;
use warnings;

if (@ARGV != 2) {
    printUsage();
}

my $in_sample_config = $ARGV[0];
my $in_pipe_config = $ARGV[0];

my %info;
read_config ($in_sample_config, \%info);

my $pair_id = $info{pair_id};
my $project_path = $info{project_path};
my $mutect_snpeff_path = "$project_path/result/30-2_snpeff_cancer_run";
my $virmid_snpeff_path = "$project_path/result/31-2_snpeff_cancer_run";
my $indel_snpeff_path = "$project_path/result/32-2_snpeff_cancer_run";

my @pair_id_list = split /\,/, $pair_id;

#my %hash_sum;
my %hash;

foreach (@pair_id_list) {
    my $somatic_id = $_;
    my $mutect_snpeff_html = "$mutect_snpeff_path/$somatic_id/$somatic_id".".SNP.snpeff.html";
    my $virmid_snpeff_html = "$virmid_snpeff_path/$somatic_id/$somatic_id".".SNP.snpeff.html";
    my $indel_snpeff_huml = "$indel_snpeff_path/$somatic_id/$somatic_id".".INDEL.snpeff.html";
   
    open my $mutect_fh, '<:encoding(UTF-8)', $mutect_snpeff_html or die;
    my @mutect_html_array;
    
    while (my $mutect_row = <$mutect_fh>){ 
        chomp $mutect_row;
        #print $mutect_row."\n";

        push @mutect_html_array, $mutect_row;

    }
    close $mutect_fh;
    
    for ( my $i=0; $i < @mutect_html_array; $i++){
        if($mutect_html_array[$i] =~ /intergenic_region/){
            print $mutect_html_array[$i+4]."\n";
        }
    }
}

sub parse_snpeff_html {
    my ($lines_ref, $hash_ref) = @_;
    my @lines = @{$line_ref};

    my %hash_one_chr;
    for (my $i=0; $i<@lines; $i++){
        my $line = $lines[$i];
        my ($key, $value);
        if ($line =~ /Number of lines/){
            $key = "num_line";
            $value = rm_tag($lines[$i+1]);
        }elsif ($line =~ /Number of variants \(before filter\)/){
            $key = "num_variant"


        #print @mutect_html_array; 
    }}}

#print $pair_id;



sub read_config {
    my ($file, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)',$file or die;
    while ( my $row = <$fh> ) {
        chomp $row;
        if ($row =~ /^#/) {next;}
        if (length $row == 0) {next;}

        my ($key, $value) = split /\=/, $row;
        $key = trim ($key);
        $value = trim ($value);
        $hash_ref->{$key}=$value;
    }
    close $fh;
}

sub trim {
    my @result = @_;
    foreach (@result) {
        s/^\s+//g;
        s/\s+$//g;
    }
    return wantarray ? @result:$result[0];
}
