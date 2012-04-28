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

	sub is_empty {
		my $arg = shift;
		return (ref($arg) && $arg == $EXAUSTED);
	}
}

{
	sub iMap(&) {
		validate_pos(@_,{ type=> CODEREF } ); #function
		my $f = shift;

		return sub {
			validate_pos(@_,{ type=> HASHREF } ); #iterator
			my $it = shift;

			return Iterator->new ( sub {
				local $_ = $it->next;
				return empty() unless is_not_empty($_);
				return $f->($_);
			});
		}
	}
} 

{
	sub iGrep(&) {
		validate_pos(@_,{ type=> CODEREF }); #function,#iterator
		my $predicate = shift;
		return sub {
			validate_pos(@_,{ type=> HASHREF } ); #function,#iterator
			my $it = shift;
			return Iterator->new ( sub {
				local $_;
				while ( is_not_empty( $_ = $it->next ) ) {
					return $_ if $predicate->($_);
				}
				return empty();
			});
		}
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
				my $map = iMap { 
							my $it = shift; 
							$stopCondition = 1 unless 
								is_not_empty( my $value = $it->next);
							push @ret, $value;
				}->iterList(\@its);
				while ( is_not_empty( $map->next) ) {}
				return empty() if $stopCondition == 1;
				return \@ret;
		});
	}
}

{
	sub iZipWith (&) {
		# Zips two iterators using an argument funtion;
		# for now this will stop as soon as the shortest iterator is empty;
		my $joiner = shift;
		return sub {
			my $stopCondition = shift || 
				sub { is_empty($_[0]) || is_empty($_[1]) };
			return sub {
				# This is the sub that takes two iterators and joins them with the
				# previously provided funcion.
				# This shall also take a stop condition in the future

				my ($ai, $bi)  = @_;

				return Iterator->new( sub {
						my $va = $ai->next;
						my $vb = $bi->next;
						return empty()
							if $stopCondition->($va,$vb);
						return $joiner->($va,$vb)
				});
			}
		}
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
					$r = $f->($r,$value);
				}
				return $r;
			}
		}
	}
}

{
	sub iAny (&) {
		my $predicate = shift;
		return sub {
			my $iterator = shift;
			while ( is_not_empty( my $value = $iterator->next)) {
				return 1 if $predicate->($value);
			}
			return 0;
		}
	}
}

{ 
	sub iPartition (&) {
		my $predicate = shift;
		return sub {
			my $it = shift;
			my @a;
			my @b;

			while (is_not_empty(my $value = $it->next)) {
				if ($predicate->($value)) {
					push @a,$value;
				}else {
					push @b,$value;
				}
			}

			return (\@a,\@b);
		}
	}
}

{ 
	sub arrayPartition (&) {
		my $predicate = shift;
		return sub {
			my $it = iterList(\@_);
			my @a;
			my @b;

			while (is_not_empty(my $value = $it->next)) {
				if ($predicate->($value)) {
					push @a,$value;
				}else {
					push @b,$value;
				}
			}

			return (\@a,\@b);
		}
	}
}

{
	sub iTakeWhile (&) {
		my $predicate = shift;
		return sub {
			my $it = shift;
			return Iterator->new( sub {
				my $v = $it->next;
				return $v if ( is_not_empty($v) && $predicate->($v) );
				return empty();
			});
		}
	}
}

{
	sub iTake {
		my $n = shift;
		my $i = 0;
		return iTakeWhile { $n >= $i++ };
	}
}

{
	sub iToList {
		# Stores an interator into a list. This could be useful to sort things.
		my $iterator = shift;
		iFold { push @{$_[0]}, $_[1]; $_[0] }->([])->($iterator);
	}
}

1;
