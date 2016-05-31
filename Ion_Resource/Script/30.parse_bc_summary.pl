use warnings;
use strict;

if (@ARGV !=2){
	printUsage();
}

my $in_general_config = $ARGV[0];
my $in_sample_config  = $ARGV[1];

my %info;
read_general_config( $in_general_config, \%info );

my $project_path = $info{project_path};

my $bc_summary_xls = "$project_path/00_upload_file/02_coverage_dir/Summary.bc_summary.xls";
checkFile ( $bc_summary_xls );

open my $fh_sample, '<:encoding(UTF-8)', $in_sample_config or die;
print "[[10],[],[],[130]]\n";
print "Delivery ID\\n(Sample ID)\t".
        "Mapped Reads\t".
        "On target\\nrate(%)\t".
        "Mean Depth\t".
        "Uniformity\n";

while (my $row = <$fh_sample>){
    chomp $row;
    my @sample_information = split /\t/, $row;
    my $tbi_id = $sample_information[1];
   
    my $delivery_id = `cat $bc_summary_xls | grep \"$tbi_id\" | cut -f 1 | head -n 1`;
    chomp ($delivery_id);
    my $mapped_read = `cat $bc_summary_xls | grep \"$tbi_id\" | cut -f 3 | head -n 1`;
    chomp ($mapped_read);
    my $on_target =  `cat $bc_summary_xls | grep \"$tbi_id\" | cut -f 4 | head -n 1`;
    chomp ($on_target);
    my $mean_depth = `cat $bc_summary_xls | grep \"$tbi_id\" | cut -f 5 | head -n 1`;
    chomp ($mean_depth);
    my $uniformity = `cat $bc_summary_xls | grep \"$tbi_id\" | cut -f 6 | head -n 1`;
    chomp ($uniformity);
    
    
    print "$delivery_id\\n($tbi_id)\t$mapped_read\t$on_target\t$mean_depth\t$uniformity\n";
#cat /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/result/01_fastqc_orig/TN1507D0293/TN1507D0293_1_fastqc/fastqc_data.txt | grep "Total Sequences" | sed 's/Total Sequences\s//g'
}close $fh_sample;

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
