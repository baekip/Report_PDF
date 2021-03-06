use warnings;
use strict;

if (@ARGV !=2){
	printUsage();
}

my $in_general_config = $ARGV[0];
my $in_sample_config = $ARGV[1];

my %info;
read_general_config( $in_general_config, \%info );

my $project_path = $info{project_path};
my $coverage_path = "$project_path/00_upload_file/02_coverage_dir/";


open my $fh_sample, '<:encoding(UTF-8)', $in_sample_config or die;
print "[[12],[],[],[85]]\n";
print "Delivery ID\\n(Sample ID)\tAmplicon GC Contents\tAmplicon Length\n";
while (my $row = <$fh_sample>) {
    chomp $row;
    my @sample_information = split /\t/, $row; 
    
    my $delivery_id = $sample_information[0];
    my $tbi_id = $sample_information[1];
    my $barcode_id = $sample_information[2];
   
    my $gc_contents_distribution = "$coverage_path/$barcode_id/$barcode_id.gc_rep.png";
    my $length_distribution = "$coverage_path/$barcode_id/$barcode_id.ln_rep.png";
	
    print "$delivery_id\\n\($tbi_id\)\t<img:$gc_contents_distribution>\t<img:$length_distribution>\n";
}close $fh_sample;

sub RoundXL {
	sprintf("%.$_[1]f", $_[0]);
}

sub RoundToInt {
	int($_[0] + .5 * ($_[0] <=> 0));
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
