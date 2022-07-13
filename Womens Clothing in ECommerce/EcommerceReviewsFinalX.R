#############################################################################
## Name: Group 3 - Andrea Bradshaw, Neal Bates, John Fields
## Class: IST707 - Dr. Ami Gates
## Assignment: Final Project - Women's E-Commerce Reviews
#############################################################################
##------------------------------------------------------------------
# PROCESS & TRANSFORM DATA 
##------------------------------------------------------------------
library(ggplot2) #Create Elegant Data Visualisations Using the Grammar of Graphics
library(tidyverse) #Install and load multiple 'tidyverse' packages in a single step
library(plyr) #The split-apply-combine paradigm for R
library(tm) #A framework for text mining applications within R.
library(tidyr) #Easily Tidy Data with 'spread()' and 'gather()' Functions
library(wordcloud) #Plot a word cloud
library(factoextra) # Visualize the Results of Multivariate Data Analyses
library(reshape2) #Flexibly restructure and aggregate data using just two functions: melt and 'dcast' (or 'acast').
library(stringr) #Simple, Consistent Wrappers for Common String Operations
library(tidytext) #Text Mining using 'dplyr', 'ggplot2', and Other Tidy Tools
library(arules) #Mining Association Rules and Frequent Itemsets
library(arulesViz) #Visualizing Association Rules and Frequent Itemsets
library(corrplot) #A visualization of a correlation matrix.
library(cluster) #Methods for cluster analysis
library(useful) #Several functions including plotting the results of K-means clustering, 
library(naivebayes) #Computes the conditional a-posterior probabilities of a categorical class variable given independent predictor variables using the Bayes rule.
library(dplyr) #Flexible grammar of data manipulation.
library(psych) #Functions for personality and psychological research
library(e1071) #Misc Functions of the Department of Statistics, Probability Theory Group
library(rpart) #Recursive Partitioning and Regression Trees
library(rpart.plot) #Plot an rpart model. 
library(ROCit) #Performance Assessment of Binary Classifier with Visualization        
library(RGtk2) #For programming graphical interfaces         
library(rattle) #Graphical user interface for data mining         
library(RColorBrewer) #Color palettes 
library(sqldf) #Manipulate R Data Frames Using SQL'
library(tree) #Draw a tree using box drawing characters.
library(ggpubr) #'ggplot2' Based Publication Ready Plots
library(mlr) #Machine learning in R
library(lattice) #Create a lattice graph
library(caret) #Classification and regression training

## Set the working directory to the path where the code and datafile are located
setwd("C:\\Users\\ABrennan\\Documents\\Personal\\IST 707\\Project") #Andrea working directory


## Read in .csv data
filename="Womens Clothing E-Commerce Reviews.csv"
ReviewData <- read.csv(filename, header = TRUE, na.strings=c("","NA"))

## Initial Review of Data
ReviewData
str(ReviewData)

## Change column names
colnames(ReviewData)<- c("RowID", "ClothingID","Age","Title","ReviewText","Rating","Recommended","PositiveFeedbackCount","DivisionName","DepartmentName","ClassName")

## Quick glance at dataframe
(head(ReviewData))

## Check for missing values
Total <-sum(is.na(ReviewData))
cat("The number of missing values in ReviewData is ", Total )
colSums(is.na(ReviewData)) 

## Check each numerical variable to see that it is >=0 
for(varname in names(ReviewData)){
  ## Only check numeric variables
  if(sapply(ReviewData[varname], is.numeric)){
    cat("\n", varname, " is numeric\n")
    ## Get median
    (Themedian <- sapply(ReviewData[varname],FUN=median))
    ##print(Themedian)
    ## check/replace if the values are <=0 
    ReviewData[varname] <- replace(ReviewData[varname], ReviewData[varname] < 0, Themedian)
  }
  
}

## Use table to explore the data
(table(ReviewData$DepartmentName))
(table(ReviewData$DivisionName))
(table(ReviewData$ClassName))

## The structure (types) of the data
(str(ReviewData))

## Summary of the data - mean median, sums
summary(ReviewData)

# Preliminary Data Viz
ggplot(data = melt(ReviewData), mapping = aes(x = value)) + geom_histogram(bins = 20,color = "black", fill = "steel blue") + facet_wrap(~variable, scales = 'free_x')

## The following will find the mean of rows for each "Rating" with numeric data
## Save this new aggregated result as a DF
(RatingMeanDF <- ddply(ReviewData, "Rating", numcolwise(mean)))

## Clothing is an identifier and there is no value in calculating the mean, so remove it
(RatingMeanDF <- RatingMeanDF[,-2:-3])

## Visualize the RatingMeanDF Data
ggplot(data = melt(RatingMeanDF), mapping = aes(x = value)) + 
  geom_histogram(bins=5, color = "black", fill = "steel blue") + 
  facet_wrap(~variable, scales = 'free_x') + 
  theme(axis.text.x = element_text(angle=90, hjust=1))

#Code to replace NA in Title with "XTitle"
ReviewData$Title = as.character(ReviewData$Title)
ReviewData$Title[is.na(ReviewData$Title)] = "XTitle "

#Code to correct the spelling of intimates in Division Name
ReviewData$DivisionName <- as.character(ReviewData$DivisionName)
ReviewData$DivisionName <- replace(ReviewData$DivisionName,ReviewData$DivisionName=="Initmates","Intimates")

#Code to change DepartmentName from Intimate to Intimates
ReviewData$DepartmentName <- as.character(ReviewData$DepartmentName)
ReviewData$DepartmentName <- replace(ReviewData$DepartmentName,ReviewData$DepartmentName=="Intimate","Intimates")

## Remove remaining NA (added by JTF 8/7)
Total2 <-sum(is.na(ReviewData))
cat("The number of missing values in ReviewData is ", Total2 )
ReviewData <- na.omit(ReviewData)
Total2 <-sum(is.na(ReviewData))
cat("The number of missing values in ReviewData is ", Total2 )
colSums(is.na(ReviewData)) 

## The structure (types) of the data
(str(ReviewData))

## Changed the data types for ClothingID, ReviewText, DivisionName, DepartmentName and Rating
ReviewData$ClothingID <- as.character(ReviewData$ClothingID)
ReviewData$ReviewText <- as.character(ReviewData$ReviewText)
ReviewData$DivisionName <- as.factor(ReviewData$DivisionName)
ReviewData$DepartmentName <- as.factor(ReviewData$DepartmentName)
ReviewData$Rating <- as.factor(ReviewData$Rating)
(str(ReviewData))

## Summary of the data - mean median, sums
summary(ReviewData)

