# perl script to pull user timelines from twitter and store in individual files for later analysis

use strict;
use warnings;

use Net::Twitter;
use Storable;

# Create Twitter API object
my $nt = Net::Twitter->new(
    traits   => [qw/API::RESTv1_1/],
    consumer_key        => "XXXXXXXXXXXXXXXXXXXXXXXXX",
    consumer_secret     => "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    access_token        => "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    access_token_secret => "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
);

print "Fetching data...\n";

# Loop through users listed at bottom of program
my $failures = 0;
while ( my $username = <DATA> ) {

    $username = lc( $username );     # Make lower case: "FooBar" becomes "foobar"
    $username =~ s/\s//g;            # Remove white space " foo bar " becomes "foobar"
    next unless ( $username );       # Ignore empty lines: where username = ""
    next if ( -e "$username.data" ); # Ignore user if we already have a file for them
    
    # Trap errors
    eval {
        
        print "Procesing $username...\n";

        # Start building list of tweets
        my $tweets = [];

        # Fetch first (latest) batch of tweets from Twitter
        my $results = $nt->user_timeline( { screen_name => $username, count => 200 } );
        my $max_id = 0;

        # Loop while batches still have tweets in them
        my $count = 0;
        while ( @$results ) {

            # Loop through tweets in batch (from latest to earliest)
            foreach my $result( @$results ) {
            
                # Get id of last (earliest) tweet in batch
                $max_id = $result->{id} - 1;
        
                # Delete things we are not interested in to save space
                delete $result->{user};
                delete $result->{retweeted_status};
                
                # Add tweet to list
                push( @$tweets, $result );
            }
            
            # Fetch next (earlier) batch of tweets from Twitter
            $results = $nt->user_timeline( { screen_name => $username, count => 200, max_id => $max_id } );
        }
    
        # Write tweets to file
        store( $tweets, "$username.data" );

        print "Wrote ".scalar( @$tweets )." tweets to $username.json\n";
    };
    if ( $@ ) {
        print "Failed to process tweets for username $username: $@ (try again later)\n";
        $failures++;
    }
}

print "Finished ($failures failures)\n";

__DATA__
katyperry
barackobama
realdonaldtrump
billgates
jimmyfallon
hillaryclinton
