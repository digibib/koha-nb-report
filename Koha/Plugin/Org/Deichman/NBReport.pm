package Koha::Plugin::Org::Deichman::NBReport;

use Modern::Perl;

use base qw(Koha::Plugins::Base);

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

    print $cgi->header();
    print $template->output();
}

sub install() {
    my ( $self, $args ) = @_;

    return 1;    # return true if installation succeded
}

sub uninstall() {
    my ( $self, $args ) = @_;

    return 1;
}
