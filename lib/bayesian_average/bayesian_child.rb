module Mongoid::BayesianChild
  extend ActiveSupport::Concern

  def update_bayesian_parent
    bayesian_parent.inc :num_bayesian_children, 1
    bayesian_parent.inc :num_bayesian_points,   send(self.class.bayesian_field)
  end

  included do |base|
    base.field          :bayesian_average, type: Float, default: 0
    base.before_create  :update_bayesian_parent
  end

  module ClassMethods
    def bayesian_child_for parent, options
      # returns the owner on this record
      define_method "bayesian_child" do
        send parent
      end
      define_singleton_method "bayesian_field" do
        options[:field]
      end
    end
  end
end
