#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;

## Program Info:
#
# Name: Cancer Report Gengerator
#
# Author: Inpyo Baek
#   Copyright (c) Theragen Bio Institute, 2015,
#   all rights reserved
#
# LicenceL This script may be used freely as long as no free is charged
#   for use, and as long as the author/copyright attributions 
#   are not removed.
#
########################################################################################

if (@ARGV !=2){
	printUsage();
}

my $in_general_config = $ARGV[0];
my $in_pipeline_config = $ARGV[1];

my %info;

read_general_config( $in_general_config, \%info );
#read_pipeline_config();

my @list_delivery_tbi_id = split /\,/, $info{delivery_tbi_id};
my $project_path = $info{project_path};
my $rawdata_path = "$project_path/rawdata";

my $pair_id = $info{pair_id};
my @pair_list = split /\,/, $pair_id;
#print $pair_id."\n";


my %delivery_hash;
delivery_split (\@list_delivery_tbi_id,\%delivery_hash);
#print Dumper %delivery_hash;

my $Sequencing_Statistics_Result_xls = "$rawdata_path/Sequencing_Statistics_Result.xls";
checkFile( $Sequencing_Statistics_Result_xls );

my %sample_id_list;

print "[[12],[],[],[0,90]]\n";
print "Type\tDelivery ID\\n(Sample ID)\tTotal\\nreads\tTotal\\nyield\\n(Gbp)\tN rate\tQ30\\nMoreBases\\nRate\tQ20\\nMoreBases\\nRate\n";

foreach ( @pair_list ) {
    my ( $control_id, $case_id ) = split /\_/, $_;
    
    ####Case Contents#####
#    my $case_delivery_id = $sample_id{$case_delivery_id};
#    chomp ($case_delivery_id);
    my $case_delivery_id = $delivery_hash{$case_id};
    chomp ($case_delivery_id);

    my $case_total_reads = `cat $Sequencing_Statistics_Result_xls | grep \"^$case_id\" | cut -f 3`;
    chomp ($case_total_reads);
    $case_total_reads = num($case_total_reads);
    
    my $case_total_yield = `cat $Sequencing_Statistics_Result_xls | grep \"^$case_id\" | cut -f 4`;
    chomp ($case_total_yield);
    $case_total_yield = changeGbp($case_total_yield);
    
    my $case_N_rate = `cat $Sequencing_Statistics_Result_xls | grep \"^$case_id\" | cut -f 13`;
    chomp ($case_N_rate);

    my $case_Q30 = `cat $Sequencing_Statistics_Result_xls | grep \"^$case_id\" | cut -f 15`;
    chomp ($case_Q30);
    
    my $case_Q20 = `cat $Sequencing_Statistics_Result_xls | grep \"^$case_id\" | cut -f 17`;
    chomp ($case_Q20);

    print "Case\t$case_delivery_id\\n($case_id)\t$case_total_reads\t$case_total_yield\t$case_N_rate\t$case_Q30\t$case_Q20\n";

    ####Control Contents####
#    my $control_delivery_id = $sample_id{$control_id};
#    chomp ($control_delivery_id);
    
    my $control_delivery_id = $delivery_hash{$control_id};
    chomp ($control_delivery_id);

    my $control_total_reads = `cat $Sequencing_Statistics_Result_xls | grep \"^$control_id\" | cut -f 3`;
    chomp ($control_total_reads);
    $control_total_reads = num($control_total_reads);
    
    my $control_total_yield = `cat $Sequencing_Statistics_Result_xls | grep \"^$control_id\" | cut -f 4`;
    chomp ($control_total_yield);
    $control_total_yield = changeGbp($control_total_yield);

    my $control_N_rate = `cat $Sequencing_Statistics_Result_xls | grep \"^$control_id\" | cut -f 13`;
    chomp ($control_N_rate);

    my $control_Q30 = `cat $Sequencing_Statistics_Result_xls | grep \"^$control_id\" | cut -f 15`;
    chomp ($control_Q30);

    my $control_Q20 = `cat $Sequencing_Statistics_Result_xls | grep \"^$control_id\" | cut -f 17`;
    chomp ($control_Q20);

    print "Control\t$control_delivery_id\\n($control_id)\t$control_total_reads\t$control_total_yield\t$control_N_rate\t$control_Q30\t$case_Q20\n";
}

sub delivery_split{
    my($delivery_list, $delivery_ref) = @_;

    foreach (@$delivery_list) {
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
        $delivery_ref->{$tbi_id} = $delivery_id;
    }
}




=pod
foreach ( @list_delivery_tbi_id ){
	my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;

	# Total reads 
	my $total_reads = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 3`;
	chomp($total_reads);
        $total_reads = num($total_reads);

#	my $index = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 2`;
#	chomp($index);

        my $N_rate = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 13`;
        chomp ($N_rate);

	my $total_yield = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 4`;
	chomp($total_yield);
	$total_yield = changeGbp($total_yield);

	my $q30_base_pf = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 15`;
	chomp($q30_base_pf);

	my $q20_base_pf = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 17`;
	chomp($q20_base_pf);
	
	print "Case\t$delivery_id\\n($tbi_id)\t$total_reads\t$total_yield\t$N_rate\t$q30_base_pf\t$q20_base_pf\n";
	print "Control\t$delivery_id\\n($tbi_id)\t$total_reads\t$total_yield\t$N_rate\t$q30_base_pf\t$q20_base_pf\n";
}
=cut
#cat /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/result/01_fastqc_orig/TN1507D0293/TN1507D0293_1_fastqc/fastqc_data.txt | grep "Total Sequences" | sed 's/Total Sequences\s//g'


sub read_pipeline_config{
	my $file = shift;
	open my $fh, '<:encoding(UTF-8)', $file or die;
	while (my $row = <$fh>) {
		chomp $row;
		if ($row =~ /^#/ or $row =~ /^\s/){ next; }
	}
	close($fh);	
}

sub changeGbp{
	my $val = shift;
	$val = $val / 1000000000;
	$val = &RoundXL ($val, 2);
	return $val;
}

sub RoundXL {
	sprintf("%.$_[1]f", $_[0]);
}

sub read_general_config{
	my ($file, $hash_ref) = @_;
	open my $fh, '<:encoding(UTF-8)', $file or die;
	while (my $row = <$fh>) {
		chomp $row;
		if ($row =~ /^#/){ next; } # pass header line
		if (length($row) == 0){ next; }

		my ($key, $value) = split /\=/, $row;
		$key = trim($key);
		$value = trim($value);
		$hash_ref->{$key} = $value;
	}
	close($fh);	
}

sub trim {
	my @result = @_;

	foreach (@result) {
		s/^\s+//;
		s/\s+$//;
	}

	return wantarray ? @result : $result[0];
}

sub checkFile{
	my $file = shift;
	if (!-f $file){
		die "ERROR ! not found <$file>\n";
	}
}

sub num{
        my $cnum = shift;
        if ($cnum =~ /\d\./){
                return $cnum;
        }
        while( $cnum =~ s/(\d+)(\d{3})\b/$1,$2/ ) {
                1;
        }
        my $result = sprintf "%s", $cnum;
        return $result;
}

sub printUsage{
	print "Usage: perl $0 <in.config> <in.pipeline.config>\n";
	print "Example: perl $0 /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_config.human.txt /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_pipeline_config.human.txt\n";
	exit;
}
