# Text Mining Jane Austen Books

# About Jane Austen
Jane Austen (16 December 1775 – 18 July 1817) was an English novelist known primarily for her six major novels, which interpret, critique and comment upon the British landed gentry at the end of the 18th century. Austen's plots often explore the dependence of women on marriage in the pursuit of favourable social standing and economic security. Her works critique the novels of sensibility of the second half of the 18th century and are part of the transition to 19th-century literary realism. Her use of biting irony, along with her realism and social commentary, have earned her acclaim among critics and scholars.

# Jane Austen's Official Works
* 1811 - Sense & Sensibility
* 1813 - Pride & Prejudice
* 1814 - Mansfield Park
* 1815 - Emma
* 1817 - Persuasion
* 1817 - Northanger Abbey
* 1817 - Sanditon (unfinished at the time of death)

# JaneAustenR Package

Package contains full texts for Jane Austen's 6 completed novels, ready for text analysis. These novels are ``Sense and Sensibility'', ``Pride and Prejudice'', ``Mansfield Park'', ``Emma'', ``Northanger Abbey'', and ``Persuasion''.

URL: https://github.com/juliasilge/janeaustenr


## austen_books 

Tidy data frame of Jane Austen’s 6 completed, published novels
Description: Returns a tidy data frame of Jane Austen’s 6 completed, published novels with two columns: text,
which contains the text of the novels divided into elements of up to about 70 characters each, and
book, which contains the titles of the novels as a factor in order of publication.
Usage: austen_books()
Details: Users should be aware that there are some differences in usage between the novels as made available
by Project Gutenberg. For example, "anything" vs. "any thing", "Mr" vs. "Mr.", and using
underscores vs. all caps to indicate italics/emphasis.
Value: A data frame with two columns: text and book

Examples:
library(dplyr)
austen_books() %>% group_by(book) %>%
summarise(total_lines = n())


