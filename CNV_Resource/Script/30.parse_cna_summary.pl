#!/usr/bin/perl

if ( @ARGV != 2 ) {
    printUsage();
}

my $in_sample_config = $ARGV[0];
my $in_pipeline_config = $ARGV[1]; 

my %info;
read_config ($in_sample_config, \%info);

my $delivery_tbi_id = $info{delivery_tbi_id};
my $project_path = $info{project_path};
my $cna_path = "$project_path/result/41_cna_call";
my @list_sample_id = split /\,/, $info{delivery_tbi_id};
my @list_pair_id = split /\,/, $info{pair_id};


my %delivery_hash;
delivery_split (\@list_sample_id, \%delivery_hash);


print "[[10],[],[],[40,80,80,0,0,30,30]]\n";
print "Chr\tStart\tEnd\tSegment\tCNF\tCN\tCall\tProbCall\n";


for (my $i; $i<@list_pair_id; $i++) {
    my $j = $i + 1;
    my ($control, $case) = split /\_/, $list_pair_id[$i];
    my $delivery_case = "$delivery_hash{$case}_$j";
    
    my $test_result = "$cna_path/$list_pair_id[$i]/Results/$delivery_case/FastCallResults_$delivery_case.txt";
    open my $fh_cna, '<:encoding(UTF-8)', $test_result  or die;
    while (my $row = <$fh_cna>){
        chomp $row;
        if ($row =~ /^Chromosome/) {next;}
        my @column = split /\t/, $row;
    
        my $chr = $column[0]; my $start = num($column[1]); my $end = num($column[2]);
        my $segment = &RoundXL($column[3],3); my $cnf = &RoundXL($column[4],3); my $probcall = &RoundXL($column[7],3);
        print "$chr\t$start\t$end\t$segment\t$cnf\t$column[5]\t$column[6]\t$probcall\n";
    }
    close $fh_cna;
}

sub RoundXL {
    sprintf("%.$_[1]f", $_[0]);
}

sub delivery_split {
    my ($delivery_list, $del_ref_hash) = @_;
    for (@$delivery_list){
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
        $del_ref_hash->{$tbi_id}=$delivery_id;
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

sub read_config { 
    my ($file, $ref_hash) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while (my $row = <$fh>){
        chomp $row;
        if ($row =~ /^#/){ next; }
        if ( length($row) == 0) { next; }
        my ($key, $value) = split /\=/, $row;
        $key = trim ($key);
        $value = trim ($value);
        $ref_hash->{$key}=$value;
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
    print "perl $0 <in.sample.config> <in.pipe.config> \n";
}
