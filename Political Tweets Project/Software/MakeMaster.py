# Caleb Darnell
import csv

def get_data(file_name):

    return_list = []

    with open(file_name, encoding="utf8") as read_file:
        reader = csv.reader(read_file)
        for row in reader:
            return_list.append(row)

    return return_list


def find_empty(tweets_list):
    indices = []
    for i in range(1, len(tweets_list)):
        if not len(tweets_list[i][2]) < 1:  # makes sure the tweet has text
            for j in range(1, len(tweets_list[i])):
                if len(tweets_list[i][j]) < 1:  # The cell is empty
                    tweets_list[i][j] = "NA"
        else:  # The tweet does not have text
            indices.append(i)  # There was not tweet text and this entry should be removed

    # removes all Tweets without text
    for j in sorted(indices, reverse=True):
        del tweets_list[j]

    return tweets_list


def control():
    # Where the csv is located
    combine = 'Data\combine.csv'

    # reading the csv files
    master_list = get_data(combine)

    """
    Note: id,user_id,tweet_text,hashtag_entities,favorites_count,retweet_count,political_party
    index 0: twitter ID
    index 1: user ID
    index 2: tweet text
    index 3: hashtag 
    index 4: favorites_count
    index 5: retweet count
    index 5: political party
    """

    return_list = find_empty(master_list)

    # Writing to new csv
    with open('Data/Master.csv', 'w', encoding="utf8", newline='') as csvFile:
        writer = csv.writer(csvFile)
        for row in return_list:
            writer.writerow(row)

    csvFile.close()