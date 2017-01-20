#!/usr/bin/perl 

use strict;
use warnings;

use File::Basename;
use Cwd qw(abs_path);
my $script_path = dirname (abs_path $0);

if (@ARGV != 2) {
    printUsage();
}

my $in_sample_config = $ARGV[0];
my $in_pipeline_config = $ARGV[1];

my %hash;
read_sample_config ($in_sample_config, \%hash);

my @list_delivery_id = split /\,/, $hash{delivery_tbi_id};
my @list_pair_id = split /\,/, $hash{pair_id};
# my @trans_arr;

my %delivery_hash;
delivery_split (\@list_delivery_id, \%delivery_hash);

my $project_path = $hash{project_path};
my $alignment_statistics_xls = "$project_path/report/alignment.statistics.xls";
checkFile ( $alignment_statistics_xls );

print "[[11]]\n";
#print "Sample ID\tTS\tTV\tTs/Tv\tHetero\\nVariants\tHomo\\nVariants\tHetero\\n/Homo\n";
print "Sample ID\tTS\tTV\tTs/Tv ratio\n";

for (my $i=0; $i < @list_pair_id; $i++){
    my $no_somatic = $i + 1;
    my $somatic_id = $list_pair_id[$i];
    my ($control, $case) = split /\_/, $list_pair_id[$i];
    my $delivery_case = substr ($delivery_hash{$case}, 0, 25);
    my $tmp_id = $delivery_case."_".$no_somatic;
    my $html = "$project_path/result/30-2_snpeff_cancer_run/".$somatic_id."/".$somatic_id.".SNP.snpeff.html";
    checkFile($html);
#    my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;
#    my $html = "$project_path/result/14_snpeff_human_run/".$tbi_id."/".$tbi_id.".BOTH.snpeff.html";

#print $html."\n";
    open my $fh_html, '<:encoding(UTF-8)', $html or die;
    my @html_arr;
    while ( my $row = <$fh_html>){
        chomp $row;
        push @html_arr, $row;
    } close $fh_html;
#    print @html_arr;

    my @Ts;
    my @Tv;
    my @ratio;
        for (my $i=0; $i<@html_arr; $i++){
            if ( $html_arr[$i] =~ /Transitions/){
                push @Ts ,$html_arr[$i];
            }elsif ( $html_arr[$i] =~ /Transversions/){
                push @Tv ,$html_arr[$i];
            }elsif ( $html_arr[$i] =~ /Ts\/Tv/){
                push @ratio , $html_arr[$i];
            }
        } 
        
        my ($Ts_type, $transition_1, $transition_2, $total_ts) = split /\,/, $Ts[1];
        my ($Tv_type, $transversion_1, $transversion_2, $total_tv) = split /\,/,$Tv[1];
        my $ratio;
        if ( $total_tv ) {
            $ratio = $total_ts / $total_tv;
            $ratio = &RoundXL ($ratio, 3);
        }else{
            $total_tv = 0;
            $ratio = "Illegal Division";
        }

        my $ts = num($total_ts);
        my $tv = num($total_tv);
       
#        my $hetero = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 35 | head -n 1 `;
#        chomp $hetero;
#        $hetero = num($hetero);
        #
#        my $homo = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 36 | head -n 1 `;
#        chomp $homo;
#        $homo = num($homo);
#        
#        my $hh_ratio = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 37 | head -n 1 `;
#        chomp $hh_ratio;
#        $hh_ratio = num($hh_ratio);
        
        print "$tmp_id\t$ts\t$tv\t$ratio\n";
#        print "$delivery_id\t$ts\t$tv\t$ratio\t$hetero\t$homo\t$hh_ratio\n";
}
sub delivery_split {
    my ($delivery_list, $del_ref_hash) = @_;
    for (@$delivery_list){
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
    $del_ref_hash->{$tbi_id}=$delivery_id;
    }
}

sub RoundXL {
    sprintf ("%.$_[1]f", $_[0]);
}

sub checkFile {
    my $file = shift;
    if ( !-f $file) {
        die "ERROR! not found <$file>\n";
    }
}


sub num {
    my $cnum = shift;
    if ($cnum =~ /\d\./){
        return $cnum;
    }
    while ( $cnum =~ s/(\d+)(\d{3})\b/$1,$2/){
        1;
    }
    my $result = sprintf "%s", $cnum;
    return $result;
}

sub read_sample_config {
    my ($file, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while ( my $row = <$fh>){
        chomp $row;
        if ($row =~ /^#/) { next; }
        if (length $row == 0) { next; }

        my($key, $value) = split /\=/, $row;
         $key = trim ($key);
         $value = trim ($value);
         $hash_ref->{$key} = $value;
    }
    close $fh;
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
    print "perl $0 <in.sample.config> <in.pipeline.config> \n";
}
