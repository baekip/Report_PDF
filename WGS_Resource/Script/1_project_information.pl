#!/usr/bin/perl -w 

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
my $rawdata_path = $info{rawdata_path};
my $Sequencing_Statistics_Result_xlsx = "$rawdata_path/Sequencing_Statistics_Result.xlsx";
checkFile( $Sequencing_Statistics_Result_xlsx );
my $Sequencing_Statistics_Result_csv = "$rawdata_path/Sequencing_Statistics_Result.csv";
my $Sequencing_Statistics_Result_xls = "$rawdata_path/Sequencing_Statistics_Result.xls";
my $resource_path = "$project_path/report/resource";
make_dir($resource_path);
my $information_path = "$resource_path/1_Project_Information";
make_dir($information_path);
#----------------Report Sample Info-----------------
my $customer = $info{customer};
my $institute = $info{institute};
my $project_id = $info{project_id};
my $species = $info{species};
my $reference_dict = $info{reference_dict};
my $sample_id = $info{sample_id};
my @sample_list = split /\,/, $sample_id;
my $sample_number = $#sample_list + 1;
#---------------------------------------------------
my $client_label = "$information_path/a_label.txt";
open my $fh_client, '>', $client_label or die;
print $fh_client "[[20,15]]\n";
print $fh_client "A. Client\n";
print $fh_client "\t -Name: $customer \n";
print $fh_client "\t -Organization: $institute \n\n\n";
close $fh_client;

my $analysis_label = "$information_path/b_label.txt";
open my $fh_analysis, '>', $analysis_label or die;
print $fh_analysis "[[20,15]]\n";
print $fh_analysis "B. Analysis Information \n";
print $fh_analysis "\t -Project ID: $project_id \n";
print $fh_analysis "\t -Application: Whole genome Re-Sequencing \n";
print $fh_analysis "\t -Species: $species \n";
print $fh_analysis "\t -Sample Number: $sample_number \n\n\n";
close $fh_analysis;

#---------------Project Information------------------
my $cmd_csv_transfer = "/TBI/People/tbi/baekip/.local/bin/xlsx2csv $Sequencing_Statistics_Result_xlsx > $Sequencing_Statistics_Result_csv ";
system($cmd_csv_transfer);
my $cmd_xls_transfer = "cat $Sequencing_Statistics_Result_csv \| tr \',\' \'\\t\' > $Sequencing_Statistics_Result_xls ";
system($cmd_xls_transfer);

#my $index_label = "$information_path/c_1_label.txt";
#open my $fh_index, '>', $index_label or die;
#print $fh_index "[[20]]\n";
#print $fh_index "C. Sample Index \n";
#close $fh_index;

my $index_table = "$information_path/c_2_table_01.txt";
open my $fh_table, '>', $index_table or die;
print $fh_table "[[13]]\n";
print $fh_table "Delivery ID\tSequence ID\tSample ID\tInfo\n";
foreach ( @list_delivery_tbi_id ){
	my ($delivery_id,$tbi_id,$sample_id) = split /\:/, $_;
        my $info = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 5`;
        chomp($info);
        print $fh_table "$delivery_id\t$tbi_id\t$sample_id\t$info\n";
}
close $fh_table;

#--------------Reference Information----------------
my $ref_info_lable = "$resource_path/1_Project_Information/d_2_label.txt"; 
my $ref_table_tmp = "$resource_path/1_Project_Information/d_3_tmp.txt";
my $ref_info_table = "$resource_path/1_Project_Information/d_3_table_01.txt";
my $no_scaffold = 0;
my $no_chr = 0;
my $no_mit = 0;
my $no_chl = 0;

open my $fh_dict, '<:encoding(UTF-8)', $reference_dict or die;
open my $fh_ref_tmp, '>', $ref_table_tmp or die;
open my $fh_ref_table, '>', $ref_info_table or die;

print $fh_ref_table "[[12],[],[],[200]]\n";
print $fh_ref_table "Chromosome\tSequence-Length(bp)\n";

while (my $row = <$fh_dict>){
    chomp $row;
#    my $sn_header; my $chr_name;
#    my $ln_header; my $chr_length;
    if ( $row =~ /^\@SQ/){
        my @row_list = split /\t/, $row;
        my($sn_header, $chr_name) = split /\:/, $row_list[1];
        my($ln_header, $chr_length) = split /\:/, $row_list[2];
#        print "$chr_name\t$chr_length\n";
        if ($chr_name =~ /^Chr/){
            $no_chr += 1;
            print $fh_ref_tmp "$chr_name\t$chr_length\n";
        }elsif ($chr_name =~ /^Mit/){
            print $no_mit += 1;
            print $fh_ref_tmp "$chr_name\t$chr_length\n";
        }elsif ($chr_name =~ /^Chl/){
            $no_chl += 1;
            print $fh_ref_tmp "$chr_name\t$chr_length\n";
        }elsif ($chr_name =~ /Scaffold/){
            $no_scaffold += 1;
        }
    }
} close $fh_dict;
close $fh_ref_table;
close $fh_ref_tmp;
my $cmd_arrage = "cat $ref_table_tmp \| sort >> $ref_info_table ";
system($cmd_arrage); 
#print $no_scaffold."\n";

open my $fh_ref_lable, '>', $ref_info_lable or die;
print $fh_ref_lable "[[15,12]]\n";
print $fh_ref_lable "- Species: $species \n\n";
print $fh_ref_lable "\t  - The Number of Scaffolds: $no_scaffold \n";
print $fh_ref_lable "\t  - The Number of Chromosomes: $no_chr \n";
print $fh_ref_lable "\t  - The Number of Chloroplasts: $no_chl \n";
print $fh_ref_lable "\t  - The Number of Mitochodrion Sequences: $no_mit \n\n\n\n\n";
close $fh_ref_lable;

#--------------sub module---------------------------
sub make_dir {
    my $dir_name = shift;
    unless (-d $dir_name) {
        my $cmd_mkdir = "mkdir -p $dir_name";
        system($cmd_mkdir);
    }
}

sub cat_xls {
    my ($xls_file, $tbi_id, $col_num) = @_;
    my $cmd = "cat $xls_file | grep \"^$tbi_id\" | cut -f $col_num";
    print $cmd."\n";
    system ($cmd);
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
