package Iterator;
use v5.14;

use Params::Validate qw/ CODEREF ARRAYREF HASHREF validate_pos /;
use Data::Dumper;

sub new {

	validate_pos (@_, 1, {type=>CODEREF} ); #mandatory coderef to iterate
		
	my $class = shift;
	my $self = { callback=>shift};

	bless($self,$class);
	return $self;
}

sub next {
	my $self = shift;
	return $self->{callback}->();
}

{ 
	my $EXAUSTED = [];

	sub empty() {
		return $EXAUSTED;
	}

	sub is_not_empty {
		my $arg = shift;
		return !(ref($arg) && $arg == $EXAUSTED);
	};
}

{
	sub imap(&$) {
		validate_pos(@_,{ type=> CODEREF },{ type=> HASHREF } ); #function,#iterator

		my ($transform,$it) = @_;

		return Iterator->new ( sub {
			local $_ = $it->next;
			return empty() unless is_not_empty($_);
			return $transform->($_);
		});
	}
} 

{
	sub igrep(&$) {
		validate_pos(@_,{ type=> CODEREF },{ type=> HASHREF } ); #function,#iterator

		my ($is_intresting,$it) = @_;

		return Iterator->new ( sub {
				local $_;
				while ( is_not_empty( $_ = $it->next ) ) {
					return $_ if $is_intresting->($_);
				}

				return empty();
		});
	}
}

{
	sub iterList {
		validate_pos(@_, {type=>ARRAYREF} );

		my $aref = shift;
		my @list = @{$aref};
		return Iterator->new( sub {	
			return empty() unless defined ( my $ret = shift @list );	
			return $ret;
		});
	}
}

{
	sub append {
		my @its = @_; #list of iterators
		return Iterator->new( sub {
				while( @its ) {
					my $val = $its[0]->next;
					return $val if is_not_empty($val);
					shift @its;
				}
				return empty();
		});
	}
}

{
	sub coIterate {
		my @its = @_;
		my $currentElement = 0;
		my $stopCondition = 0;

		return Iterator->new ( sub {
				my $i = $currentElement++;
				my @ret; 
				my $empty;
				my $map = imap( sub { 
							my $it = shift; 
							$stopCondition = 1 unless is_not_empty( my $value =
								$it->next);
							push @ret, $value;
				},iterList(\@its) );
				while ( is_not_empty( $map->next) ) {}
				return empty() if $stopCondition == 1;
				return \@ret;
		});
	}
}
{
	sub iFold (&) {
		validate_pos(@_,{ type=> CODEREF } ); 

		my $f = shift;

		sub {
			my $r = shift; #initial Value
			sub {
				my $i = shift; #iterator
				while( is_not_empty( my $value = $i->next ) ) {
					say "Value $value";
					$r = $f->($r,$value);
				}
			}
		}
	}
}
1;
