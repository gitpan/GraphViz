#!/usr/bin/perl
#
# This is a simple example of constructing
# undirected graphs. It shows factors, kinda ;-)
#


use strict;
use lib '..';
use GraphViz;

my $g = GraphViz->new({directed => 0});

foreach my $i (1..16) {
  my $used = 0;
  $used = 1 if $i >= 2 and $i <= 4;
  foreach my $j (2..4) {
    if ($i != $j && $i % $j == 0) {
      $g->add_edge({from => $i, to => $j});
      $used = 1;
    }
  }
  $g->add_node({ name => $i}) if $used;
}

#print $g->_as_debug;
#print $g->as_text;
print $g->as_png;

