package Curry;

sub curry {
	my $f = shift;
	return sub {
		my $first_arg = shift;
		my $r = sub { $f->($first_arg,@_) };
		return @_ ? $r->(@_) : $r;
	};
}

sub curry_listfunction {
	my $f = shift;
	return sub {
		my $first_arg = shift;
		return sub { $f->($first_arg,@_) };
	};
}

# Makes a function with N arguments take default values.
sub curry_n {
	my ($N,$f) = @_;
	my $c;

	$c = sub {
		if (@_>$N) { $f->(@_) }
		else {
			my $a = @_;
			curry_n($N-@a, sub { $f->(@a,@_) });
		}
	};
}

sub fold {
	my $f = shift;
	sub {
		my $x = shift;
		sub {
			my $r = $x;
			while(@_) {
				$r = $f->($r,shift());
			}
			return $r;
		}
	}
}

1;
