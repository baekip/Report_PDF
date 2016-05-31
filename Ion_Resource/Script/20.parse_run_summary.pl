#!/usr/bin/perl -w 

use warnings;
use strict;

if (@ARGV !=1){
	printUsage();
}

my $in_general_config = $ARGV[0];

my %info;

read_general_config( $in_general_config, \%info );
#read_pipeline_config();


my $project_path = $info{project_path};
my $figure_path = "$project_path/00_upload_file/01_figure_dir";
my $resource_path = "$project_path/report/resource/";

my $cmd_ISP_copy = "cp $figure_path/Bead_density_contour.png $resource_path/2-1_Run_Summary/c_photo_01.png";
system($cmd_ISP_copy);

my $cmd_trace_copy = "cp $figure_path/iontrace_Library.png $resource_path/2-1_Run_Summary/e_photo_01.png";
system($cmd_trace_copy);

sub cat_xls {
    my ($xls_file, $tbi_id, $col_num) = @_;
    my $cmd = "cat $xls_file | grep \"^$tbi_id\" | cut -f $col_num";
    print $cmd."\n";
    system ($cmd);
    # print $cmd."\n";
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
	print "Usage: perl $0 <in.config> <in.sample>\n";
	print "Example: perl $0 /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_config.human.txt\n";
	exit;
}
