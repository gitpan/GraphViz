#!/usr/bin/perl

use strict;
use Test;

BEGIN { plan tests => 5 }

use GraphViz;

# Does it load?
ok(1); # 1

my $g = GraphViz->new();

# Does the constructor work?
ok(defined($g), 1); #2

# Let's build a simple graph
$g->add_node({ name => 'London'});
$g->add_node({ name => 'Paris', label => 'City of\nlurve'});
$g->add_node({ name => 'New York'});

$g->add_edge({ from => 'London',
	         to => 'Paris',});

$g->add_edge({ from => 'London',
                 to => 'New York',
	      label => 'Far'});

$g->add_edge({ from => 'Paris',
                 to => 'London',});

my $expect_text = q|digraph test {
	node1 [label="London"];
	node2 [label="New York"];
	node3 [label="City of\nlurve"];
	node1 -> node3;
	node1 -> node2 [label="Far"];
	node3 -> node1;
}
|;

# Does is generate the right .dot text?
ok($g->_as_debug, $expect_text); #3

$expect_text = q|digraph test {
	node [	label = "\N" ];
	node1 [label=London];
	node2 [label="New York"];
	node3 [label="City of\nlurve"];
	node1 -> node3;
	node1 -> node2 [label=Far];
	node3 -> node1;
}
|;

# Does it run dotneato and return the canonical representation
ok($g->as_canon, $expect_text); #4

$expect_text = q|digraph test {
	node [	label = "\N" ];
	graph [bb= "0,0,162,134"];
	node1 [label=London, pos="129,116", width="0.89", height="0.50"];
	node2 [label="New York", pos="39,23", width="1.08", height="0.50"];
	node3 [label="City of\nlurve", pos="129,23", width="0.92", height="0.62"];
	node1 -> node3 [pos="e,123,45 124,98 122,86 122,70 123,55"];
	node1 -> node2 [label=Far, pos="e,53,40 111,101 103,94 95,86 89,80 81,71 69,58 59,47", lp="105,72"];
	node3 -> node1 [pos="s,134,98 135,89 136,75 136,59 135,45"];
}
|;

# Does it run dotneato and lay things out properly?
ok($g->as_text, $expect_text); #5