## CREATE TABLES TO SUMMARIZE DATA
## Use table to explore the data
(DeptTable <- data.frame(table(ReviewData$DepartmentName)))
(DivisionTable <- data.frame(table(ReviewData$DivisionName)))
(ClassTable <- data.frame(table(ReviewData$ClassName)))
(ClothingIDTable <- data.frame(table(ReviewData$ClothingID)))
ClothingIDTable$Var1 <- as.integer(ClothingIDTable$Var1)
ClothingIDTable <- ClothingIDTable[ClothingIDTable$Var1,]

#View(ClothingIDTable)
plot(ClothingIDTable$Freq)

ggplot(ClothingIDTable, aes(x=Var1, y=Freq, color=Freq)) + geom_point() + geom_smooth() + coord_cartesian(ylim=c(0, 1000)) + labs(title="Clothing ID Frequency",x="Clothing ID")

##------------------------------------------------------------------
# CREATE THE CORPUS
##------------------------------------------------------------------
## Merge the text data from Title and Review Text
combinetext <- unite(ReviewData,"AllText", c("Title","ReviewText"))
a <- combinetext$AllText
head(a)
## Remove numbers
a <- removeNumbers(a)
## Remove punctuation
a <- removePunctuation(a, preserve_intra_word_contractions = FALSE, preserve_intra_word_dashes = FALSE)
## Remove whitespace
a <- stripWhitespace(a)
## Change to all lower case
a <- tolower(a)
## Remove standard stop words
a <- removeWords(a, stopwords("english")) 
## Remove additional stop words
MyStopwords <- c("like", "very", "can", "I", "also", "lot", "xtitle")
a <- removeWords(a,MyStopwords)
## Lemmitize - ALB removed this function as it breaks words incorrectly
#a <- stemDocument(a,language="english")

## Create a clean data frame and write to CSV
review.text.df <- data.frame(text=sapply(a, identity), stringsAsFactors=F)
write.csv(review.text.df, "review.text.df.csv")

## NOTE: DocumentTermMatrix vs. TermDocumentMatrix.  TermDocument means that the 
## terms are on the vertical axis and the documents are along the horizontal axis. 
## DocumentTerm is the reverse.

## View corpus as a document matrix

review.text.df2<- gsub('"', '', review.text.df)
review.text.df2<- gsub(',', '', review.text.df2)
review.text.df2<- gsub('/', '', review.text.df2)
ReviewCorpus2 = Corpus(VectorSource(review.text.df2))
reviewTDM <- TermDocumentMatrix(ReviewCorpus2)
#tm::inspect(reviewTDM)

## This will find words that occur from 1-5 times in the reviews
freq1 <- NROW(findFreqTerms(reviewTDM, 1))
freq2 <- NROW(findFreqTerms(reviewTDM, 2))
freq3 <- NROW(findFreqTerms(reviewTDM, 3))
freq4 <- NROW(findFreqTerms(reviewTDM, 4))
freq5 <- NROW(findFreqTerms(reviewTDM, 5))
freqAll <- c(freq1,freq2,freq3,freq4,freq5)
plot(freqAll, main="Frequency of Terms", xlab="Minimum Frequency of a Term", ylab = "Number of Reviews with Term")

## Visualize Wordclouds
m <- as.matrix(reviewTDM)
(m)
#View(m)
(word.freq <- sort(rowSums(m), decreasing = T))
#wordcloud(words = names(word.freq), freq = word.freq*2, min.freq = 1000,random.order = F,colors=brewer.pal(3, "Set1"))
summary(word.freq)
#plot(word.freq)  Would not use this plot - ALB
wordcloud(words = names(word.freq), freq = word.freq*2, min.freq = 1000,random.order = F,colors=brewer.pal(3, "Set1"))

##------------------------------------------------------------------
# TEXT MINING MODELS - SENTIMENT ANALYSIS BY RATING
##------------------------------------------------------------------

#read in afinn word list
afinnRaw <- "AFINN-en-165.txt"
input <- readLines(afinnRaw)
#input
afinnTxt <- gsub("\t","",input)
afinnTxt2 <- gsub("-","",afinnTxt)
#separate the word and store in a new vector
afinnWord <- gsub("[[:digit:]]","",afinnTxt2)

#function to separate the score and store in a new vector
#Note: code found at http://stla.github.io/stlapblog/posts/Numextract.html
numextract <- function(string)
{ 
  str_extract(string, "\\-*\\d+\\.*\\d*")
}
afinnScore <- numextract(afinnTxt)
afinnCombined <- data.frame(afinnWord,as.numeric(afinnScore))
colnames(afinnCombined) <- c("Word", "Score")
#afinnCombined
afinnCombined[1,]
str(afinnCombined)
#View(afinnCombined)

wordCounts <- rowSums(m)
wordCounts <- sort(wordCounts,decreasing=TRUE)
head(wordCounts)

#calculate the total number of words
totalWords <- sum(wordCounts)
totalWords

#have a vector that just has all the words
words <- names(wordCounts)

# word counts
matchedWords <- match(words,afinnCombined$Word,nomatch=0)
head(matchedWords)
matchedScores <- as.numeric(afinnCombined$Score[matchedWords])
matchedCount <- wordCounts[which(matchedWords!=0)]
sum(matchedCount*matchedScores)
#View(matchedWords)
#View(matchedScores)

## Start the AFINN analysis by rating
#split the reviews by ratings
ReviewR1 <- ReviewData[ReviewData$Rating==1,]
ReviewR2 <- ReviewData[ReviewData$Rating==2,]
ReviewR3 <- ReviewData[ReviewData$Rating==3,]
ReviewR4 <- ReviewData[ReviewData$Rating==4,]
ReviewR5 <- ReviewData[ReviewData$Rating==5,]

#create a function to run each review by rating
#This section developed with help from this site --> https://github.com/jashmehta89/IST-687-Applied-Data-Science-LabWork/blob/master/week%2011%20Text%20Mining/HW11.R#L73
sentScore <- function(ratingAFINN)
{
  q.vector <- VectorSource(ratingAFINN)
  q.corpus <- Corpus(q.vector)
  q.TDM <- TermDocumentMatrix(q.corpus)
  q.matrix <- as.matrix(q.TDM)
  q.WordCount <- rowSums(q.matrix)
  q.Words <- names(q.WordCount)
  q.Matched <- match(q.Words,afinnCombined$Word,nomatch=0)
  q.MatchScore <- as.numeric(afinnCombined$Score[q.Matched])
  q.MatchCount <- q.WordCount[which(q.Matched!=0)]
  q.Score <- sum(q.MatchCount*q.MatchScore)
  return (q.Score)
}

#run the function for each rating
(one <- sentScore(ReviewR1))
(two<- sentScore(ReviewR2))
(three <- sentScore(ReviewR3))
(four <- sentScore(ReviewR4))
(five <- sentScore(ReviewR5))

