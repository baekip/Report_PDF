#!/usr/bin/perl

use strict;
use warnings;

if (@ARGV != 1){
    printUsage();
}

my $in_sample_config = $ARGV[0];

my %info;
read_sample_config($in_sample_config, \%info);

my $dev_path = $info{dev_path};
my $figure_path = "$dev_path/wes/Raw_Resource/Figure";
my $text_path = "$dev_path/wes/Raw_Resource/Text";
my $raw_type = $info{raw_type};
my $report_path = $info{report_path};
my $resource_path = "$report_path/resource";
my($raw_format,$raw_report_type) = split /\#/, $raw_type;
$raw_type = trim($raw_format);

print "Raw_Report_Type: ".$raw_format."\n";
#print $figure_path."\n";

print $resource_path."\n";
if ($raw_type eq "dna"){
`cp $figure_path/DNA_library.png "$resource_path/2. Workflow/2.1 c_photo_01.png" \n`;
`cp $text_path/DNA_library.txt "$resource_path/2. Workflow/2.1 c_label.txt" \n`;
`cp $text_path/copyright_Ill.txt "$resource_path/2. Workflow/2.1 d_label.txt" \n`;
}elsif ($raw_type eq "wes"){
`cp $figure_path/WES.png "$resource_path/2. Workflow/2.1 c_photo_01.png" \n`;
`cp $text_path/WES.txt "$resource_path/2. Workflow/2.1 c_label.txt" \n`;
`cp $text_path/copyright_agilent.txt "$resource_path/2. Workflow/2.1 d_label.txt" \n`;
}elsif ($raw_type eq "mate"){
`cp $figure_path/Mate_Pair.png "$resource_path/2. Workflow/2.1 c_photo_01.png" \n`;
`cp $text_path/Mate_Pair.txt "$resource_path/2. Workflow/2.1 c_label.txt" \n`;
`cp $text_path/copyright_Ill.txt "$resource_path/2. Workflow/2.1 d_label.txt" \n`;
}elsif ($raw_type eq "rna"){
`cp $figure_path/mRNA_isolation.png "$resource_path/2. Workflow/2.1 c_photo_01.png" \n`;
`cp $text_path/mRNA_isolation.txt "$resource_path/2. Workflow/2.1 c_label.txt" \n`;
`cp $text_path/copyright_Ill.txt "$resource_path/2. Workflow/2.1 d_label.txt" \n`;
}elsif ($raw_type eq "strand"){
`cp $figure_path/RNA_Stranded.png "$resource_path/2. Workflow/2.1 c_photo_01.png" \n`;
`cp $text_path/RNA_Stranded.txt "$resource_path/2. Workflow/2.1 c_label.txt" \n`;
`cp $text_path/copyright_Ill.txt "$resource_path/2. Workflow/2.1 d_label.txt" \n`;
}
sub read_sample_config {
    my ($config, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $config or die;
    while (my $row = <$fh>){
        chomp $row;
        if($row =~ /^#/){next;}
        if(length($row) == 0) {next;}


        my ($key, $value) = split /\=/, $row;
        $key = trim($key);
        $value = trim($value);
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
    return wantarray ? @result:$result[0];
}


sub printUsage {
    print "perl $0 <in.config> \n";
}
