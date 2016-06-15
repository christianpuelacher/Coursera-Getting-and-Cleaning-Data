# Final Exam R-course Getting and Cleaning Data, CP

library(dplyr)
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              "data.zip")
if (!file.exists("UCI HAR Dataset")) {
    unzip("data.zip") 
}
setwd("./UCI HAR Dataset")

# Identify columnnames and activities
features <-  read.table("features.txt")
features[,2] <- as.character(features[,2])
activity.labels <- read.table("activity_labels.txt")
activity.labels[,2] <- as.character(activity.labels[,2])

# Identify relevant columns
sel <- grep(".mean|.std", features[,2])

# Testset
xtest <- read.table("test/X_test.txt")
colnames(xtest) <- features[,2]
xtest.sel <- xtest[,sel]
xtest.sel$set <- rep("test", length(xtest.sel[,1]))
subject <- read.table("test/subject_test.txt")
colnames(subject) <- "subject"
activity <- read.table("test/Y_test.txt")
colnames(activity) <- "activity"
xtest.done <- cbind(subject, activity, xtest.sel)

# Trainingset
xtrain <- read.table("train/X_train.txt")
colnames(xtrain) <- features[,2]
xtrain.sel <- xtrain[,sel]
xtrain.sel$set <- rep("train", length(xtrain.sel[,1]))
subject <- read.table("train/subject_train.txt")
colnames(subject) <- "subject"
activity <- read.table("train/Y_train.txt")
colnames(activity) <- "activity"
xtrain.done <- cbind(subject, activity, xtrain.sel)

# Combine and tidy
total <- rbind(xtrain.done, xtest.done)
total <- tbl_df(total)
total$subject <- as.factor(total$subject)
total$activity <- factor(total$activity, levels = activity.labels[,1], labels = activity.labels[,2])
col <- colnames(total)
col <- tolower(col)
col <- sub(".-mean", "mean", col)
col <- sub(".-std", "std", col)
col <- gsub("[-()]", "", col)
colnames(total) <- col

# Create average set
library(reshape2)
total$set <- NULL
total.m <- melt(total, id = c("subject", "activity"))
tidy.avg <- dcast(total.m, subject + activity ~ variable, mean)
write.csv(tidy.avg, "finalset.csv", row.names=FALSE, quote=FALSE)
