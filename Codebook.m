The run_analysis.R file is a script that performs 5 steps over data that has been produced by a smartphone’s gyroscope and accelerometer.  30 different subjects generated this data; these subjects were split into two groups (test and train).

The fifth step culminates in the production of a CourseProject_TidyData.txt file.  An over of the steps taken to produce this is given below:

Step One:  A subjectMaster dataset is produced through the use of rbind.  Rbind combines the two separate ‘train’ and ‘test’ datasets.

Step Two: A package called grepl is used to produce a logical vector called master	Logic.  This vector is used to create a subset of all the mean and std. dev. measurements.

Step Three: The dataset is merged with an activity labels dataset to give a more descriptive understanding of the exercises undertaken by the subjects (Walking, Walking_Upstairs, Walking_Downstairs, Sitting, Standing, Laying).

Step Four: A for loop is used in combination with gsub to make the column headings more meaningful to users.

Step Five: A tidy dataset of 180 rows is produced and provides the average measures of each activity for each of the 30 subjects. 
