#!/usr/local/bin/perl
#
# This is a simple example which provides an 
# alternative way of displaying a data structure
# than Data::Dumper

use strict;
use lib '..';
use Data::Dumper;
use GraphViz;

my $g = GraphViz->new;

my(@d);

@d = qw(3 1 4 1);
@d = ([3, 1, 4, 1], 9, 9, 9);
@d = ([3, 1, 4, 1], "foo", \"bar", \3.141, [[3]]);
@d = ({ a => '3', b => '4'});
@d = ("red", { a => [3, 1, 4, 1], b => { q => 'a', w => 'b'}}, "blue", undef);

dumper(@d);

warn Dumper(@d);

#print $g->_as_debug;
#print $g->as_text;
print $g->as_png;

sub dumper {
  my(@items) = @_;

  my @parts;

  foreach my $item (@items) {
    push @parts, label($item);
  }

  my $colour = 'black';
  $colour = 'blue' if @parts == 1;

  my $source = $g->add_node({ label => \@parts, color => $colour });

  foreach my $port (0.. @items-1) {
    my $item = $items[$port];
#warn "$port = $item\n";

    next unless ref $item;
    my $ref = ref $item;
    if ($ref eq 'SCALAR') {
      my $target = dumper($$item);
      $g->add_edge({ from => $source, from_port => $port, to => $target });
    } elsif ($ref eq 'ARRAY') {
      my $target = dumper(@$item);
      $g->add_edge({ from => $source, from_port => $port, to => $target });
    } elsif ($ref eq 'HASH') {
      my @hash;
      foreach my $key (sort keys(%$item)) {
        push @hash, $key;
      }
      my $hash = $g->add_node({ label => \@hash, color => 'brown' });
      foreach my $port (0.. @hash-1) { 
        my $key = $hash[$port]; 
        my $target = dumper($item->{$key});
        $g->add_edge({ from => $hash, from_port => $port, to => $target });
      }
      $g->add_edge({ from => $source, from_port => $port, to => $hash }); 
    }
  }

  return $source;
}

sub label {
  my $scalar = shift;

  my $ref = ref $scalar;

  if (not defined $scalar) {
    return 'undef';
  } elsif ($ref eq 'ARRAY') {
    return '@';
  } elsif ($ref eq 'SCALAR') {
    return '$';
  } elsif ($ref eq 'HASH') {
    return '%';
  } else {
    return $scalar;
  }
}