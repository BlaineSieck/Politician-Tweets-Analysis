# Caleb Darnell
import csv

def get_data(file_name):

    return_list = []

    with open(file_name, encoding="utf8") as read_file:
        reader = csv.reader(read_file)
        for row in reader:
            return_list.append(row)

    return return_list


def find_stats(tweets_list):
    stats = [[tweets_list[0][1], "number_tweets", tweets_list[0][6]]]  # File Header
    for i in range(1, len(tweets_list)):
        found = False  # A match has not been found
        for j in range(0, len(stats)):
            if tweets_list[i][1] == stats[j][0]:  # Politician was already found
                stats[j][1] += 1  # Add one to their count
                found = True
                break
        if not found:  # First time seeing a Tweet from this Politician
            stats.append([tweets_list[i][1], 1, tweets_list[i][6]])

    return stats


def control():
    # Where the csv is located
    master = 'Data\Master.csv'

    # reading the csv files
    master_list = get_data(master)

    """ master_list
    id,user_id,tweet_text,hashtag_entities,favorites_count,retweet_count,political_party
    User_ID = 1
    Political Party = 6
    """

    return_list = find_stats(master_list)

    # Writing to new csv
    with open('Data/Stats.csv', 'w', encoding="utf8", newline='') as csvFile:
        writer = csv.writer(csvFile)
        for row in return_list:
            writer.writerow(row)

    csvFile.close()