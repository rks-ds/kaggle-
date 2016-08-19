library(randomForest)
library(dplyr)
library(rpart)
library(party)
#input the train and test data
train<-read.csv("train.csv")
test<-read.csv("test.csv")
all_data <- bind_rows(train, test)
#tackling the missing data
#Imputing and Feature Engineering
table(all_data$Embarked)
all_data$Embarked[c(62, 830)] <- "S"
all_data$Embarked <- factor(all_data$Embarked)
all_data$Fare[1044] <- median(all_data[all_data$Pclass == '3' & all_data$Embarked == 'S', ]$Fare, na.rm = TRUE)
all_data$Title <- gsub(".*\\ (.*)\\..*", "\\1", all_data$Name)
if(TRUE){
    all_data$Title[all_data$Title == 'L'] <- 'Other'
    all_data$Title[all_data$Title == 'Capt'] <- 'Other'
    all_data$Title[all_data$Title == 'Countess'] <- 'Other'
    all_data$Title[all_data$Title == 'Don'] <- 'Other'
    all_data$Title[all_data$Title == 'Dona'] <- 'Other'
    all_data$Title[all_data$Title == 'Mme'] <- 'Other'
    all_data$Title[all_data$Title == 'Major'] <- 'Other'
    all_data$Title[all_data$Title == 'Jonkheer'] <- 'Other'
    all_data$Title[all_data$Title == 'Mlle']        <- 'Miss' 
    all_data$Title[all_data$Title == 'Ms']          <- 'Miss'
    all_data$Title[all_data$Title == 'Mme']         <- 'Mrs'   
    rare_title <- c('Dona', 'Lady', 'the Countess','Capt', 'Col', 'Don', 
                'Dr', 'Major', 'Rev', 'Sir', 'Jonkheer')
    all_data$Title[all_data$Title %in% rare_title]  <- 'Rare Title'
}
all_data$Title <- factor(all_data$Title)
all_data$Family_size <- all_data$Parch + all_data$SibSp + 1
all_data$FarePerPerson <- all_data$Fare / all_data$Family_size
all_data$Surname <- sapply(all_data$Name, FUN=function(x) {strsplit(x, split='[,.]')[[1]][1]})
all_data$FamilyID <- paste(as.character(all_data$Family_size), all_data$Surname, sep="")
all_data$FamilyID[all_data$Family_size < 2] <- 'Small'
famIDs <- data.frame(table(all_data$FamilyID))
famIDs <- famIDs[famIDs$Freq < 2,]
all_data$FamilyID[all_data$FamilyID %in% famIDs$Var1] <- 'Small'
all_data$FamilyID <- factor(all_data$FamilyID)
#impute age
predicted_age <- cforest(Age ~ Pclass + Sex + SibSp + Parch + Fare + Embarked + Title +Family_size + FarePerPerson + FamilyID, data = all_data[!is.na(all_data$Age),],controls=cforest_unbiased(ntree=200, mtry=3))
all_data$Age[is.na(all_data$Age)] <- predict(predicted_age, all_data[is.na(all_data$Age),], OOB=TRUE, type = "response")
all_data$Child[all_data$Age < 18] <- 'Child'
all_data$Child[all_data$Age >= 18] <- 'Adult'
all_data$Child <- factor(all_data$Child)
all_data$Mother <- 'Not Mother'
all_data$Mother[all_data$Sex == 'female' & all_data$Parch > 0 & all_data$Age > 18 & all_data$Title != 'Miss'] <- 'Mother'
all_data$Mother <- factor(all_data$Mother)
all_data$Deck<-substring(all_data$Cabin, 1, 1)
all_data$Deck <- factor(all_data$Deck)
predicted_deck <- cforest(Deck ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Title + Child + Mother + Family_size + FarePerPerson + FamilyID,data = all_data[all_data$Deck != '',],controls=cforest_unbiased(ntree=200, mtry=3))
all_data$Deck[all_data$Deck == ''] <- predict(predicted_deck, all_data[all_data$Deck == '',], OOB=TRUE, type = "response")
train <- all_data[1:891,]
test <- all_data[892:1309,]
#Predicting
t_forest <- cforest(as.factor(Survived) ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Title+ Deck + Child + Mother + Family_size + FarePerPerson + FamilyID, data = train,controls=cforest_unbiased(ntree=500, mtry=3))
t_prediction <- predict(t_forest, test, OOB=TRUE, type = "response")





