Titanic

In this competition, the aim is to predict the fate of the passengers aboard the RMS Titanic, which famously sank in the Atlantic ocean during its maiden voyage from the UK to New York City after colliding with an iceberg.

the Titanic reportedly struck an iceberg at 11:40 pm ship's time. The majority of its 2,224 passengers and crew had likely retired to their respective cabins for the evening by that time. Those on the upper decks had a shorter journey to the lifeboats, and possibly access to more timely and accurate information about the impending threat. Also it is not surprising that a disproportionate number of men were apparently left aboard because of a women and children first protocol followed by some of the officers overseeing the loading of lifeboats with passengers.

As always in the Kaggle problem there are two datasets provided. one is train dataset on which model is prepared and another is test dataset on which model is tested. The data provide is-

[!alt tag](https://github.com/thefiercedemon/kaggle-/blob/master/titanic/data.PNG)

Datatype given: 
[!alt tag](https://github.com/thefiercedemon/kaggle-/blob/master/titanic/data%20type.PNG)

On observing the data and analysing it. Few of the datatype was changed
- Survived, Pclass changed to factor variable
- Name to character variable
- Ticket to Numerical variable

Observing the intial summary and getting the idea of the training data. It was found that lot of missing values are present in the training data as well as in test data.

For the puppose of cleansing and feature engineering the data it is good to combine both dataset without the dependent variable.

[!alt tag](https://github.com/thefiercedemon/kaggle-/blob/master/titanic/summary.PNG)

The summary showed that Fare and Embarked had very few missing values which can me imputed manually.
- Embarked missing value was imputed with the dominating class
- Fare missing value was imputed with the median of the Pclass which the missing value belongs.

Visualising the data to get deep idea

[!alt tag](https://github.com/thefiercedemon/kaggle-/blob/master/titanic/visual.png)

Inspection of the next feature -- Name -- reveals what could be an even better approach...
The titles -- Mr., Mrs., Miss., Master. -- following each of the surnames
On the basis of titles a new variable is made Title which contains all the titles.
The graph below shows various titles present and on the basis of frequency of the particular title they are again binned into 4 levels-
    Mrs, Mr, rare_title, Miss
    
[!alt tag](https://github.com/thefiercedemon/kaggle-/blob/master/titanic/Title_count.png)

Well, there’s those two variables SibSb and Parch that indicate the number of family members the passenger is travelling with. Seems reasonable to assume that a large family might have trouble tracking down little Johnny as they all scramble to get off the sinking ship, so let’s combine the two variables into a new one, FamilySize

A new feature named Family size is created by adding the feature "Parch" and "SibSp".

What can we do next???

Well we just thought about a large family having issues getting to lifeboats together, but maybe specific families had more trouble than others? We could try to extract the Surname of the passengers and group them to find families, but a common last name such as Johnson might have a few extra non-related people aboard. In fact there are three Johnsons in a family with size 3, and another three probably unrelated Johnsons all travelling solo.

Combining the Surname with the family size though should remedy this concern. No two family-Johnson’s should have the same FamilySize variable on such a small ship. So a new variable familyID is created using Family size and Surname of the family.

Now lets Look at the fare variable-

[!alt tag](https://github.com/thefiercedemon/kaggle-/blob/master/titanic/fare_freq.png)

The fare looks quite skewed. May be due to tickets bought all together which increases the fare.
so new feature is introduced named as Fare Per Person. As the name suggest Fare of the ticket per person is calculated as Fare divided by the Family size.

The policy of women and child first must have affected the chances of survival.
For finding out children and mother the age of each passenger must be known. Looking to the age variable-

[!alt tag](https://github.com/thefiercedemon/kaggle-/blob/master/titanic/age-count.png)

The graph shows the number of different age persons and it can be easily imputed using predictions. So using party Package in R and predicting the missing values of age variable.
After imputation-

[!alt tag](https://github.com/thefiercedemon/kaggle-/blob/master/titanic/imputedage-freq.png)

After the age variable is imputed now Child and Mother variable can be created.
Child variable is created on the basis of age
Mother variable is created on the basis of sex, age and title.
[alt tag](https://github.com/thefiercedemon/kaggle-/blob/master/titanic/child.png)

[alt tag](https://github.com/thefiercedemon/kaggle-/blob/master/titanic/mother.png)


Now after the cleansing and feature engineering is done, the model is prepared using party package which also gives a random Forest but a robust one.

Plotting the feature importance and using only the important variable at last for submission.

[!alt tag](https://github.com/thefiercedemon/kaggle-/blob/master/titanic/variable_importance.png)

Deep Dive in the data! :)







