The On-Line Encyclopedia of Integer Sequences is a 50+ year effort by mathematicians the world over to catalog sequences of integers.
If it has a pattern, it's probably in the OEIS, and probably described with amazing detail. This competition challenges you create a
machine learning algorithm capable of guessing the next number in an integer sequence. While this sounds like pattern recognition
in its most basic form, a quick look at the data will convince you this is anything but basic!

This dataset contains the majority of the integer sequences from the OEIS. It is split into a training set, where you are given the
full sequence, and a test set, where we have removed the last number from the sequence. The task is to predict this removed integer.

The most obvious attempt is to predict using the mode, median and mean of the sequence given.
Mode performed well among all of these.
P.S No mode function present in R so created own mode function.

After looking deeper into the data applying linear regression to the given sequence and if the linear model is not good using mode
for submission for calculating number of points for regression a evaluation function is made which evaluate result on the basis of
last term of the sequence the result of this model was quite good 0.18099 (Rank 36/286).

Another option is to apply polynomial regression which i did using quadratic function but it is more complex and didnt perform well

Dive Deep in Data! :)
