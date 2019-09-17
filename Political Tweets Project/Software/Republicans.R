library(igraph)
library(readr)
REPtweets <- read.csv("Desktop/Political Data Files/MasterREPUBLICAN.csv", header = TRUE)

#view the structure of the tweets
str(REPtweets)
#how many rows of tweets
nrow(REPtweets)
# Isolate text from tweets: tweets_text
REPtweets_text <- REPtweets$tweet_text
str(REPtweets_text)

REPtweets <- na.omit(REPtweets)
View(REPtweets)
REPtweets_text <- REPtweets$tweet_text

#text mining - making a Corpus
#VCorpus is held in RAM and is volatile
#PCorpus is permanent and on disk
library(tm)
tweets_source <- VectorSource(REPtweets_text)
# Make a volatile corpus: tweets_corpus
tweets_corpus <- VCorpus(tweets_source)
# Print out the tweets_corpus
tweets_corpus

#find the 100 most frequent terms
#qdap requires Java to be installed 64-bit for 64-bit machines
#need to set a system path variable JAVA_HOME to the jre directory
#Sys.setenv(JAVA_HOME='C:\Program Files\Java\jre7')
library(qdap)
#Let's find the most frequent words in our tweets_text and see whether we should get rid of some
frequent_terms <- freq_terms(REPtweets_text, 100)
plot(frequent_terms)

# standard vocabulary of stopwords in English will do just fine.
# Create the custom function that will be used to clean the corpus: clean_coupus
clean_corpus <- function(corpus){
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeWords, stopwords("en"))
  corpus <- tm_map(corpus, stripWhitespace)
  return(corpus)
}
# Apply your customized function to the tweet_corp: clean_corp
clean_corp <- clean_corpus(tweets_corpus)

#Term-document matrix without stemming
# Create the tdm from the corpus: 
tweets_tdm <- TermDocumentMatrix(clean_corp, control=list(weighting=weightTfIdf,stemming=F))
# Print out tweets_tdm data
tweets_tdm
# Convert tweets_tdm to a matrix: tweets_m
tweets_m <- as.matrix(tweets_tdm)
# Print the dimensions of tweets_m
dim(tweets_m)

#Term-document matrix with stemming
# Create the tdm from the corpus: 
tweets_tdm_stem <- TermDocumentMatrix(clean_corp, control=list(weighting=weightTfIdf,stemming=T))
# Print out tweets_tdm data
tweets_tdm_stem
# Convert tweets_tdm to a matrix: tweets_m
tweets_m_stem <- as.matrix(tweets_tdm_stem)
# Print the dimensions of tweets_m
dim(tweets_m_stem)

# Since the sparsity is so high, i.e. a proportion of cells with 0s/ cells with other values is too large,
# let's remove some of these low frequency terms
tweets_tdm_rm_sparse <- removeSparseTerms(tweets_tdm, 0.99)
# Print out tweets_dtm data
tweets_tdm_rm_sparse
# Convert tweets_dtm to a matrix: tweets_m
tweets_m_sparse <- as.matrix(tweets_tdm_rm_sparse)
# Print the dimensions of tweets_m
dim(tweets_m_sparse)

#word cloud
library(syuzhet)
library(plotly)
library(tm)
library(wordcloud)

# Function for data cleaning
f_clean_tweets <- function (REPtweets) {
  
  clean_tweets = REPtweets$tweet_text
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
  
  clean_tweets = tolower(clean_tweets)
  
  clean_tweets
}

# get the emotions using the NRC dictionary
clean_tweets <- f_clean_tweets(REPtweets)
emotions <- get_nrc_sentiment(clean_tweets)
emo_bar = colSums(emotions)
emo_sum = data.frame(count=emo_bar, emotion=names(emo_bar))
emo_sum$emotion = factor(emo_sum$emotion, levels=emo_sum$emotion[order(emo_sum$count, decreasing = TRUE)])

# Visualize the emotions from NRC sentiments
plot_ly(emo_sum, x=~emotion, y=~count, type="bar", color=~emotion) %>%
  layout(xaxis=list(title=""), showlegend=FALSE,
         title="Distribution of emotion categories for REPUBLICAN Tweets")

# Comparison word cloud
all = c(
  paste(clean_tweets[emotions$anger > 0], collapse=" "),
  paste(clean_tweets[emotions$anticipation > 0], collapse=" "),
  paste(clean_tweets[emotions$disgust > 0], collapse=" "),
  paste(clean_tweets[emotions$fear > 0], collapse=" "),
  paste(clean_tweets[emotions$joy > 0], collapse=" "),
  paste(clean_tweets[emotions$sadness > 0], collapse=" "),
  paste(clean_tweets[emotions$surprise > 0], collapse=" "),
  paste(clean_tweets[emotions$trust > 0], collapse=" ")
)
all <- removeWords(all, stopwords("english"))
#remove special characters
all <- iconv(all,"UTF-8","UTF-8",sub='')
# create corpus
corpus = Corpus(VectorSource(all))
#
# create term-document matrix
tdm = TermDocumentMatrix(corpus)
#
# convert as matrix
tdm = as.matrix(tdm)
tdm1 <- tdm[nchar(rownames(tdm)) < 11,]
#
# add column names
colnames(tdm) = c('anger', 'anticipation', 'disgust', 'fear', 'joy', 'sadness', 'surprise', 'trust')
colnames(tdm1) <- colnames(tdm)
comparison.cloud(tdm1, random.order=FALSE,
                 colors = c("#00B2FF", "red", "#FF0099", "#6600CC", "green", "orange", "blue", "brown"),
                 title.size=1, max.words=100, scale=c(2.5, 0.5),rot.per=0.4)

#using textstem - stemming and lemmitization
#https://cran.r-project.org/web/packages/textstem/README.html
library (textstem)
library(dplyr)
dw <- c('driver', 'drive', 'drove', 'driven', 'drives', 'driving')
stem_words(dw)
lemmatize_strings(dw)
bw <- c('are', 'am', 'being', 'been', 'be')
stem_words(bw)
lemmatize_strings(bw)