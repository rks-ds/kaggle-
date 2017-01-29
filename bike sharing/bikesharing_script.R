Bike sharing: Predicting number of bike rented
Kaggle Problem

In this competition, participants are asked to combine historical usage patterns with weather data in order to
forecast bike rental demand in the Capital Bikeshare program in Washington, D.C.

In this competition the data provided is hourly rental data spanning two years. For this competition, the training set
is comprised of the first 19 days of each month, while the test set is the 20th to the end of the month. We have to 
predict the total count of bikes rented during each hour covered by the test set, using only information available prior
to the rental period. It is a typical time-series problem

This is the simple model for bike sharing which give RMSLE as 0.47 on leaderboard

The approach is simple getting the hour, weekend and month from datetime provided and applying randomforest.

 library(randomForest)
  library(ggplot2)
#reading training and test data
train=read.csv("train.csv")
test=read.csv("test.csv")

#Obtaining data from datetime
test$datetime=as.character(test$datetime)
train$datetime=as.character(train$datetime)
train$date=strptime(train$datetime,format="%Y-%m-%d %H:%M:%S")
test$date=strptime(test$datetime,format="%Y-%m-%d %H:%M:%S")
train$year=format(train$date,"%Y")
train$dayofmonth=format(train$date,"%d")
train$month=format(train$date,"%m")
train$hour=train$date$hour
train$weekday=weekdays(train$date)
Sys.setlocale("LC_ALL","C")
test$year=format(test$date,"%Y")
test$dayofmonth=format(test$date,"%d")
test$month=format(test$date,"%m")
test$hour=test$date$hour
test$weekday=weekdays(test$date)

#Categorical variables
for(i in 2:5){test[,i]=as.factor(test[,i])}
for(i in 11:15){test[,i]=as.factor(test[,i])}
for(i in 2:5){train[,i]=as.factor(train[,i])}
for(i in 14:18){train[,i]=as.factor(train[,i])}
  
# Visualisation
# 1. Variation in count with hour on every day of week
# here the heatmap shows that on working days of week people count is more in morning and
# evening but on weekends the count is more in daytime.
day_hour_count=as.data.frame(aggregate(train$count,list(train$weekday,train$hour),mean))
day_hour_count$Group.1=factor(day_hour_count$Group.1,ordered=TRUE,levels=c("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"))
day_hour_count$hour=as.numeric(as.character(day_hour_count$Group.2))
heatmap_weekday=ggplot(day_hour_count,aes(x=hour,y=Group.1))+geom_tile(aes(fill=x))+scale_fill_gradient(name="Average count",low="white",high="green")+theme(axis.title.y=element_blank())
heatmap_weekday

# 2. Variation in count with hour in every season
# here the lineplot depicts that people rent bikes more in fall

train$season=factor(train$season,labels=c("spring","summer","fall","winter"))
train$weather=factor(train$weather,labels=c("good","normal","bad","verybad"))
season_hour_count=as.data.frame(aggregate(train$count,list(train$season,train$hour),mean))
season_hour_count$hour=as.numeric(as.character(season_hour_count$Group.2))
heatmap2_season=ggplot(season_hour_count,aes(x=hour,y=Group.1))+geom_tile(aes(fill=x))+scale_fill_gradient(name="Average count",low="white",high="red")+theme(axis.title.y=element_blank())
heatmap2_season

linemap_season=ggplot(season_hour_count,aes(x=hour,y=x,color=Group.1))+geom_line()+geom_point()+scale_x_discrete("Hour")+scale_y_continuous("Count")
linemap_season


# 3. Variation in count with hour in different weather
# here the lineplot depicts that people rent bikes more when weather is good which totally supports the human physchology

weather_hour_count=as.data.frame(aggregate(train$count,list(train$weather,train$hour),mean))
weather_hour_count$hour=as.numeric(as.character(weather_hour_count$Group.2))
linemap2_weather=ggplot(weather_hour_count,aes(x=hour,y=x,color=Group.1))+geom_line()+geom_point()+xlab("Hour")+ylab("count")
linemap2_weather


# 4. Variation in count with hour in every weekend

linemap3_weekday=ggplot(day_hour_count,aes(x=hour,y=x,color=Group.1))+geom_line()+geom_point()+xlab("Hour")+ylab("count")+theme_minimal()
linemap3_weekday

 # 5. distribution of count is skewed
      plot(train$count,xlab="observation",ylab="count")
       #To reduce skewness of count
               train$newcount=log(train$count+1)
               plot(train$newcount,xlab="observation",ylab="count")

#Applying randomforest
model=randomForest(newcount~hour+month+year+weekday+windspeed+atemp+humidity+weather+season+holiday+workingday,train,ntree=500)
pred=predict(model,test)
pred=as.data.frame(pred)
pred$datetime=test$datetime
pred$count=exp(pred[,1])-1
pred[,1]=NULL
write.csv(pred,"submission.csv",row.names=FALSE)
# above randomforest depicts that hour and atemp are the most important variables






