#!/usr/bin/perl

use strict;
use warnings;

if (@ARGV != 2) {
    printUsage();
}

my $in_general_config = $ARGV[0];
my $in_pipeline_config = $ARGV[1];
my @fh_table;

my %info;
read_general_config( $in_general_config, \%info);

my $project_path = $info{project_path};
my $output_path = "$project_path/report";
my $resource_path = "$output_path/resource/3-2_Somatic_Information/";

my @list_delivery_id = split /\,/, $info{delivery_tbi_id};
my @pathogenic_total_list;

my @list_pair_id = split /\,/, $info{pair_id};

my %delivery_hash;
delivery_split (\@list_delivery_id, \%delivery_hash);

for (my $i=0; $i < @list_pair_id; $i++){
    my $no_somatic = $i + 1; 
    my $somatic_id = $list_pair_id[$i];
    my ($control, $case) = split /\_/, $list_pair_id[$i];
    my $delivery_case = substr ($delivery_hash{$case}, 0, 25);
    my $tmp_id = $delivery_case."_".$no_somatic;
    my $SNP_snpeff_tsv = "$project_path/result/30-2_snpeff_cancer_run/".$somatic_id."/".$somatic_id.".SNP.snpeff.isoform.tsv";
    my $INDEL_snpeff_tsv = "$project_path/result/32-2_snpeff_cancer_run/".$somatic_id."/".$somatic_id.".INDEL.snpeff.isoform.tsv";
    
    my $output_new_page = "$resource_path/7_".$i."_0_new_page.txt";
    my $output_label = "$resource_path/7_".$i."_label.txt";
    my $output_table = "$resource_path/7_".$i."_table_01.txt";

#    my $output_new_page = "3.4.1 ".$i."_0_new_page.txt";
#    my $output_label = "3.4.1 ".$i."_label.txt";
#    my $output_table = "3.4.1 ".$i."_table_01.txt";
    
    open (my $fh_new_page, '>', $output_new_page) or die;
    print $fh_new_page "h \n";
    close $fh_new_page;
    
    my $k = $i + 1;
    open (my $fh_txt,'>',$output_label) or die;
    print $fh_txt "[[13]]\n";
    print $fh_txt $k.") ".$tmp_id."\n";
    close $fh_txt;
   
#    print "Somatic Variants Processing: ".$tmp_id."\n";
    open (my $fh_table,'>',$output_table) or die;
    print $fh_table "[[10],[],[],[30,50,30,30,40,0,70]]\n";
    print $fh_table "Chr\tPos\tRef\tAlt\tVar_Type\tAnn_Effect\tAnn_Gene\tAnn_HGVS_C\tAnn_HGVS_P\n";
    open (my $fh_snp, '<:encoding(UTF-8)', $SNP_snpeff_tsv) or die "Could open not <$SNP_snpeff_tsv>";
    while (my $row = <$fh_snp>){
        chomp $row;
        if ( $row =~ /^#/) {next;}
        my @col_contents = split /\t/, $row;
#        print $col_contents[30];
        my $chr = $col_contents[0]; my $pos = num($col_contents[1]); my $ref = $col_contents[3]; my $alt = $col_contents[4];
        my $var_type = $col_contents[6]; my $ann_effect = $col_contents[7]; my $ann_gene = $col_contents[9];
        my $ann_hgvs_c = $col_contents[14]; my $ann_hgvs_p = $col_contents[15];

        print $fh_table "$chr\t$pos\t$ref\t$alt\t$var_type\t$ann_effect\t$ann_gene\t$ann_hgvs_c\t$ann_hgvs_p\n";
#       print "$chr\t$pos\t$ref\t$alt\t$var_type\t$ann_effect\t$ann_gene\n";
    }
    
    open (my $fh_indel, '<:encoding(UTF-8)', $INDEL_snpeff_tsv) or die "Could open not <$INDEL_snpeff_tsv>"; 
            #print "$clinical_effect\t$gene\t$dna_change\t$protein_change\t$variant_count\t$depth\t$exonic_effect\t$disease\n";
    while (my $row = <$fh_indel>){
        chomp $row;
        if ( $row =~ /^#/) {next;}
        my @col_contents = split /\t/, $row;
#        print $col_contents[30];
        my $chr = $col_contents[0]; my $pos = num($col_contents[1]); my $ref = $col_contents[3]; my $alt = $col_contents[4];
        my $var_type = $col_contents[6]; my $ann_effect = $col_contents[7]; my $ann_gene = $col_contents[9];
        my $ann_hgvs_c = $col_contents[14]; my $ann_hgvs_p = $col_contents[15];

        print $fh_table "$chr\t$pos\t$ref\t$alt\t$var_type\t$ann_effect\t$ann_gene\t$ann_hgvs_c\t$ann_hgvs_p\n";
#        print "$chr\t$pos\t$ref\t$alt\t$var_type\t$ann_effect\t$ann_gene\n";
    }
   
 close $fh_table;   
} 

=pod
sub tran_disease {
    my $dis = shift;
    chomp $dis;
    my $dis =~ tr/2//;
    # return $dis;
}
=cut

sub delivery_split {
    my ($delivery_list, $del_ref_hash) = @_;
    for (@$delivery_list){
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
        $del_ref_hash->{$tbi_id}=$delivery_id;
    }
}


sub comma {
    my $file = shift;
    my @value = split /\,/, $file;
    my $depth = $value[1];
    return $depth;
}

    #print "\n";
        
        # check rountine for pattern
        #if ($clnsig  =~ /\|/){
        #    print $row."\n";
        #    die;
        #}

#    print $delivery_id."\n";
#    print $list_delivery_id;

#    print "[[11]]\n";
=pod
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $list_delivery_id;
        my $in_pathogenic_snpeff_tsv = "$project_path/result/14_snpeff_human_run/".$tbi_id."/".$tbi_id.".BOTH.snpeff.isoform.tsv";
        checkFile( $in_pathogenic_snpeff_tsv );

        open my $fh, '<:encoding(UTF-8)', $file or die;
        while (my $row = <$fh>){
            chomp $row;
            if ( $row[30] == 5 || $row[30] ==6 ) {
                my $clinical_effect = $row[30];
                my $gene = $row[12];
                my $dna_change = $row[17];
=cut

sub num {
    my $cnum = shift;
    if ($cnum =~ /\d\./){
        return $cnum;
    }while ( $cnum =~ s/(\d+)(\d{3})\b/$1,$2/){
        1;
    }
    my $result = sprintf "%s", $cnum;
    return $result;
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
