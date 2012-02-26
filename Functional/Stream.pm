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
	my ($ls) = @_;
	return $ls->[1];
}

sub set_head {
	my ($ls,$new_head) = @_;
	$ls->[0] = $new_head;
}

sub set_tail {
	my ($ls,$new_tail) = @_;
	$ls->[1] = $new_tail;
}

1;
