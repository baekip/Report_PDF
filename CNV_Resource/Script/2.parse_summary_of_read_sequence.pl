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
print "[[12],[],[],[130]]\n";

print "Delivery ID\\n(Sample ID)\tSequence\\nread\t".
	"Deduplicated\\nread\\n(%)\t".
	"Mapping\\nread\\n(%)\t".
	"On target\\nread\\n(%)\n";
foreach ( @list_delivery_tbi_id ){
	my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;

	my $sequence_read = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 2 | head -n 1`;
	chomp($sequence_read);
    $sequence_read = num($sequence_read);
	my $deduplication_read_rate = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 4 | head -n 1`;
	chomp($deduplication_read_rate);
	my $mapping_read_rate = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 6 | head -n 1`;
	chomp($mapping_read_rate);
	my $on_target_read_rate = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 12 | head -n 1`;
	chomp($on_target_read_rate);
 
	print "$delivery_id\\n($tbi_id)\t$sequence_read\t$deduplication_read_rate\t$mapping_read_rate\t$on_target_read_rate\n";

#cat /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/result/01_fastqc_orig/TN1507D0293/TN1507D0293_1_fastqc/fastqc_data.txt | grep "Total Sequences" | sed 's/Total Sequences\s//g'
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
	print "Usage: perl $0 <in.config> <in.pipeline.config>\n";
	print "Example: perl $0 /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_config.human.txt /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_pipeline_config.human.txt\n";
	exit;
}
