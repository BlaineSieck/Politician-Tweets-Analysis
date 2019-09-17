#~~~Libraries~~~~
library(igraph)
library(readr)
library(tm)
library(qdap)
library(textreg)
library(SnowballC)
library(syuzhet)
library(plotly)
library(wordcloud)
#~~~~~~~~~~~~~~~~

#Read in data
MasterTweets <- read.csv(file.choose(), header = TRUE)


#~~~~Seeing the dataframe~~~~

#view the structure of the tweets
#str(MasterTweets)
#how many rows of tweets
#nrow(MasterTweets)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Creating master set of all Tweets
master_text <- MasterTweets$tweet_text

#~~~~~~~~~~text mining - making a Corpus~~~~~~~~~~~

tweets_source <- VectorSource(master_text)
# Make a volatile corpus: tweets_corpus
tweets_corpus <- VCorpus(tweets_source)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~find the 100 most frequent terms~~~~~~~~~~

#Most Common Words before preprocessing
frequent_terms <- freq_terms(master_text, 100)
plot(frequent_terms)

#The above plot shows that common words like "the" flood
#the data as the most frequent terms in the Tweets

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~Clean the Corpus~~~~~~~~~~~~~~~~~
clean_corpus <- function(corpus){
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeWords, stopwords("en"))
  corpus <- tm_map(corpus, stripWhitespace)
  return(corpus)
}

clean_corp <- clean_corpus(tweets_corpus)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Make List from corpus~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Corpus is too large to run analysis on so need to convert back to a data.frame
clean_tweets_df <- data.frame(text=sapply(clean_corp, identity), stringsAsFactors=F)

#Convert the "tweet_text" row of this dataframe to a vector of strings
clean_tweets_list <- unname(as.vector(clean_tweets_df[1,]))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~find the 20 most frequent terms After cleaning~~~~~~~~

#Most Common Words after processing
frequent_terms_c <- freq_terms(clean_tweets_list, 20)
plot(frequent_terms_c)

#Words that need to be deleted from both political party subset:
#listcontent, rt, amp, today, httpstco, w, httpstco

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




#~~~~~~~~~~~~~~~~Create the Republican Dataset~~~~~~~~~~~~~~~~

#Remove all Democrats from the csv
REPtweets <- MasterTweets[MasterTweets$political_party != "Democrat", ]
# Isolate text from tweets: tweets_text
REPtweets_text <- REPtweets$tweet_text

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#~~~~~~~~~~~~~~~~Create the Democrat Dataset~~~~~~~~~~~~~~~~~~

#Remove all Republicans from the csv
DEMtweets <- MasterTweets[MasterTweets$political_party != "Republican", ]
# Isolate text from tweets: tweets_text
DEMtweets_text <- DEMtweets$tweet_text

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# New corpus cleaning function
clean_corpus_2 <- function(corpus){
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeWords, stopwords("en"))
  corpus <- tm_map(corpus, removeWords, c("listcontent", "rt", "amp", "today", "httpstco", "w", "httpstco"))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  return(corpus)
}

# Function for data cleaning
f_clean_tweets <- function (tweets) {
  
  clean_tweets = tweets
  # remove retweet entities
  clean_tweets = gsub('(RT|via)((?:\\b\\W*@\\w+)+)', '', clean_tweets)
  # remove at people
  clean_tweets = gsub('@\\w+', '', clean_tweets)
  # remove punctuation
  clean_tweets = gsub('[[:punct:]]', '', clean_tweets)
  # remove numbers
  clean_tweets = gsub('[[:digit:]]', '', clean_tweets)
  # remove html links
  clean_tweets = gsub('http\\w+', '', clean_tweets)
  # remove unnecessary spaces
  clean_tweets = gsub('[ \t]{2,}', '', clean_tweets)
  clean_tweets = gsub('^\\s+|\\s+$', '', clean_tweets)
  # remove emojis or special characters
  clean_tweets = gsub('<.*>', '', enc2native(clean_tweets))
  # remove listcontent+
  clean_tweets = gsub('listcontent\\w+', '', clean_tweets)
  
  clean_tweets = tolower(clean_tweets)
  
  clean_tweets
}


