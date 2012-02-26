package Stream;

sub node {
	my ($h,$t) = @_;
	return [$h,$t];
}

sub head {
	my ($ls) = @_;
	return $ls->[0];
}

sub tail {
	my ($s) = @_;
	if ( is_promise( $s->[1])) {
		return $s->[1]->();
	}
	return $s->[1];
}

sub set_head {
	my ($ls,$new_head) = @_;
	$ls->[0] = $new_head;
}

sub set_tail {
	my ($ls,$new_tail) = @_;
	$ls->[1] = $new_tail;
}

sub is_promise {
	UNIVERSAL::isa($_[0],'CODE');
}

sub promise (&) { $_[0] }

sub upto_list {
	my ($m,$n) = @_;
	return if $m>$n;
	return node($m, promise { upto_list($m+1,$n) });
}
1;
