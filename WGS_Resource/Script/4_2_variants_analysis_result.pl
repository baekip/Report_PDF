#!/usr/bin/perl

use warnings;
use strict;

if (@ARGV !=1){
	printUsage();
}

my $in_general_config = $ARGV[0];
my %info;

read_general_config( $in_general_config, \%info );
my @list_delivery_tbi_id = split /\,/, $info{delivery_tbi_id};
my $project_path = $info{project_path};
my $result_path = "$project_path/result/";
my $stat_vcf_path = "$result_path/23_statistics_vcf_run/multisample";
my $multi_SNPs_xls = "$stat_vcf_path/multisample.SNPs.stat.xls";
checkFile($multi_SNPs_xls);
my $multi_INDELs_xls = "$stat_vcf_path/multisample.InDels.stat.xls";
checkFile($multi_INDELs_xls);
#-----------------------C_Statistics_of_Indels_and_SNPs------------------------------
my $no_indel_table = "$project_path/report/resource/4_Data_Analysis_Result/3_b_table_01.txt";

open my $fh_indel_table, '>', $no_indel_table or die;
print $fh_indel_table "[[11],[],[TL],[100]]\n";
my $cmd_indel_copy = "cat $multi_INDELs_xls >> $no_indel_table ";
system ($cmd_indel_copy);
close $fh_indel_table;

=pod
open my $fh_indel, '<:encoding(UTF-8)', $multi_INDELs_xls or die; 
while (my $row = <$fh_indel>){
    chomp $row; 
    print $row."\n";
}
close $fh_indel;
=cut

my $no_snps_table = "$project_path/report/resource/4_Data_Analysis_Result/3_c_table_01.txt";

open my $fh_snps_table, '>', $no_snps_table or die;
print $fh_snps_table "[[11],[],[TL],[100]]\n";
my $cmd_snp_copy = "cat $multi_SNPs_xls >> $no_snps_table ";
system($cmd_snp_copy);
close $fh_snps_table;

#-----------------------------------sub module----------------------------------
sub RoundXL {
    sprintf("%.$_[1]f",$_[0]);
}

sub read_pipeline_config{
	my $file = shift;
	open my $fh, '<:encoding(UTF-8)', $file or die;
	while (my $row = <$fh>) {
		chomp $row;
		if ($row =~ /^#/ or $row =~ /^\s/){ next; }
	}
	close($fh);	
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

sub printUsage{
	print "Usage: perl $0 <in.config> <in.pipeline.config>\n";
	print "Example: perl $0 /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_config.human.txt /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_pipeline_config.human.txt\n";
	exit;
}
