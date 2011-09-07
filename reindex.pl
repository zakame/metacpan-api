use ElasticSearch;

my $es = ElasticSearch->new( servers => 'localhost:9200' );

my $source = $es->scrolled_search(
    search_type => 'scan',
    scroll      => '1m',
    index       => 'cpan_v3',
    type        => 'file',
    fields      => [ '_source', '_parent' ],
);

$es->reindex(
    source     => $source,
    bulk_size  => 1000,
    dest_index => 'cpan_v1',
);
