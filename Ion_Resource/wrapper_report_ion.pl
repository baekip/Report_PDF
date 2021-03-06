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
my $ion_sample = $ARGV[1];

my %info;
read_general_config( $general_config_file, \%info );

my $java = "/BiO/BioTools/java/jre1.7.0_51/bin/java";
checkFile( $java );

my $Rscript = "Rscript";
my $dev_path = $info{dev_path};
my $project_id = $info{project_id};
my $project_path = $info{project_path};
my $out_path = "$project_path/report";
my $text2pdf = "$dev_path/etc/text2pdf.jar"; ###
checkFile ( $text2pdf );
my $output_pdf = "$out_path/Analysis_report_".$project_id.".pdf"; #########
my $template_resource_path = "$dev_path/wes/Ion_Resource/PDF_resource"; ###
my $resource_path = "$out_path/resource";

if (!-d $template_resource_path){
	die "ERROR ! not found template resource directory\n";
}
# make new_path
if (!-d $out_path){
    my $report_dir = "$project_path/report";
    system (mkdir -p $report_dir);
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

my $script_10 = $script_path."/10.parse_experiment.pl";
checkFile( $script_10 );

my $script_20 = $script_path."/20.parse_run_summary.pl";
checkFile( $script_20 );

my $script_30 = $script_path."/30.parse_bc_summary.pl";
checkFile( $script_30 );

my $script_31 = $script_path."/31.parse_amplicon_gc_contents.pl";
checkFile( $script_31 );

run_script ( $script_0, $general_config_file, $ion_sample, "$resource_path/0-1_Cover_page/c_intro_title.txt" );
run_script ( $script_10, $general_config_file, $ion_sample, "$resource_path/1-1_Experiment_Result/c_table_01.txt");
run_script_1 ( $script_20, $general_config_file);
run_script ( $script_30, $general_config_file, $ion_sample, "$resource_path/3-1_Results_Summary/1_c_table_01.txt");
run_script ( $script_31, $general_config_file, $ion_sample, "$resource_path/3-2_Results_QualityControl/1_a_photoMap_01.txt");


#run_script_1 ( $script_20, $general_config_file);

sub checkFile {
    my $file = shift;
    if (!-f $file) {
        die "ERRPR! not found <$file> \n";
    }
}

sub Input_Check{
	my ($script, $file) = @_;
	$script = "$script_path/$file";
        if (!-f $script){
		die "ERROR ! not found <$script>\n";
	}
}

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
my $report_version = "Analysis Report V0.1";

my $cmd_make_pdf = "$java -jar $text2pdf -sp 2 -hl -fl -ht $report_version -ha r -fa r -r $resource_path -of $output_pdf -f $user_font_file -fi $user_CI_file";
print $cmd_make_pdf."\n";
system($cmd_make_pdf);
`rm -r $out_path/temp\n`;

sub run_script{
	my ( $script, $config_1, $config_2, $outfile ) =  @_;
		
	my $command = "perl $script $config_1 $config_2  > \"$outfile\"";
	print $command."\n";
	system($command);
}

sub run_script_1{
    my ( $script, $config_1 ) = @_;

    my $command = "perl $script $config_1";
    print $command."\n";
    system($command);
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
	print "Usage: perl $0 <in.config> <in.sample>\n";
	print "Example: perl $0 /BiO/BioProjects/Ion_Torrent/RIKEN_Human_Ion-2016-01-TBO150146/Ion_Config.txt /BiO/BioProjects/Ion_Torrent/RIKEN_Human_Ion-2016-01-TBO150146/Ion_Sample.txt \n";
	exit;
}
