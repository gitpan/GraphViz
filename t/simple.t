#!/usr/bin/perl -w

use lib '..';
use GraphViz;
use Test;

BEGIN { plan tests => 21 }

my @lines = <DATA>;

foreach my $lines (split '-- test --', (join "", @lines)) {
  my($test, $expect) = split '-- expect --', $lines;
  next unless $test;
  $expect =~ s|^\n||mg;
  $expect =~ s|\n$||mg;

  $test =~ s|^\n||mg;
  $test =~ s|\n$||mg;

  my $g;
  eval $test;

  my $result = $g->_as_debug;

  $result =~ s|^\n||mg;
  $result =~ s|\n$||mg;

  if ($expect eq $result) {
    ok(1);
  } else {
    ok($result, $expect);
#    print "[$result]\n";
  }
}


__DATA__
-- test --
$g = GraphViz->new();
-- expect --
digraph test {
}

-- test --
$g = GraphViz->new(directed => 1)
-- expect --
digraph test {
}

-- test --
$g = GraphViz->new(directed => 0)
-- expect --
graph test {
}

-- test --
$g = GraphViz->new(rankdir => 1)
-- expect --
digraph test {
	rankdir=LR;
}

-- test --
$g = GraphViz->new();
$g->add_node(label => 'London');
-- expect --
digraph test {
	node1 [label="London"];
}

-- test --
$g = GraphViz->new(directed => 0);
$g->add_node('London');
-- expect --
graph test {
	node1 [label="London"];
}

-- test --
$g = GraphViz->new();
$g->add_node('London', label => 'Big smoke');
-- expect --
digraph test {
	node1 [label="Big smoke"];
}

-- test --
$g = GraphViz->new();
$g->add_node('London', label => 'Big\nsmoke');
-- expect --
digraph test {
	node1 [label="Big\nsmoke"];
}

-- test --
$g = GraphViz->new();
$g->add_node('London', label => 'Big smoke', color => 'red');
-- expect --
digraph test {
	node1 [color="red", label="Big smoke"];
}

-- test --
$g = GraphViz->new();
$g->add_node('London');
$g->add_node('Paris');
-- expect --
digraph test {
	node1 [label="London"];
	node2 [label="Paris"];
}

-- test --
$g = GraphViz->new();
$g->add_node('London');
$g->add_edge('London' => 'London');
-- expect --
digraph test {
	node1 [label="London"];
	node1 -> node1;
}

-- test --
$g = GraphViz->new();
$g->add_node('London');
$g->add_edge('London' => 'London', label => 'Foo');
-- expect --
digraph test {
	node1 [label="London"];
	node1 -> node1 [label="Foo"];
}

-- test --
$g = GraphViz->new();
$g->add_node('London');
$g->add_edge('London' => 'London', color => 'red');
-- expect --
digraph test {
	node1 [label="London"];
	node1 -> node1 [color="red"];
}

-- test --
$g = GraphViz->new();
$g->add_node('London');
$g->add_node('Paris');
$g->add_edge('London' => 'Paris');
-- expect --
digraph test {
	node1 [label="London"];
	node2 [label="Paris"];
	node1 -> node2;
}

-- test --
$g = GraphViz->new();
$g->add_node('London');
$g->add_node('Paris');
$g->add_edge('London' => 'Paris');
$g->add_edge('Paris' => 'London');
-- expect --
digraph test {
	node1 [label="London"];
	node2 [label="Paris"];
	node1 -> node2;
	node2 -> node1;
}

-- test --
$g = GraphViz->new();
$g->add_node('London');
$g->add_node('Paris');
$g->add_edge('London' => 'London');
$g->add_edge('Paris' => 'Paris');
$g->add_edge('London' => 'Paris');
$g->add_edge('Paris' => 'London');
-- expect --
digraph test {
	node1 [label="London"];
	node2 [label="Paris"];
	node1 -> node1;
	node1 -> node2;
	node2 -> node1;
	node2 -> node2;
}

-- test --
$g = GraphViz->new();
$g->add_node('London');
$g->add_node('Paris', label => 'City of\nlurve');
$g->add_node('New York');

$g->add_edge('London' => 'Paris');
$g->add_edge('London' => 'New York', label => 'Far');
$g->add_edge('Paris' => 'London');
-- expect --
digraph test {
	node1 [label="London"];
	node3 [label="New York"];
	node2 [label="City of\nlurve"];
	node1 -> node3 [label="Far"];
	node1 -> node2;
	node2 -> node1;
}

-- test --
# Test clusters
$g = GraphViz->new();

$g->add_node('London', cluster => 'Europe');
$g->add_node('Paris', label => 'City of\nlurve', cluster => 'Europe');
$g->add_node('New York');

$g->add_edge('London' => 'Paris');
$g->add_edge('London' => 'New York', label => 'Far');
$g->add_edge('Paris' => 'London');
-- expect --
digraph test {
	node3 [label="New York"];
	node1 -> node3 [label="Far"];
	node1 -> node2;
	node2 -> node1;
	subgraph cluster_node4 {
		label="Europe";
		node1 [label="London"];
		node2 [label="City of\nlurve"];
	}
}

-- test --
$g = GraphViz->new({directed => 0});

foreach my $i (1..16) {
  my $used = 0;
  $used = 1 if $i >= 2 and $i <= 4;
  foreach my $j (2..4) {
    if ($i != $j && $i % $j == 0) {
      $g->add_edge($i => $j);
      $used = 1;
    }
  }
  $g->add_node($i) if $used;
}
-- expect --
graph test {
	node7 [label="10"];
	node8 [label="12"];
	node9 [label="14"];
	node10 [label="15"];
	node11 [label="16"];
	node1 [label="2"];
	node2 [label="3"];
	node3 [label="4"];
	node4 [label="6"];
	node5 [label="8"];
	node6 [label="9"];
	node7 -- node1;
	node8 -- node1;
	node8 -- node2;
	node8 -- node3;
	node9 -- node1;
	node10 -- node2;
	node11 -- node1;
	node11 -- node3;
	node3 -- node1;
	node4 -- node1;
	node4 -- node2;
	node5 -- node1;
	node5 -- node3;
	node6 -- node2;
}

-- test --
$g = GraphViz->new();

$g->add_node('London', label => ['Heathrow', 'Gatwick']);
$g->add_node('Paris', label => 'CDG');
$g->add_node('New York', label => 'JFK');

$g->add_edge('London' => 'Paris', from_port => 0);

$g->add_edge('New York' => 'London', to_port => 1);
-- expect --
digraph test {
	node1 [label="<port0>Heathrow|<port1>Gatwick", shape="record"];
	node3 [label="JFK"];
	node2 [label="CDG"];
	"node1":port0 -> node2;
	node3 -> "node1":port1;
}

-- test --
$g = GraphViz->new(width => 400, height => 400)
-- expect --
digraph test {
	size="400,400";
	ratio=fill
}
