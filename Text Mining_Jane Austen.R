# Text Mining the Books by Jane Austen

install.packages("tidytext")
install.packages("tidyverse")
install.packages("ggplot2")
install.packages("janeaustenr")
install.packages("wordcloud")

library(tidytext)
library(tidyverse)
library(ggplot2)
library(stringr)
library(janeaustenr)
library(wordcloud)

data(package = "janeaustenr") # Contains Jane Austen Books

# Grouping books, finding chapters and then ungroup again!
orignal_books <- austen_books() %>%
        group_by(book) %>%
        mutate(linenumber = row_number(), 
               chapter = cumsum(str_detect(text, regex("^chapter [\\divxlc]", 
                                                       ignore_case = TRUE)))) %>%
  ungroup()

# Explore the orignal_books 
# Contains text, book name, line number and chapter
head(orignal_books)
tail(orignal_books)


# Using the filter on the book
orignal_books %>% 
  filter(book == "Emma")

orignal_books %>%
  filter(book == "Sense & Sensibility")


# Tokenization of the text in the books
tidy_book <- orignal_books %>%
            unnest_tokens(word, text)


head(tidy_book)
tail(tidy_book)

# Dimensions of tidy_book
dim(tidy_book)

# Finding the frequency of each word
tidy_book %>%
  count(word, sort = TRUE)

# Removing stop words
data(stop_words)
unique(stop_words$lexicon)

tidy_book <- tidy_book %>%
            anti_join(stop_words)

sum_book <- tidy_book %>%
  count(word, sort = TRUE)

# Exploring the frequency of the words
tidy_book %>%
  count(word, sort = TRUE) %>%
  filter(n > 600) %>%
  ggplot(aes(word, n)) + geom_bar(stat = "identity") +
  coord_flip()

# Rearranging using mutation
tidy_book %>%
  count(word, sort = TRUE) %>%
  filter(n > 600) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_bar(stat = "identity") +
  xlab(NULL) +
  ylab("count") +
  coord_flip()

# Words with the frequency per book
book_words <- austen_books() %>%
  unnest_tokens(word, text) %>%
  count(book, word, sort = TRUE) %>%
  ungroup()

# Total words per book
total_words <- book_words %>% 
  group_by(book) %>% 
  summarize(total = sum(n))

# left-join to add the "total words" column
book_words <- left_join(book_words, total_words)

book_words


# Frequency of words by total words with the facet wrap
ggplot(book_words, aes(n/total, fill = book)) + 
  geom_histogram(show.legend = FALSE) + 
  xlim(NA, 0.0009) +
  facet_wrap(~book, ncol = 2, scales = "free_y")

# ZIPF's LAW - Frequency of a word is inversely prop to its rank

freq_rank <- book_words %>% 
            group_by(book) %>%
            mutate(rank = row_number(), 
           `term frequency` = n/total)

head(freq_rank)

freq_rank %>%
  ggplot(aes(rank, `term frequency`, color = book)) +
  geom_line(size = 1.3, alpha = 0.7) +
  scale_x_log10() + 
  scale_y_log10()


# bind_tf_idf function
# Decreases the weight of commonly used words and 
# increases the weight of the ones not used much 
# idf stands for Inverse Document Frequency

book_words <- book_words %>%
            bind_tf_idf(word, book, n)

book_words

book_words %>%
  select(-total) %>%
  arrange(desc(tf_idf))


# Exploring the high Tf-idf words
plot_austen <- book_words %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word))))


ggplot(plot_austen[1:20,], aes(word, tf_idf, fill = book)) +
  geom_col() + 
  labs(x = NULL, y = "tf_idf") +
  coord_flip()

# Now, books individually
plot_austen <- plot_austen %>%
  group_by(book) %>%
  top_n(15) %>%
  ungroup()

ggplot(plot_austen, aes(word, tf_idf, fill = book)) + 
  geom_col(show.legend = FALSE) + 
  labs(x = NULL, y = "tf_idf") + 
  facet_wrap(~book, ncol = 2, scales = "free") +
  coord_flip()

# Creating a wordcloud
book_words %>%
  anti_join(stop_words) %>%
  count(word, n) %>%
  with(wordcloud(word, n, max.words = 100))


# Sentiment Analysis
bing <- sentiments %>% 
  filter(lexicon == "bing") %>%
  select(-score)

jane.sentiment <- tidy_book %>%
  inner_join(bing) %>%
  count(book, index = linenumber %/% 80, sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

install.packages("viridis")
library(viridis)

# Plotting the sentiment per book
ggplot(jane.sentiment, aes(index, sentiment, fill = book)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  facet_wrap(~book, ncol = 2, scales = "free_x") +
  labs(title = "Sentiment in Jane Austen's Books", y = "Sentiment") +
  #scale_fill_viridis(end = 0.75, discrete = TRUE, direction = -1) +
  scale_x_discrete(expand = c(0.02, 0))

# Now using the sentimentr Package
# To apply sentiment analysis on sentences

austen_sentences <- austen_books() %>%
  mutate(text = iconv(text, to = 'latin1')) %>%
  group_by(book) %>%
  unnest_tokens(sentences, text, token = "sentences") %>%
  ungroup()

# Checking the sentences created above
austen_sentences$sentences[39]

bingnegative <- sentiments %>%
  filter(lexicon == "bing", sentiment == "negative")

wordcounts <- tidy_book %>%
  group_by(book, chapter) %>%
  summarize(words = n())

# Chapter with most negative words per book
tidy_book %>%
  semi_join(bingnegative) %>%
  group_by(book, chapter) %>%
  summarize(negativewords = n()) %>%
  left_join(wordcounts, by = c("book", "chapter")) %>%
  mutate(ratio = negativewords/words) %>%
  filter(chapter != 0) %>%
  top_n(1)


