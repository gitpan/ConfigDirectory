#!/usr/bin/perl
# 02-readlocalkey.t - [description]
# Copyright (c) 2005 Jonathan Rockway

use Test::More tests=>17;
use ConfigDirectory::Local;

is(read_local_key("control/1/2/3", "fallback"),
   "level 3 fallback");

is(read_local_key("./control/1/2/3", "fallback"),
   "level 3 fallback");

is(read_local_key("control/1/2", "fallback"),
   "level 2 fallback");

is(read_local_key("control/1", "fallback"),
   "level 1 fallback");

is(read_local_key("control", "fallback"),
   "reached root level fallback");

is(read_local_key("control/1/2/3/4/5/6/7/8", "doesn't exist"),
   undef);

is(read_local_key("control/1/2/3/4/5/6/7/8/9/10/11/12/", "fallback"),
   "level 3 fallback");

is(read_local_key("control/1/level2", "fallback"),
   "level 1 fallback");

is(read_local_key("control/1/level2/nothing", "fallback", 
		  "control/1/level2/nothing"),
   undef);

is(read_local_key("control/1/level2/nothing", "fallback", 
		  "control/1/level2"),
   undef);

is(read_local_key("control/1/level2/nothing", "fallback", 
		  "control/1"),
   "level 1 fallback");

is(read_local_key("./control/1/level2/nothing", "fallback", 
		  "control/1/level2/nothing"),
   undef);

is(read_local_key("control/1/level2/nothing", "fallback", 
		  "./control/1/level2"),
   undef);

is(read_local_key("./control/1/level2/nothing", "fallback", 
		  "./control/1"),
   "level 1 fallback");

my @result = read_local_key("./control", "local_lines", "./control");
is_deeply(\@result, [qw(1 2 3 4 5 6 7 8 9 10)]);

# should be undefined not "error".
is(read_local_key("./control/override_test/level1/", "undefined", 
		  "./control/override_test"), undef);

is(read_local_key("./control/override_test", "undefined", 
		  "./control/override_test"),
  "error: this should not be defined :)");
