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

my @list_sample_id = split /\,/, $hash{delivery_tbi_id};
my $project_path = $hash{project_path};

my @list_pair_id = split /\,/, $hash{pair_id};
my %delivery_hash;
delivery_split (\@list_sample_id, \%delivery_hash);

print "[[13],[],[],[130]]\n";
print "Temporary ID\tTransitions\tTransversions\tTs/Tv\\nratio\n";

for (my $i=0; $i<@list_pair_id; $i++) {
    my $no_somatic = $i + 1;
    my $somatic_id = $list_pair_id[$i];
    my ($control, $case) = split /\_/, $list_pair_id[$i];
    my $delivery_case = substr ($delivery_hash{$case}, 0, 15);
    my $tmp_id = $delivery_case."_".$no_somatic;
    #my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;
    my $html = "$project_path/result/30-2_snpeff_cancer_run/".$somatic_id."/".$somatic_id.".SNP.snpeff.html";

#print $html."\n";
    open my $fh_html, '<:encoding(UTF-8)', $html or die;
    my @html_arr;
    while ( my $row = <$fh_html>){
        chomp $row;
        push @html_arr, $row;
    } close $fh_html;

    my @Ts;my @Tv;
    my $ts;my $tv;my $ratio;

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
        
        if (!$Ts[1]){
            $ts = 0;
        }else{ 
            my ($Ts_type, $transition, $transition_1, $transition_2) = split /\,/, $Ts[1];
            # print $transition_2."\n";
            $ts = check_null($transition_2);
        }
        
        if (!$Tv[1]){
            $tv = 0;
        }else{
            my ($Tv_type, $transversion, $transversion_1, $transversion_2) = split /\,/,$Tv[1];
            # print $transversion_2."\n";
            $tv = check_null($transversion_2);
        }

        if ($tv == 0 ){
            $ratio = 'Illegal Division';
        }else{
            $ratio = $ts/$tv;
            $ratio = &RoundXL ($ratio, 2);
        }
        print "$tmp_id\t$ts\t$tv\t$ratio\n";
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

sub check_null {
    my $check_value = shift;
    if (!$check_value){
        return 0;
    }else{
        return $check_value;
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
    print "Usage:perl $0 <in.sample.config> <in.pipeline.config> \n";
    exit;
}
