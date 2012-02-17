use v5.14;
use Functional::Iterator;
use Data::Dumper;

my $l1 = Iterator::iterList( [1,2,3] );
my $l2 = Iterator::iterList( [4,5,6] );
my $l3 = Iterator::iterList( [7,8,9] );
my $i = Iterator::coIterate( $l1,$l2,$l3);

while ( Iterator::is_not_empty( my $j = $i->next ) ) {
	say Dumper($j);
}
