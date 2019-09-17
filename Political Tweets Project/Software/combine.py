# Caleb Darnell
import csv

def get_data(file_name):

    return_list = []

    with open(file_name, encoding="utf8") as read_file:
        reader = csv.reader(read_file)
        for row in reader:
            return_list.append(row)

    return return_list


def find_party(tweets_list, user_list):
    '''
    tweets_list: the cleaned 'csv' of tweets
    user_list: the list of the political figures in the study
    '''
    for i in range(1, len(tweets_list)):
        for j in range(1, len(user_list)):
            if tweets_list[i][1] == user_list[j][0]:  # The user ID matched
                tweets_list[i][6] = user_list[j][3]   # Copy over political party
                break

    return tweets_list


def control():
    # Where the csv is located
    accounts = 'Data\\new_pol_accounts.csv'
    tweets = 'Data\cleaned_tweets.csv'

    # reading the csv files
    accounts_list = get_data(accounts)
    tweets_list = get_data(tweets)

    """
    Note:
    In new_pol_accounts, user ID is index 0
    In new_pol_accounts, political party is index 3
    In tweets, user ID is index 1
    In tweets, political party is index 6 (empty at start)
    """

    return_list = find_party(tweets_list, accounts_list)

    # Writing to new csv
    with open('Data/combine.csv', 'w', encoding="utf8", newline='') as csvFile:
        writer = csv.writer(csvFile)
        for row in return_list:
            writer.writerow(row)

    csvFile.close()