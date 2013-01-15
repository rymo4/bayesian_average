# Bayesian Average

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/rymo4/bayesian_average)

A (work in progress) gem for adding Bayesian averages to your Rails projects. What is a Bayesian average?

tl;dr - Get rid of the issues caused by averages (means) of small datasets or datasets with outliars. 

>A Bayesian average is a method of estimating the mean of a population consistent with Bayesian interpretation, 
>where instead of estimating the mean strictly from the available data set, other existing information related 
>to that data set may also be incorporated into the calculation in order to minimize the impact of large 
>deviations, or to assert a default value when the data set is small.

>For example, in a calculation of an average review score of a book where only two reviews are available, both 
>giving scores of 10, a normal average score would be 10. However, as only two reviews are available, 10 may not 
>represent the true average had more reviews been available. The review site may instead calculate a Bayesian 
>average of this score by adding the average review score of all books in the store to the calculation. For example, by adding five scores of 7 each, the Bayesian average becomes 7.86 instead of 10, which the review site would hope that it will better represent the quality of the book.

Taken from the [Wikipedia article](http://en.wikipedia.org/wiki/Bayesian_average).

## Dependencies

Currently the project is dependent on [Mongoid](https://github.com/mongoid/mongoid). I might add AR support later.

## Use

Gemfile:

```ruby
gem "bayesian_average", "~> 0.1.1"
```

In your model being ranked:

```ruby
class Movie
  include Mongoid::Document
  include Mongoid::BayesianParent
  
  has_many :rankings
  
  bayesian_parent_for :ranking, weight: 100
  
  def bayesian_collection
    Movie.all
  end
end
```

In your model representing the rankings:
```ruby
class Ranking
  include Mongoid::Document
  include Mongoid::BayesianChild
  
  belongs_to :movie
  
  field :score, type: Integer, default: 0
  
  bayesian_child_for :movie, field: :score
end
```
  
Here we define the parent and child. Let's look at the parent first.

The parent must ```have_many``` of the child objects. The line ```bayesian_parent_for :ranking, weight: 100```  signifies that objects of the ```Ranking``` class hold the scores, and that the average of the collection will have the weight of `weight` objects. At this point parents can only have Bayesian  scores for one class. The method definition is important. It signifies what the Bayesian score is based off of. In this case, the average of all the movies will be taken into account, but defining this method allows you to define  more appropriate subsets. For example, if the ```Movie``` class has a ```Director```, then ```director.movies``` might be a more reliable mean, since the movies by a particular director tend to be of a certain quality. Keep in mind that if this dataset is small, it will defeat the purpose of a Bayesain average, thus something like this might be better:

```ruby
def bayesian_collection
  director.movies.count >= 5 ? director.movies : Movie.all
end
```

The child class only has one interesting line in it. ```bayesian_child_for :movie, field: :score``` simply denotes
which field should be used in the average, and which class it is scoring. 

This exposes the following method:

```ruby
movie.bayesian_average #=> Float
```

Also, you will get a method to update your existing database:

```ruby
Movie.all.each do { |movie| movie.update_bayesian }
```

Keep in mind that this will put a large load on your database. You probably want to do this a small section at a time and 
asynchronously with [Resque](https://github.com/defunkt/resque) or something similar.

## How It Works

This gem will store two fields on your parent model, ```num_bayesian_children``` and ```num_bayesian_points```.
Instead of storing a float, it will keep these fields to prevent rounding errors from propagating over the 
lifetime of your application. 

The child model gets a ```before_create``` that increments the parent model atomically to update the number
of children and number of total points.

## License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
