#!/usr/bin/perl -w

use lib '../lib', 'lib';
use GraphViz;
use Test;

BEGIN { plan tests => 25 }

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
	London [label="London"];
}

-- test --
$g = GraphViz->new();
$g->add_node('London', label => 'Big smoke');
-- expect --
digraph test {
	London [label="Big smoke"];
}

-- test --
$g = GraphViz->new();
$g->add_node('London', label => 'Big\nsmoke');
-- expect --
digraph test {
	London [label="Big\nsmoke"];
}

-- test --
$g = GraphViz->new();
$g->add_node('London', label => 'Big smoke', color => 'red');
-- expect --
digraph test {
	London [color="red", label="Big smoke"];
}

-- test --
$g = GraphViz->new();
$g->add_node('London');
$g->add_node('Paris');
-- expect --
digraph test {
	London [label="London"];
	Paris [label="Paris"];
}

-- test --
$g = GraphViz->new();
$g->add_node('London');
$g->add_edge('London' => 'London');
-- expect --
digraph test {
	London [label="London"];
	London -> London;
}

-- test --
$g = GraphViz->new();
$g->add_node('London');
$g->add_edge('London' => 'London', label => 'Foo');
-- expect --
digraph test {
	London [label="London"];
	London -> London [label="Foo"];
}

-- test --
$g = GraphViz->new();
$g->add_node('London');
$g->add_edge('London' => 'London', color => 'red');
-- expect --
digraph test {
	London [label="London"];
	London -> London [color="red"];
}

-- test --
$g = GraphViz->new();
$g->add_node('London');
$g->add_node('Paris');
$g->add_edge('London' => 'Paris');
-- expect --
digraph test {
	London [label="London"];
	Paris [label="Paris"];
	London -> Paris;
}

-- test --
$g = GraphViz->new();
$g->add_node('London');
$g->add_node('Paris');
$g->add_edge('London' => 'Paris');
$g->add_edge('Paris' => 'London');
-- expect --
digraph test {
	London [label="London"];
	Paris [label="Paris"];
	London -> Paris;
	Paris -> London;
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
	London [label="London"];
	Paris [label="Paris"];
	London -> London;
	London -> Paris;
	Paris -> London;
	Paris -> Paris;
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
	London [label="London"];
	"New York" [label="New York"];
	Paris [label="City of\nlurve"];
	London -> "New York" [label="Far"];
	London -> Paris;
	Paris -> London;
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
	"New York" [label="New York"];
	London -> "New York" [label="Far"];
	subgraph cluster_Europe {
		label="Europe";
		London [label="London"];
		Paris [label="City of\nlurve"];
		London -> Paris;
		Paris -> London;
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
	10 [label="10"];
	12 [label="12"];
	14 [label="14"];
	15 [label="15"];
	16 [label="16"];
	2 [label="2"];
	3 [label="3"];
	4 [label="4"];
	6 [label="6"];
	8 [label="8"];
	9 [label="9"];
	10 -- 2;
	12 -- 2;
	12 -- 3;
	12 -- 4;
	14 -- 2;
	15 -- 3;
	16 -- 2;
	16 -- 4;
	4 -- 2;
	6 -- 2;
	6 -- 3;
	8 -- 2;
	8 -- 4;
	9 -- 3;
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
	London [label="<port0>Heathrow|<port1>Gatwick", shape="record"];
	"New York" [label="JFK"];
	Paris [label="CDG"];
	"London":port0 -> Paris;
	"New York" -> "London":port1;
}

-- test --
$g = GraphViz->new(width => 400, height => 400)
-- expect --
digraph test {
	size="400,400";
	ratio=fill
}

-- test --
$g = GraphViz->new(concentrate => 1)
-- expect --
digraph test {
	concentrate=true;
}

-- test --
$g = GraphViz->new(epsilon => 0.001, random_start => 1)
-- expect --
digraph test {
	epsilon=0.001;
	start=rand;
}

-- test --
# Test incremental buildup
$g = GraphViz->new();

$g->add_node('London');
$g->add_node('London', cluster => 'Europe');
$g->add_node('London', color => 'blue');
$g->add_node('Paris');
$g->add_node('Paris', label => 'City of\nlurve');
$g->add_node('Paris', cluster => 'Europe');
$g->add_node('Paris', color => 'green');
$g->add_node('New York');
$g->add_node('New York', color => 'yellow');

$g->add_edge('London' => 'Paris');
$g->add_edge('London' => 'New York', label => 'Far', color => 'red');
$g->add_edge('Paris' => 'London');
-- expect --
digraph test {
	"New York" [color="yellow", label="New York"];
	London -> "New York" [color="red", label="Far"];
	subgraph cluster_Europe {
		label="Europe";
		London [color="blue", label="London"];
		Paris [color="green", label="City of\nlurve"];
		London -> Paris;
		Paris -> London;
	}
}

-- test --
$g = GraphViz->new(node => { shape => 'box' }, edge => { color => 'red' }, graph => { rotate => "90" });
$g->add_node('London');
$g->add_node('Paris', label => 'City of\nlurve');
$g->add_node('New York');

$g->add_edge('London' => 'Paris');
$g->add_edge('London' => 'New York', label => 'Far');
$g->add_edge('Paris' => 'London');

-- expect --
digraph test {
	node [shape="box"];
	edge [color="red"];
	graph [rotate="90"];
	London [label="London"];
	"New York" [label="New York"];
	Paris [label="City of\nlurve"];
	London -> "New York" [label="Far"];
	London -> Paris;
	Paris -> London;
}
