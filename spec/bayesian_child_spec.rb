require 'spec_helper'

describe Mongoid::BayesianChild do
  context 'newly created' do

    before :each do
      @movie = Movie.create!
    end

    it 'should send the update messages to the parent' do
      @movie.should_receive :increment_values
      child = @movie.rankings.create! score: 3
      child.bayesian_parent.should be(@movie)
    end

    it 'should add `score` points to the parent' do
      @movie.num_bayesian_points.should eq(0)
      @movie.rankings.create! score: 5
      @movie.num_bayesian_points.should eq(5)
    end
  end
end
