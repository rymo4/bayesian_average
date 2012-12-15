module Mongoid::BayesianParent
  extend ActiveSupport::Concern

  C = 10

  def bayesian_average
    klass                  = self.class
    field                  = klass.child_field
    points_in_collection   = bayesian_collection.map(&:num_bayesian_points).inject(&:+)
    elements_in_collection = bayesian_collection.map(&:num_bayesian_children).inject(&:+)

    mean_for_collection = points_in_collection.to_f / elements_in_collection

    (C * mean_for_collection + num_bayesian_points).to_f / (num_bayesian_children + C)
  end

  # Method to update existind database
  def update_bayesian
    association = self.class.bayesian_child.to_s.pluralize

    update_attribute :num_bayesian_children, send(association).count
    points_in_children = send(association).inject(0) { |s, c|
      s + c.send(self.class.child_field)
    }
    update_attribute :num_bayesian_points, points_in_children
  end

  included do |base|
    base.field    :num_bayesian_children, type: Integer, default: 0
    base.field    :num_bayesian_points,   type: Integer, default: 0
  end

  module ClassMethods
    def bayesian_parent_for child
      define_singleton_method "bayesian_child_class" do
        child.to_s.camelize.constantize
      end
      define_singleton_method "bayesian_child" do
        child 
      end
    end

    def child_field
      bayesian_child_class.bayesian_field
    end
  end
end
