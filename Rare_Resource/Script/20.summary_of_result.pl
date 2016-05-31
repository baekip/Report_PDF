use strict;
use warnings;

if ( @ARGV != 1) {
    printUsage();
}

my $in_general_config = $ARGV[0];
#my $in_pipeline_config = $ARGV[1];

my %info;

read_general_config ( $in_general_config, \%info);

my $project_path = $info{project_path};
my @list_delivery_tbi_id = split /\,/ ,$info{delivery_tbi_id};
my $filter_statistics_xls = "$project_path/result/32_filter_sta_run/multisample/multisample.filter.statistics.xls";
checkFile ( $filter_statistics_xls );
my $summary_table_txt = "$project_path/report/resource/3-4_Candidate_Variants/1_b_table_01.txt";

my $cmd_header = "echo [[10,10]] > $summary_table_txt";
system($cmd_header);
my $cmd_contents = "cat $filter_statistics_xls >> $summary_table_txt";
system($cmd_contents);

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

#print $last_value."\n";
#print "%filtered";
#print "@filter_statistics_contents[0]";

#my @col;
#@col = split /\t/, @filter_statistics_contents;
#print "@col";

#if (@col[7] != 0){
#    $xls = "$path./sas./filter6.xls";}
#elsif(


sub read_general_config {
    my ($file, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while (my $row = <$fh>){
        chomp $row;
        if ($row =~ /^#/){ next; }
        if (length($row) == 0){ next; }
        
        my ($key, $value) = split /\=/, $row;
        $key =  trim ($key);
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
    ###Returns true if the context of the currently executing subroutine or eval is looking for a list value. 
    return wantarray ? @result : $result[0];
}

sub checkFile {
    #You can take a base off the beginning of the array with sift#
    my $file = shift;
    
    #if( -f <filename> ) { ... }, -f appears to test whether the filename exists or not but I am not sure
    if (!-f $file) {
        die "ERROR! not found <$file>\n";
    }
}

#print "cp /BiO/BioProject/Aju-Human-WES-2015-08-TBO15056/family1/result/32_filter_sta_run/multisample/multisample.filter.statistics.xls $resource_path/3-3. Candidate_Variants/3.3.2 c_table_01.txt";



sub printUsage {
    print "Usage: perl $0 <in.config> <in.pipeline>\n";
}