ReviewAllQ <- c(one,two,three,four,five)

barplot(ReviewAllQ, col = c("cornsilk", "lavender", "lightcyan","lightblue","light green"), legend.text=c("1","2","3","4","5"),args.legend = list(x = "topleft"),main="Sentiment Scores by Rating", ylab="AFINN Sentiment Score")

##------------------------------------------------------------------
# TEXT MINING MODELS - SENTIMENT ANALYSIS BY REVIEW
##------------------------------------------------------------------

# CREATE A FUNCTION TO CALCULATE BY INTERVIEW ID

ReviewData$sentscore <- 0
for (i in 1:nrow(ReviewData)) 
{
  review.person <- (ReviewData[i,4:5])
  review.person$RowID <- ReviewData[i,]
  colnames(review.person)<- c("Title","ReviewText","RowID")
  reviewcombined <- paste(review.person$Title,review.person$ReviewText,review.person$RowID)
  reviewlength <- length(reviewcombined)
  words.vec2 <- VectorSource(reviewcombined)
  words.corpus2 <- Corpus(words.vec2)
  words.corpus2 <- tm_map(words.corpus2,content_transformer(tolower))
  words.corpus2 <- tm_map(words.corpus2,removePunctuation)
  words.corpus2 <- tm_map(words.corpus2,removeNumbers)
  words.corpus2 <- tm_map(words.corpus2,removeWords,stopwords("english"))
  tdm2 <- TermDocumentMatrix(words.corpus2)
  m2 <- as.matrix(tdm2)
  wordCounts2 <- rowSums(m2)
  wordCounts2 <- sort(wordCounts2,decreasing=TRUE)
  totalWords2 <- sum(wordCounts2)
  words2 <- names(wordCounts2)
  matchedWords2 <- match(words2,afinnCombined$Word,nomatch=0)
  matchedScores2 <- as.numeric(afinnCombined$Score[matchedWords2])
  matchedCount2 <- wordCounts2[which(matchedWords2!=0)]
  n2 <- (sum(matchedCount2*matchedScores2)/(reviewlength))
  ReviewData$sentscore[i] <- n2
}

##Scale the scores
#allfields$IDscore <- scale(allfields$IDscore)

## Visualize the data
plot(ReviewData$sentscore,ReviewData$Rating)
ggplot(ReviewData, aes(x=sentscore, y=Rating)) + geom_point(colour = "red", size = 1)
boxplot(sentscore~Rating,data=ReviewData, main="Sentiment Score by Rating",
        xlab="Rating", ylab="Sentiment Score",notch=TRUE,
        col=(c("gold","darkgreen"))) 

ggballoonplot(ReviewData, x = "Rating", y = "sentscore", size = "Age",
              fill = "sentscore",ggtheme = theme_bw())

p<-ggplot(ReviewData, aes(x=Rating, y=sentscore)) +
  geom_boxplot()
p

## Statistics about the data
mean(ReviewData$sentscore)
tapply(ReviewData$sentscore, ReviewData$Rating, mean)
summary(ReviewData$sentscore)

## Dataframe by Review Rating
SentR1 <- ReviewData[ReviewData$Rating==1,]
SentR2 <- ReviewData[ReviewData$Rating==2,]
SentR3 <- ReviewData[ReviewData$Rating==3,]
SentR4 <- ReviewData[ReviewData$Rating==4,]
SentR5 <- ReviewData[ReviewData$Rating==5,]

# Sentiment score averages by rating
(mean(SentR1$sentscore))
(mean(SentR2$sentscore))
(mean(SentR3$sentscore))
(mean(SentR4$sentscore))
(mean(SentR5$sentscore))

(lowSentR5 <- SentR5[SentR5$sentscore < -5,])
#######################################################
##  
##  Begin Association Rule Mining 
##  
#######################################################
##  DataSets:  
##  m = term frequency via term document matrix (needs to be corrected)
##  ReviewData = Main dataset
##  Discretize numeric and integer data:
ReviewData$Age <- as.numeric(ReviewData$Age)
ReviewData$AgebyGroup <- cut(ReviewData$Age, breaks = c(17, 24, 34, 44, 54, 64, 74, 110), labels=c("18-24", "25-34", "35-44", "45-54", "55-64", "65-74", ">74"))
ReviewData$RecommendedBins <- ifelse(ReviewData$Recommended==0, "NO", "YES")
ReviewData$RecommendedBins <- factor(ReviewData$RecommendedBins)
ReviewData$PositiveFeedbackCount <- as.numeric(ReviewData$PositiveFeedbackCount) 
ReviewData$PositiveFeedbackCountBins <- cut(ReviewData$PositiveFeedbackCount, breaks = c(0, 1, 25, 50, 75, 100, 125,999), labels = c("0", "1-25", "26-50", "51-75", "76-100", "101-125", "125+")) 
ReviewData$PositiveFeedbackCountBins[is.na(ReviewData$PositiveFeedbackCountBins)] = "0"
ReviewData$sentscoreBins <- cut(as.numeric(ReviewData$sentscore), breaks = c(-14.87, 6.38, 10.62, 14.88, 43.562), labels = c("VeryNegative", "Negative", "Positive", "VeryPositive"))

##  Generate Rules:

##  Remove all non factor data and remove Department & Division as they create irrelevant rules
RulesData <- data.frame(ReviewData$AgebyGroup, ReviewData$Rating, ReviewData$RecommendedBins, ReviewData$PositiveFeedbackCountBins, ReviewData$ClassName)
colnames(RulesData)<- c("AgeGroup", "Rating", "RecommendedBin", "PositiveFBCountBin", "Class")
rules = arules::apriori(RulesData, parameter=list(supp=0.01, confidence=0.9, minlen=2, maxlen = 4))
summary(rules)
str(RulesData)
detach(package:tm, unload=TRUE)

##  Review by highest lift
rules<-sort(rules, by="lift", decreasing=TRUE)
inspect(rules)

##  Visualize initial data
plot(rules, measure=c("support", "lift"), shading = "confidence")
## plot(rules[1:30], method="graph", supp=0.001, interactive = TRUE, shading=NA)

##  Re-run rules setting minimum supp to mean and confidence to mean, sort by lift desc:
rules = arules::apriori(RulesData, parameter=list(supp=0.04729, confidence=0.9820, minlen = 2, maxlen = 4))
rules<-sort(rules, by="lift", decreasing=TRUE)
inspect(rules)

##  Review by highest confidence
rules<-sort(rules, by="confidence", decreasing=TRUE)
inspect(rules)

