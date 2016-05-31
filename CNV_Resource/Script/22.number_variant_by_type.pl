use warnings;
use strict;

use File::Basename;
use Cwd qw(abs_path);
my $script_path = dirname (abs_path $0);

my $script_snpeff_html_parser = "$script_path/22.snpeff_html_parser.pl";
checkFile( $script_snpeff_html_parser );

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

my %delivery_hash;
my $delivery_tbi_id = $info{delivery_tbi_id};
my @delivery_tbi_list = split /\,/, $delivery_tbi_id;
delivery_split (\@delivery_tbi_list, \%delivery_hash);

print "[[10,10],[],[],[130]]\n";
print "Temporary ID\tSNP\tINS\tDEL\tTotal\n";

my @pair_id_list = split /\,/, $info{pair_id};
for (my $i=0; $i<@pair_id_list; $i++){
    my $no_somatic = $i + 1;
    my $somatic_id = $pair_id_list[$i];
    my ($control, $case) = split /\_/, $pair_id_list[$i];
    my $delivery_case = substr ($delivery_hash{$case},0,10);
    my $tmp_id = $delivery_case."_".$no_somatic;
    #my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;

	#file
	my $SNP_snpeff_html = "$project_path/result/30-2_snpeff_cancer_run/$somatic_id/$somatic_id.SNP.snpeff.html";
	checkFile ( $SNP_snpeff_html );

        my $INDEL_snpeff_html = "$project_path/result/32-2_snpeff_cancer_run/$somatic_id/$somatic_id.INDEL.snpeff.html";
        checkFile ( $INDEL_snpeff_html);

	my @SNP_result_line = `perl $script_snpeff_html_parser $SNP_snpeff_html`;
        my $snp = $SNP_result_line[0];
        chomp($snp);
        my @INDEL_result_line = `perl $script_snpeff_html_parser $INDEL_snpeff_html`;
        my $ins = $INDEL_result_line[1];
        my $del = $INDEL_result_line[2];
        chomp($ins);
        chomp($del);
        
        my $total = $snp+$ins+$del;
	print "$tmp_id\t$snp\t$ins\t$del\t$total\n";

#cat /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/result/01_fastqc_orig/TN1507D0293/TN1507D0293_1_fastqc/fastqc_data.txt | grep "Total Sequences" | sed 's/Total Sequences\s//g'
}

sub delivery_split {
    my ($delivery_list, $del_ref_hash) = @_;
    foreach (@$delivery_list){
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
        $del_ref_hash->{$tbi_id}=$delivery_id;
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