#                   CLEAN REPUBLICAN


#~~~~~~~~~~text mining - making a Corpus~~~~~~~~~~~

tweets_source_rep <- VectorSource(REPtweets_text)
# Make a volatile corpus: tweets_corpus
tweets_corpus_rep <- VCorpus(tweets_source_rep)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~Clean the Corpus~~~~~~~~~~~~~~~~~

clean_corp_rep <- clean_corpus_2(tweets_corpus_rep)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Final clean~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Corpus is too large to run analysis on so need to convert back to a data.frame
clean_tweets_df_rep <- data.frame(text=sapply(clean_corp_rep, identity), stringsAsFactors=F)

#Convert the "tweet_text" row of this dataframe to a vector of strings
clean_tweets_list_rep <- unname(as.vector(clean_tweets_df_rep[1,]))

#Runs final cleaning of the Tweets
final_clean_tweets_rep <- f_clean_tweets(clean_tweets_list_rep)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#                   CLEAN DEMOCRAT


#~~~~~~~~~~text mining - making a Corpus~~~~~~~~~~~

tweets_source_dem <- VectorSource(DEMtweets_text)
# Make a volatile corpus: tweets_corpus
tweets_corpus_dem <- VCorpus(tweets_source_dem)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~Clean the Corpus~~~~~~~~~~~~~~~~~

clean_corp_dem <- clean_corpus_2(tweets_corpus_dem)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Final clean~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Corpus is too large to run analysis on so need to convert back to a data.frame
clean_tweets_df_dem <- data.frame(text=sapply(clean_corp_dem, identity), stringsAsFactors=F)

#Convert the "tweet_text" row of this dataframe to a vector of strings
clean_tweets_list_dem <- unname(as.vector(clean_tweets_df_dem[1,])) 

#Runs final cleaning of the Tweets
final_clean_tweets_dem <- f_clean_tweets(clean_tweets_list_dem)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Emotions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Republican

emotions_rep <- get_nrc_sentiment(final_clean_tweets_rep)
emo_bar_rep <- colSums(emotions_rep)
emo_sum_rep <- data.frame(count=emo_bar_rep, emotion=names(emo_bar_rep))
emo_sum_rep$emotion = factor(emo_sum_rep$emotion, levels=emo_sum_rep$emotion[order(emo_sum_rep$count, decreasing = TRUE)])

# Visualize the emotions from NRC sentiments
plotly_plot_rep <- plot_ly(emo_sum_rep, x=~emotion, y=~count, type="bar", color=~emotion) %>%
  layout(xaxis=list(title=""), showlegend=FALSE,
         title="Distribution of emotion categories for REPUBLICAN Tweets")

#Ignoring Warning brought on by plot_ly
suppressWarnings(print(plotly_plot_rep))

#Democrat

emotions_dem <- get_nrc_sentiment(final_clean_tweets_dem)
emo_bar_dem <- colSums(emotions_dem)
emo_sum_dem <- data.frame(count=emo_bar_dem, emotion=names(emo_bar_dem))
emo_sum_dem$emotion = factor(emo_sum_dem$emotion, levels=emo_sum_dem$emotion[order(emo_sum_dem$count, decreasing = TRUE)])

# Visualize the emotions from NRC sentiments
plotly_plot_dem <- plot_ly(emo_sum_dem, x=~emotion, y=~count, type="bar", color=~emotion) %>%
  layout(xaxis=list(title=""), showlegend=FALSE,
         title="Distribution of emotion categories for DEMOCRAT Tweets")

#Ignoring Warning brought on by plot_ly
suppressWarnings(print(plotly_plot_dem))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Comparison word cloud~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set.seed(12022014)

#Republican

all_rep = c(
  paste(final_clean_tweets_rep[emotions_rep$anger > 0], collapse=" "),
  paste(final_clean_tweets_rep[emotions_rep$anticipation > 0], collapse=" "),
  paste(final_clean_tweets_rep[emotions_rep$disgust > 0], collapse=" "),
  paste(final_clean_tweets_rep[emotions_rep$fear > 0], collapse=" "),
  paste(final_clean_tweets_rep[emotions_rep$joy > 0], collapse=" "),
  paste(final_clean_tweets_rep[emotions_rep$sadness > 0], collapse=" "),
  paste(final_clean_tweets_rep[emotions_rep$surprise > 0], collapse=" "),
  paste(final_clean_tweets_rep[emotions_rep$trust > 0], collapse=" ")
)

