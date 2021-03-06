#!/usr/bin/perl

use warnings;
use strict;

use File::Basename;
use Cwd qw(abs_path);
my $now_script_path = dirname (abs_path $0);
my $script_path = $now_script_path."/Script";

if (@ARGV != 1){
	printUsage();
}

my $general_config_file = $ARGV[0];

my %info;
read_general_config( $general_config_file, \%info );

my $java = $info{java_1_7};
checkFile( $java );

my $Rscript = "Rscript";
my $dev_path = $info{dev_path};
my $project_id = $info{project_id};
my $project_path = $info{project_path};
my $out_path = "$project_path/report";
my $text2pdf = "$dev_path/etc/text2pdf.jar"; ###
checkFile ( $text2pdf );
my $output_pdf = "$out_path/Analysis_report_".$project_id.".pdf"; #########
my $template_resource_path = "$dev_path/wes/WGS_Resource/PDF_resource"; ###
my $resource_path = "$out_path/resource";

if (!-d $template_resource_path){
	die "ERROR ! not found template resource directory\n";
}
# make new_path
if (!-d $out_path){
	die "ERROR ! not found report directory in your project_directory <$project_path>\n";
}

`rm -r $out_path/temp\n`;
`rm -r $out_path/resource\n`;
`rm $output_pdf\n`;
# check before reults
if (-d "$out_path/temp" or -d "$out_path/resource" or -f $output_pdf){
	die "# Warning! Check your before results for making pdf\n".
	"rm -r $out_path/temp\n".
	"rm -r $out_path/resource\n".
	"rm $output_pdf\n";
}

# copy template resource directory into out_path;
my $cmd_copy_template = "cp -rL $template_resource_path $resource_path";
system ($cmd_copy_template) and die "ERROR with".$!."\n";

my $script_0 = $script_path."/0_parse_project_id.pl";
checkFile( $script_0 );

my $script_1 = $script_path."/1_project_information.pl";
checkFile( $script_1 );

my $script_2 = $script_path."/2_read_quality.pl";
checkFile( $script_2 );
my $script_2_plot = $script_path."/2_coverage_depth_of_raw_data.R";
checkFile( $script_2_plot);

my $script_4_1 = $script_path."/4_1_data_analysis_result.pl";
checkFile( $script_4_1);

my $script_4_2 = $script_path."/4_2_variants_analysis_result.pl";
checkFile( $script_4_2);

my $script_5 = $script_path."/5_parse_summary_of_variant.pl";
checkFile( $script_5);
my $script_5_plot = $script_path."/5_parse_summary_of_variant.R";
checkFile( $script_5_plot);

run_script ($script_0, $general_config_file, "$resource_path/0-1_Cover_page/c_intro_title.txt");
run_script_1 ($script_1, $general_config_file);
run_script_1 ($script_2, $general_config_file);
my $cmd_script_2_plot = "$Rscript $script_2_plot \"$resource_path/2_Read_Quality/3_c_table_01.txt\" \"$resource_path/2_Read_Quality/3_b_photo_01.PNG\"";
system($cmd_script_2_plot);

run_script_1 ($script_4_1, $general_config_file);
run_script_1 ($script_4_2, $general_config_file);
run_script ($script_5, $general_config_file, "$resource_path/4_Data_Analysis_Result/4_c_table_01.txt");
my $cmd_script_5_plot = "$Rscript $script_5_plot \"$resource_path/4_Data_Analysis_Result/4_c_table_01.txt\" \"$resource_path/4_Data_Analysis_Result/4_b_photo_01.PNG\"";
system($cmd_script_5_plot);


#--------------Make a Report--------------------------
# sp : start page 
# hl : header line
# fl : floating line
# ht : header title
# ha : header arrange
# fa : floating arrange
# r : resource folder
# of : output pdf filename
chdir $out_path;
my $user_font_file = "$dev_path/wes/etc/Font/SangSangBodyM.ttf";
my $user_CI_file = "$dev_path/wes/etc/CI/Theragen_CI.png";
my $report_version = "Analysis Report V0.2";

my $cmd_make_pdf = "$java -jar $text2pdf -sp 2 -hl -fl -ht $report_version -ha r -fa r -r $resource_path -of $output_pdf -f $user_font_file -fi $user_CI_file";
print $cmd_make_pdf."\n";
system($cmd_make_pdf);
`rm -r $out_path/temp\n`;

sub run_script{
	my ( $script, $config_1, $outfile ) =  @_;
		
	my $command = "perl $script $config_1  > \"$outfile\"";
	print $command."\n";
	system($command);
}

sub run_script_1{
    my ( $script, $config_1 ) = @_;

    my $command = "perl $script $config_1";
    print $command."\n";
    system($command);
}


sub checkFile{
	my $file = shift;
	if (!-f $file){
		die "ERROR ! not found <$file>\n";
	}
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

sub printUsage{
	print "Usage: perl $0 <in.config> <in.pipeline.config>\n";
	print "Example: perl $0 /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_config.human.txt /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_pipeline_config.human.txt\n";
	exit;
}
