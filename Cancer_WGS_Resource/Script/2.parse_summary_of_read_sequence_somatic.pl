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

my $pair_id = $info{pair_id};
my @pair_list = split /\,/, $pair_id;

my %hash_sample;
print "[[12],[],[],[0,90]]\n";

print "Type\tDelivery ID\\n(Sample ID)\tSequence read\t".
	"Deduplication\\nread\\n(%)\t".
	"Mapping\\nread\\n(%)\t".
	"On target\\nread\\n(%)\n";

my %delivery_ref;
split_delivery(\@list_delivery_tbi_id, \%delivery_ref);

foreach ( @pair_list ){
    my ($control_id,$case_id) = split /\_/, $_;
    
    ##case_contents##

    my $case_delivery_id = $delivery_ref{$case_id};
    my $case_sequence_read = `cat $alignment_statistics_xls | grep \"^$case_id\" | cut -f 2`;
    chomp ($case_sequence_read);

    my $case_deduplication_read_rate = `cat $alignment_statistics_xls | grep \"^$case_id\" | cut -f 9`;
    chomp ($case_deduplication_read_rate);

    my $case_mapping_read_rate = `cat $alignment_statistics_xls | grep \"^$case_id\" | cut -f 11`;
    chomp ($case_mapping_read_rate);

    my $case_on_target_rate = `cat $alignment_statistics_xls | grep \"^$case_id\"  | cut -f 17`;
    chomp ($case_on_target_rate);

    print "Case\t$case_delivery_id\\n($case_id)\t$case_sequence_read\t$case_deduplication_read_rate\t$case_mapping_read_rate\t$case_on_target_rate\n";

    ##control_contents##
    my $control_delivery_id = $delivery_ref{$control_id};
    my $control_sequence_read = `cat $alignment_statistics_xls | grep \"^$control_id\" | cut -f 2`;
    chomp ($control_sequence_read);
    
    my $control_deduplication_read_rate = `cat $alignment_statistics_xls | grep \"^$control_id\" | cut -f 9`;
    chomp ($control_deduplication_read_rate);

    my $control_mapping_read_rate = `cat $alignment_statistics_xls | grep \"^$control_id\" | cut -f 11`;
    chomp ($control_mapping_read_rate);

    my $control_on_target_rate = `cat $alignment_statistics_xls | grep \"^$control_id\" | cut -f 17`;
    chomp ($control_on_target_rate);
    
    print "Control\t$control_delivery_id\\n($control_id)\t$control_sequence_read\t$control_deduplication_read_rate\t$control_mapping_read_rate\t$control_on_target_rate\n";
}


#cat /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/result/01_fastqc_orig/TN1507D0293/TN1507D0293_1_fastqc/fastqc_data.txt | grep "Total Sequences" | sed 's/Total Sequences\s//g'

sub read_pipeline_config{
	my $file = shift;
	open my $fh, '<:encoding(UTF-8)', $file or die;
	while (my $row = <$fh>) {
		chomp $row;
		if ($row =~ /^#/ or $row =~ /^\s/){ next; }
	}
	close($fh);	
}

sub split_delivery{
    my ($delivery_list,$delivery_hash) = @_;
    foreach (@$delivery_list){
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
        $delivery_hash->{$tbi_id}=$delivery_id;
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