# Last check for cleaning data

all_rep <- removeWords(all_rep, stopwords("english"))
# Congress was the main word and we felt as though that did not convey much as the dataset is all congress people
all_rep <- removeWords(all_rep, c("congress","hearing"))
all_rep <- iconv(all_rep,"UTF-8","UTF-8",sub='')

# create corpus
corpus_cloud_rep = Corpus(VectorSource(all_rep))

# create term-document matrix
tdm_rep = TermDocumentMatrix(corpus_cloud_rep)

# convert as matrix
tdm_rep = as.matrix(tdm_rep)
tdm1_rep <- tdm_rep[nchar(rownames(tdm_rep)) < 11,]

# add column names
colnames(tdm_rep) = c('anger', 'anticipation', 'disgust', 'fear', 'joy', 'sadness', 'surprise', 'trust')
colnames(tdm1_rep) <- colnames(tdm_rep)
comparison.cloud(tdm1_rep, random.order=FALSE,
                 colors = c("#00B2FF", "red", "#FF0099", "#6600CC", "green", "orange", "blue", "brown"),
                 title.size=1, max.words=100, scale=c(2.5, 0.5),rot.per=0.4)


#Democrat

all_dem = c(
  paste(final_clean_tweets_dem[emotions_dem$anger > 0], collapse=" "),
  paste(final_clean_tweets_dem[emotions_dem$anticipation > 0], collapse=" "),
  paste(final_clean_tweets_dem[emotions_dem$disgust > 0], collapse=" "),
  paste(final_clean_tweets_dem[emotions_dem$fear > 0], collapse=" "),
  paste(final_clean_tweets_dem[emotions_dem$joy > 0], collapse=" "),
  paste(final_clean_tweets_dem[emotions_dem$sadness > 0], collapse=" "),
  paste(final_clean_tweets_dem[emotions_dem$surprise > 0], collapse=" "),
  paste(final_clean_tweets_dem[emotions_dem$trust > 0], collapse=" ")
)

# Last check for cleaning data

all_dem <- removeWords(all_dem, stopwords("english"))
# Congress was the main word and we felt as though that did not convey much as the dataset is all congress people
all_dem <- removeWords(all_dem, c("congress","hearing"))
all_dem <- iconv(all_dem,"UTF-8","UTF-8",sub='')

# create corpus
corpus_cloud_dem = Corpus(VectorSource(all_dem))

# create term-document matrix
tdm_dem = TermDocumentMatrix(corpus_cloud_dem)

# convert as matrix
tdm_dem = as.matrix(tdm_dem)
tdm1_dem <- tdm_dem[nchar(rownames(tdm_dem)) < 11,]

# add column names
colnames(tdm_dem) = c('anger', 'anticipation', 'disgust', 'fear', 'joy', 'sadness', 'surprise', 'trust')
colnames(tdm1_dem) <- colnames(tdm_dem)
comparison.cloud(tdm1_dem, random.order=FALSE,
                 colors = c("#00B2FF", "red", "#FF0099", "#6600CC", "green", "orange", "blue", "brown"),
                 title.size=1, max.words=100, scale=c(2.5, 0.5),rot.per=0.4)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Tweet Frequency~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Library
library(ggplot2)

#Read in data
MasterTweets <- read.csv(file.choose(), header = TRUE)

party <- MasterTweets$political_party

values <- MasterTweets$number_tweets

dataframe <- data.frame(party,values)

# plot
ggplot(dataframe, aes(x=party, y=values, fill=party)) +
  geom_boxplot(alpha=0.4) +
  stat_summary(fun.y=mean, geom="point", shape=20, size=10, color="red", fill="red") +
  theme(legend.position="none") +
  scale_fill_brewer(palette="Set3")+ggtitle("Mean Number of Tweets 2009-2017")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
