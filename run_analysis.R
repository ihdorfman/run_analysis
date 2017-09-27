#Getting and Cleaning Data - Peer Reviewed Assignment
#Isaac Dorfman - September, 2017

#check to see if the packages we need are installed and if they aren't then 
#install them

packages <- c("car")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
        install.packages(setdiff(packages, rownames(installed.packages())))  
}

#Check to see if file repository exists.  If it does not download and unzip files

if (!dir.exists("~/UCI HAR Dataset")){
        tmp <- tempfile()
        download.file(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
                      ,tmp)
        unzip(tmp)
} else {
        print("The directory already exists.")
}

#Importing the relevent data sets from the appropriate directory
#Removing unneeded variables from test and training sets

x_test <- read.table("~/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("~/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("~/UCI HAR Dataset/test/subject_test.txt")

x_train <- read.table("~/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("~/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("~/UCI HAR Dataset/train/subject_train.txt")

#Importing variable names from supplied codebook

features <- read.table("~/UCI HAR Dataset/features.txt")
features<-features[,2]

#Renaming applicable variables for greater clarity

colnames(y_test) <- "activity"
colnames(y_train) <- "activity"
colnames(subject_test) <- "subject"
colnames(subject_train) <- "subject"
colnames(x_test) <- features
colnames(x_train) <- features

#Subsetting the x_test and x_train data set to contain only variables pertaining
#to the mean or standard deviation of an observation

mean_std <- grep("(std\\())+|(mean\\())", features)

x_test <- x_test[,mean_std]
x_train <- x_train[,mean_std]

#Consolidating data sets while preserving order of observations

test <- cbind(subject_test,y_test,x_test)
train <- cbind(subject_train,y_train,x_train)
complete <- rbind(test,train)

#Recode 'activity' variable to be more informative

require(car)

complete$activity<-recode(complete$activity,"1='walking';2='walking_upstairs';
                          3='walking_downstairs';4='sitting';
                          5='standing';6='laying'")

#Step by step Renaming variables for greater clarity 

names(complete) <- tolower(names(complete))
names(complete) <- sub("^t","time_",names(complete))
names(complete) <- sub("^f","fast_",names(complete))
names(complete) <- sub("\\()", "",names(complete))
names(complete) <- sub("-", "",names(complete))
names(complete) <- sub("body","body_", names(complete))
names(complete) <- sub("acc", "acceleration_",names(complete))
names(complete) <- sub("mean-","mean", names(complete))
names(complete) <- sub("std-", "std",names(complete))
names(complete) <- sub("mag","mag_",names(complete))
names(complete) <- sub("jerk","jerk_",names(complete))
names(complete) <- sub("gyro","gyro_",names(complete))
names(complete) <- sub("gravity","gravity_",names(complete))
names(complete) <- sub("x$","_x",names(complete))
names(complete) <- sub("y$","_y",names(complete))
names(complete) <- sub("activit_y", "activity",names(complete))
names(complete) <- sub("z$","_z",names(complete))


#Export processed data set to .txt file

write.table(complete, file = "run_analysis.txt", row.names = FALSE)
        
#Calculate the average of will eventually need the mean()

run_tidy <- aggregate(.~subject + activity, data = complete, mean)

#Export tidy data set to .txt file

write.table(run_tidy, file = "run_tidy.txt", row.names = FALSE)
