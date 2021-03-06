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
my $ftp_info   =  $info{ftp_info};
my ($ftp_server, $ftp_id, $ftp_pw, $ftp_dir) = split /\:/,$ftp_info;
#-----------------------ftp_info------------------------------

my $info_table = "$project_path/report/resource/4_Data_Analysis_Result/1_c_table_01.txt";
open my $fh_info, '>', $info_table or die;

print $fh_info "[[11],[],[TL],[280]]\n";
print $fh_info "FTP server \t $ftp_server \n";
print $fh_info "ID \t $ftp_id \n";
print $fh_info "PW \t $ftp_pw \n";
print $fh_info "Directory \t $ftp_dir \n"; 
close $info_table;

#----------------------data directory information-----------------

my $info_dir = "$project_path/report/resource/4_Data_Analysis_Result/2_b_label.txt";
open my $fh_dir, '>', $info_dir or die;

print $fh_dir "[[12]]\n";
print $fh_dir "     - Main directory name: $ftp_dir \n";
print $fh_dir "     - Containing two sub-directories, 01.RawData and 02.Analysis \n";
print $fh_dir "     - 01.Raw: containing raw sequencing gzip files \n";
print $fh_dir "     - 02.Analysis: containing WGRS analysis results \n";
print $fh_dir "     - Below is an examples: \n";

close $fh_dir;



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
