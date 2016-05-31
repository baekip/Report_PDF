use warnings;
use strict;

use File::Basename;
use Cwd qw(abs_path);
my $script_path = dirname (abs_path $0);
$script_path = $script_path."/Script";

my $general_config_file = $ARGV[0];
my $pipeline_config_file = $ARGV[1];

if (@ARGV !=2){
    printUsage();
}

my %info;
read_general_config ($general_config_file, \%info);

my $version = "V0.4";
my $project_path = $info{project_path};
my $out_path = "$project_path/report";
my $project_id = $info{project_id};
my $dev_path = $info{dev_path};
my $Rscript = "Rscript";
my $java = "/BiO/BioTools/java/jre1.7.0_51/bin/java";
checkFile( $java );
my $text2pdf = "$dev_path/wes/etc/text2pdf.jar"; 
checkFile ( $text2pdf );

my $template_resource_path = "$dev_path/wes/Cancer_Resource/PDF_resource"; ###
if (!-d $template_resource_path){
	die "ERROR ! not found template resource directory\n";
}

# make new_path
if (!-d $out_path){
	die "ERROR ! not found report directory in your project_directory <$project_path>\n";
}

# check before reults
my $output_pdf = "$out_path/Analysis_report_".$project_id.".pdf"; #########


print `rm -r $out_path/temp\n`;
print `rm -r $out_path/resource\n`;
print `rm $output_pdf\n`;

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
checkFile( $script_0_1 );

my $script_1 = $script_path."/1.parse_sample_information.pl";
checkFile( $script_1 );

my $script_2 = $script_path."/2.parse_summary_of_read_sequence.pl";
checkFile( $script_2 );

my $script_3 = $script_path."/3.parse_summary_of_coverage.pl";
checkFile( $script_3 );

my $script_5 = $script_path."/5.parse_allele_frq.pl";
checkFile ( $script_5 );

my $script_6 = $script_path."/6.parse_fastqc_results.pl";
checkFile( $script_6 );

my $script_7 = $script_path."/7.parse_qualimap_results.pl";
checkFile( $script_7 );

my $script_8 = $script_path."/8.parse_Read_Sequence_Statistics.pl";
checkFile( $script_8);
my $script_8_plot = $script_path."/8.parse_Read_Sequence_Statistics.R";
checkFile ( $script_8_plot );

my $script_9 = $script_path."/9.parse_sequence_and_enrichment_statistics.pl";
checkFile( $script_9 );
my $script_9_plot = $script_path."/9.parse_sequence_and_enrichment_statistics.R";
checkFile ( $script_9_plot );

my $script_12 = $script_path."/12.parse_pathogenic_variants.pl";
checkFile( $script_12);

my $script_20 = $script_path."/20.somatic_information.pl";
checkFile( $script_20);

my $script_21 = $script_path."/21.parse_summary_of_somatic.pl";
checkFile( $script_21);
my $script_21_plot = $script_path."/21.parse_summary_of_somatic.R";
checkFile( $script_21_plot);

my $script_22 = $script_path."/22.number_variant_by_type.pl";
checkFile( $script_22);
my $script_22_plot = $script_path."/22.number_variant_by_type.R";
checkFile( $script_22_plot);

my $script_23 = $script_path."/23.number_of_effect.pl";
checkFile ($script_23);
my $script_23_plot = $script_path."/23.number_of_effect.R";
checkFile ($script_23_plot);

my $script_24 = $script_path."/24.parse_trans.pl";
checkFile ($script_24);
my $script_24_plot = $script_path."/24.parse_trans.R";
checkFile ($script_24_plot);

my $script_25 = $script_path."/25.parse_variants_information.pl";
checkFile ($script_25);

my $script_26 = $script_path."/26.parse_transition_transversion.pl";
checkFile($script_26);
my $script_26_plot = $script_path."/26.parse_transition_transversion.R";
checkFile($script_26_plot);