##  Plot initial strongest 19 rules
plot(rules, method="graph", interactive = TRUE, shading=NA)
library(RColorBrewer)
itemFrequencyPlot(items(rules), topN=10, type="relative", col=brewer.pal(8,'Pastel2'), main="Relative Item Frequency Plot") 


############################################################################
##  
##  ARM setting LHS to Ratings 1 - 4
##
############################################################################
##  Re-run rules setting LHS to show Rating as an attribute
R1rules = arules::apriori(RulesData, parameter=list(supp=0.0001, conf=.5, minlen=2, maxlen = 4),
                          appearance = list(lhs=c("Rating=1", "Rating=2", "Rating=3", "Rating=4", "Rating=5"), default="rhs"))
R1rules<-sort(R1rules, decreasing=TRUE,by="lift")
inspect(R1rules)


############################################################################
##  
##  ARM setting RHS to PFBCountBins = 0
##
############################################################################
##  What is the breakdown of our FBCount Votes?
(Votes <- sqldf("select PositiveFeedbackCountBins as Votes, count(*) as number from ReviewData group by PositiveFeedbackCountBins"))
sqldf("select PositiveFeedbackCountBins, count(*) as Votes from ReviewData group by PositiveFeedbackCountBins")
PFBrules0 = arules::apriori(RulesData, parameter=list(support=0.001, conf=.6, minlen=2, maxlen = 4),
                            appearance = list(default="lhs", rhs="PositiveFBCountBin=0"))
PFBrules0<-sort(PFBrules0, decreasing=TRUE,by="lift")
summary(PFBrules0)
inspect(PFBrules0)
##  Tune the rules & re-run:
PFBrules02 = arules::apriori(RulesData, parameter=list(supp=0.017594, conf=.6737, minlen=2, maxlen = 4),
                             appearance = list(default="lhs", rhs=c("PositiveFBCountBin=0")))
PFBrules02<-sort(PFBrules02, decreasing=TRUE,by="lift")
inspect(PFBrules02)

############################################################################
##  
##  ARM setting RHS to PFBCountBins = 101-125
##
############################################################################
PFBrules101 = arules::apriori(RulesData, parameter=list(support=0.000001, conf=.001, minlen=2, maxlen = 4),
                              appearance = list(default="lhs", rhs="PositiveFBCountBin=101-125"))
PFBrules101<-sort(PFBrules101, decreasing=TRUE,by="lift")
summary(PFBrules101)
inspect(PFBrules101)
PFBrules101 = arules::apriori(RulesData, parameter=list(support=0.000001, conf=.010226, minlen=2, maxlen = 4),
                              appearance = list(default="lhs", rhs="PositiveFBCountBin=101-125"))
PFBrules101<-sort(PFBrules101, decreasing=TRUE,by="lift")
inspect(PFBrules101)

############################################################################
##  
##  Recommended = NO (ARM) 
##
############################################################################
NOrules = arules::apriori(RulesData, parameter=list(support=0.01, conf=.9, minlen=2, maxlen = 4),
                          appearance = list(default="lhs", rhs="RecommendedBin=NO"))
NOrules<-sort(NOrules, decreasing=TRUE,by="lift")
inspect(NOrules)

############################################################################
##  KMeans
##   
############################################################################
library(tm)
dtm <- t(reviewTDM)
tm::inspect(dtm)
str(ReviewData)
#str(kmLabeled)
km_mat <- as.matrix(dtm)
kmLabeled <- ReviewData[,-13:-16]
kmLabeled <- kmLabeled[, -9:-11]
kmLabeled <- kmLabeled[,-4:-5]
kmLabeled <- kmLabeled[,-1:-2]
kmUnlabeled <- kmLabeled[,-2]
str(kmUnlabeled)
str(kmLabeled)
kmeansFIT_1 <- kmeans(kmUnlabeled,centers=5)
(summary(kmeansFIT_1))
(kmeansFIT_1$cluster)
(table(kmeansFIT_1$cluster))
kmLabeled$Rating <- as.numeric(kmLabeled$Rating)
factoextra::fviz_cluster(kmeansFIT_1, data=kmLabeled, geom = "point") 

# get cluster assigment
# clusplot(kmUnlabeled, kmeansFIT_1$cluster, color = TRUE, shade = TRUE, labels = 5, lines = 0) # click the plot of the graph and hit escape to exit this graph.  it is interactive.

##------------------------------------------------------------------
# CORRELATION
##------------------------------------------------------------------

## Think this has been corrected:
ReviewDataNumeric <- ReviewData[,-c(1:2,4:5,9:14)]

str(ReviewDataNumeric)
#ReviewDataNumeric <- ReviewData[,-c(1,3,4,8,9,10,11)]

colSums(is.na(ReviewDataNumeric))

ReviewDataNumeric$Rating <- as.integer(ReviewDataNumeric$Rating)
(correlationMatrix <- cor(ReviewDataNumeric,use="complete.obs"))
corrplot(correlationMatrix, method="number")

##------------------------------------------------------------------
# DIFFERENCES BY GROUPS
##------------------------------------------------------------------

boxplot(PositiveFeedbackCount~AgebyGroup,data=ReviewData, main="Positive Feedback Count by Age Group",
        xlab="Age By Group", ylab="Positive Feedback Count",notch=TRUE,
        col=(c("gold","darkgreen"))) 


##############################################################################################################################
##
##Naive Bayes Analysis
##  
##############################################################################################################################

#checking NAs now
colSums(is.na(ReviewData))

df1 <- ReviewData

#needing the proper label for the 1-25 values as 0 is na
df1$PositiveFeedbackCountBins<- as.character(df1$PositiveFeedbackCountBins)
df1$PositiveFeedbackCountBins[df1$PositiveFeedbackCountBins == "0-25"] <- "1-25" # renaming this bin,as it doens't include 0
df1[["PositiveFeedbackCountBins"]][is.na(df1[["PositiveFeedbackCountBins"]])] <- "0"  #making a 0 postive review section

#lets see if i got it right
colSums(is.na(df1))

str(df1)

#lets set field back to a factor now that I fixed the NAs for it
df1$PositiveFeedbackCountBins<- as.factor(df1$PositiveFeedbackCountBins)
df1$Recommended <- as.factor(df1$Recommended)
str(df1)

df <- df1 # cause I might want to switch the fields or cobind later
df1<- df1[ , -which(names(df1) %in% c("RecommendedBins","PositiveFeedbackCountBins","RowID", "ReviewText", "Title"))]


# note this will take it a minute to compute, doing a pairs analysis, will tell me if the independent variables are coorelated,
## if they are coorelated that's bad for a NB  (i left in  my dependent varaible, so some suggestinsit and recomded are coorelated)
pairs.panels(df1) # this tells you a lot, but takes a while to run fyi.
pairs.panels(ReviewDataNumeric)
cor(ReviewDataNumeric)

