# Caleb Darnell
import csv

def get_data(file_name,):
    list = []

    data_file = open(file_name, encoding="utf8")    # Saves the file into a variable

    for line in data_file:
        line = line.rstrip()             # Removes /n character
        split_list = [line.split(',')]
        list += split_list           # adds sub-list to main list for each row

    return list

# Removes everything that is not a letter, returns that new string
def remove_nums(string):
    alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    new_string = ''
    for char in string:
        if(char in alphabet):
            new_string = new_string + char
    return new_string

def clean_list(list):

    return_list = list
    indices = []

    # Cleaning labels
    for j in range(0,len(list[0])):
        temp_label = ''
        for char in list[0][j]:
            if char not in "\"\'":
                temp_label = temp_label + char
        return_list[0][j] = temp_label

    i = 1
    while i < len(list):

        # Cleaning handle
        handle = return_list[i][1]
        temp_handle = ''
        # removing the crazy amount of quotes surrounding the twitter handles
        for char in handle:
            if char not in "\"\'":
                temp_handle = temp_handle + char
        return_list[i][1] = temp_handle

        # Cleaning description
        description = return_list[i][2]
        temp_description = ''
        # removing the crazy amount of quotes surrounding the twitter descriptions
        for char in description:
            if char not in "\"\'":
                temp_description = temp_description + char
        return_list[i][2] = temp_description

        # Seeing if handle is legit. adds row to be removed if not
        if not len(remove_nums(temp_handle)) > 1:
            # Stores this twitter handle's index to be removed later
            indices.append(i)

        i += 1

    # removes all Twitter handles that were not legit
    for i in sorted(indices, reverse=True):
        del return_list[i]

    return return_list

def find_party(master, temp):
    # master is the list that will be having information added to it and will be returned
    # temp is the list that data will be taken from

    i = 1  # This is used to cycle through the master list
    while i < len(master):
        master_handle = master[i][1]
        for row in temp:
            # Checks if there is a twitter handle present
            if len(row[18]) > 0:
                temp_handle = row[18]
                # Checks for a match in twitter handles
                if master_handle == temp_handle:
                    # This is needed because the csv has some weird stuff around the party
                    if row[12] in "Republican Democrat":
                        master[i][10] = row[12]
        i += 1

    return master

def control():
    # Where the csv is located
    pol_accounts = 'Data\pol_accounts.csv'
    legislators_historical = 'Data/legislators-historical.csv'
    legislators_current = 'Data/legislators-current.csv'

    # reading the csv files
    master_list = get_data(pol_accounts)
    historic_list = get_data(legislators_historical)
    current_list = get_data(legislators_current)

    '''Notes:
            Index 10 for entries in master_list = political party (default is empty)
            Index 1 for entries in master_list = Twitter handle (should not be empty)
            Index 12 for entries in historic/current list = political party (should not be empty)
                -historical politicians include those that are not democrats or republicans
            Index 18 for entries in historic/current list = Twitter handle (may be empty)
    '''

    # Clean the handles of the master list (can add more to clean other sections)
    master_list = clean_list(master_list)

    # Compares with the historic list to find political party
    master_list = find_party(master_list, historic_list)

    # Compares with the current list to find political party
    master_list = find_party(master_list, current_list)

    # Finding entries without political parties
    indices = []
    for i in range(1,len(master_list)):
        if not len(master_list[i][10]) > 0:  # There is a political party present
            indices.append(i)

    # removes all Twitter handles that were not legit
    for i in sorted(indices, reverse=True):
        del master_list[i]

    # For whatever reason there are two political parties that look """{some_party)
    # These two entries will be manually removed for now

    # Writing to new csv
    with open('Data/new_pol_accounts.csv', 'a', encoding="utf8") as csvFile:
        writer = csv.writer(csvFile)
        for row in master_list:
            writer.writerow(row)

    csvFile.close()
