#!/usr/bin/perl
#
# This is a simple idea which illustrates the use
# of clusters to, well, cluster nodes together
#


use strict;
use lib '..';
use GraphViz;

my $g = GraphViz->new();

$g->add_node({ name => 'London', cluster => 'Europe'});
$g->add_node({ name => 'Paris', label => 'City of\nlurve', cluster => 'Europe'});
$g->add_node({ name => 'New York'});

$g->add_edge({ from => 'London',
                   to => 'Paris',});

$g->add_edge({ from => 'London',
                   to => 'New York',
                label => 'Far'});

$g->add_edge({ from => 'Paris',
                   to => 'London',});

#print $g->_as_debug;
#print $g->as_text;
print $g->as_png;

