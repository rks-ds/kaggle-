#input data

train<-read.csv("train.csv")
test<-read.csv("test.csv")

# The train include information about the gray scale images of handwritten digits from zero to nine.
# Each image is 28 pixel in height and 28 pixel in width which in total is 784 pixels.
# The train data includes 42000 images each with 784 pixels.
# The test data includes 28000 images.
# All together data is huge and it is not easy to build model on it.

X <- train[,-1]
Y <- train[,1]
trainlabel <- train[,1]

#The data provided is huge and modelling this data without dimension reduction is not possible in R. So as to reduce the data
# without loosing the information PCA(Principal Components Explained is applied.
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
trainlabel<-as.factor(trainlabel)

#Support Vector Machines

library(e1071)
model_svm<-svm(Xfinal, trainlabel, kernel="polynomial")

#Applying PCA to test data

testlabel<-as.factor(test[,1])
testreduced<-test/255
testfinal<-as.matrix(testreduced) %*% Xpca$rotation[,1:45]

#predicting

prediction<-predict(model_svm, testfinal, type="class")
prediction<-as.data.frame(prediction)
