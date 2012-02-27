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
