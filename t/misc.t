use Set::Scalar;

print "1..2\n";

{
	# Malcolm Purvis <malcolm.purvis@alcatel.com.au>
	my $s1 = Set::Scalar->new("A");
	my $s1_again = Set::Scalar->new("A");
	my $s2 = $s1->union($s1_again);
	my $s3 = Set::Scalar->new("C");
	my $s4 = $s2->difference($s3);
	print "not " unless $s4 eq "(A)";
	print "ok 1\n";
}

{
	# Malcolm Purvis <malcolm.purvis@alcatel.com.au>
	my $s1 = Set::Scalar->new(("A", "B"));
	my $s1_again = Set::Scalar->new(("A", "B"));
	my $s2 = $s1->union($s1_again);  
	my $s3 = Set::Scalar->new("C");
	my $s4 = $s2->difference($s3);
	print "not " unless $s4 eq "(A B)";
	print "ok 2\n";
}
