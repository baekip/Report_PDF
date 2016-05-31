#!/usr/bin/perl

use strict;
use warnings;

if ( @ARGV != 2 ){
    printUsage();
}

my $in_general_config = $ARGV[0];
my $in_pipeline_config = $ARGV[1];

my %info;

read_general_config ($in_general_config, \%info);

my @list_delivery_tbi_id = split /\,/, $info{delivery_tbi_id};
my $project_path = $info{project_path};
my @rare_list = split /\,/, $info{rare_id};


my %disease;
#use Data::Dumper;
#print Dumper %disease;

#die;
print "[[12],[],[],[0,95]]\n";
print "Delivery ID\tSample ID\tGender\tDisease\n";
foreach (@rare_list){
    my ($delivery_id,$tbi_id,$gender,$disease) = split /\:/, $_;
    my $gender_type;
    my $disease_type;

    #transfer to gender type

    if ($gender eq "1"){
        $gender_type = "Male";
    }elsif ($gender eq "2"){
        $gender_type = "Female";
    }else {print "Error: Check your gender type in the configure file\n";
        exit;
    }
    
    #transfer to disease type

    if ($disease eq "1"){
        $disease_type = "No";
    }elsif ($disease eq "2"){
        $disease_type = "Yes";
    }else {print "Error: Check your disease type in the configure file\n";
        exit;
    }

    print "$delivery_id\t$tbi_id\t$gender_type\t$disease_type\n";
}

#print $control_id[1];

sub read_general_config {
    my ($file, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while (my $row = <$fh>) {
        chomp $row;
        if ($row =~ /^#/){ next; }
        if (length($row) == 0){ next; }
        my ($key, $value) = split /\=/, $row;
        $key = trim ($key);
        $value = trim ($value);
        $hash_ref->{$key} = $value;
    }
    close ($fh);
}

sub trim {
    my @result = @_;
    foreach (@result) {
        s/^\s+//;
        s/\s+$//;
    }

    return wantarray ? @result : $result[0];
}

sub checkFile {
    my $file = shift;
    if ( !-f $file) {
        die "ERROR! not found <$file>\n";
    }
}

sub printUsage {
    print "Usage: perl $0 <in.sample.config> <in.pipeline.config>\n";
}

