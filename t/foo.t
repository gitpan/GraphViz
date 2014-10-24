#!/usr/bin/perl -w

use strict;

use lib '../lib', 'lib';
use GraphViz;
use Test;

BEGIN { plan tests => 6 }

# make a nice simple graph and check how output is handled.
my $g = GraphViz->new();
$g->add_node(label => 'London');

{
  # Check filehandle
  my $fh = do { local *FH; *FH; }; # doubled to avoid warnings
  open $fh, ">as_foo.1"
    or die "Cannot write to as_foo.1: $!";
  $g->as_dot($fh);
  close $fh;

  my @result = read_file('as_foo.1');
  check_result(@result);
}

{
  # Check filehandle #2
  local *OUT;
  open OUT, ">as_foo.2"
    or die "Cannot write to as_foo.2: $!";
  $g->as_dot(\*OUT);   
  close OUT;

  my @result = read_file('as_foo.2');
  check_result(@result);
}

{
  # Check filename
  $g->as_dot('as_foo.3');
  my @result = read_file('as_foo.3');
  check_result(@result);
}

{
  # Check scalar ref
  my $result;
  $g->as_dot(\$result);
  check_result(split /\n/, $result);
}

{
  # Check returned
  my $result = $g->as_dot();
  check_result(split /\n/, $result);   
}

{
  # Check coderef
  my $result;
  $g->as_dot(sub { $result .= shift });
  check_result(split /\n/, $result);   
}

unlink 'as_foo.1';
unlink 'as_foo.2';
unlink 'as_foo.3';

sub read_file {
  my $filename = shift;
  local *FILE;
  open FILE, "<$filename"
    or die "Cannot read $filename: $!";
  return (<FILE>);
}

sub check_result {
  my @result = @_;
  my $ok = 1;


  my $expect = <<'EOF';
Expected something like:
    
digraph test {
        node [  label = "\N" ];
        graph [bb= "0,0,66,38"];
        node1 [label=London, pos="33,19", width="0.89", height="0.50"];
}
EOF

  # have to use regexes cause the output includes numbers that may
  # change each time
  $ok = 0
    unless $result[0] =~ /^digraph test {/;
  $ok = 0
   unless $result[1] =~ /^\s*node\s*\[\s*label\s*=\s*"\\N"\s*\];\s*/;
  $ok = 0
    unless $result[2] =~ /^\s*graph\s*\[bb=.*/;
  $ok = 0
    unless $result[3] =~ /^\s*node1\s*\[label=London.*\];/;

  if ($ok) {
    ok(1);
  } else {
    ok(0, $expect);
  }
}
