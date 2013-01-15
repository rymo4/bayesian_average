module Mongoid::BayesianParent
  extend ActiveSupport::Concern

  DEFAULT_WEIGHT = 10

  def bayesian_average
    klass       = self.class
    field       = klass.child_field
    collection  = literal_bayesian_collection

    if collection.any?
      points_in_collection = collection.map(&klass.child_field).inject(&:+)
      mean_for_collection  = points_in_collection.to_f / collection.count
    else
      mean_for_collection = num_bayesian_points.to_f / num_bayesian_children
    end

    ((C * mean_for_collection) + num_bayesian_points).to_f / (num_bayesian_children + C)
  end

  def literal_bayesian_collection
    self.class.bayesian_child_class.nin(
      id: bayesian_children.only(:id).map(&:id)
    )
  end

  def bayesian_children
    send self.class.bayesian_child.to_s.pluralize
  end

  # Method to update existind database
  def update_bayesian
    points_in_children = bayesian_children.inject(0) { |s, c|
      s + c.send(self.class.child_field)
    }

    update_attributes num_bayesian_children: send(association).count,
                      num_bayesian_points:   points_in_children
  end

  def increment_bayesian_score_by num_bayesian_points
    inc :num_bayesian_children, 1
    inc :num_bayesian_points, num_bayesian_points
  end

  included do |base|
    base.field :num_bayesian_children, type: Integer, default: 0
    base.field :num_bayesian_points,   type: Integer, default: 0
  end

  module ClassMethods
    def bayesian_parent_for child, options = {}
      weight = options[:weight] || Mongoid::BayesianParent::DEFAULT_WEIGHT
      Mongoid::BayesianParent.const_set 'C', weight

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
