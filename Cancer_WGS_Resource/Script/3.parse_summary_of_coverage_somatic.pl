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
my $pair_id = $info{pair_id};
my @pair_list = split /\,/, $pair_id;

# file
my $alignment_statistics_xls = "$project_path/report/alignment.statistics.xls";
checkFile ( $alignment_statistics_xls );

my %delivery_ref;
split_delivery(\@list_delivery_tbi_id,\%delivery_ref);

print "[[12],[],[],[0,90]]\n";
print "Type\tDelivery ID\\n(Sample ID)\tAverage depth\t".
    "Coverage 1x rate\\n(%)\t".
    "Coverage 5x rate\\n(%)\t".
    "Coverage 10x rate\\n(%)\t".
    "Coverage 20x rate\\n(%)\t".
    "Coverage 50x rate\\n(%)\n";

foreach ( @pair_list ){
	my ($control_id,$case_id) = split /\_/, $_;

        ##case_contents##
        my $case_delivery_id = $delivery_ref{$case_id};     
	my $case_average_coverage = `cat $alignment_statistics_xls | grep \"^$case_id\" | cut -f 18`;
	chomp($case_average_coverage);
	my $case_coverage_1x_rate = `cat $alignment_statistics_xls | grep \"^$case_id\" | cut -f 21`;
	chomp($case_coverage_1x_rate);
	my $case_coverage_5x_rate = `cat $alignment_statistics_xls | grep \"^$case_id\" | cut -f 22`;
	chomp($case_coverage_5x_rate);
	my $case_coverage_10x_rate = `cat $alignment_statistics_xls | grep \"^$case_id\" | cut -f 23`;
	chomp($case_coverage_10x_rate);
	my $case_coverage_20x_rate = `cat $alignment_statistics_xls | grep \"^$case_id\" | cut -f 24`;
	chomp($case_coverage_20x_rate);
	my $case_coverage_50x_rate = `cat $alignment_statistics_xls | grep \"^$case_id\" | cut -f 25`;
	chomp($case_coverage_50x_rate);
	print "Case\t$case_delivery_id\\n($case_id)\t$case_average_coverage\t$case_coverage_1x_rate\t$case_coverage_5x_rate\t$case_coverage_10x_rate\t$case_coverage_20x_rate\t$case_coverage_50x_rate\n";

        ##control_contents##
        my $control_delivery_id = $delivery_ref{$control_id};
	my $control_average_coverage = `cat $alignment_statistics_xls | grep \"^$control_id\" | cut -f 18`;
	chomp($control_average_coverage);
	my $control_coverage_1x_rate = `cat $alignment_statistics_xls | grep \"^$control_id\" | cut -f 21`;
	chomp($control_coverage_1x_rate);
	my $control_coverage_5x_rate = `cat $alignment_statistics_xls | grep \"^$control_id\" | cut -f 22`;
	chomp($control_coverage_5x_rate);
	my $control_coverage_10x_rate = `cat $alignment_statistics_xls | grep \"^$control_id\" | cut -f 23`;
	chomp($control_coverage_10x_rate);
	my $control_coverage_20x_rate = `cat $alignment_statistics_xls | grep \"^$control_id\" | cut -f 24`;
	chomp($control_coverage_20x_rate);
	my $control_coverage_50x_rate = `cat $alignment_statistics_xls | grep \"^$control_id\" | cut -f 25`;
	chomp($control_coverage_50x_rate);

	print "Control\t$control_delivery_id\\n($control_id)\t$control_average_coverage\t$control_coverage_1x_rate\t$control_coverage_5x_rate\t$control_coverage_10x_rate\t$control_coverage_20x_rate\t$control_coverage_50x_rate\n";

#cat /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/result/01_fastqc_orig/TN1507D0293/TN1507D0293_1_fastqc/fastqc_data.txt | grep "Total Sequences" | sed 's/Total Sequences\s//g'
}

sub split_delivery{
    my ($delivery_list, $hash_ref) = @_;
    foreach (@$delivery_list) {
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
        $hash_ref->{$tbi_id}=$delivery_id;
    }
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