# department name and Clothing ID are highly coorelated for my independent variables.  So taking it outout department name
df1<- df1[ , -which(names(df1) %in% c("ClothingID", "DepartmentName"))]  #might go back and remove department name from it

#---------------------------------------------------------model 1------------------------------------------
#setting up test and train datasets
set.seed(1234)
ind<-sample(2, nrow(df1), replace=T, prob=c(0.8, 0.2))
train <- df1[ind == 1,]
test <- df1[ind == 2, ]

model_nb <- naive_bayes(Recommended ~., data=train)
model_nb
plot(model_nb)

#making a prediction method.  I noticed the predictions were not taking the probablities by default for the variables, so set it up 
## so set it up to do that  (That took way too long to google how)
### you also get a fun warning message as i was starting, if you  build a model and leave in the prediction it doesn't
#### cheat, at least not for niave bayes as it won't take the fatures into account
p <- predict(model_nb, train, type = 'prob')
head(cbind(p,train)) # might take a screen shot of this, but showing the probablity.  looking at row 3, it has a hard time with
## that row
p1 <- predict(model_nb, train)
(conf_train_1 <- table(p1, train$Recommended))
# 92.93% accuracy.  Issue is has way more trouble of picking not recomded
#lets do an error rate
print("Error Rate for Train:  " ,1-sum(diag(conf_train_1)) / sum(conf_train_1)) # okay, that's python, gotta remeber how R does it

#lets do a test now
#removing test recomended
test_nolabel<- test[ , -which(names(test) %in% c("Recommended"))]
head(cbind(p,train)) # might take a screen shot of this, but showing the probablity.  looking at row 3, it has a hard time with
## that row
p2 <- predict(model_nb, test_nolabel)
(conf_test_1 <- table(p2, test$Recommended))
# 92.35 accuracy
(1 - sum(diag(conf_test_1)) / sum(conf_test_1))

#--------------------Model 2 -------------------------------------------------------------------------------------------
#lets do a second model with only the numeric values
ReviewDataNumeric$Recommended <- as.factor(ReviewDataNumeric$Recommended)

ind<-sample(2, nrow(ReviewDataNumeric), replace=T, prob=c(0.8, 0.2))
train2 <- ReviewDataNumeric[ind == 1,]
test2 <- ReviewDataNumeric[ind == 2, ]

model2_nb <- naive_bayes(Recommended ~., data=train2)
model2_nb
plot(model2_nb)
p3 <- predict(model2_nb, train2)
(conf_train_2 <- table(p3, train2$Recommended))
#93.17% accuracy

test_nolabel2<- test2[ , -which(names(test) %in% c("Recommended"))]
head(cbind(p3,train2)) # might take a screen shot of this, but showing the probablity.  looking at row 3, it has a hard time with
## that row
p4 <- predict(model2_nb, test_nolabel2)
(conf_test_2 <- table(p4, test2$Recommended))
# 93.55 accuracy  again, not much different between test and train  But a touch better accuracy from using only numbers vs. classifications

#-----------------------------------Model 3 ----------------------------------------------------------------------------------
#trying a kernel out to see if it improves at all

model3_nb <- naive_bayes(Recommended ~., data=train2, usekernel = T)
model3_nb
plot(model3_nb)
p5 <- predict(model3_nb, train2)
(conf_train_3 <- table(p5, train2$Recommended))
#91.99

test_nolabel2<- test2[ , -which(names(test) %in% c("Recommended"))]
head(cbind(p5,train2)) # might take a screen shot of this, but showing the probablity.  looking at row 3, it has a hard time with
## that row
p6 <- predict(model3_nb, test_nolabel2)
(conf_test_3 <- table(p6, test2$Recommended))
(sum(diag(conf_test_3)) / sum(conf_test_3))
#  92.08 accuracy  again, not much different between test and train  But a touch better accuracy from using only numbers vs. classifications

#so model 2 is the best!!!!!!!!!!!!!!!!!!!!!!!!!!
## kernel help by the fact it uses base densisties, so when numberical variables are not normally distributed it generally helps.
### whelp despite not having any semblance to normal distribution, still better to run without. 


#--------------------Model 4 -------------------------------------------------------------------------------------------
#lets do a second model with only the numeric values
ReviewDataNumeric$Recommended <- as.factor(ReviewDataNumeric$Recommended)

ind<-sample(2, nrow(ReviewDataNumeric), replace=T, prob=c(0.8, 0.2))
train2 <- ReviewDataNumeric[ind == 1,]
test2 <- ReviewDataNumeric[ind == 2, ]

model4_nb <- naive_bayes(Recommended ~., data=train2, laplace=1)
model4_nb
p23 <- predict(model4_nb, train2)
(conf_train_2 <- table(p23, train2$Recommended))
(sum(diag(conf_train_2)) / sum(conf_train_2))
#93.15% accuracy

test_nolabel2<- test2[ , -which(names(test) %in% c("Recommended"))]
head(cbind(p23,train2)) # might take a screen shot of this, but showing the probablity.  looking at row 3, it has a hard time with
## that row
NB_Best <- predict(model4_nb, test_nolabel2)
(conf_test_24 <- table(NB_Best, test2$Recommended))
(sum(diag(conf_test_24)) / sum(conf_test_24))
# 93.55 accuracy
## best model the one going with
plot(model4_nb)




##############################################################################################################################
##
##SVM Analysis
## 
##############################################################################################################################
# 
# ind<-sample(2, nrow(ReviewDataNumeric), replace=T, prob=c(0.8, 0.2))
# train2 <- ReviewDataNumeric[ind == 1,]
# test2 <- ReviewDataNumeric[ind == 2, ]

df2<- ReviewDataNumeric
# lets see if there is some potential groupings in the data


qplot(Rating,PositiveFeedbackCount, data=df2, color=Recommended)  # looks like a possiblity
qplot(Age,Rating, data=df2, color=Recommended)
qplot(PositiveFeedbackCount,Age, data=df2, color=Recommended) # does appear that older you are the less it is for you to
## provide positive feedback  Also it looks like 38-50 are particularly not recomending

#----------------------------------------------------SVM Model 1 ------------------------------------------------------------
## gonna do the default svm (radial)
model_svm <- svm(Recommended~., data=train2)
summary(model_svm)
pred <- predict(model_svm, train2)
(confusion_matrix_train <- table(pred, train2$Recommended))
(sum(diag(confusion_matrix_train)) / sum(confusion_matrix_train))
#93.47

#lets test the data
pred1 <- predict(model_svm, test_nolabel2)
(confusion_matrix_test <- table(pred1, test2$Recommended))
(sum(diag(confusion_matrix_test)) / sum(confusion_matrix_test))
# 93.70 accuracy so in the same ball park so think my sampling is alright

