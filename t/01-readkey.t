#!/usr/bin/perl

use Test::More tests=>25;
use ConfigDirectory::Read;

my @array;
my $PWD = $ENV{PWD};

my $config = ConfigDirectory::Read->new("$PWD/control/");

my $real_author = `cat $PWD/control/author`;
chomp $real_author;

my $real_email = `cat $PWD/control/e-mail`;
chomp $real_email;

is($config->read_key("numbers.one"),   1, "number 1");
is($config->read_key("numbers.two"),   2, "number 2");
is($config->read_key("numbers.three"), 3, "number 3");
is($config->read_key("numbers.four"),  4, "number 4");

is($config->read_key("e-mail"), $real_email, "reading email key" );
is($config->read_key("author"), $real_author, "reading author key");

is_deeply([$config->read_key("natural_numbers")], [1..10], "reading array");
is(scalar $config->read_key("natural_numbers"), 1, "reading array as scalar");

is($config->read_key("blank.blank_hello"), "hello", "ignoring blank lines");
is_deeply([$config->read_key("blank.blank_numbers")], [1..10], "reading array w/ blank lines");

is($config->read_key("spacing.spacing_before"), "spacing_before", "spacing before");
is($config->read_key("spacing.spacing_after"),  "spacing_after", "spacing after");
is($config->read_key("spacing.spacing_both"),   "spacing_both", "spacing before and after");

is($config->read_key("spacing.weird_before"), "tab", "tabs and spaces before");
is($config->read_key("spacing.weird_after"),  "tab", "tabs and spaces after");
is($config->read_key("spacing.weird_both"),   "tab", "tabs and spaces before and after");

is($config->read_key("this_doesnt_exist"), undef, "nonexistent key");
is($config->read_key("path.to.key.that.I.dont.have"), undef, "nonexistant parent directory");

is($config->read_key("path.I.dont.have"), undef, "nonexistant parent directory [array context]");

ok(!$config->exists("no_way"), "testing existence");
ok($config->exists("0"), "testing existence of a file contaning a 0");
is($config->read_key("0"), 0, "testing reading a file containing a 0");
is($config->read_key("0"), "0", "testing reading a file containing a 0");
is($config->read_key("0_true"), "0 but true", "file contains 0 but true"); 
is($config->read_key("no_way"), undef, "reading a key that doesn't exist");
 
