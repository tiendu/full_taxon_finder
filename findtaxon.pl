use strict;
use Getopt::Long;
use Pod::Usage;

my $fullnamelineage_path;
my $names_path;
my $result_path;
my $help = 0;
GetOptions(
    "fullnamelineage=s" => \$fullnamelineage_path,
    "names=s" => \$names_path,
    "result=s" => \$result_path,
    "help|?" => \$help) or pod2usage(2);
pod2usage(1) if $help;

my $result_path_cp = $result_path;
$result_path_cp =~ s/.*\///;
my ($file_name, $file_extension) = $result_path_cp =~ /^(.+)\.([^.]+)$/;

open my $names, "<:utf8", $names_path or die;
my %name_id;
while (<$names>) {
    chomp;
    my @fields = split /\t\|\t/;
    my $id = $fields[0];
    my $name = $fields[1];
    $name_id{$name} = $id unless exists $name_id{$name};
    last if eof $names;
};
close $names;

open my $fullnames, "<:utf8", $fullnamelineage_path or die;
my %id_fullname;
while (<$fullnames>) {
    chomp;
    my @fields = split /\t\|\t/;
    my $id = $fields[0];
    my $name = $fields[1];
    my $fullname = $fields[2];
    $fullname =~ s/\t\|//;
    $id_fullname{$id} = "${fullname}${name}" unless exists $id_fullname{$id};
    last if eof $fullnames;
};
close $fullnames;

open my $result, "<:utf8", $result_path or die;
open my $result_full, ">:utf8", "full_${file_name}.${file_extension}" or die;
while (my $line = <$result>) {
    chomp $line;
    my @fields = split /\t/, $line;
    my $id = $fields[0];
    my $taxon = $fields[1];
    $taxon =~ s/ +\z//;
    $taxon =~ s/\A +//;
    if (exists $name_id{$taxon}) {
        print $result_full "$id\t$id_fullname{$name_id{$taxon}}\n";
    } else {
        print $result_full "$id\t$taxon\n";
    };
    last if eof $result;
};
close $result;
close $result_full;

__END__

=head1 SYNOPSIS

findtaxon.pl -fullnamelineage fullnamelineage.dmp -names names.dmp -result path_to_blastx_result

=head1 OPTIONS

=over 20   

=item B<-fullnamelineage>

Path to 'fullnamelineage.dmp'.

=item B<-names>

Path to 'names.dmp'.

=item B<-result>

Path to DIAMOND BLASTx result.

=item B<-help>

Print this message and exits.

=cut
