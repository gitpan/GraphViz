#!/usr/bin/perl -w

use lib '..';
use lib '../lib';
use lib 'lib';
use GraphViz::Regex;
use Test;

BEGIN { plan tests => 14 }

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
$g = GraphViz::Regex->new('foo');

-- expect --
digraph test {
	node1 [label="foo", shape="box"];
	node2 [label="END"];
	node1 -> node2;
}


-- test --
$g = GraphViz::Regex->new('foo|bar');

-- expect --
digraph test {
	node1 [label="", shape="diamond"];
	node4 [label="foo", shape="box"];
	node2 [label="bar", shape="box"];
	node3 [label="END"];
	node1 -> node4;
	node1 -> node2;
	node4 -> node3;
	node2 -> node3;
}


-- test --
$g = GraphViz::Regex->new('foo|bar|quux');

-- expect --
digraph test {
	node1 [label="", shape="diamond"];
	node3 [label="END"];
	node5 [label="foo", shape="box"];
	node4 [label="bar", shape="box"];
	node2 [label="quux", shape="box"];
	node1 -> node5;
	node1 -> node4;
	node1 -> node2;
	node5 -> node3;
	node4 -> node3;
	node2 -> node3;
}


-- test --
$g = GraphViz::Regex->new('[a-z]');

-- expect --
digraph test {
	node1 [label="[a-z]", shape="box"];
	node2 [label="END"];
	node1 -> node2;
}


-- test --
$g = GraphViz::Regex->new('a+');

-- expect --
digraph test {
	node1 [label="REPEAT"];
	node3 [label="a", shape="box"];
	node2 [label="END"];
	node1 -> node1 [label="+"];
	node1 -> node3;
	node1 -> node2 [style="dashed"];
}


-- test --
$g = GraphViz::Regex->new('a*');

-- expect --
digraph test {
	node1 [label="REPEAT"];
	node3 [label="a", shape="box"];
	node2 [label="END"];
	node1 -> node1 [label="*"];
	node1 -> node3;
	node1 -> node2 [style="dashed"];
}


-- test --
$g = GraphViz::Regex->new('a?');

-- expect --

digraph test {
	node1 [label="REPEAT"];
	node3 [label="a", shape="box"];
	node2 [label="END"];
	node1 -> node1 [label="{0, 1}"];
	node1 -> node3;
	node1 -> node2 [style="dashed"];
}


-- test --
$g = GraphViz::Regex->new('a{50,55}');

-- expect --
digraph test {
	node1 [label="REPEAT"];
	node3 [label="a", shape="box"];
	node2 [label="END"];
	node1 -> node1 [label="{50, 55}"];
	node1 -> node3;
	node1 -> node2 [style="dashed"];
}

-- test --
$g = GraphViz::Regex->new('a+b*c?');

-- expect --
digraph test {
	node1 [label="REPEAT"];
	node4 [label="END"];
	node7 [label="a", shape="box"];
	node2 [label="REPEAT"];
	node6 [label="b", shape="box"];
	node3 [label="REPEAT"];
	node5 [label="c", shape="box"];
	node1 -> node1 [label="+"];
	node1 -> node7;
	node1 -> node2 [style="dashed"];
	node2 -> node2 [label="*"];
	node2 -> node6;
	node2 -> node3 [style="dashed"];
	node3 -> node4 [style="dashed"];
	node3 -> node3 [label="{0, 1}"];
	node3 -> node5;
}

-- test --
$g = GraphViz::Regex->new('(foo)');

-- expect --

digraph test {
	node1 [label="START \$1"];
	node2 [label="foo", shape="box"];
	node3 [label="END \$1"];
	node4 [label="END"];
	node1 -> node2;
	node2 -> node3;
	node3 -> node4;
}

-- test --
$g = GraphViz::Regex->new('(foo)+');

-- expect --
digraph test {
	node1 [label="REPEAT"];
	node2 [label="END"];
	node3 [label="foo", shape="box"];
	node4 [label="SUCCEED"];
	node1 -> node1 [label="{1, 32767}"];
	node1 -> node2 [style="dashed"];
	node1 -> node3;
	node3 -> node4;
}


-- test --
$g = GraphViz::Regex->new('(foo)+(bar)+');

-- expect --
digraph test {
	node1 [label="REPEAT"];
	node2 [label="REPEAT"];
	node4 [label="bar", shape="box"];
	node5 [label="SUCCEED"];
	node3 [label="END"];
	node6 [label="foo", shape="box"];
	node7 [label="SUCCEED"];
	node1 -> node1 [label="{1, 32767}"];
	node1 -> node2 [style="dashed"];
	node1 -> node6;
	node2 -> node2 [label="{1, 32767}"];
	node2 -> node4;
	node2 -> node3 [style="dashed"];
	node4 -> node5;
	node6 -> node7;
}

-- test --
$g = GraphViz::Regex->new('(([abcd0-9])|(foo))');

-- expect --
digraph test {
	node1 [label="START \$1"];
	node10 [label="END \$2"];
	node3 [label="START \$3"];
	node4 [label="foo", shape="box"];
	node5 [label="END \$3"];
	node6 [label="END \$1"];
	node7 [label="END"];
	node2 [label="", shape="diamond"];
	node8 [label="START \$2"];
	node9 [label="[0-9a-d]", shape="box"];
	node1 -> node2;
	node10 -> node6;
	node3 -> node4;
	node4 -> node5;
	node5 -> node6;
	node6 -> node7;
	node2 -> node3;
	node2 -> node8;
	node8 -> node9;
	node9 -> node10;
}

-- test --
$g = GraphViz::Regex->new('^All$');

-- expect --
digraph test {
	node1 [label="^"];
	node2 [label="All", shape="box"];
	node3 [label="$"];
	node4 [label="END"];
	node1 -> node2;
	node2 -> node3;
	node3 -> node4;
}
