### Course Project for Getting and Cleaning Data Course

## Objective - You should create one R script called run_analysis.R
## that does the following:

## 1) Merges the training and the test sets to create one data set.
## 2) Extracts only the measurements on the mean and standard
## deviation for each measurement. 
## 3) Uses descriptive activity names to name the activities in the
## data set
## 4) Appropriately labels the data set with descriptive variable
## names. 
## 5) From the data set in step 4, creates a second, independent tidy
## data set with the average of each variable for each activity and
## each subject.

####################################################################

## Step 0: Before beginning to merge the training and test sets,
## we need to download the necessary files

# Set variables for fileURL and fileDownload
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileDownload <- "CourseProject.zip"

# Download project file
if(!file.exists(fileDownload)){
        download.file(url <- fileURL, destfile = fileDownload, method = "curl")
}

# Unzip downloaded file to set directory
unzip(zipfile = fileDownload, exdir = "./")

## Step 1: With the files downloaded and unzipped, we can now look
## to merging the required files into one dataset

# Setwd to be the dataset folder that has been unzipped
setwd("Coursera/Getting_and_Cleaning_Data/Course_Project/UCI HAR Dataset")

# Read features and activity_labels .txt files
features <- read.table("features.txt")
activity_labels <- read.table("activity_labels.txt") 

# Read train .txt files
train_data <- read.table("./train/X_train.txt")
train_labels <- read.table("./train/y_train.txt")
train_subject <- read.table("./train/subject_train.txt")

# Read test .txt files
test_data <- read.table("./test/X_test.txt")
test_labels <- read.table("./test/y_test.txt")
test_subject <- read.table("./test/subject_test.txt")

# Assign colnames to each of the datasets
colnames(activity_labels) <- c("ActivityCode", "Activity")
colnames(train_labels) <- "ActivityCode"
colnames(test_labels) <- "ActivityCode"
colnames(train_data) <- features[,2]
colnames(test_data) <- features[,2]
colnames(train_subject) <- "Participant"
colnames(test_subject) <- "Participant"

# Create Test and Train respective datasets
test_set <- cbind(test_subject,test_labels, test_data)
train_set <- cbind(train_subject, train_labels, train_data)

# Join both datasets togther to create a master file
subjectMaster <- rbind(test_set, train_set)

## Step 2: Extract only the means and std. dev. for each measurement

# Create a variable (colNames_) that takes the colnames of the subjectMaster
# dataset

colNames_ <- colnames(subjectMaster)

# Use grepl function to create a logical vector variable. This vector will
# then be used to pull out the measurements of the mean and std. dev.
# only.
# Masterlogic used as an example to show how can exclude columns
# that share a similar naming convention but shouldn't be included
masterLogic <- (grepl("ActivityCode",colNames_) | 
                        grepl("Participant",colNames_) | 
                        grepl("-mean..",colNames_) & 
                        !grepl("-meanFreq..",colNames_) & 
                        !grepl("mean..-",colNames_) | 
                        grepl("-std..",colNames_) & 
                        !grepl("-std()..-",colNames_))


masterLogic2 <- (grepl("ActivityCode",colNames_) | 
                        grepl("Participant",colNames_) | 
                        grepl("-mean..",colNames_) | 
                        grepl("-std..",colNames_))

# Use this vector to subject the data for the relevant entries
subjectMasterLogic <- subjectMaster[masterLogic == TRUE]

subjectMasterLogic2 <- subjectMaster[masterLogic2 == TRUE]

## Step 3: Use descriptive activity names to name the activities
## in the master dataset

# Update the existing subjectMaster datset with activity_labels.
# Merged the two sets together by ActivityCode
subjectMasterLogic <- merge(subjectMasterLogic, activity_labels, by.x = "ActivityCode", all.x = TRUE)

subjectMasterLogic2 <- merge(subjectMasterLogic2, activity_labels, by.x = "ActivityCode", all.x = TRUE)
# Update the colNames_ variable we created, given we have now added
# a new column, "Activity"
# subjectMasterLogic2 selected as the viable option for this course
# as it yields 81 columns vs. 20.  More direction required.
colNames_ <- colnames(subjectMasterLogic2)

## Step 4: Appropriately label the master dataset with descriptive
## activity names

# Use a for loop to run through each of the columns of the dataset.
# Use gsub to replace the scientific terms with a list of clearer 
# headings

for (i in 1:length(colNames_)) 
{
        colNames_[i] = gsub("\\()","",colNames_[i])
        colNames_[i] = gsub("-std$","StdDev",colNames_[i])
        colNames_[i] = gsub("-mean","Mean",colNames_[i])
        colNames_[i] = gsub("^(t)","time",colNames_[i])
        colNames_[i] = gsub("^(f)","freq",colNames_[i])
        colNames_[i] = gsub("([Gg]ravity)","Gravity",colNames_[i])
        colNames_[i] = gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",colNames_[i])
        colNames_[i] = gsub("[Gg]yro","Gyro",colNames_[i])
        colNames_[i] = gsub("AccMag","AccMagnitude",colNames_[i])
        colNames_[i] = gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",colNames_[i])
        colNames_[i] = gsub("JerkMag","JerkMagnitude",colNames_[i])
        colNames_[i] = gsub("GyroMag","GyroMagnitude",colNames_[i])
        colNames_[i] = gsub("tBody", "timeBody", colNames_[i])
}

# Assign the new column names to the master dataset
colnames(subjectMasterLogic2) <- colNames_

## Step 5: Create a second, independent tidy dataset with the avg. 
## of each variable for each activity and each subject.

# Remove ActivityCode column, leaving the Activity column and
# Participant as the key identifiers
subjectMasterLogic2$ActivityCode <- NULL

# Reorder columns so that Activity is between Participant and
# remainder of columns
subjectMasterLogic2 <- subjectMasterLogic2[,c(1,81,2:80)]

# Apply means to each column except Participant and Activity.
# Do this by using ddply (plyr)
library(plyr)

# Participant and Activity columns taken as variables for this, so
# that the mean isn't applied.
# Numcolwise used to apply function to each column number entry
tidyData <-  ddply(subjectMasterLogic2, c("Participant", "Activity"), numcolwise(mean))

# Write the file for the tidyData dataset
write.table(tidyData, file = "CourseProject_TidyData.txt")
