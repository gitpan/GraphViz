#!/usr/bin/perl

use strict;
use Test;

BEGIN { plan tests => 3 }

use GraphViz;

ok(1); # 1

my $g = GraphViz->new();

ok(defined($g), 1); #2

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

my $expect_text = qq|digraph test {
\tLondon -> Paris;
\tLondon -> New_York [label=Far];
\tParis -> London;
\tLondon [label=London];
\tNew_York [label="New York"];
\tParis [label="City of\\nlurve"];
}
|;

ok($g->as_text, $expect_text); #3



