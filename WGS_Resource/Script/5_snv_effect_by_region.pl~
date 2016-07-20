#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Cwd qw(abs_path);
my $script_path = dirname (abs_path $0);

if(@ARGV != 1){
    printUsage();
}

my $in_general_config = $ARGV[0];
my @fh_table;

my %info;
read_general_config( $in_general_config, \%info);

my $project_path = $info{project_path};
my $report_path = "$project_path/report";
my $result_path = "$project_path/result";
my $resource_path = "$report_path/resource/4_Data_Analysis_Result/";
my $script_html_parser = "$script_path/4_snpeff_html_parser.pl";
checkFile( $script_html_parser);
my @list_delivery_id = split /\,/, $info{delivery_tbi_id};


#----------------------Make a snpeff categories table-------------------------
for (my $i=0; $i < @list_delivery_id; $i++){
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $list_delivery_id[$i];
    my $snpeff_html = "$result_path/14_snpeff_run/".$delivery_id."/".$delivery_id.".snpeff.html";
    checkFile($snpeff_html);

    my $output_new_page = "$resource_path/4_".$i."_0_new_page.txt";
    my $output_label = "$resource_path/4_".$i."_label.txt";
    my $output_table = "$resource_path/4_".$i."_table_01.txt";

    my $result_line = "perl $script_html_parser $snpeff_html";
    print $result_line."\n";

    open my $fh_new_page, '>', $output_new_page or die;
    close $fh_new_page;

    open my $fh_label, '>', $output_label or die;
    my $k = $i + 1;
    print $fh_label "[[13]]\n";
    print $fh_label "$k) $delivery_id ($tbi_id) \n";
    close $fh_label;

    open my $fh_table, '>', $output_table or die;
    print $fh_table "[[12],[],[],[300]]\n";
    print $fh_table "Type\tCount\tPercentage(%)\n";
    close $fh_table;
}    

=pod
for (my $i=0; $i < @list_delivery_id; $i++){
#    print $list_delivery_id[$i]."\n";
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $list_delivery_id[$i];
    my $snpeff_html = "$result_path/14_snpeff_run/".$delivery_id."/".$delivery_id.".snpeff.html";
    checkFile($snpeff_html);

    my $output_new_page = "$resource_path/1_".$i."_0_new_page.txt";
    my $output_label = "$resource_path/1_".$i."_label.txt";
    my $output_table = "$resource_path/1_".$i."_table_01.txt";
    
    my $result_line = `perl $script_html_parser $snpeff_html`;
    chomp ($r
    
    open (my $fh_new_page, '>', $output_new_page) or die;
    print $fh_new_page "h \n";
    close $fh_new_page;
    
    my $k = $i + 1;
    open (my $fh_txt,'>',$output_label) or die;
    print $fh_txt "[[13]]\n";
    print $fh_txt $k.") ".$delivery_id."(".$tbi_id.")\n";
    close $fh_txt;

    print "Processing Pathogenic Analysis: ".$delivery_id."\n";
    open (my $fh_table,'>',$output_table) or die;
    print $fh_table "[[10],[],[],[0,50,0,0,40,40,85,135]]\n";
    print $fh_table "Clinical\\neffect\tGene\tDNA\\nchange\tProtein\\nchange\tVariant\\ncount\tDepth\tExonic\\neffect\tDisease\n";
    open (my $fh, '<:encoding(UTF-8)', $in_pathogenic_snpeff_tsv) or die 'Could open not <$in_pathogenic_snpeff_tsv>';
    while (my $row = <$fh>){
        chomp $row;
        my @col_contents = split /\t/, $row;
#        print $col_contents[30];
        my $gene = $col_contents[12]; my $dna_change = $col_contents[17]; my $protein_change = $col_contents[18];
        my $variant_count = comma($col_contents[8]);
        my $depth = $col_contents[9]; my $exonic_effect = $col_contents[10];

        my $clnsig = $col_contents[30];
        my $clndbn = $col_contents[31];

        my @criteria;
        if ($clnsig=~ /,/ or $clnsig =~ /|/){
            @criteria = split /[,|]+/, $clnsig;
        }else{
            push @criteria, $clnsig;
        }

        my @contents_disease;
        if ($clndbn =~ /,/ or $clndbn =~ /|/){
            @contents_disease = split /[,|]+/, $clndbn;
        }else{
            push @contents_disease, $clndbn;
        }

        # open (my $fh_table, '>', $output_table) or die;

        if ($exonic_effect eq "missense_variant" or
            $exonic_effect eq "missense_variant&splice_region_variant" or
            $exonic_effect eq "splice_region_variant&intron_variant" or
            $exonic_effect eq "synonymous_variant" or
            $exonic_effect eq "stop_gained" or
            $exonic_effect eq "frameshift_variant"){

#            open (my $fh_table, '>', $output_table) or die;
            for (my $j=0; $j<@criteria; $j++){ 
                my $clinical_effect = $criteria[$j];
                my $disease = $contents_disease[$j];
                #my $disease = tran_disease($contents_disease[$j]);
                # if (!$disease){
                #    print $clnsig."\n";
                #    die "ERORR ! not found disease \n$row\n";
                #}
                if ($clinical_effect eq "5"){ 
                    $clinical_effect = "pathogenic";
                    if ($disease =~ /\\x2c/){
                        $disease =~ s/\\x2c//g;
                    }elsif (!$disease){
                        print $disease."\n";
                        die "ERORR! not found disease \n$row\n";
                    }
                    print $fh_table "$clinical_effect\t$gene\t$dna_change\t$protein_change\t$variant_count\t$depth\t$exonic_effect\t$disease\n";
                #print $value."\t".$disease."\t";
                }elsif ($clinical_effect eq "6"){
                    $clinical_effect = "drug response";
                    if ($disease =~ /\\x2c/){
                        $disease =~ s/\\x2c//g;
                    }
                    print $fh_table "$clinical_effect\t$gene\t$dna_change\t$protein_change\t$variant_count\t$depth\t$exonic_effect\t$disease\n"; 
                #print $value."\t".$disease."\t";
            } 
        }
            #print "$clinical_effect\t$gene\t$dna_change\t$protein_change\t$variant_count\t$depth\t$exonic_effect\t$disease\n";
     } 
 } 
 
close $fh_table;   
 }
=cut

#--------------sub perl definition--------------------

sub comma {
    my $file = shift;
    my @value = split /\,/, $file;
    my $depth = $value[1];
    return $depth;
}

sub checkFile {
    my $file = shift;
    if ( !-f $file) {
        print "ERROR! not found <$file>\n";
    }
}

sub read_general_config {
    my ($file, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while (my $row = <$fh>){
        chomp $row;
        if ($row =~ /^#/) {next;}
        if ( length($row) == 0 ) {next;}
        
        my ($key, $value) = split /\=/, $row;
        $key = trim ($key); 
        $value = trim ($value);
        $hash_ref->{$key} = $value;
    }
    close ($fh);
}

sub trim { 
    my @result = @_;
    foreach (@result){
        s/^\s+//;
        s/\s+$//;
    }
    return wantarray ? @result : $result[0];
}

sub printUsage {
    print "Usage: perl $0 <in.general.config> <in.pipeline.config> \n";
}
