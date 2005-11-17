#!perl -T

use Test::More tests => 3;

BEGIN {
	use_ok( 'ConfigDirectory::Internal' );
}

BEGIN {
	use_ok( 'ConfigDirectory::Local' );
}

BEGIN {
	use_ok( 'ConfigDirectory::Read' );
}
