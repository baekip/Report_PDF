#!/usr/bin/perl

use strict;
use warnings;

if (@ARGV != 2) {
    printUsage();
}

my $in_general_config = $ARGV[0];
my $in_pipeline_config = $ARGV[1];


my %info;
read_config ($in_general_config, \%info);

my $project_path = $info{project_path};
my $resource_path = "$project_path/report/resource/3-2_Somatic_Information/";

my @list_delivery_id = split /\,/, $info{delivery_tbi_id};
my @pathogenic_total_list;

my @list_pair_id = split /\,/, $info{pair_id};

my %delivery_hash;
delivery_split (\@list_delivery_id, \%delivery_hash);

my $output_table = "$resource_path/4_c_table_01.txt";

open (my $fh_table, '>', $output_table) or die;
print $fh_table "[[10]]\n";
print $fh_table "Sample ID\tT/A->G/C\tT/A->C/G\tT/A->A/T\tC/G->A/T\tC/G->G/C\tC/G->T/A\tTotal\n";

for (my $i=0; $i < @list_pair_id; $i++){
    my ($a,$b,$c,$d,$e,$f) = (0,0,0,0,0,0);
    my $no_somatic = $i + 1;
    my $somatic_id = $list_pair_id[$i];
    my ($control, $case) = split /\_/, $list_pair_id[$i];
    my $delivery_case = substr ($delivery_hash{$case}, 0, 15);
    my $tmp_id = $delivery_case."_".$no_somatic;
    my $mutect_tsv = "$project_path/result/30-1_mutect_run/".$somatic_id."/".$somatic_id.".mutect.pass.vcf";

    open (my $fh_mutect, '<:encoding(UTF-8)', $mutect_tsv) or die "Could open not <$mutect_tsv>";
    while (my $row = <$fh_mutect>){
        chomp $row;
        if ($row =~ /^#/) {next;}
        my @col_contents = split/\t/, $row;
        my $chr = $col_contents[0]; 
        my $ref = $col_contents[3];
        my $alt = $col_contents[4];
        

        if (($ref eq "T" and $alt eq "G") or ($ref eq "A" and $alt eq "C")){
            $a = $a + 1;
        }elsif (($ref eq "T" and $alt eq "C") or ($ref eq "A" and $alt eq "G")) {
            $b = $b + 1;
        }elsif (($ref eq "T" and $alt eq "A") or ($ref eq "A" and $alt eq "T")) {
            $c = $c + 1;
        }elsif (($ref eq "C" and $alt eq "A") or ($ref eq "G" and $alt eq "T")) {
            $d = $d + 1;
        }elsif (($ref eq "C" and $alt eq "G") or ($ref eq "G" and $alt eq "C")) {
            $e = $e + 1;
        }elsif (($ref eq "C" and $alt eq "T") or ($ref eq "G" and $alt eq "A")) {
            $f = $f + 1;
        }else{ print "Not change Single Nucleotide Variants!!\n";}
    }
    my $total = $a+$b+$c+$d+$e+$f;
    
    print $fh_table "$tmp_id\t$a\t$b\t$c\t$d\t$e\t$f\t$total\n";
}
close $fh_table;

sub delivery_split {
    my ($delivery_list, $del_ref_hash) = @_;
    for (@$delivery_list) {
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
        $del_ref_hash->{$tbi_id}=$delivery_id;
    }
}

sub read_config {
    my ($file, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while (my $row = <$fh>) {
        chomp $row; 
        if ($row =~ /^#/) {next;}
        if (length($row) == 0) {next;}
        my ($key, $value) = split /\=/, $row;
        $key = trim($key);
        $value = trim ($value);
        $hash_ref->{$key}=$value;
    }
    close $fh;
}

sub trim {
    my @result = @_;
    foreach (@result) {
        s/^\s+//;
        s/\s+$//;
    }

    return wantarray ? @result:$result[0];
}

sub checkFile {
    my $file = shift;
    if ( !-f $file) {
        die "ERROR! not found <$file>\n";
    }
}

sub printUsage {
    print "perl $0 <in.sample.config> <in.pipe.config> \n";
    exit;
}
