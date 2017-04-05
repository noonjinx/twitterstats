# Report timeline for username

use strict;
use warnings;

use Storable;
use Data::Dumper;

# Get username and tweet id from command line
my $username = $ARGV[0] || "";
my $id = $ARGV[1] || "";
die "USAGE: $0 username tweetid" unless ( $username && $id );
$username = lc( $username );	                                    # Make lower case: "FooBar" becomes "foobar"
die "File $username.data not found" unless ( -e "$username.data" ); # Ignore user unless we have a file for them

print "Username $username, tweet $id...\n\n";

# Read data file and locate tweet
my $data = retrieve( "$username.data" );
my $id2tweet = { map { $_->{id} => $_ } @$data };
die "Tweet $id not found" unless  ( $id2tweet->{$id} );


print Dumper( $id2tweet->{$id} );