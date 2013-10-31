package Koha::Plugin::Org::Deichman::NBReport;

use Modern::Perl;

use base qw(Koha::Plugins::Base);

use C4::Context;

our $VERSION = 0.1;

our $metadata = {
    name   => 'NB statistikkrapport',
    author => 'Petter Goksøyr Åsen / Magnus Enger',
    description =>
        'Dette pluginet genererer en rapport med statistikkdata ment for å sendes til Nasjonalbiblioteket.',
    date_authored   => '2013-10-31',
    date_updated    => '2013-10-31',
    minimum_version => '3.0100107',
    maximum_version => undef,
    version         => $VERSION,
};

sub new {
    my ( $class, $args ) = @_;

    $args->{'metadata'} = $metadata;

    my $self = $class->SUPER::new($args);

    return $self;
}

sub report {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};

    my $template = $self->get_template( { file => 'report-step1.tt' } );

    $template->param(
        holdings => GetCounts(),
        year => 2013,
    );

    print $cgi->header();
    print $template->output();
}

sub GetCounts() {
    my $dbh = C4::Context->dbh;
    my $year = 2013;

    my @itemtypes = (
        {   name       => "bestand bøker",
            itypes     => ["L"],
            holdings   => 0,
            holdings_n => '007',
            added      => 0,
            added_n    => '008',
            deleted    => 0,
            deleted_n  => '009'
        },
        {   name       => 'AV-dokumenter',
            itypes     => [ "EE", "GD", "DC", "DI", "EF", "ED" ],
            holdings   => 0,
            holdings_n => '023',
            added      => 0,
            added_n    => '024',
            deleted    => 0,
            deleted_n  => '025'
        }
    );

    my $count = scalar(@itemtypes);

    for ( my $i = 0; $i < $count; $i++ ) {

        # 1. holdings
        my $hold_query = "SELECT count(biblionumber)
                          FROM items
                          WHERE " . orify('itype', @{$itemtypes[$i]{'itypes'}});

        my $hold_sth = $dbh->prepare($hold_query);
        $hold_sth->execute();
        my $hold_count = $hold_sth->fetchrow;
        $itemtypes[$i]{'holdings'} = $hold_count;

        # 2. additions
        my $acq_query = "SELECT count(biblionumber)
                         FROM items
                         WHERE YEAR(dateaccessioned) = $year
                         AND " . orify('itype', @{$itemtypes[$i]{'itypes'}});

        # 3. deletions
        my $del_query = "SELECT count(itemnumber)
                         FROM deleteditems
                         WHERE YEAR(timestamp) = $year
                         AND " . orify('itype', @{$itemtypes[$i]{'itypes'}});
        my $del_sth = $dbh->prepare($del_query);
        $del_sth->execute();
        my $del_count = $del_sth->fetchrow;
        $itemtypes[$i]{'deleted'} = $del_count;
    }

    return \@itemtypes;
}

sub install() {
    my ( $self, $args ) = @_;

    return 1;    # return true if installation succeded
}

sub uninstall() {
    my ( $self, $args ) = @_;

    return 1;
}


# Utilities:

# Takes the name of a column and an array of values and creates a list of ORed values:
# In: orify('i.itype', ['DVD', 'LBOK', 'VID']);
# Out: "(i.itype = 'DVD' OR i.itype = 'LBOK' OR i.itype = 'VID')"
sub orify {
        my $column = shift;
        my @values = @_;
        my $count = 0;
        my $out = '(';
        for my $value (@values) {
                if ($count > 0) {
                        $out .= " OR ";
                }
                $out .= "$column = '" . $value . "'";
                $count++;
        }
        $out .= ')';
        return $out;
}