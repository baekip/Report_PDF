use warnings;
use strict;

if (@ARGV !=2){
	printUsage();
}

my $in_general_config = $ARGV[0];
my $in_pipeline_config = $ARGV[1];

my %info;

read_general_config( $in_general_config, \%info );
#read_pipeline_config();

my @list_delivery_tbi_id = split /\,/, $info{delivery_tbi_id};

my $project_path = $info{project_path};

# file
my $alignment_statistics_xls = "$project_path/report/alignment.statistics.xls";
checkFile ( $alignment_statistics_xls );

my %hash_sample;
print "[[12]]\n";
print "Delivery ID\tSample ID\tAverage depth\t".
    "Coverage 1x rate\\n(%)\t".
    "Coverage 4x rate\\n(%)\t".
    "Coverage 8x rate\\n(%)\t".
    "Coverage 20x rate\\n(%)\t".
    "Coverage 50x rate\\n(%)\n";
foreach ( @list_delivery_tbi_id ){
	my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;

	my $sequence_base = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 2`;
        chomp($sequence_base);
#        my $average_depth = $sequence_base * 101;
#        chomp($average_depth);
        
        my $average_depth = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 21`;
        chomp ($average_depth);

#        my $target_region = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 15`;
#        my $average_depth = $sequence_base * 101 /$target_region;
#        $average_depth = &RoundXL ($average_depth, 2);


	my $coverage_1x_rate = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 24`;
	chomp($coverage_1x_rate);
	my $coverage_4x_rate = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 25`;
	chomp($coverage_4x_rate);
	my $coverage_8x_rate = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 26`;
	chomp($coverage_8x_rate);
	my $coverage_20x_rate = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 27`;
	chomp($coverage_20x_rate);
	my $coverage_50x_rate = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 28`;
	chomp($coverage_50x_rate);
 
	print "$delivery_id\t$tbi_id\t$average_depth\t$coverage_1x_rate\t$coverage_4x_rate\t$coverage_8x_rate\t$coverage_20x_rate\t$coverage_50x_rate\n";

#cat /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/result/01_fastqc_orig/TN1507D0293/TN1507D0293_1_fastqc/fastqc_data.txt | grep "Total Sequences" | sed 's/Total Sequences\s//g'
}

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
