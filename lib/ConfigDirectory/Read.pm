package ConfigDirectory::Read;

use warnings;
use strict;
use ConfigDirectory::Internal;

1;

# start the module

=head1 NAME

ConfigDirectory::Read - Reads configuration from a configuration directory.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Example usage:

    use ConfigDirectory::Read;

    my $config = ConfigDirectory::Read->new("/path/to/config/directory/");    

    my $username = $config->read_key("database.username");
    my $password = $config->read_key("database.password");
    my @groups   = $config->read_key("groups");

=head1 FUNCTIONS

=cut

=head2 new

Creates a new ControlDirectory::Read class.  Accepts one optional argument,
the path to the control directory.  If this is omitted, the following locations
are checked:

   * /etc/$0_control
   * $PWD/control
   * $PWD/control_dir (where control_dir contains the location of the
     directory)

If a directory cannot be found, the constructor will die.

=cut

sub new {
    my $class = shift;
    my $dir = shift;
    my $self = {};

    if(!$dir){
	$dir = _find_control_directory();
	if(!$dir){
	    die "Couldn't find a control directory -- none specified and ".
	        "none found in default locations.";
	}
    }
    
    if(!-d $dir || !-e $dir){
	die "$dir is not a valid directory";
    }

    $self->{DIRECTORY} = $dir;

    return bless $self, $class;
}

=head2 read_key

Reads an entry from the configuration directory.  Returns the first
line in scalar context, or all lines in array context.  If file is
empty, or cannot be read, undef is returned.

Leading and trailing spaces are removed from each line.

Entries are named based on the directory hierarchy.  For example,
"test.entry" is located at "CONTROL_DIRECTORY/test/entry".

=cut

sub read_key {
    my $self = shift;
    my $key = shift;

    my $control = $self->{DIRECTORY};

    return ConfigDirectory::Internal::_internal_read_keyfile($control, $key);
}

=head2 list_keys 

Returns an array of all keys.  Filter controls filtering of results:

something.: true if key starts with "something"
.something: true if key contains something starting with "something"
foo:        true if key contains the string "foo"
^test$:     true if key contains the string "^test$"

If filter is omitted, all keys are returned.  Note that a filter ".*"
does not match all keys, it matches a key contaning ".*".

=cut

sub list_keys {
    my $self = shift;
    my $filter = shift;
    
    # build a regex out of the filter
    $filter =~ s{(\.|\[|\]|\\|\^|\$|\*|\+|\{|\})}{\\$1}g;
    
    if($filter){
	$filter =~ s{/}{}g;
	if($filter =~ /^(\w+)\.$/){
	    $filter = "^$1.";
	}
    }

    my $control = $self->{DIRECTORY};
    
    my @keys = `find -L $control`;
    my @result;
    
  CONVERT:
    foreach my $key (@keys) { 
	next CONVERT if $key =~ /\/\.\w+($|\/)/; # skip hidden files
	$key =~ s{^$control/?}{}g;
	$key =~ s{/}{.}g;
	
	next CONVERT if !$key;
	push @result, $key if ($filter && $key =~ /$filter/) || !$filter;
    }
    return @result;
}

=head2 exists

Returns true if the key exists.  This is useful for determining the
difference between a file containing no text, and a file that doesn't
exist.

=cut

sub exists {
    my $self = shift;
    my $key = shift;
    my $control = $self->{DIRECTORY};

    $key =~ s{[.]}{/}g;
    
    return -e "$control/$key";
}

=head1 AUTHOR

Jonathan T. Rockway, C<< <jon-perl@jrock.us> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-configdirectory-read@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ConfigDirectory-Read>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

Thanks to Daniel J. Bernstein for the the configuration directory idea (which
first appeared in qmail).

=head1 COPYRIGHT & LICENSE

Copyright 2005 Jonathan T. Rockway, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# internal use only
sub _find_control_directory {
    my $PWD = $ENV{"PWD"};

    if(-d "/etc/$0_control/") {
	return "/etc/$0_control";
    }
    
    elsif(-d "$PWD/control"){
	return "$PWD/control";
    } 

    elsif(-e "$PWD/control_dir" ){
	open (my $control_dir_location, "<$PWD/control_dir" )
	  or die "Can't open $PWD/control_dir";

	my $control_root = <$control_dir_location>;
	chomp $control_root;
	
	(-e $control_root) or return;
	return $control_root;
    }
    
    return;
}