1-sum(diag(confusion_matrix_test))/sum(confusion_matrix_test) # error rate for test
## 6.3% error rate

plot(model_svm, data=test2, test2$Rating~test2$PositiveFeedbackCount)

#----------------------------------------------SVM Model 2 -----------------------------------------------------------------
## gonna do a linear svm this time
model_svm2 <- svm(Recommended~., data=train2, kernel="linear")
summary(model_svm2)
pred <- predict(model_svm2, train2)
(confusion_matrix_train2 <- table(pred, train2$Recommended))
(sum(diag(confusion_matrix_train2)) / sum(confusion_matrix_train2))
# 93.46 accuracy (so 1/100th of a percentage down)

#lets test the data
pred2 <- predict(model_svm2, test_nolabel2)
(confusion_matrix_test2 <- table(pred2, test2$Recommended))
# 93.77 accuracy so in the same ball park so think my sampling is alright (so went up 7/100ths of a point)
(sum(diag(confusion_matrix_test2)) / sum(confusion_matrix_test2))
1-sum(diag(confusion_matrix_test2))/sum(confusion_matrix_test2) # error rate for test
## 6.2% error rate (so lost an error 10th of a percentage point)

# so a touch better over all but a touch down from train
plot(model_svm2, data=test2, test2$Rating~test2$PositiveFeedbackCount)
#------------------------------------------SVM Model 3 ---------------------------------------------------------------------
## gonna do a polynomial svm this time
model_svm3 <- svm(Recommended~., data=train2, kernel="polynomial")
summary(model_svm3)
pred <- predict(model_svm3, train2)
(confusion_matrix_train3 <- table(pred, train2$Recommended))
(sum(diag(confusion_matrix_train3)) / sum(confusion_matrix_train3))
# 91.58 accuracy (so not great)

#lets test the data
pred3 <- predict(model_svm3, test_nolabel2)
(confusion_matrix_test3 <- table(pred3, test2$Recommended))
(sum(diag(confusion_matrix_test3)) / sum(confusion_matrix_test3))
# 91.89 accuracy so in the same ball park so think my sampling is alright (so went up 7/100ths of a point)
1-sum(diag(confusion_matrix_test3))/sum(confusion_matrix_test3) # error rate for test
## 8.3% error rate (so no on polynomial kernel)
plot(model_svm3, data=test2, test2$Rating~test2$PositiveFeedbackCount)
#-------------------------------------SVM Model 4 --------------------------------------------------------------------------
## gonna do a sigmoid svm this time
model_svm4 <- svm(Recommended~., data=train2, kernel="sigmoid")
summary(model_svm4)
pred <- predict(model_svm4, train2)
(confusion_matrix_train4 <- table(pred, train2$Recommended))
(sum(diag(confusion_matrix_train4)) / sum(confusion_matrix_train4))
# 88.74 accuracy (so getting way worse, looks like linear is the best option)

#lets test the data
pred4 <- predict(model_svm4, test_nolabel2)
(confusion_matrix_test4 <- table(pred4, test2$Recommended))
# 88.79 accuracy so in the same ball park so think my sampling is alright but yea, not doing great in other kernels
1-sum(diag(confusion_matrix_test4))/sum(confusion_matrix_test4) # error rate for test
(sum(diag(confusion_matrix_test4)) / sum(confusion_matrix_test4))
## 11.4% error rate (so no on polynomial kernel)
plot(model_svm4, data=test2, test2$Rating~test2$PositiveFeedbackCount)

#---------------------------------------------------------------------------------------------------------------------------
# model 5
# tuning linear model did the 

model_svm22 <- svm(Recommended~., data=train2, kernel="linear", cost=1.5)
summary(model_svm22)
pred22 <- predict(model_svm22, train2)
(confusion_matrix_train22 <- table(pred22, train2$Recommended))
(sum(diag(confusion_matrix_train22)) / sum(confusion_matrix_train22))
# 93.46 accuracy (so 1/100th of a percentage down)

#lets test the data
pred22 <- predict(model_svm22, test_nolabel2)
(confusion_matrix_test22 <- table(pred22, test2$Recommended))
# 93.77 accuracy so in the same ball park so think my sampling is alright (so went up 7/100ths of a point)
(sum(diag(confusion_matrix_test22)) / sum(confusion_matrix_test22))
1-sum(diag(confusion_matrix_test22))/sum(confusion_matrix_test22) # error rate for test
## 6.2% error rate (so lost an error 10th of a percentage point)

#okay 1.5 is some rookie numbers lets bump this up.



#---------------------------------------------------------------------------------------------------------------------------
# model 6
# tuning linear model lets se what cost does

model_svm22 <- svm(Recommended~., data=train2, kernel="linear", cost=10)
summary(model_svm22)
pred22 <- predict(model_svm22, train2)
(confusion_matrix_train22 <- table(pred22, train2$Recommended))
(sum(diag(confusion_matrix_train22)) / sum(confusion_matrix_train22))
# 93.46 accuracy (so 1/100th of a percentage down)

#lets test the data
pred22 <- predict(model_svm22, test_nolabel2)
(confusion_matrix_test22 <- table(pred22, test2$Recommended))
# 93.77 accuracy so in the same ball park so think my sampling is alright (so went up 7/100ths of a point)
(sum(diag(confusion_matrix_test22)) / sum(confusion_matrix_test22))
1-sum(diag(confusion_matrix_test22))/sum(confusion_matrix_test22) # error rate for test
## 6.2% error rate (so lost an error 10th of a percentage point)

#okay 10 is some rookie numbers lets bump this up.


#---------------------------------------------------------------------------------------------------------------------------
# model 7
# tuning linear model lets se what cost does

model_svm22 <- svm(Recommended~., data=train2, kernel="linear", cost=100)
summary(model_svm22)
pred22 <- predict(model_svm22, train2)
(confusion_matrix_train22 <- table(pred22, train2$Recommended))
(sum(diag(confusion_matrix_train22)) / sum(confusion_matrix_train22))
# 93.46 accuracy (so 1/100th of a percentage down)

#lets test the data
pred22 <- predict(model_svm22, test_nolabel2)
(confusion_matrix_test22 <- table(pred22, test2$Recommended))
# 93.77 accuracy so in the same ball park so think my sampling is alright (so went up 7/100ths of a point)
(sum(diag(confusion_matrix_test22)) / sum(confusion_matrix_test22))
1-sum(diag(confusion_matrix_test22))/sum(confusion_matrix_test22) # error rate for test
## 6.2% error rate (so lost an error 10th of a percentage point)

#okay even at cost=100 it really doesn't change meaning this is pretty high

