# Getting and Cleaning Data - Course Project - Codebook
##Isaac Dorfman
##September, 2017

##Loading and Processing the Data

This function isn't need immediately but is still helpful to include at this  
stage so that the script isn't accidentally slowed down later trying to  
re-install a package that may already be present.


```r
packages <- c("car")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
        install.packages(setdiff(packages, rownames(installed.packages())))  
}
```

In order to ensure maximum portability of the script the require data set is  
set up to be downloaded and unzipped.  This will only occur if the files are  
not already present in the working directory.

```r
if (!dir.exists("~/UCI HAR Dataset")){
        tmp <- tempfile()
        download.file(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
                      ,tmp)
        unzip(tmp)
} else {
        print("The directory already exists.")
}
```

```
## [1] "The directory already exists."
```
At this point we can begin importing and manipulating the data that we hope  
to turn into a tidy data set.

```r
x_test <- read.table("~/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("~/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("~/UCI HAR Dataset/test/subject_test.txt")

x_train <- read.table("~/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("~/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("~/UCI HAR Dataset/train/subject_train.txt")

features <- read.table("~/UCI HAR Dataset/features.txt")
features<-features[,2]
```
The 'features' data set is were we are going to extract the variable names that  
we need to work on the x_test/train data sets.  It is helpful to apply variable  
names at this stage while the data sets are still separate.

```r
colnames(y_test) <- "activity"
colnames(y_train) <- "activity"
colnames(subject_test) <- "subject"
colnames(subject_train) <- "subject"
colnames(x_test) <- features
colnames(x_train) <- features
```
For this assignment we have been asked to exclusively look at variables that are  
related to the mean or standard deviation which this step accomplishes by  
searching for the indices of the appropriate text strings withing the variable  
names and then sub-setting the data on those indices.

```r
mean_std <- grep("(std\\())+|(mean\\())", features)

x_test <- x_test[,mean_std]
x_train <- x_train[,mean_std]
```
We are now ready to combine our data.  This step is, due to the steps taken  
previously to reduce the number of variables, a relatively quick step in the  
process.

```r
test <- cbind(subject_test,y_test,x_test)
train <- cbind(subject_train,y_train,x_train)
complete <- rbind(test,train)
```
We now have a clean and reasonably well organized data set.  However, it is not  
clear what the various values in the 'activity' variable actually represent.  
Here we will re-code that variable for greater clarity with the 'car' package  
providing the 're-code' function to make the process a fairly simple one.

```r
require(car)
```

```
## Loading required package: car
```

```r
complete$activity<-recode(complete$activity,"1='walking';2='walking_upstairs';
                          3='walking_downstairs';4='sitting';
                          5='standing';6='laying'")
```
While there are likely more concise methods of renaming the imported variable  
names this step is carefully laid out for greater clarity in understanding what  
each variable is describing.

```r
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
```
The variables prefaced with a 't' were the original observations from the raw  
data with 't' standing for 'time'.  The variables that were previously prefaced  
with an 'f' are analogous to those that had a 't' except that they have had a  
'Fast Fourier Transformation' applied to the values.  Other changes included  
clarifying 'acc' as 'acceleration' and formatting variable names to be more  
easily read.

Having now created a clean and organized data set the actual task of calculating  
the mean for each of the applicable variables is a relatively simple one.

```r
run_tidy <- aggregate(.~subject + activity, data = complete, mean)
```
At this point we are done and all that remains is to export the data sets for  
archival purposes.

```r
write.table(complete, file = "run_analysis.txt", row.names = FALSE)
        
write.table(run_tidy, file = "run_tidy.txt", row.names = FALSE)
```
The posts clarifying this assignment found here:
https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/

and here:
https://drive.google.com/file/d/0B1r70tGT37UxYzhNQWdXS19CN1U/view

Were essential in the timely completion of this work.
