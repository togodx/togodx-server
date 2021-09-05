class Classification < ApplicationRecord
  acts_as_nested_set counter_cache: :count

  include Breakdown

  def breakdown(node = nil, mode = nil)
    if node
      parent = self.class.find_by!(classification: node)
    else
      parent = self.class.root
    end
    #list = parent.children.where(leaf: false).map do |child|
    list = children_without_leaf(parent).map do |child|
      count_breakdown(child)
    end
    sort_breakdown(list, mode)
  end

  def entries(node = nil)
    $stderr.print ">> condition: "
    $stderr.puts node.inspect
    if node
      record = self.class.find_by!(classification: node)
    else
      record = self.class.root
    end
    record.descendants.where(leaf: true).map{|x| x.classification}
  end

  private

  # TODO: ad hoc fix to avoid node.children looks classification table
  def children_without_leaf(record)
    self.class.where(parent_id: record.id).where(leaf: false)
  end

  def count_breakdown(record)
    label = record.classification_label
    count = record.descendants.where(leaf: true).count
    tip = children_without_leaf(record).count == 0
    # * renamed categoryId to node (or classificaiton, too long though)
    # * renamed hasChild to tip as an inverse boolean
    #{ label: label, count: count, node: record.classification, tip: tip }
    #bool = record.children.where(leaf: false).count > 0
    { label: label, count: count, categoryId: record.classification, hasChild: ! tip }
  end
end