#however; I would not suggesting going above the dfaults as 22k rows is such a small sample size to the estimated amount of
## of values so don't want to overtrain.  Model 2 is the best then to follow

qplot(ReviewDataNumeric$PositiveFeedbackCount, ReviewDataNumeric$Rating, col=ReviewDataNumeric$Recommended)

######################################################################################################################
#
##Random Forest
#####################################################################################################################


#######  Set up Random Forest -----------------



fit_RF <- randomForest(Recommended ~ . , data = train2)
print(fit_RF)

(pred_RF <- predict(fit_RF, test_nolabel2, type="class"))
(RFtable_1 <- table(pred_RF, test2$Recommended))


(sum(diag(RFtable_1)) / sum(RFtable_1))
#accuracy Score Polynomial
#0.937925

1-sum(diag(RFtable_1))/sum(RFtable_1) # error rate for test


plot(fit_RF)
# # Tune mtry
# t <- tuneRF(train[,-1], train[,1],
#              stepFactor = 0.5,
#              plot = TRUE,
#              ntreeTry = 700,
#              trace = TRUE,
#              improve = 0.03)


#-------------------------------------------Model 2, swithing up mtry--------------------
fit_RF2 <- randomForest(Recommended ~ . , data = train2, mtry=4, ntree=200)
print(fit_RF2)

(pred_RF2 <- predict(fit_RF2, test_nolabel2, type="class"))
(RFtable_2 <- table(pred_RF2, test2$Recommended))


(sum(diag(RFtable_2)) / sum(RFtable_2))
#accuracy Score Polynomial
#0.9315639

1-sum(diag(RFtable_2))/sum(RFtable_2) # error rate for test


plot(fit_RF2)


#-------------------------------------------Model 3, swithing up mtry--------------------
fit_RF3 <- randomForest(Recommended ~ . , data = train2, mtry=8, ntree=200)
print(fit_RF3)

(pred_RF3 <- predict(fit_RF3, test_nolabel2, type="class"))
(RFtable_3 <- table(pred_RF3, test2$Recommended))


(sum(diag(RFtable_3)) / sum(RFtable_3))
#accuracy Score Polynomial
#0.93.24413

1-sum(diag(RFtable_3))/sum(RFtable_3) # error rate for test


plot(fit_RF3)

#-------------------------------------------Model 4, swithing up mtry--------------------

fit_RF4 <- randomForest(Recommended ~ . , data = train2, mtry=2, ntree=200)
print(fit_RF4)

(pred_RF4 <- predict(fit_RF4, test_nolabel2, type="class"))
(RFtable_4 <- table(pred_RF4, test2$Recommended))


(sum(diag(RFtable_4)) / sum(RFtable_4))
#accuracy Score Polynomial
#0.93.24413

1-sum(diag(RFtable_4))/sum(RFtable_4) # error rate for test


plot(fit_RF4)


#-------------------------------------------Model 5, swithing up trees--------------------

fit_RF5 <- randomForest(Recommended ~ . , data = train2, ntree=200)
print(fit_RF5)

(pred_RF4 <- predict(fit_RF4, test_nolabel2, type="class"))
(RFtable_4 <- table(pred_RF4, test2$Recommended))


(sum(diag(RFtable_4)) / sum(RFtable_4))
#accuracy Score Polynomial
#0.93.24413

1-sum(diag(RFtable_4))/sum(RFtable_4) # error rate for test


plot(fit_RF5)


#default maturity is best.  number of trees can be really 100 and it does fine


################################################################################################################
#
################# Decision Tree Analysis # ## Model 5 ##########################################################
#
################################################################################################################

##Objectives: 
# A. Determining what a consumer will do. Buy? Give good marks? Give a high rating? (Don't have sales)
# B. What do recommendations mean to new customers, what does a review mean to custoemrs?
# C. Collaborative Filtering - recommendations through comparing customers with similar preferences and providing cross-sell and up-sell options. 

##Tree Labels:  The dependant variable in the trees:
# A. What results in a more positive RATING? 
# B. Which types of reviews are most helpful, POSITIVE FEEDBACK COUNT?
# C. Can AGE be used to determine to chose what to promote? (do not have a customer ID)

## Assumptions:
# PositiveFeedBackCount: Number of OTHER CUSTOMERS, purchasers, who found this review helpful in making a decision
# Written reviews and scores are from purchasers
# Rating is topline review graphic on the ecommerces site similiar to Amazon
# Rating is most quickly influences customer
# Positive reviews - especially RATING - equate to more sales


############# FILE SUMMARY ################################
########## RevewData ##### is the Master to use  ##########
########## Test/Train #### for entire data set   ##########
########## Test2/Train2 ## numberic only data set #########
## Combined Text Includes Choice of Factors and Key Text ##
##### df, df1, df2, kml, kmlunlabeled includes binned #####
##### Rules data is binned labeled: #######################
## AgeGroup, Rating, RecommendedBin, PositiveFBBin, Class # 
###########################################################


##########  Create Sentiment Score Bins ###################

str(RulesData)
str(ReviewData)
print(ReviewData)

## Visualize the data
plot(ReviewData$sentscore,ReviewData$Rating)
ggplot(ReviewData, aes(x=sentscore, y=Rating)) + geom_point()


## Statistics about the data
mean(ReviewData$sentscore)

hist(ReviewData$sentscore)

ReviewData$sentscore <- as.numeric(ReviewData$sentscore) 
ReviewData$SentBins <- cut(ReviewData$sentscore, breaks = c(-100, 5, 10, 15, 999), labels = c("<6", "6-10", "11-15","16+")) 
#ReviewData$SentBins[is.na(ReviewData$sentscore)] = "0"

count(ReviewData$SentBins)

str(ReviewData)

########## Cleaning up the Data # Chosing Variables for Tree Analysis  #############

##Tree Labels:  The dependant variable in the two trees:
# A. What results in a more positive rating?
# B. Which types of reviews are most helpful?
# C. Which products are purchased by specific ages?

TreeData <- data.frame(ReviewData)
str(TreeData)
#Deleting the not needed columns
MyVarsA=c("Rating", "SentBins", "DepartmentName")
MyVarsB=c("PositiveFeedbackCountBins", "Rating", "RecommendedBins", "SentBins")
MyVarsC=c("ClassName", "AgebyGroup")

# Create the df 

RtgTree <- TreeData[,MyVarsA] 
HelpfulTree <- TreeData[,MyVarsB] 
AgeTree <- TreeData[,MyVarsC] 
str(RtgTree)
str(HelpfulTree)
str(AgeTree)
print(RtgTree)
print(HelpfulTree)
print(AgeTree)

######### Creating indices for test and train data ##################

