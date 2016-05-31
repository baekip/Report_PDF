#!/usr/bin/perl

use warnings;
use strict;

if (@ARGV != 2) {
    printUsage();
}

my $in_sample_config = $ARGV[0];
my $in_pipe_config = $ARGV[1];

my %info;
read_config_info ($in_sample_config, \%info);

my $pair_id = $info{pair_id};
my @pair_list = split /\,/, $pair_id;


my $delivery_tbi_id = $info{delivery_tbi_id};
my @delivery_tbi_list = split /\,/, $delivery_tbi_id;

my %delivery_hash;
delivery_split (\@delivery_tbi_list, \%delivery_hash);

#for (my $i=1; $i++; 
#print $delivery_tbi_list[0]."\n";

print "[[12],[],[],[60,120]]\n";
print "No.\tTemporary ID\tCase\tControl\n";
for (my $i=0; $i<@pair_list; $i++) {
   
    my $no = 0;
    $no=$i+1;
    my ($control, $case) = split /\_/, $pair_list[$i];
    
    my $delivery_case = substr ($delivery_hash{$case},0,10);
    my $delivery_control = $delivery_hash{$control};
    my $tmp_id = $delivery_case."_".$no; 

    print "$no\t$tmp_id\t$delivery_case\\n($case)\t$delivery_control\\n($control)\n";
}

sub delivery_split {
    my ($delivery_list, $del_ref_hash) = @_;

    for (@$delivery_list){
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
        $del_ref_hash->{$tbi_id}=$delivery_id;
    }
}

sub read_config_info {
    my ($file, $ref_hash) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while (my $row = <$fh>) {
        chomp $row;
        if ($row =~ /^#/) {next;}
        if (length ($row) == 0) {next;}
        my ($key, $value) = split /\=/, $row;
        $key = trim($key);
        $value = trim($value);
        $ref_hash->{$key}=$value;
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




sub printUsage {
    print "Usage: perl $0 <in.config> <in.pipe.config> \n";
}