####################Run Script#######################
run_script ( $script_0, $general_config_file, $pipeline_config_file, "$resource_path/0-1_Cover_page/c_intro_title.txt" );
run_script_1 ( $script_0_1, $general_config_file, $pipeline_config_file);
run_script ( $script_1, $general_config_file, $pipeline_config_file, "$resource_path/1-1_Sample_Information/c_table_01.txt" );
run_script ( $script_2, $general_config_file, $pipeline_config_file, "$resource_path/3-1_Results_Summary/1_c_table_01.txt" );
run_script ( $script_3, $general_config_file, $pipeline_config_file, "$resource_path/3-1_Results_Summary/2_c_table_01.txt" );

#run_script ( $script_5, $general_config_file, $pipeline_config_file, "$resource_path/3-3. Results_QualityControl/3.2.3 b_photoMap_01.txt" );


run_script ( $script_6, $general_config_file, $pipeline_config_file, "$resource_path/3-3_Results_QualityControl/1_a_photoMap_01.txt" );
run_script ( $script_7, $general_config_file, $pipeline_config_file, "$resource_path/3-3_Results_QualityControl/2_b_photoMap_01.txt" );

run_script ($script_8, $general_config_file, $pipeline_config_file, "$resource_path/3-4_Results_Sequence/1_c_table_01.txt");
my $cmd_script_8_plot = "$Rscript $script_8_plot \"$resource_path/3-4_Results_Sequence/1_c_table_01.txt\" \"$resource_path/3-4_Results_Sequence/1_b_photo_01.PNG\"";
system($cmd_script_8_plot);

run_script ( $script_9, $general_config_file, $pipeline_config_file, "$resource_path/3-4_Results_Sequence/2_c_table_01.txt" );
my $cmd_script_9_plot = "$Rscript $script_9_plot \"$resource_path/3-4_Results_Sequence/2_c_table_01.txt\" \"$resource_path/3-4_Results_Sequence/2_b_photo_01.PNG\"";
system($cmd_script_9_plot);

#run_script_1 ($script_12, $general_config_file, $pipeline_config_file);

run_script ( $script_20, $general_config_file, $pipeline_config_file, "$resource_path/3-2_Somatic_Information/1_b_table_01.txt");

run_script ( $script_21, $general_config_file, $pipeline_config_file, "$resource_path/3-2_Somatic_Information/2_c_table_01.txt");
my $cmd_script_21_plot = "$Rscript $script_21_plot \"$resource_path/3-2_Somatic_Information/2_c_table_01.txt\" \"$resource_path/3-2_Somatic_Information/2_b_photo_01.png\"";
system($cmd_script_21_plot);

run_script ( $script_22, $general_config_file, $pipeline_config_file, "$resource_path/3-2_Somatic_Information/3_c_table_01.txt");
my $cmd_script_22_plot = "$Rscript $script_22_plot \"$resource_path/3-2_Somatic_Information/3_c_table_01.txt\" \"$resource_path/3-2_Somatic_Information/3_b_photo_01.PNG\"";
system($cmd_script_22_plot);

run_script ( $script_23, $general_config_file, $pipeline_config_file, "$resource_path/3-2_Somatic_Information/4_c_table_01.txt");
my $cmd_script_23_plot = "$Rscript $script_23_plot \"$resource_path/3-2_Somatic_Information/4_c_table_01.txt\" \"$resource_path/3-2_Somatic_Information/4_b_photo_01.PNG\"";
system($cmd_script_23_plot);

run_script ( $script_24, $general_config_file, $pipeline_config_file, "$resource_path/3-2_Somatic_Information/5_c_table_01.txt");
my $cmd_script_24_plot = "$Rscript $script_24_plot \"$resource_path/3-2_Somatic_Information/5_c_table_01.txt\" \"$resource_path/3-2_Somatic_Information/5_b_photo_01.PNG\"";
system($cmd_script_24_plot);

run_script_1 ( $script_25, $general_config_file, $pipeline_config_file);

run_script ( $script_26, $general_config_file, $pipeline_config_file, "$resource_path/3-2_Somatic_Information/6_c_table_01.txt");
my $cmd_script_26_plot = "$Rscript $script_26_plot \"$resource_path/3-2_Somatic_Information/6_c_table_01.txt\" \"$resource_path/3-2_Somatic_Information/6_b_photo_01.PNG\"";
system($cmd_script_26_plot);




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
	my ( $script, $config_1, $config_2) =  @_;
	my $command = "perl $script $config_1 $config_2 ";
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
