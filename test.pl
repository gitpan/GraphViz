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
	London -> Paris;
	London -> node1 [label="Far"];
	Paris -> London;
	London [label="London"];
	node1 [label="New York"];
	Paris [label="City of\nlurve"];
}
|;

# Does is generate the right .dot text?
ok($g->_as_debug, $expect_text); #3

$expect_text = q|digraph test {
	node [	label = "\N" ];
	London [label=London];
	Paris [label="City of\nlurve"];
	node1 [label="New York"];
	London -> Paris;
	London -> node1 [label=Far];
	Paris -> London;
}
|;

# Does it run dotneato and return the canonical representation
ok($g->as_canon, $expect_text); #4

$expect_text = q|digraph test {
	node [	label = "\N" ];
	graph [bb= "0,0,162,134"];
	London [label=London, pos="33,116", width="0.89", height="0.50"];
	Paris [label="City of\nlurve", pos="33,23", width="0.92", height="0.62"];
	node1 [label="New York", pos="123,23", width="1.08", height="0.50"];
	London -> Paris [pos="e,27,45 28,98 26,86 26,70 27,55"];
	London -> node1 [label=Far, pos="e,107,40 49,100 63,85 84,63 101,46", lp="99,72"];
	Paris -> London [pos="s,38,98 39,92 40,78 40,60 39,45"];
}
|;

# Does it run dotneato and lay things out properly?
ok($g->as_text, $expect_text); #5

