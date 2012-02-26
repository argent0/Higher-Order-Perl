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

sub upfrom {
	my $n = $_[0];
	return node($n, promise { upfrom($n+1) });
}

sub show {
	my ($s,$n) = @_;
	while( $s && (!defined $n ||  $n-- > 0 ) ) {
		print drop($s),$";
		#$s = tail($s);
	}
	print $/;
}

sub drop {
	my $h = head($_[0]);
	$_[0] = tail($_[0]);
	return $h;
}

sub transform (&$) {
	my ($f,$s) = @_;
	return unless $s;
	node($f->(head($s)),
		promise { transform( $f,tail($s)) });
}

sub filter (&$) {
	my ($f,$s) = @_;
	until( !$s || $f->(head($s))) {
		drop($s);
	}
	return if !$s;
	node(head($s), promise { filter($f,tail($s))});
}
1;
