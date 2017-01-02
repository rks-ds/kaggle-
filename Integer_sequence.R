

#Loading the data
train=read.csv("train.csv")
test=read.csv("test.csv")
train$Sequence=as.character(train$Sequence)
test$Sequence=as.character(test$Sequence)

#creating own mode function because mode() in R gives type of data
  getmode=function(x)
  {
   ux=unique(x)
   ux[which.max(tabulate(match(x,ux)))]
  }
install.packages("stringr")
library(stringr)
library(dplyr)
library(plyr)

# feature engineering

for(i in 1:113845)
 {
   x=as.numeric(str_split(test[i,2],",")[[1]])
   test$mean[i]=mean(x)
   test$median[i]=median(x)
   test$mode[i]=getmode(x)
   test$std[i]=sd(x)
   test$secondlast[i]=tail(x,1)
   test$first[i]=head(x,1)
   test$NOP[i]=length(x)
 }

for(i in 1:113845)
 {
  x=as.numeric(str_split(train[i,2],",")[[1]])
  train$mean[i]=mean(x)
  train$median[i]=median(x)
  train$std[i]=sd(x)
  train$mode[i]=getmode(x)
  train$last[i]=tail(x,1)
  train$first[i]=head(x,1)
  train$secondlast[i]=sum(tail(x,2))-train$last[i]
  train$NOP[i]=length(x)}
 }
#mode, mean and last tried as submission
submission=train[,1:2]
write.csv(submission,"mode_submission.csv",row.names=FALSE)
#with mode .05746 (rank: 194/286)

#Look deeper into the data
#Applying linear regression to the given sequence and if the linear model is not good
#using mode for submission
#for calculating number of points for regression a evaluation function is made which evaluate result on the
#the basis of last term of the sequence
#the result of this model was quite good 0.18099 (Rank 36/286) 


fitModel <- function(sequence,numberOfPoints,forSubmission=FALSE,modeFallbackThreshold)
 {
   # Convert to a vector of numbers
   sequence <- as.numeric(strsplit(sequence,split=",")[[1]])
   if(!forSubmission)
   {
     oos <- tail(sequence,1)
     sequence <- head(sequence,-1)
   }
   
   # Need at least <numberOfPoints>+1 observations to fit the model, otherwise just return the last value
   if(length(sequence)<=numberOfPoints)
   {
     if(length(sequence)==0)
     {
       prediction <- NA
     }
     else
     {
       prediction <- tail(sequence,1)
     }
     mae <- NA
   }
   else
   {
     df <- data.frame(y=tail(sequence,-numberOfPoints))
     formulaString <- "y~"
     for(i in 1:numberOfPoints)
     {
       df[[paste0("x",i)]] <- sequence[i:(length(sequence)-numberOfPoints+i-1)]
       formulaString <- paste0(formulaString,"+x",i)
     }
     formulaString <- sub("~\\+","~",formulaString)
 
     fit <- lm(formula(formulaString),df)
     mae <- max(abs(fit$residuals))
 
     # Make prediction
     if(forSubmission && mae > modeFallbackThreshold)
     {
       prediction <- Mode(sequence)
     }
     else
     {
       df <- list()
       for(i in 1:numberOfPoints)
       {
         df[[paste0("x",i)]] <- sequence[length(sequence)-numberOfPoints+i]
      }
       df <- as.data.frame(df)
   
       prediction <- predict(fit,df)
     }
 
     # Round the prediction to an integer
     prediction <- round(prediction)
   }
   
   if(forSubmission)
   {
     return(prediction)
   }
   else
   {
     return(data.frame(prediction=prediction,
                       mae=mae,
                       oos=oos,
                       mode=Mode(sequence)))
   }
 }
 
 # Calculates the accuracy of predictions from calling fitModel with <forSubmission> = FALSE and a given <modeFallbackThreshold>
 evaluateResults <- function(results,modeFallbackThreshold)
 {
   (sum((results$prediction==results$oos)[results$mae<modeFallbackThreshold],na.rm=TRUE) +
    sum((results$mode==results$oos)[results$mae>=modeFallbackThreshold],na.rm=TRUE)) /
     sum(!is.na(results$prediction))
 }
 
 generateSubmission <- function(filename,numberOfPoints,modeFallbackThreshold,verbose=TRUE)
 {
   submission <- data.frame(Id=data$Id,
                            Last=sapply(1:nrow(data),
                                        function(i)
                                        {
                                          model <- fitModel(data$Sequence[[i]],
                                                            numberOfPoints=numberOfPoints,
                                                            modeFallbackThreshold=modeFallbackThreshold,
                                                            forSubmission=TRUE)
                                          if(verbose && i %% 2500 == 0)
                                          {
                                            print(paste("Done",i,"sequences"))
                                          }
                                          return(model)
                                        }))
   options(scipen=999)
   write.csv(submission,filename,row.names=FALSE)
}
data=read.csv("test.csv",stringsAsFactors=FALSE)
generateSubmission("linearPrevious11WithModeFallback.csv",numberOfPoints=16,modeFallbackThreshold=15)




