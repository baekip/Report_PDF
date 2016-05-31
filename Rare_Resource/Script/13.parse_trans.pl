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
# my @trans_arr;

my $project_path = $hash{project_path};

print "[[13]]\n";
print "Delivery ID\tSample ID\tTransitions\tTransversions\tTs/Tv\\nratio\n";

foreach (@list_sample_id) {
    my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;
    my $html = "$project_path/result/14_snpeff_human_run/".$tbi_id."/".$tbi_id.".BOTH.snpeff.html";

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
        
        my ($Ts_type, $transition, $transition_1) = split /\,/, $Ts[1];
        my ($Tv_type, $transversion, $transversion_1) = split /\,/,$Tv[1];
        my $ratio = $transition / $transversion;
        $ratio = &RoundXL ($ratio, 3);

        #print @Ts;
        #print @Tv;

        my $ts = num($transition);
        my $tv = num($transversion);
        

        print "$delivery_id\t$tbi_id\t$ts\t$tv\t$ratio\n";
}

sub RoundXL {
    sprintf ("%.$_[1]f", $_[0]);
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
