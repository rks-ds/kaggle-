#input data
train<-read.csv("train.csv")
test<-read.csv("test.csv")
X <- train[,-1]
Y <- train[,1]
trainlabel <- train[,1]
#Principal component analysis
Xreduced <- X/255
Xcov <- cov(Xreduced)
pcaX <- prcomp(Xcov)
vexplained <- as.data.frame(pcaX$sdev^2/sum(pcaX$sdev^2))
vexplained <- cbind(c(1:784),vexplained,cumsum(vexplained[,1]))
colnames(vexplained) <- c("No_of_Principal_Components","Individual_Variance_Explained","Cumulative_Variance_Explained")
plot(vexplained$No_of_Principal_Components,vexplained$Cumulative_Variance_Explained, xlim = c(0,100),type='b',pch=16,xlab = "Principal Componets",ylab = "Cumulative Variance Explained",main = 'Principal Components vs Cumulative Variance Explained')
vexplainedsummary <- vexplained[seq(0,100,5),]
Xfinal <- as.matrix(Xreduced) %*% pcaX$rotation[,1:45]
trainLabel<-as.factor(trainLabel)
library(e1071)
model_svm<-svm(Xfinal, trainLabel, kernel="polynomial")
#Applying PCA to test data
testLabel<-as.factor(test[,1])
testreduced<-test/255
testfinal<-as.matrix(testreduced) %*% Xpca$rotation[,1:45]
#predicting
prediction<-predict(model_svm, testfinal, type="class")
prediction<-as.data.frame(prediction)
