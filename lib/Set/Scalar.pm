package Set::Scalar;

use strict;
local $^W = 1;

use vars qw($VERSION @ISA);

$VERSION = '1.17';

@ISA = qw(Set::Scalar::Real Set::Scalar::Null Set::Scalar::Base);

use Set::Scalar::Base qw(_make_elements is_equal as_string_callback);
use Set::Scalar::Real;
use Set::Scalar::Null;
use Set::Scalar::Universe;

sub ELEMENT_SEPARATOR { " "    }
sub SET_FORMAT        { "(%s)" }

sub _insert_hook {
    my $self     = shift;

    if (@_) {
	my $elements = shift;

	$self->universe->_extend( $elements );

	$self->_insert_elements( $elements );
    }
}

sub _new_hook {
    my $self     = shift;
    my $elements = shift;

    $self->{ universe } = Set::Scalar::Universe->universe;

    $self->_insert( { _make_elements( @$elements ) } );
}

=pod

=head1 NAME

Set::Scalar - basic set operations

=head1 SYNOPSIS

    use Set::Scalar;
    $s = Set::Scalar->new;
    $s->insert('a', 'b');
    $s->delete('b');
    $t = Set::Scalar->new('x', 'y', $z);

=head1 DESCRIPTION

=head2 Creating

    $s = Set::Scalar->new;
    $s = Set::Scalar->new(@members); 

    $t = $s->clone;
    $t = $s->copy; # clone of clone

=head2 Modifying

    $s->insert(@members);
    $s->delete(@members);
    $s->invert(@members); # insert if hasn't, delete if has

    $s->clear; # removes all the elements

Note that clear() only releases the memory used by the set to
be reused by Perl; it will not reduce the overall memory use.

=head2 Displaying

    print $s, "\n";

The display format of a set is the members of the set separated by
spaces and enclosed in parentheses ().

You can even display recursive sets.

See L</"Customising Display"> for customising the set display.

=head2 Querying

    @members  = $s->members;
    @elements = $s->elements; # alias for members

    $size = $s->size; # the number of members

    $s->has($m)       # return true if has that member
    $s->contains($m)  # alias for has

    if ($s->has($member)) { ... }

    $s->member($m)    # returns the member if has that member
    $s->element($m)   # alias for member

    $s->is_null       # returns true if the set is empty
    $s->is_empty      # alias for is_null
    $s->is_universal  # returns true if the set is universal

    $s->null          # the null set
    $s->empty         # alias for null
    $s->universe      # the universe of the set

=head2 Deriving

    $u = $s->union($t);
    $i = $s->intersection($t);
    $d = $s->difference($t);
    $e = $s->symmetric_difference($t);
    $v = $s->unique($t);
    $c = $s->complement;

These methods have operator overloads:    

    $u = $s + $t; # union
    $i = $s * $t; # intersection
    $d = $s - $t; # difference
    $e = $s % $t; # symmetric_difference
    $v = $s / $t; # unique
    $c = -$s;     # complement

Both the C<symmetric_difference> and C<unique> are symmetric on all
their arguments.  For two sets they are identical but for more than
two sets beware: C<symmetric_difference> returns true for elements
that are in an odd number (1, 3, 5, ...) of sets, C<unique> returns
true for elements that are in one set.

Some examples of the various set differences:

    set or difference                   value

    $a                                  (a b c d e)
    $b                                  (c d e f g)
    $c                                  (e f g h i)

    $a->difference($b)                  (a b)
    $a->symmetric_difference($b)        (a b f g)
    $a->unique($b)                      (a b f g)

    $b->difference($a)                  (f g)
    $b->symmetric_difference($a)        (a b f g)
    $b->unique($a)                      (a b f g)

    $a->difference($b, $c)              (a b)
    $a->symmetric_difference($b, $c)    (a b e h i)
    $a->unique($b, $c)                  (a b h i)

=head2 Comparing

    $eq = $s->is_equal($t);
    $dj = $s->is_disjoint($t);
    $pi = $s->is_properly_intersecting($t);
    $ps = $s->is_proper_subset($t);
    $pS = $s->is_proper_superset($t);
    $is = $s->is_subset($t);
    $iS = $s->is_superset($t);

    $cmp = $s->compare($t);

The C<compare> method returns a string from the following list:
"equal", "disjoint", "proper subset", "proper superset", "proper
intersect", and in future (once I get around implementing it),
"disjoint universes".

These methods have operator overloads:    

    $eq = $s == $t; # is_equal
    $dj = $s != $t; # is_disjoint
    # No operator overload for is_properly_intersecting.
    $ps = $s < $t;  # is_proper_subset
    $pS = $s > $t;  # is_proper_superset
    $is = $s <= $t; # is_subset
    $iS = $s >= $t; # is_superset

    $cmp = $s <=> $t;

=head2 Boolean contexts

In Boolean contexts such as

    if ($set) { ... }
    while ($set1 && $set2) { ... }

the size of the C<$set> is tested, so empty sets test as false,
and non-empty sets as true.

=head2 Iterating

    while (defined(my $e = $s->each)) { ... }

This is more memory-friendly than

    for my $e ($s->elements) { ... }

which would first construct the full list of elements and then
walk through it: the C<$s-E<gt>each> handles one element at a time.

Analogously to using normal C<each(%hash)> in scalar context,
using C<$s-E<gt>each> has the following caveats:

=over 4

=item *

The elements are returned in (apparently) random order.
So don't expect any particular order.

=item *

When no more elements remain C<undef> is returned.  Since you may one
day have elements named C<0> don't test just like this

    while (my $e = $s->each) { ... }          # WRONG

but instead like this

    while (defined(my $e = $s->each)) { ... } # right

=item *

There is one iterator per one set which is shared by many
element-accessing interfaces-- using the following will reset the
iterator: elements(), insert(), members(), size(), unique().  insert()
causes the iterator of the set being inserted (not the set being the
target of insertion) becoming reset.  unique() causes the iterators of
all the participant sets becoming reset.  B<The iterator getting reset
most probably causes an endless loop.>  So avoid doing that.

=item *

Modifying the set during the iteration may cause elements to be missed
or duplicated, or in the worst case, an endless loop; so don't do
that, either.

=back

=head2 Customising Display

If you want to customise the display routine you will have to
modify the C<as_string> callback.  You can modify it either
for all sets by using C<as_string_callback()> as a class method:

    my $class_callback = sub { ... };

    Set::Scalar->as_string_callback($class_callback);

or for specific sets by using C<as_string_callback()> as an object
method:

    my $callback = sub  { ... };

    $s1->as_string_callback($callback);
    $s2->as_string_callback($callback);

The anonymous subroutine gets as its first (and only) argument the
set to display as a string.  For example to display the set C<$s>
as C<a-b-c-d-e> instead of C<(a b c d e)>

    $s->as_string_callback(sub{join("-",sort $_[0]->elements)});

If called without an argument, the current callback is returned.

If called as a class method with undef as the only argument, the
original callback (the one returning C<(a b c d e)>) for all the sets
is restored, or if called for a single set the callback is removed
(and the callback for all the sets will be used).

=head1 AUTHOR

Jarkko Hietaniemi <jhi@iki.fi>

=head1 COPYRIGHT AND LICENSE

Copyright 2001 by Jarkko Hietaniemi

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;