#A
nobs <- nrow(RtgTree)
nobs
set.seed(6701)
train.indices <- sample(nobs, 0.7*nobs)
rtg.train.indices <- setdiff(1:nobs, train.indices)
#B
nobs <- nrow(HelpfulTree)
nobs
set.seed(6701)
train.indices <- sample(nobs, 0.7*nobs)
help.train.indices <- setdiff(1:nobs, train.indices)
#C
nobs <- nrow(AgeTree)
nobs
set.seed(6701)
train.indices <- sample(nobs, 0.7*nobs)
age.train.indices <- setdiff(1:nobs, train.indices)

##### Create Training/Testing df #####

Rtgtrain<- RtgTree[rtg.train.indices,]
Rtgtest<- RtgTree[-rtg.train.indices,]
Helpfultrain<- HelpfulTree[help.train.indices,]
Helpfultest<- HelpfulTree[-help.train.indices,]
Agetrain<- AgeTree[age.train.indices,]
Agetest<- AgeTree[-age.train.indices,]


#######Steps to execute##########
#Train the model
#Validate the model and calculate accuracy
#Test the model, withe the label removed
################################

############  Building the decision tree model by rpart #############

#####################################################################################
### A "What Impacts Rating" MyVarsA=c("Rating", "SentBins", "DepartmentName")########
#####################################################################################

str(Rtgtrain)
#count(Rtgtrain$Rating)
count(Rtgtrain$RecommendedBins)
count(Rtgtrain$DepartmentName)
count(Rtgtrain$AgebyGroup)
count(Rtgtrain$PositiveFeedbackCountBins)
count(Rtgtrain$PositiveFeedbackCount)
count(Rtgtrain$SentBins)
#cor <- cor(RtgTreeData$Rating,RtgTreeData$RecommendedBins)

#WITH PRUNING SET to .02.  No PRUNING SET CP = 0
rpart_modelA <- rpart(Rating~ ., data = Rtgtrain, method = "class", model = TRUE, 
                      control = rpart.control(cp = .000108910))
#.0009000000000010
#.0031965
#.000389
#999999

#dev.off()

#use rattle and  fancyRpartPlot()

#library(rattle)

fancyRpartPlot(rpart_modelA, uniform=T, cex=.9, space=0, tweak=0.5, gap=0)

cat("Training predictions ################################################\n")
results.A.trn<-predict(rpart_modelA,rtgdata=Rtgtrain[train.indices,],type="class")
tab.A.trn=table(className=data.frame(Predicted=results.A.trn,Actual=Rtgtrain$Rating))
print(results.A.trn)

#Confusion Matrix or a contingency table for the train data
print(tab.A.trn)
#Error Rate
1-sum(diag(tab.A.trn))/sum(tab.A.trn)
#Accuracy
sum(diag(tab.A.trn))/sum(tab.A.trn)
#tn=sum(tab.A.trn)-sum(diag(tab.A.trn)) #true negatives


plot(Agetrain$ClassName,results.A.trn)


#your model goes between the ( __insert it here_)

#rpart.plot(rpart_model,fallen.leaves = T, cex = .6 )

#################################################################################################################
### B "Influence Positive Feedback?" "PositiveFeedbackCountBins", "Rating", "RecommendedBins", "sentscore")
#################################################################################################################

#Rtgtrain <- factor(Rtgtrain$PositiveFeedbackCount)
#Rtgtrain <- factor(Rtgtrain$PositiveFeedbackCountBins)
str(Helpfultrain)
count(Helpfultrain$Rating)
count(Helpfultrain$RecommendedBins)
count(Helpfultrain$DepartmentName)
count(Helpfultrain$AgebyGroup)
count(Helpfultrain$PositiveFeedbackCountBins)
count(Helpfultrain$PositiveFeedbackCount)
count(Helpfultrain$SentBins)
#cor <- cor(RtgTreeData$Rating,RtgTreeData$RecommendedBins)

#WITH PRUNING SET to .02.  No PRUNING SET CP = 0
rpart_modelB <- rpart(PositiveFeedbackCountBins~ ., data = Helpfultrain, method = "class", model = TRUE, control = rpart.control(cp = .0009))
#.0009000000000010
#.0031965
#.000389
#999999

#dev.off()

#use rattle and  fancyRpartPlot()

#library(rattle)

fancyRpartPlot(rpart_modelB, uniform=T, cex=.9, space=0, tweak=0.5, gap=0)


cat("Training predictions ################################################\n")
results.B.trn<-predict(rpart_modelB,helpfuldata=Helpfultrain[train.indices,],type="class")
tab.B.trn=table(className=data.frame(Predicted=results.B.trn,Actual=Helpfultrain$PositiveFeedbackCountBins))
print(results.B.trn)

#Confusion Matrix or a contingency table for the train data
print(tab.B.trn)
#Error Rate
1-sum(diag(tab.B.trn))/sum(tab.B.trn)
#Accuracy
sum(diag(tab.B.trn))/sum(tab.B.trn)

plot(Helpfultrain$PositiveFeedbackCountBins,results.B.trn)

###############################################################################
### C "Age Purchases Class of ("AgebyGroup","ClassName")#######################
###############################################################################

str(Agetrain)
print(Agetrain)
count(Agetrain$Rating)
count(Agetrain$RecommendedBins)
count(Agetrain$DepartmentName)
count(Agetrain$AgebyGroup)
count(Agetrain$PositiveFeedbackCountBins)
count(Agetrain$ClassName)
#cor <- cor(RtgTreeData$Rating,RtgTreeData$RecommendedBins)

#WITH PRUNING SET to .02.  No PRUNING SET CP = 0
rpart_modelC <- rpart(ClassName~ ., data = Agetrain, method = "class", model = TRUE, control = rpart.control(cp = 0))

#.0.001256))
#.0009000000000010
#.0031965
#.000389
#999999

fancyRpartPlot(rpart_modelC, uniform=T, cex=.9, space=0, tweak=0.5, gap=0)

## When matrices are larger than two by two its much more difficult.  Perhaps decision trees are 
#best when you are trying to determine left and right, go and not go.

length(age.train.indices)
#length(age.test.indices)

str(age.train.indices)

cat("Training predictions ################################################\n")
results.trn<-predict(rpart_modelC,agedata=Agetrain[train.indices,],type="class")
tab.trn=table(className=data.frame(Predicted=results.trn,Actual=Agetrain$ClassName))
print(results.trn)
print(tab.trn)

#Confusion Matrix or a contingency table for the train data
print(tab.trn)
#Error Rate
1-sum(diag(tab.trn))/sum(tab.trn)
#Accuracy
sum(diag(tab.trn))/sum(tab.trn)

plot(Agetrain$ClassName,results.trn)

## END ##########################################################################################

