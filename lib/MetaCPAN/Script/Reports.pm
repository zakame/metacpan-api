package MetaCPAN::Script::Reports;

use Moose;
with 'MooseX::Getopt';
use Log::Contextual qw( :log :dlog );
with 'MetaCPAN::Role::Common';
use File::Spec::Functions qw(catfile);
use File::Temp qw(tempdir);
use JSON           ();
use Parse::CSV     ();
use LWP::UserAgent ();
use Archive::Tar   ();
use DBI            ();

has db => ( is => 'ro', default => 'var/tmp/cpanstats.db' );
has full => ( isa => 'Bool', is => 'ro', default => 0 );

sub run {
    my $self = shift;
    $self->index_reports;
    $self->index->refresh;
}

sub index_reports {
    my $self  = shift;
    my $es    = $self->model->es;
    my $index = $self->index->name;
    log_info { "Opening database file at " . $self->db };
    my $dbh = DBI->connect( "dbi:SQLite:dbname=" . $self->db );
    my $sth;
    if ( $self->full ) {
        $sth = $dbh->prepare("SELECT * FROM cpanstats");
    } else {
        my $latest = $es->search(
            index => $index,
            type  => 'testreport',
            query => { match_all => {} },
            size  => 1,
            sort  => [ { date => 'desc' } ] );
        my $from = $latest->{hits}->{hits}->[0]->{_source}->{date};
        log_info { "Indexing reports from $from" };
        $from =~ s/[\-T:]//g;
        $sth = $dbh->prepare(
            "SELECT * FROM cpanstats WHERE date >= $from ORDER BY date");
    }
    $sth->execute;
    my @bulk;

    while ( my $data = $sth->fetchrow_hashref ) {
        my @date = split( //, $data->{date} );
        my $date = join( '-',
            join( '', @date[ 0 .. 3 ] ),
            join( '', @date[ 4, 5 ] ),
            join( '', @date[ 6, 7 ] ) )
          . 'T'
          . join( ':',
            join( '', @date[ 8,  9 ] ),
            join( '', @date[ 10, 11 ] ), '00' );
        push(
            @bulk,
            Dlog_trace { $_ } +{
                create => {
                    index => $index,
                    type  => 'testreport',
                    id    => $data->{guid},
                    data  => {
                        distribution => $data->{dist},
                        id           => $data->{guid},
                        date         => $date,
                        os           => {
                            $data->{osname} ? ( name => $data->{osname} ) : (),
                            $data->{osvers}
                            ? ( version => $data->{osvers} )
                            : ()
                        },
                        map { $_ => $data->{$_} }
                          qw(perl platform state tester type version)
                    } } } );
        if ( @bulk > 1000 ) {
            log_debug { "Bulk" };
            $es->bulk(@bulk);
            @bulk = ();
        }
    }
    log_info { "done" };
}

1;

=pod

=head1 SYNOPSIS

 $ bin/metacpan mirrors

=head1 SOURCE

L<http://www.cpan.org/indices/mirrors.json>

=cut
