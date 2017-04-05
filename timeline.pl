# Report timeline for username

use strict;
use warnings;

use Storable;

my $username = $ARGV[0] || die "USAGE: $0 username";                # Get username from command line
$username = lc( $username );	                                    # Make lower case: "FooBar" becomes "foobar"
die "File $username.data not found" unless ( -e "$username.data" ); # Ignore user unless we have a file for them

# Read data file
my $data = retrieve( "$username.data" );

print "Timeline for $username...\n\n";

# Loop through tweets
foreach my $status ( @$data ) {
	print "$status->{created_at}: <$status->{id}> $status->{text}\n";
}