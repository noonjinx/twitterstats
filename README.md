# twitterstats
Simple perl project to pull timelines from Twitter and examine them offline (eg. using Bayes theorum)

1. Create Twitter keys at https://dev.twitter.com/
2. Install Net::Twitter and Algorithm::NaiveBayes
3. Add Twitter keys at top of fetchdata.pl
4. Add Twitter usernames at bottom of fetchdata.pl
5. Run "perl fetchdata.pl"

This will pull the full timeline (up to the last 3000+ tweets) for each user from twitter and store them as data files

At peak times, twitter sometimes refuses to connect so not all downloads are successful. If so, the script will
store the ones which are successful and ask you to try again later. Each time you run the script it will ignore
previous successes and you should get a bit more data until you have everything

6. Run "perl timeline.pl username" to print all tweets in the timeline file for username (each tweet printed includes date and id)

7. Run "perl tweet.pl username id" to dump the tweet id in the timeline file for username

8. Add Twitter usernames and personal data at the bottom of bayes.pl
9. Run "perl bayes.pl"

This will...

* Read the data files stored by fetchdata.pl
* Train Algorithm::NaiveBayes using the first half of everyone's tweets
* Ask Algorithm::NaiveBayes to predict the personal details of each user based on the second half of their tweets
