package MetaCPAN::Document::TestReport;
use Moose;
use ElasticSearchX::Model::Document;
use ElasticSearchX::Model::Document::Types qw(:all);
use MooseX::Types::Structured qw(Dict Tuple Optional);
use MooseX::Types::Moose qw(Int Num Bool Str ArrayRef HashRef Undef);

has id => ( required => 1, id => 1, isa => Str, is => 'ro', store => 'no' );
has state  => ( required => 1, isa => Str, is => 'ro', store => 'no' );
has tester => ( required => 1, isa => Str, is => 'ro', store => 'no' );
has date => ( required => 1, isa => 'DateTime', is => 'ro', store => 'no' );
has distribution => ( required => 1, isa => Str, is => 'ro', store => 'no' );
has version      => ( required => 0, isa => Str, is => 'ro', store => 'no' );
has release      => (
    required => 1,
    isa      => Str,
    is       => 'ro',
    builder  => '_build_release',
    store    => 'no' );
has perl => ( required => 1, isa => Str, is => 'ro', store => 'no' );
has os => (
    required => 0,
    isa      => Dict [ name => Optional [Str], version => Optional [Str] ],
    is       => 'ro',
    dynamic  => 1,
    store    => 'no',
    default => sub { {} } );
has platform => ( required => 0, isa => Str, is => 'ro', store => 'no' );
has type     => ( required => 1, isa => Int, is => 'ro', store => 'no' );

__PACKAGE__->meta->make_immutable;
