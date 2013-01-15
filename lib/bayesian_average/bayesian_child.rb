module Mongoid::BayesianChild
  extend ActiveSupport::Concern

  included do
    before_create :update_bayesian_parent
  end

  def update_bayesian_parent
    bayesian_parent.increment_bayesian_score_by score
  end

  module ClassMethods
    def bayesian_child_for parent, options
      # returns the owner on this record
      define_method "bayesian_parent" do
        send parent
      end
      define_singleton_method "bayesian_field" do
        options[:field]
      end
    end
  end
end
