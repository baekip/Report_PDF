use warnings;
use strict;

use File::Basename;
use Cwd qw(abs_path);
my $script_path = dirname (abs_path $0);
$script_path = $script_path."/Script";

if (@ARGV != 2){
	printUsage();
}

my $general_config_file = $ARGV[0];
my $pipeline_config_file = $ARGV[1];

my %info;
read_general_config( $general_config_file, \%info );

my $version = "V0.1";
my $dev_path = $info{dev_path};
my $project_path = $info{project_path};
my $project_id = $info{project_id};
my $out_path = "$project_path/report";
my $output_pdf = "$out_path/Analysis_report_$project_id.pdf"; #########
my $Rscript = "Rscript";
my $text2pdf = "$dev_path/wes/etc/text2pdf.jar"; ###
checkFile ( $text2pdf );
my $java = "/BiO/BioTools/java/jre1.7.0_51/bin/java";
checkFile( $java );

my $template_resource_path = "$dev_path/wes/Rare_Resource/PDF_resource"; ###
if (!-d $template_resource_path){
	die "ERROR ! not found template resource directory\n";
}

# make new_path
if (!-d $out_path){
	die "ERROR ! not found report directory in your project_directory <$project_path>\n";
}

# check before reults

`rm -r $out_path/temp\n`;
`rm -r $out_path/resource\n`;
`rm $output_pdf\n`;

=pod
if (-d "$out_path/temp" or -d "$out_path/resource" or -f $output_pdf){
	die "# Warning! Check your before results for making pdf\n".
	"rm -r $out_path/temp\n".
	"rm -r $out_path/resource\n".
	"rm $output_pdf\n";
}
=cut

# copy template resource directory into out_path;
my $resource_path = "$out_path/resource";
my $cmd_copy_template = "cp -rL $template_resource_path $resource_path";
system( $cmd_copy_template );

my $script_0 = $script_path."/0.parse_project_id.pl";
checkFile( $script_0 );

#my $script_0_1 = $script_path."/0-1.parse_kit_type.pl";
my $script_0_1 = $script_path."/0-1.parse_kit_type_sh.pl";
checkFile( $script_0_1);

my $script_1 = $script_path."/1.parse_sample_information.pl";
checkFile( $script_1 );

my $script_1_2 = $script_path."/1-2.parse_pedigree_information.pl";
checkFile( $script_1_2 );

my $script_2 = $script_path."/2.parse_summary_of_read_sequence.pl";
checkFile( $script_2 );

my $script_3 = $script_path."/3.parse_summary_of_coverage.pl";
checkFile( $script_3 );

my $script_4 = $script_path."/4.parse_summary_of_variant.pl";
checkFile( $script_4 );

my $script_4_plot = $script_path."/4.parse_summary_of_variant.R";
checkFile ( $script_4_plot );

my $script_6 = $script_path."/6.parse_fastqc_results.pl";
checkFile( $script_6 );

my $script_7 = $script_path."/7.parse_qualimap_results.pl";
checkFile( $script_7 );

my $script_8 = $script_path."/8.parse_Read_Sequence_Statistics.pl";
checkFile( $script_8 );
my $script_8_plot = $script_path."/8.parse_Read_Sequence_Statistics.R";
checkFile ( $script_8_plot );

my $script_9 = $script_path."/9.parse_sequence_and_enrichment_statistics.pl";
checkFile( $script_9 );
my $script_9_plot = $script_path."/9.parse_sequence_and_enrichment_statistics.R";
checkFile ( $script_9_plot );

my $script_10 =$script_path."/10.number_variant_by_type.pl";
checkFile( $script_10 );
my $script_10_plot =$script_path."/10.number_variant_by_type.R";
checkFile( $script_10_plot );

my $script_11 = $script_path."/11.number_of_effect.pl";
checkFile( $script_11 );
my $script_11_plot = $script_path."/11.number_of_effect.R";
checkFile( $script_11_plot);

my $script_12 = $script_path."/12.parse_pathogenic_variants.pl";
checkFile( $script_12 );

my $script_13 = $script_path."/13.parse_trans.pl";
checkFile( $script_13);
my $script_13_plot = $script_path."/13.parse_trans.R";
checkFile( $script_13_plot );

my $script_20 = $script_path."/20.summary_of_result.pl";
checkFile( $script_20 );

my $script_21_1 = $script_path."/21.parse_all_of_model.pl";
checkFile( $script_21_1);

my $script_21 = $script_path."/21.parse_recessive_model.pl";
checkFile( $script_21 );

my $script_22 = $script_path."/22.parse_dominant_model.pl";
checkFile( $script_22 );

my $script_23 = $script_path."/23.parse_compound_hetero_model.pl";
checkFile( $script_23 );

