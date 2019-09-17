# Caleb Darnell
import csv

def get_data(file_name):

    return_list = []

    with open(file_name, encoding="utf8") as read_file:
        reader = csv.reader(read_file)
        for row in reader:
            return_list.append(row)

    return return_list

def clean_tweets(tweets):
    return_list = tweets
    i = 1
    while i < len(tweets):
        # Cleaning Tweet ID
        tweet_id = return_list[i][0]
        temp_tweet_id = ''
        for char in tweet_id:
            if char not in "\"\'{}":
                temp_tweet_id = temp_tweet_id + char
        return_list[i][0] = temp_tweet_id

        # Cleaning user ID
        user_id = return_list[i][1]
        temp_user_id = ''
        for char in user_id:
            if char not in "\"\'{}":
                temp_user_id = temp_user_id + char
        return_list[i][1] = temp_user_id

        # Cleaning text
        text = return_list[i][2]
        temp_text = ''
        for char in text:
            if char not in "\"\'{}":
                temp_text = temp_text + char
        return_list[i][2] = temp_text

        # Cleaning hashtag
        hastag = return_list[i][3]
        temp_hastag = ''
        for char in hastag:
            if char not in "\"\'{}":
                temp_hastag = temp_hastag + char
        return_list[i][3] = temp_hastag

        # Cleaning favorite count
        favorite = return_list[i][4]
        temp_favorite = ''
        for char in favorite:
            if char not in "\"\'{}":
                temp_favorite = temp_favorite + char
        return_list[i][4] = temp_favorite

        # Cleaning retweet count
        retweet = return_list[i][5]
        temp_retweet = ''
        for char in retweet:
            if char not in "\"\'{}":
                temp_retweet = temp_retweet + char
        return_list[i][5] = temp_retweet

        i += 1

    return return_list

def convert(tweets):
    """
    Index 4 is favorites and should be NA or a number
    Index 5 is retweets and should be NA or a number
    """
    numbers = "0123456789"

    for i in range(1,len(tweets)):
        for char in tweets[i][3]:
            if len(tweets[i][3]) == 0:
                tweets[i][3] = "NA"
        for char in tweets[i][4]:
            if char not in numbers or len(tweets[i][4]) == 0:
                tweets[i][4] = "NA"  # The favorite count was not a number and is therefore NA
        for char in tweets[i][5]:
            if char not in numbers or len(tweets[i][5]) == 0:
                tweets[i][5] = "NA"  # The retweet count was not a number and is therefore NA

    return tweets

def control():
    # Where the csv is located
    tweets = 'Data\\new_pol_tweets.csv'
    """
    Note:
    Tweet ID, user ID, text, hashtags, favorites, retweet_count
    """
    # reading the csv files
    tweets = get_data(tweets)

    cleaned_tweets = clean_tweets(tweets)

    converted_tweets = convert(cleaned_tweets)

    # TODO: There are some cells that are not being switched to NA but most are

    # Writing to new csv
    with open('Data/cleaned_tweets.csv', 'w', encoding="utf8", newline='') as csvFile:
        writer = csv.writer(csvFile)
        for row in converted_tweets:
            writer.writerow(row)

    csvFile.close()

