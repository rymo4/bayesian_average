require 'spec_helper'

describe Mongoid::BayesianParent do
  context 'with its children == its collection' do
    it 'should return the average' do
      @movie = Movie.create!
      @movie.rankings.count.should eq(0)

      @movie.rankings.create! score: 10
      @movie.bayesian_average.should eq(10)

      @movie.rankings.create! score: 5
      @movie.bayesian_average.should eq(7.5)
    end
  end

  context 'with an existing collection' do
    before :each do
      @movie_1 = Movie.create!
      @movie_2 = Movie.create!

      @movie_1.rankings.create! score: 10
      @movie_1.rankings.create! score: 8
    end

    it 'should not contain in elements in the collection' do
      @movie_1.literal_bayesian_collection.count.should eq(0)
    end

    it 'should return the bayesian average' do
      @movie_1.bayesian_average.should eq(9)

      @movie_2.rankings.create! score: 0
      @movie_2.rankings.create! score: 1

      @movie_2.num_bayesian_children.should eq(2)
      @movie_2.num_bayesian_points.should eq(1)

      @movie_2.bayesian_average.should eq(
        ((9 * Mongoid::BayesianParent::C) + 1 + 0).to_f / (Mongoid::BayesianParent::C + 2)
      )
    end
  end
end
