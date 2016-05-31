use warnings;
use strict;

if (@ARGV !=1){
	printUsage();
}

my $in_general_config = $ARGV[0];
#my $in_pipeline_config = $ARGV[1];

my %info;

read_general_config( $in_general_config, \%info );
#read_pipeline_config();

my @list_delivery_tbi_id = split /\,/, $info{delivery_tbi_id};

my $project_path = $info{project_path};

my $rawdata_path = "$project_path/rawdata";

# Index, Total yield, Q20/Q30 Bases PF
my $Sequencing_Statistics_Result_xls = "$rawdata_path/Sequencing_Statistics_Result.xls";
checkFile( $Sequencing_Statistics_Result_xls );

my %hash_sample;
print "[[12],[],[],[0,90]]\n";
print "Delivery ID\tSample ID\tTotal\\nreads\tTotal\\nbases (Gbp)\tGC\\nPercent\tQ30 MoreBasesRate\n";
foreach ( @list_delivery_tbi_id ){
	my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;

	my $total_reads = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 3`;
	chomp($total_reads);
    	$total_reads = num($total_reads);
	
        my $total_yield = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 5`;
	chomp($total_yield);
        #$total_yield = changeGbp($total_yield);

	my $GC_contents = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 5`;
	chomp($GC_contents);
        #$GC_contents = changeGbp($GC_contents);

	my $GC_percent = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 7`;
	chomp($GC_percent);	

	my $q30_base_pf = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 15`;
	chomp($q30_base_pf);

	print "$delivery_id\t$tbi_id\t$total_reads\t$total_yield\t$GC_percent\t$q30_base_pf\n";
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

sub changeGbp{
	my $val = shift;
	$val = $val / 1000000000;
	$val = &RoundXL ($val, 2);
	return $val;
}

sub RoundXL {
	sprintf("%.$_[1]f", $_[0]);
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
	print "Usage: perl $0 <in.config>\n";
	print "Example: perl $0 /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_config.human.txt\n";
	exit;
}
