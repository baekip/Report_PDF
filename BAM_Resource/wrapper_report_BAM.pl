use warnings;
use strict;

use File::Basename;
use Cwd qw(abs_path);
my $now_script_path = dirname (abs_path $0);
my $script_path = $now_script_path."/Script";

if (@ARGV != 2){
	printUsage();
}

my $general_config_file = $ARGV[0];
my $pipeline_config_file = $ARGV[1];

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
my $template_resource_path = "$dev_path/wes/BAM_Resource/PDF_resource"; ###
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

my $script_0 = $script_path."/0.parse_project_id.pl";
checkFile( $script_0 );

#my $script_0_1 = $script_path."/0-1.parse_kit_type.pl";
my $script_0_1 = $script_path."/0-1.parse_kit_type_sh.pl";
checkFile( $script_0_1 );

my $script_1 = $script_path."/1.parse_sample_information.pl";
checkFile( $script_1 );

my $script_2 = $script_path."/2.parse_summary_of_read_sequence.pl";
checkFile( $script_2 );

my $script_3 = $script_path."/3.parse_summary_of_coverage.pl";
checkFile( $script_3 );
my $script_3_plot = $script_path."/3.parse_summary_of_coverage.R";
checkFile( $script_3_plot );

my $script_5 = $script_path."/5.parse_allele_frq.pl";
checkFile( $script_5);

my $script_6 = $script_path."/6.parse_fastqc_results.pl";
checkFile( $script_6 );

my $script_7 = $script_path."/7.parse_qualimap_results.pl";
checkFile( $script_7 );

my $script_8 = $script_path."/8.parse_Read_Sequence_Statistics.pl";
my $script_8_plot = $script_path."/8.parse_Read_Sequence_Statistics.R";
checkFile ( $script_8_plot );

my $script_9 = $script_path."/9.parse_sequence_and_enrichment_statistics.pl";
checkFile( $script_9 );
my $script_9_plot = $script_path."/9.parse_sequence_and_enrichment_statistics.R";
checkFile ( $script_9_plot );

run_script ( $script_0, $general_config_file, $pipeline_config_file, "$resource_path/0-1_Cover_page/c_intro_title.txt" );
run_script_1 ( $script_0_1, $general_config_file, $pipeline_config_file);
run_script ( $script_1, $general_config_file, $pipeline_config_file, "$resource_path/1-1_Sample_Information/c_table_01.txt" );
run_script ( $script_2, $general_config_file, $pipeline_config_file, "$resource_path/3-1_Results_Summary/1_d_table_01.txt" );
run_script ( $script_3, $general_config_file, $pipeline_config_file, "$resource_path/3-1_Results_Summary/2_c_table_01.txt" );
my $cmd_script_3_plot = "$Rscript $script_3_plot \"$resource_path/3-1_Results_Summary/2_c_table_01.txt\" \"$resource_path/3-1_Results_Summary/2_b_photo_01.PNG\"";
system($cmd_script_3_plot);

#run_script ( $script_5, $general_config_file, $pipeline_config_file, "$resource_path/3-4. Allele_Distribution/3.4.1 b_photoMap_01.txt" );
run_script ( $script_6, $general_config_file, $pipeline_config_file, "$resource_path/3-2_Results_QualityControl/1_a_photoMap_01.txt" );
run_script ( $script_7, $general_config_file, $pipeline_config_file, "$resource_path/3-2_Results_QualityControl/2_b_photoMap_01.txt" );

#run_script ($script_8, $general_config_file, $pipeline_config_file, "$resource_path/3-1_Results_Summary/0_Summary_of_Reads.txt" );
#my $cmd_script_8_plot = "$Rscript $script_8_plot \"$resource_path/3-1_Results_Summary/0_Summary_of_Reads.txt\" \"$resource_path/3-1_Results_Summary/1_c_photo_01.PNG\"";
#system($cmd_script_8_plot);
#run_script ( $script_9, $general_config_file, $pipeline_config_file, "$resource_path/3-3_Results_Sequence/2_c_table_01.txt" );
#my $cmd_script_9_plot = "$Rscript $script_9_plot \"$resource_path/3-3_Results_Sequence/2_c_table_01.txt\" \"$resource_path/3-3_Results_Sequence/2_b_photo_01.PNG\"";
#system($cmd_script_9_plot);

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
my $report_version = "Analysis Report V2.3";

my $cmd_make_pdf = "$java -jar $text2pdf -sp 2 -hl -fl -ht $report_version -ha r -fa r -r $resource_path -of $output_pdf -f $user_font_file -fi $user_CI_file";
print $cmd_make_pdf."\n";
system($cmd_make_pdf);
`rm -r $out_path/temp\n`;

sub run_script{
	my ( $script, $config_1, $config_2, $outfile ) =  @_;
		
	my $command = "perl $script $config_1 $config_2 > \"$outfile\"";
	print $command."\n";
	system($command);
}

sub run_script_1{
    my ( $script, $config_1, $config_2 ) = @_;

    my $command = "perl $script $config_1 $config_2";
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
