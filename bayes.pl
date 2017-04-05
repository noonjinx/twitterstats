# Train Bayes on first half of everyone's tweets, then feed it the second half
# and ask it to guess the author's details

use strict;
use warnings;

use Storable;
use Algorithm::NaiveBayes;

# Get list of usernames from bottom of program
my %usernames = ();
while ( my $user = <DATA> ) {

    $user = lc( $user ); # Convert to lower case
    $user =~ s/\s//g;    # Remove spaces

    # Split user data into four separate fields
    my ( $username, $gender, $agerange, $country ) = split( ":", $user );

    next unless ( $username && $gender && $agerange && $country ); # Ignore lines with mising data
    next if ( ! -e "$username.data" ); # Ignore user unless we have a file for them
    
    # Store data for user
    $usernames{$username} = {
        USERNAME => $username,
        GENDER   => $gender,
        AGERANGE => $agerange,
        COUNTRY  => $country
    };
}

# Loop through tests
foreach my $test ( "USERNAME", "GENDER", "AGERANGE", "COUNTRY" ) {

    print "Test: $test\n\n";

    # Create naive bayes object
    my $nb = Algorithm::NaiveBayes->new;

    print "Loading old tweets...\n\n";

    # Loop through usernames
    foreach my $username ( sort keys %usernames ) {
        my $label = $usernames{$username}{$test};

        # Read data file and turn it back into a list of tweets
        my $data = retrieve( "$username.data" );
    
        # Remove retweets
        my @tweets = ();
        foreach my $tweet ( @$data ) {
            push( @tweets, $tweet ) unless ( $tweet->{text} =~ m/^RT \@/ );
        }

        # Get text from first half of tweets
        my @texts = ();
        my $all_count = scalar( @tweets );
        my $this_count = 0;
        foreach my $tweet ( @tweets ) {
            $this_count++;
            last if ( $this_count >= $all_count / 2 );
            my $text = $tweet->{text};
            push( @texts, $text );
        }
    
        # Process texts
        my $word_count = {};
        my $total_words = 0;
        foreach my $text ( @texts ) {
            
            # Count number of times each word appears
            foreach my $word ( split( /\s+/, $text ) ) {            # Split text on spaces
                $word =~ s/^[\"\'\(]*(.*?)[\"\'\.\,\!\;\:\)]*$/$1/; # Remove outer punctuation: "foo-bar's?" becomes foo-bar's
                next unless ( $word );                              # Ignore word if it was only punctuation so now empty
                $word_count->{$word}++;                             # Count times word appear in text
                $total_words++;                                     # Count total words used
            }
        }
        
        # Normalize (as if everyone had used 1000000 words) to prevent chatty users skewing stats
        foreach my $word ( keys %$word_count ) {
            $word_count->{$word} = int( 1000000 * $word_count->{$word} / $total_words );
        }
                    
        # Add counts to naive bayes
        $nb->add_instance( attributes => $word_count, label => $label );
    }

    # Train naive bayes
    $nb->train;

    print "Processing new tweets...\n\n";

    # Loop through usernames
    my $tests = 0;
    my $correct = 0;
    foreach my $username ( sort keys %usernames ) {
        my $label = $usernames{$username}{$test};

        $username = lc( $username );       # Make lower case: "FooBar" becomes "foobar"
        $username =~ s/\s//g;              # Remove white space " foo bar " becomes "foobar"
        next unless ( $username );         # Ignore empty lines: where username = ""
        next if ( ! -e "$username.data" ); # Ignore user unless we have a file for them
        $tests++;

        # Read data file and turn it back into a list of tweets
        my $data = retrieve( "$username.data" );
    
        # Remove retweets
        my @tweets = ();
        foreach my $tweet ( @$data ) {
            push( @tweets, $tweet ) unless ( $tweet->{text} =~ m/^RT \@/ );
        }
    
        # Get text from second half of tweets
        my @texts = ();
        my $all_count = scalar( @tweets );
        my $this_count = 0;
        foreach my $tweet ( @tweets ) {
            $this_count++;
            next if ( $this_count < $all_count / 2 );
            my $text = $tweet->{text};
            push( @texts, $text );
        }
    
        # Count number of times each word appears
        my $word_count = {};
    
        # Process texts
        foreach my $text ( @texts ) {
            
            foreach my $word ( split( /\s+/, $text ) ) {            # Split text on spaces
                $word =~ s/^[\"\'\(]*(.*?)[\"\'\.\,\!\;\:\)]*$/$1/; # Remove leading and trailing punctuation from word
                next unless ( $word );                              # Ignore word if was only punctuation
                $word_count->{$word}++;                             # Count times word appear in text
            }
        }
    
        # Ask bayes to predict details
        my $result = $nb->predict( attributes => $word_count );
    
        # Report results
        print "Test: $username, ";

        # Loop through guesses in priority order
        my $rank = 0;
        foreach my $guess ( sort { $result->{$b} <=> $result->{$a} } keys %$result ) {
            $rank++;
                    
            # Report main guess
            if ( $rank == 1 ) {
                print "Guess: $guess (score=$result->{$guess}), ";
                $correct++ if ( $guess eq $label );
            }
                    
            # Report correct guess
            if ( $guess eq $label ) {
                print "Actual: $guess (score=$result->{$guess}, rank=$rank)\n";
            }
        }
    }
    
    print "\n";
    printf( "Accuracy: %s/%s (%.02f%%)\n\n", $correct, $tests, 100 * $correct / $tests );
}

print "Finished\n";

# __DATA__
# username:gender:age-range:country

__DATA__
barackobama:Male:50-59:US
billgates:Male:60-69:US
hillaryclinton:Female:60-69:US
jimmyfallon:Male:40-49:US
katyperry:Female:30-39:US
realdonaldtrump:Male:70-79:US
