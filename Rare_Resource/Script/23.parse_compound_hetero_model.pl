use strict;
use warnings;

if (@ARGV !=2){
    printUsage();
}

my $in_general_config = $ARGV[0];
my $in_pipeline_config = $ARGV[1];

my %info;

read_general_config ($in_general_config, \%info);

my @list_delivery_tbi_id = split /\,/, $info{delivery_tbi_id};
my $project_path = $info{project_path};
my $compound_model_path = "$project_path/result/31-3_variants_filter_run/multisample/";
my $filter_statistics_xls = "$project_path/result/32_filter_sta_run/multisample/multisample.filter.statistics.xls";
checkFile( $filter_statistics_xls );

my $filter_statistics_contents = `cat $filter_statistics_xls`;
my @array = split /\n/, $filter_statistics_contents;
my $last_value;
for (my $i=0; $i < @array; $i++){
    my $line = $array[$i];
    if ($line =~ /^Filtering/){
        next;
    }
    my @line_array = split /\t/,$line;
    my $second_col_value = $line_array[1];
    if ($second_col_value == 0){
        last;
    }
    $last_value = $line_array[0];
}

$last_value = alt($last_value);
my $compound_model_xls = "$compound_model_path/multisample.compound_hetero.".$last_value.".xls";
checkFile($compound_model_xls);

sub alt {
    my $file =shift;
    $file =~ tr/F/f/;
    return $file;
}

my @contents = `cat $compound_model_xls | sed -n '1!p' | awk '{print\$1,\$2,\$17,\$24,\$25,\$19,\$39,\$41,\$49,\$50,\$59,\$65}' | tr ' ' '\t'`;

print "[[11]]\n";
print "Chr\tPos\tVariant\\nType\tcDNA change\tAmino2change\tGene\tSIFT\tPolyPhen\tCADD\t1000G\tExAC\tIn-House\n";
print "@contents";

#project_path      =    /BiO/BioProjects/Aju-Human-WES-2015-08-TBO150056/family1/

my $dominant_model_xls = "$project_path/result/31-2_variants_filter_run/multisample/multisample.dominant.filter6.xls";
checkFile ($dominant_model_xls);

#my %hash_sample;
#print "[[11]]\n"
#print "Chr\tPos\tRegion\tcDNA change\tAmino2change\tGene\tSIFT\tPolyPhen\tCADD\t1000G\tExAC\tIn-House\n";
#print %contents;



#my %contents = `cat $dominant_model_xls | sed -n \'1!p\' | awk '{print $1,$2,$17,$24,$25,$19,$39,$41,$49,$50,$59,$65}';



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


sub checkFile {
     my $file = shift;
     if ( !-f $file ) {
         print "ERROR! not found <$file>\n";
     }
 }


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



sub printUsage {
    print "Usage: perl $0 <in.config> <in.pipelien.config>\n";
    print "Exampel: perl $0 /BiO/BioProject/FOM-Human-WES-2015-07-TBO150049/wes_config.human.txt /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_pipeline_config.human.txt\n";
    exit;
}

