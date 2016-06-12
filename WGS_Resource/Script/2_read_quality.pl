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
my $rawdata_path = $info{rawdata_path};
my $report_path = "$project_path/report";
make_dir($report_path);


#-----------------------------Make a tab-delimited file---------------------------------
my $stat_dir = "$project_path/result/19_statistics_run";
my $cmd_merge = "cat $stat_dir/*/* \| sort \| uniq > $project_path/report/alignment.statistics.xls";
system ($cmd_merge);
my $alignment_statistics_xls = "$report_path/alignment.statistics.xls";
checkFile ( $alignment_statistics_xls );

my $sequencing_statistics_xls = "$rawdata_path/Sequencing_Statistics_Result.xls";
checkFile ( $sequencing_statistics_xls);

#----------------------------Statistics_of_Raw_Data-------------------------------------

my $stat_rawdata = "$report_path/resource/2_Read_Quality/1_c_table_01.txt";
open my $fh_stat_rawdata, '>', $stat_rawdata or die;

print $fh_stat_rawdata "[[11],[],[],[100]]\n";
print $fh_stat_rawdata "Delivery ID\\n(Sample ID)\ttotal\\nread\t".
	"total\\nbases\\n(%)\t".
	"GC (%)\t".
	"Q20 (%)\t".
	"Q30 (%)\n";
foreach ( @list_delivery_tbi_id ){
	my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;
	my $sequence_read = `cat $sequencing_statistics_xls | grep \"^$tbi_id\" | cut -f 3 | head -n 1`;
	chomp($sequence_read);
        $sequence_read = num($sequence_read);
	my $sequence_base = `cat $sequencing_statistics_xls | grep \"^$tbi_id\" | cut -f 4 | head -n 1`;
	chomp($sequence_base);
        $sequence_base = num($sequence_base);
	my $gc_rate = `cat $sequencing_statistics_xls | grep \"^$tbi_id\" | cut -f 7 | head -n 1`;
	chomp($gc_rate);
	my $q20 = `cat $sequencing_statistics_xls | grep \"^$tbi_id\" | cut -f 17 | head -n 1`;
	chomp($q20);
        $q20 = &RoundXL ($q20, 2)."%";
	my $q30 = `cat $sequencing_statistics_xls | grep \"^$tbi_id\" | cut -f 15 | head -n 1`;
	chomp($q30);
	print $fh_stat_rawdata "$delivery_id\\n($tbi_id)\t$sequence_read\t$sequence_base\t$gc_rate\t$q20\t$q30\n";
}
close $fh_stat_rawdata;

#---------------------------Statistics_of_Filtered_Raw_Data------------------------------------

my $stat_filtered = "$report_path/resource/2_Read_Quality/2_b_table_01.txt";
open my $fh_stat_filtered, '>', $stat_filtered or die;
print $fh_stat_filtered "[[11],[],[],[100]]\n";
print $fh_stat_filtered "Delivery ID\\n(Sample ID)\tSequence\\nread\t".
	"Clean\\nread\\n(%)\t".
	"Total bases\\n(bp)\t".
	"Clean bases\\n(%)\t".
	"Mapped reads\\n(%)\t".
	"Average\\nDepth\n";
foreach ( @list_delivery_tbi_id ){
	my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;

	my $sequence_read = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 2 | head -n 1`;
	chomp($sequence_read);
        $sequence_read = num($sequence_read);

        my $clean_read = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 3 | head -n 1`;
        chomp($clean_read);
        $clean_read = num($clean_read);
        my $clean_rate = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 4 | head -n 1`;
        chomp($clean_rate);
        $clean_rate = $clean_rate."%";
        
        my $sequence_base = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 5 | head -n 1`;
	chomp($sequence_base);
        $sequence_base = num($sequence_base);
        
        my $clean_base = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 6 | head -n 1`;
        chomp($clean_base);
        $clean_base = num($clean_base);
        my $clean_base_rate = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 7 | head -n 1`;
        chomp($clean_base_rate);
        $clean_base_rate = $clean_base_rate."%";

        my $mapped_reads = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 10 | head -n 1` ;
        chomp($mapped_reads);
        $mapped_reads = num($mapped_reads);
        my $mapped_rate = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 11 | head -n 1` ;
        chomp($mapped_rate);
        $mapped_rate = $mapped_rate."%";

        my $average_depth = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 14 | head -n 1` ;
        chomp($average_depth);

	print $fh_stat_filtered "$delivery_id\\n($tbi_id)\t$sequence_read\t$clean_read\\n($clean_rate)\t$sequence_base\t$clean_base\\n($clean_base_rate)\t$mapped_reads\\n($mapped_rate)\t$average_depth\n";
}
close $fh_stat_filtered;

#--------------------------Coverage_Depth_Of_Filtered_Raw_Data---------------------------------------------

my $coverage_depth = "$report_path/resource/2_Read_Quality/3_b_table_01.txt";
open my $fh_coverage, '>', $coverage_depth or die;

print $fh_coverage "[[11],[],[],[100]]\n";
print $fh_coverage "Delivery ID\\n(Sample ID)\tReference\\nLength\t".
	"Coverage\\n1X(%)\t".
	"Coverage\\n2X(%)\t".
	"Coverage\\n5X(%)\t".
	"Coverage\\n10X(%)\t".
	"Coverage\\n20X(%)\t".
	"Coverage\\n30X(%)\t".
	"Coverage\\n40X(%)\n";
foreach ( @list_delivery_tbi_id ){
	my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;

        my $reference_bp = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 15 | head -n 1`;
        chomp($reference_bp);
        $reference_bp = num($reference_bp);
	
        my $coverage_1x = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 16 | head -n 1`;
	chomp($coverage_1x);
        $coverage_1x = $coverage_1x."%";
        my $coverage_2x = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 17 | head -n 1`;
	chomp($coverage_2x);
        $coverage_2x = $coverage_2x."%";
        my $coverage_5x = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 18 | head -n 1`;
	chomp($coverage_5x);
        $coverage_5x = $coverage_5x."%";
        my $coverage_10x = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 19 | head -n 1`;
	chomp($coverage_10x);
        $coverage_10x = $coverage_10x."%";
        my $coverage_20x = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 20 | head -n 1`;
	chomp($coverage_20x);
        $coverage_20x = $coverage_20x."%";
        my $coverage_30x = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 21 | head -n 1`;
	chomp($coverage_30x);
        $coverage_30x = $coverage_30x."%";
        my $coverage_50x = `cat $alignment_statistics_xls | grep \"^$delivery_id\" | cut -f 22 | head -n 1`;
	chomp($coverage_50x);
        $coverage_50x = $coverage_50x."%";
        
        print $fh_coverage "$delivery_id\\n($tbi_id)\t$reference_bp\t$coverage_1x\t$coverage_2x\t$coverage_5x\t$coverage_10x\t$coverage_20x\t$coverage_30x\t$coverage_50x\n";
}

close $fh_coverage;

#---------------------------------------Reference Information--------------------------------------





#---------------------------------------sub module--------------------------------------
sub RoundXL {
    sprintf("%.$_[1]f", $_[0]);
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

sub make_dir {
    my $dir_name = shift;
    unless (-d $dir_name){
        my $cmd_mkdir = "mkdir -p $dir_name";
        system($cmd_mkdir);
    }
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
