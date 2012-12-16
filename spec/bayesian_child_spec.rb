require 'spec_helper'

describe Mongoid::BayesianChild do
  context 'with a parent' do
    before :each do
      @bayesian_child = Object.new
      @bayesian_child.extend Mongoid::BayesianChild

      @bayesian_parent = Object.new
      @bayesian_parent.extend Mongoid::BayesianParent
    end
    it 'has the correct fields' do

    end
  end

  context 'without a parent' do
  end
end
