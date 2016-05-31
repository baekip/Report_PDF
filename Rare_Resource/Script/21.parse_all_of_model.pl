use strict;
use warnings;

if (@ARGV !=1){
    printUsage();
}

my $in_general_config = $ARGV[0];
my $in_pipeline_config = $ARGV[1];

my %info;

read_general_config ($in_general_config, \%info);

my @list_delivery_tbi_id = split /\,/, $info{delivery_tbi_id};
my $project_path = $info{project_path};

#####1.generate to recessive file
my $recessive_model_path = "$project_path/result/31-1_variants_filter_run/multisample";
my $recessive_stat_file_5 = "$recessive_model_path/multisample.recessive.filter5.xls";
checkFile ( $recessive_stat_file_5);
my $recessive_stat_file_4 = "$recessive_model_path/multisample.recessive.filter4.xls";
checkFile ( $recessive_stat_file_4);
my $recessive_resource_file = "$project_path/report/resource/3-4_Candidate_Variants/2_b_table_01.txt";

open my $fh_file_1, '<:encoding(UTF-8)',$recessive_stat_file_5 or die;
while (my $row = <$fh_file_1>){
    if ($row =~ /^#/){next;}
    
    open my $fh_resource, '>', $recessive_resource_file or die;
    print $fh_resource "[[10]]\n";
    print $fh_resource "Chr\tPos\tVariant\\nType\tGene\tTranscript\\nID\tcDNA\\nchange\tAmino\\nchange\tSIFT\tPolyPhen\t1000G\tIn-House\n";
    close $fh_resource;

#    my $cmd_opt = "echo [[10]] > $recessive_resource_file";
#    system($cmd_opt);
#    my $cmd_header = "echo Chr\	Pos\	Gene\	Variant\\nType\	Transcript ID\	cDNA\\nchange\	Amino\\nchange\	SIFT\	PolyPhen\	1000G\	In-House >> $recessive_resource_file";
#    system($cmd_header);
    if (! $row) { 
        my $cmd_generator = "cat $recessive_stat_file_4 | cut -f 1,2,7,19,21,24,25,38,40,50,66 | sed -n \'1!p\' | head -n 10 >> $recessive_resource_file";
        system ($cmd_generator);
        # print "$recessive_stat_file_4\n"; }
    }else{
        my $cmd_generator = "cat $recessive_stat_file_5 | cut -f 1,2,7,19,21,24,25,38,40,50,66 | sed -n \'1!p\' | head -n 10 >> $recessive_resource_file";
        system ($cmd_generator);
        # print "$recessive_stat_file_5\n";}
    last;}  
}close $fh_file_1;

#####2.generate to dominant file
my $dominant_model_path = "$project_path/result/31-2_variants_filter_run/multisample";
my $dominant_stat_file_5 = "$dominant_model_path/multisample.dominant.filter5.xls";
checkFile ( $dominant_stat_file_5);
my $dominant_stat_file_4 = "$dominant_model_path/multisample.dominant.filter4.xls";
checkFile ( $dominant_stat_file_4);
my $dominant_resource_file = "$project_path/report/resource/3-4_Candidate_Variants/3_b_table_01.txt";

open my $fh_file_2, '<:encoding(UTF-8)',$dominant_stat_file_5 or die;
while (my $row = <$fh_file_2>){
    if ($row =~ /^#/){next;}
    
    open my $fh_resource, '>', $dominant_resource_file or die;
    print $fh_resource "[[10]]\n";
    print $fh_resource "Chr\tPos\tVariant\\nType\tGene\tTranscript\\nID\tcDNA\\nchange\tAmino\\nchange\tSIFT\tPolyPhen\t1000G\tIn-House\n";
    close $fh_resource;

#    my $cmd_opt = "echo [[10]] > $dominant_resource_file";
#    system($cmd_opt);
#    my $cmd_header = "echo Chr\	Pos\	Gene\	Variant\\nType\	Transcript ID\	cDNA\\nchange\	Amino\\nchange\	SIFT\	PolyPhen\	1000G\	In-House >> $dominant_resource_file";
#    system($cmd_header);
    if (! $row) { 
        my $cmd_generator = "cat $dominant_stat_file_4 | cut -f 1,2,7,19,21,24,25,38,40,50,66 | sed -n \'1!p\' | head -n 10 >> $dominant_resource_file";
        system ($cmd_generator);
        # print "$dominant_stat_file_4\n"; }
    }else{
        my $cmd_generator = "cat $dominant_stat_file_5 | cut -f 1,2,7,19,21,24,25,38,40,50,66 | sed -n \'1!p\' | head -n 10 >> $dominant_resource_file";
        system ($cmd_generator);
        # print "$dominant_stat_file_5\n";}
    last;}
}close $fh_file_2;

#####3.generate to compound file
my $compound_model_path = "$project_path/result/31-3_variants_filter_run/multisample";
my $compound_stat_file_5 = "$compound_model_path/multisample.compound_hetero.filter5.xls";
checkFile ( $compound_stat_file_5);
my $compound_stat_file_4 = "$compound_model_path/multisample.compound_hetero.filter4.xls";
checkFile ( $compound_stat_file_4);
my $compound_resource_file = "$project_path/report/resource/3-4_Candidate_Variants/4_b_table_01.txt";

open my $fh_file_3, '<:encoding(UTF-8)',$compound_stat_file_5 or die;
while (my $row = <$fh_file_3>){
    if ($row =~ /^#/){next;}
    
    open my $fh_resource, '>', $compound_resource_file or die;
    print $fh_resource "[[10]]\n";
    print $fh_resource "Chr\tPos\tVariant\\nType\tGene\tTranscript\\nID\tcDNA\\nchange\tAmino\\nchange\tSIFT\tPolyPhen\t1000G\tIn-House\n";
    close $fh_resource;

#    my $cmd_opt = "echo [[10]] > $compound_resource_file";
#    system($cmd_opt);
#    my $cmd_header = "echo Chr\	Pos\	Gene\	Variant\\nType\	Transcript ID\	cDNA\\nchange\	Amino\\nchange\	SIFT\	PolyPhen\	1000G\	In-House >> $compound_resource_file";
#    system($cmd_header);
    if (! $row) { 
        my $cmd_generator = "cat $compound_stat_file_4 | cut -f 1,2,8,20,22,25,26,39,41,43,51,67 | sed -n \'1!p\' | head -n 10 >> $compound_resource_file";
        system ($cmd_generator);
        # print "$compound_stat_file_4\n"; }
    }else{
        my $cmd_generator = "cat $compound_stat_file_5 | cut -f 1,2,8,20,22,25,26,39,41,43,51,67 | sed -n \'1!p\' | head -n 10 >> $compound_resource_file";
        system ($cmd_generator);
        #print "$compound_stat_file_5\n";}
    last;}
}close $fh_file_3;

#my $filter_statistics_contents = `cat $filter_statistics_xls`;
#my @array = split /\n/, $filter_statistics_contents;
#my $last_value;
#for (my $i=0; $i<@array; $i++){
#    my $line = $array[$i];
#    if ($line =~ /^Filtering/){
#        next;
#    }
#    my @line_array = split /\t/, $line;
#    my $second_col_value = $line_array[1];
#    if ($second_col_value == 0){
#        last;
#    }
#    $last_value = $line_array[0];
#}

#$last_value = alt($last_value);
#my $recessive_model_xls = "$recessive_model_path/multisample.recessive.".$last_value.".xls";
#checkFile( $recessive_model_xls);

sub alt {
    my $file = shift;
    $file =~ tr/F/f/;
    return $file;
}
#print $last_value."\n";

#my @contents = `cat $recessive_model_xls | sed -n \'1!p\' | awk '{print\$1,\$2,\$17,\$24,\$25,\$19,\$39,\$41,\$49,\$50,\$59,\$65}' | tr ' ' '\t'`;


#print "[[11]]\n";
#print "Chr\tPos\tVariant\\nType\tcDNA change\tAmino2change\tGene\tSIFT\tPolyPhen\tCADD\t1000G\tExAC\tIn-House\n";
#print "@contents";

#sed -n '1!p'

#foreach ( @list_delivery_tbi_id ){
#    my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;

#    my $chr = `cat $dominant_model_xls | cut -f 1 `;
#    chomp($chr);
#    my $pos = `cat $dominant_model_xls | cut -f 2 `;
#    chomp($pos);
#    my $variant_type = `cat $dominant_model_xls | cut -f 17 `;
#    chomp($variant_type);
#    my $dna_change = `cat $dominant_model_xls | cut -f 24 `;
#    chomp($dna_change);
#    my $aa_change = `cat $dominant_model_xls | cut -f 25 `;
#    chomp($aa_change);
#    my $gene = `cat $dominat_model_xls | cut -f 19 `;
#    chomp($gene);
#    my $sift_score = `cat $dominant_model_xls | cut -f 39 `;
#    chomp($sift_score);
#    my $polyphen_score = `cat $dominant_model_xls | cut -f 41 `;
#    chomp($polyphen_score);
#    my $cadd_score = `cat $dominant_model_xls | cut -f 49 `;
#    chomp($cadd_score);
#    my $1000g_score = `cat $dominant_model_xls | cut -f 50 `;
#    chomp($1000g_score);
#    my $exac_score = `cat $dominant_model_xls | cut -f 59 `;
#    chomp($exac_score);
#    my $in_house_score = `cat $dominant_model_xls | cut -f 65 `;
#    chomp ($in_house_score);

sub read_general_config {
    my ($file, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while (my $row = <$fh>) {
        chomp $row;
        if ($row =~ /^#/){ next; }
        if (length($row) == 0) { next; }

        my ($key, $value) = split /\=/, $row;
        $key = trim ($key);
        $value = trim ($value);
        $hash_ref->{$key} = $value;
    }
    close ($fh);
}

sub trim {
    my @result = @_;
    foreach (@result) {
        s/^\s+//;
        s/\s+$//;
    }

    return wantarray ? @result : $result[0];
}

sub checkFile {
    my $file = shift;
    if ( !-f $file){
        die "ERROR ! not found <$file>\n";
    }
}
   

sub printUsage {
    print "Usage: perl $0 <in.config> \n";
    print "Exampel: perl $0 /BiO/BioProject/FOM-Human-WES-2015-07-TBO150049/wes_config.human.txt \n";
    exit;
}