run_script ( $script_0, $general_config_file, $pipeline_config_file, "$resource_path/0-1_Cover_page/c_intro_title.txt" );
run_script_1 ( $script_0_1, $general_config_file, $pipeline_config_file);
run_script ( $script_1, $general_config_file, $pipeline_config_file, "$resource_path/1-1_Sample_Information/1_b_table_01.txt" );
run_script ( $script_1_2, $general_config_file, $pipeline_config_file, "$resource_path/1-1_Sample_Information/2_b_table_01.txt" );
run_script ( $script_2, $general_config_file, $pipeline_config_file, "$resource_path/3-1_Results_Summary/1_c_table_01.txt" );
run_script ( $script_3, $general_config_file, $pipeline_config_file, "$resource_path/3-1_Results_Summary/2_c_table_01.txt" );

run_script ( $script_4, $general_config_file, $pipeline_config_file, "$resource_path/3-2_Annotated_Variants/1_c_table_01.txt" );
my $cmd_script_4_plot = "$Rscript $script_4_plot \"$resource_path/3-2_Annotated_Variants/1_c_table_01.txt\" \"$resource_path/3-2_Annotated_Variants/1_b_photo_01.PNG\"";
system($cmd_script_4_plot);

run_script ($script_10, $general_config_file, $pipeline_config_file, "$resource_path/3-2_Annotated_Variants/2_c_table_01.txt" );
my $cmd_script_10_plot = "$Rscript $script_10_plot \"$resource_path/3-2_Annotated_Variants/2_c_table_01.txt\" \"$resource_path/3-2_Annotated_Variants/2_b_photo_01.PNG\"";
system($cmd_script_10_plot);

run_script ( $script_6, $general_config_file, $pipeline_config_file, "$resource_path/3-5_Results_QualityControl/1_a_photoMap_01.txt" );
run_script ( $script_7, $general_config_file, $pipeline_config_file, "$resource_path/3-5_Results_QualityControl/2_b_photoMap_01.txt" );

run_script ( $script_8, $general_config_file, $pipeline_config_file, "$resource_path/3-6_Results_Sequence/1_c_table_01.txt" );
my $cmd_script_8_plot = "$Rscript $script_8_plot \"$resource_path/3-6_Results_Sequence/1_c_table_01.txt\" \"$resource_path/3-6_Results_Sequence/1_b_photo_01.PNG\"";
system($cmd_script_8_plot);

run_script ( $script_9, $general_config_file, $pipeline_config_file, "$resource_path/3-6_Results_Sequence/2_c_table_01.txt" );
my $cmd_script_9_plot = "$Rscript $script_9_plot \"$resource_path/3-6_Results_Sequence/2_c_table_01.txt\" \"$resource_path/3-6_Results_Sequence/2_b_photo_01.PNG\"";
system($cmd_script_9_plot);


run_script ($script_11, $general_config_file, $pipeline_config_file, "$resource_path/3-2_Annotated_Variants/3_c_table_01.txt" );
my $cmd_script_11_plot = "$Rscript $script_11_plot \"$resource_path/3-2_Annotated_Variants/3_c_table_01.txt\" \"$resource_path/3-2_Annotated_Variants/3_b_photo_01.PNG\"";
system($cmd_script_11_plot);

run_script_1 ($script_12, $general_config_file, $pipeline_config_file);

run_script ($script_13, $general_config_file, $pipeline_config_file, "$resource_path/3-2_Annotated_Variants/4_c_table_01.txt" );
my $cmd_script_13_plot = "$Rscript $script_13_plot \"$resource_path/3-2_Annotated_Variants/4_c_table_01.txt\" \"$resource_path/3-2_Annotated_Variants/4_b_photo_01.PNG\"";
system($cmd_script_13_plot);

########ISSUE######
#cp /BiO/BioProject/Aju-Human-WES-2015-08-TBO150056/family1/result/32_filter_sta_run/multisample/multisample.filter.statistics.xls 
#$resource_path/3-3. Candidate_Variants/3.3.1 c_table_01.txt

run_script_2 ($script_20, $general_config_file);
run_script_2 ($script_21_1, $general_config_file);
#run_script ($script_21, $general_config_file, $pipeline_config_file, "$resource_path/3-4_Candidate_Variants/2_b_table_01.txt" );
#run_script ($script_22, $general_config_file, $pipeline_config_file, "$resource_path/3-4_Candidate_Variants/3_b_table_01.txt" );
#run_script ($script_23, $general_config_file, $pipeline_config_file, "$resource_path/3-4_Candidate_Variants/4_b_table_01.txt" );


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
my $cmd_make_pdf = "$java -jar $text2pdf -sp 2 -hl -fl -ht Analysis Report $version -ha r -fa r -r $resource_path -of $output_pdf -f $user_font_file -fi $user_CI_file";
print $cmd_make_pdf."\n";
system($cmd_make_pdf);



sub run_script{
	my ( $script, $config_1, $config_2, $outfile ) =  @_;
		
	my $command = "perl $script $config_1 $config_2 > \"$outfile\"";
	print $command."\n";
	system($command);
}

sub run_script_1{
    my ($script, $config_1, $config_2) = @_;
    my $command = "perl $script $config_1 $config_2 ";
    print $command."\n";
    system($command);
}

sub run_script_2{
    my ($script, $config_1) = @_;
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
