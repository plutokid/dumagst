# The work log

## Approach

Given the task, we can say that we have users and products. Each user has a set of products they like. 
The first idea is to represent each user with a vector like:

U = (p1, p2 , .. pn) 
where pi equals one if the user U liked the product, or zero otherwise.

We can compose the product-user matrix by using those user vectors as columns. The products would then become rows:

    u1  u2  u3 .. uN
p1  0   1    1
p2  1   0    0
..
pM

We can find similar users by comparing user columns with a similarity/distance function. The Jaccard distance makes sense here. 

Thus, we establish a threshold t and consider users U1 and U2 similar if

sim(U1, U2) > t

where sim is the Jaccard similarity.

For a given user Uk, having obtained similar users, you can then collect the set of products they like, remove products Uk has already liked, and present those as viable choice for Uk to like.


## Issues

In the movie lens 100K data, there are 100000 ratings by 943 users on 1682 items. If we count each rating greater or equal than 4 as a "like", we end up with users each liking 22 movies on average.
When calculating similarities, this produces really low similarity numbers that differ in the 1/100th sometimes, leaving us unable to pick a reasonable threshold.

Approach and data issues:
- similarity measure. Jaccard is a good starting point. Tanimoto, Sorensen, etc. are some of the options
- features. They should retain most of the variance while still producing sensibly different similarity scores. Right now an increase of similarity from 0.4 to 0.5 decreases the number of similar users from 80 to 10.

Implementation can be improved in various ways:
- bitwise to save memory
- map/reduce to paralelize processing
- be able to update the recommendations in the real time or close to real time

