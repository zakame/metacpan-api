package MetaCPAN::Model;
use Moose;
use ElasticSearchX::Model;

analyzer lowercase => ( tokenizer => 'keyword', filter => 'lowercase' );
analyzer fulltext => ( type => 'snowball', language => 'English' );
tokenizer camelcase => (
    type => 'pattern',
    pattern => "([^\\p{L}\\d]+)|(?<=\\D)(?=\\d)|(?<=\\d)(?=\\D)|(?<=[\\p{L}&&[^\\p{Lu}]])(?=\\p{Lu})|(?<=\\p{Lu})(?=\\p{Lu}[\\p{L}&&[^\\p{Lu}]])"
);
analyzer camelcase => (
    type => 'custom',
    tokenizer => 'camelcase',
    filter => ['lowercase', 'unique']
);

index cpan => ( namespace => 'MetaCPAN::Document', alias_for => 'cpan_v3' );

index cpan_v1 => ( namespace => 'MetaCPAN::Document' );

index user => ( namespace => 'MetaCPAN::Model::User' );

__PACKAGE__->meta->make_immutable;

__END__
