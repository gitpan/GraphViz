#!/usr/bin/perl
#
# This is a simple example for illustrating the
# concepts of ports

use strict;
use lib '..';
use GraphViz;

my $g = GraphViz->new();

$g->add_node({ name => 'London', label => ['Heathrow', 'Gatwick']});
$g->add_node({ name => 'Paris', label => 'CDG'});
$g->add_node({ name => 'New York', label => 'JFK'});

$g->add_edge({      from => 'London',
	       from_port => 0,
                      to => 'Paris',
});

$g->add_edge({    from => 'New York',
                    to => 'London',
	       to_port => 1,
});

#print $g->_as_debug;
#print $g->as_text;
print $g->as_png;

