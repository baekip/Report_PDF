#!/usr/bin/perl

if ( @ARGV != 2) {
    printUsage();
}

my $in_sample_config = $ARGV[0];
my $in_pipeline_config = $ARGV[1];

my %info;
read_config($in_sample_config,\%info);

my $delivery_tbi_id = $info{delivery_tbi_id};
my $project_path = $info{project_path};
my $cna_path = "$project_path/result/41_cna_call";
my @list_sample_id = split /\,/, $info{delivery_tbi_id};
my @list_pair_id = split /\,/, $info{pair_id};

my %delivery_hash;
delivery_split (\@list_sample_id, \%delivery_hash);

print "[[10]]\n";

for (my $i; $i<@list_pair_id; $i++) {
    my $j = $i + 1;
    my ($control, $case) = split /\_/, $list_pair_id[$i];
    my $delivery_case = "$delivery_hash{$case}_$j";
    
    for(my $a=1; $a<24; $a=$a+4){
        my $b=$a+1;
        my $c=$a+2;
        my $d=$a+3;

        my $plot_path = "$cna_path/$list_pair_id[$i]/Plots/$delivery_case/";

        print "<img:$plot_path/PlotResults_chr".$a.".png>\t<img:$plot_path/PlotResults_chr".$b.".png>\n";
        print "<img:$plot_path/PlotResults_chr".$c.".png>\t<img:$plot_path/PlotResults_chr".$d.".png>\n";
    }
}

sub delivery_split {
    my ($delivery_list, $del_ref_hash) = @_;
    for (@$delivery_list) {
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
        $del_ref_hash->{$tbi_id}=$delivery_id;
    }
}


sub read_config {
    my ($file, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while ( my $row = <$fh>){
        chomp $row;
        if ($row =~ /^#/) {next;}
        if (length($row) == 0 ) {next;}
        
        my ($key, $value) = split /\=/, $row; 
        $key = trim ($key);
        $value = trim($value);
        $hash_ref->{$key}=$value;
    }
    close $fh;
}

sub trim {
    my @result = @_;
    foreach (@result) {
        s/^\s+//;
        s/\s+$//;
    }
    return wantarray ? @result:$result[0];
}

sub printUsage {
    print "Usage: perl $0 <in.sample.config> <in.pipeline.config> \n";
    exit;
}
