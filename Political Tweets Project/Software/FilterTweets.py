# Caleb Darnell
import csv

def get_data(file_name):
    return_list = []

    data_file = open(file_name, encoding="utf8")    # Saves the file into a variable

    for line in data_file:
        line = line.rstrip()             # Removes /n character
        split_list = [line.split(',')]
        return_list += split_list           # adds sub-list to main list for each row

    return return_list

def get_tweets(file_name):
    return_list = []

    data_file = open(file_name, encoding="utf8")    # Saves the file into a variable

    for line in data_file:
        temp_list = []
        line = line.rstrip()             # Removes /n character
        split_list = [line.split(';')]

        return_list += split_list    # adds sub-list to main list for each row

    return return_list

def clean_tweets(tweets):

    return_list = tweets

    # Cleaning labels
    for j in range(0,len(tweets[0])):
        temp_label = ''
        for char in tweets[0][j]:
            if char not in "\"\'":
                temp_label = temp_label + char
        return_list[0][j] = temp_label

    return return_list

def find_tweets(tweets_list,user_list):
    '''
    tweets_list: the cleaned 'csv' of all 1.6 million tweets
    user_list: the list of the political figures in the study
    '''
    indices = []
    for i in range(1, len(tweets_list)):
        found = False
        if not len(tweets_list[i]) < 10:  # makes sure the tweet has a user ID (Some don't)
            for j in range(1, len(user_list)):
                if tweets_list[i][1] == user_list[j][0]:
                    found = True
                    break
        if not found:
            indices.append(i)  # The user ID of this tweet could not be found in the subset of users

    # removes all Tweets that are not from the subset of users we selected
    for j in sorted(indices, reverse=True):
        del tweets_list[j]

    return tweets_list

def control():
    # Where the csv is located
    pol_accounts = 'Data\\new_pol_accounts.csv'
    tweets = 'Data\pol_tweets.csv'

    # reading the csv files
    master_list = get_data(pol_accounts)
    tweets = get_tweets(tweets)

    """
    Note:
    In pol_accounts, user ID is index 0
    In tweets, user ID is index 1
    """

    tweets = clean_tweets(tweets)

    # Shows the labels for both csv files
    # print(master_list[0])
    # print(tweets[0])

    return_tweets = find_tweets(tweets, master_list)

    # Writing to new csv
    with open('Data/new_pol_tweets.csv', 'w', encoding="utf8", newline='') as csvFile:
        writer = csv.writer(csvFile)
        for row in return_tweets:
            writer.writerow(row)

    csvFile.close()
