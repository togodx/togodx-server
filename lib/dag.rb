require 'json'
require 'active_support/core_ext/hash'

class Dag
  class << self
    # Example
    #   puts Dag.open(ARGV[0]).to_tree.to_json
    #
    # @param [String] path
    def open(path)
      new(JSON.parse(File.read(path)))
    end
  end

  # @param [Array<Hash>] json
  def initialize(json)
    @json = json.map(&:deep_symbolize_keys)
  end

  # @return [Array<Hash>]
  def to_tree
    return @tree if @tree

    @tree = JSON.parse(@json.to_json).map(&:deep_symbolize_keys) # to avoid shallow copy

    @parents = Hash.new { |hash, key| hash[key] = [] }
    @childs = Hash.new { |hash, key| hash[key] = [] }
    @labels = Hash.new
    @leaves = Hash.new
    @indices = Hash.new { |hash, key| hash[key] = 0 }
    @delete_edge = Hash.new

    @tree.each do |hash|
      @childs[hash[:parent]].push(hash[:id])
      @parents[hash[:id]].push(hash[:parent])
      @labels[hash[:id]] ||= hash[:label]
      @leaves[hash[:id]] ||= hash[:leaf] if hash[:leaf]
    end

    @parents.filter { |k, v| !@leaves[k] && v.size > 1 }.keys.sort.each do |id|
      (0..@indices[id]).each do |i|
        copy_id = i.zero? ? id : "#{id}-#{i}"

        @parents[copy_id].drop(1).each do |parent_id|
          delete_edge copy_id, parent_id
          @indices[id] += 1
          new_child_id = "#{id}-#{@indices[id]}"
          add_edge new_child_id, @labels[id], parent_id, @leaves[id]
          copy_sub_graph id, new_child_id
        end
      end
    end

    @tree.tap { |tree| tree.reject! { |hash| @delete_edge.key? "#{hash[:id]}\t#{hash[:parent]}" } }
  end

  def delete_edge(id, parent)
    @childs[parent].reject! { |x| x == id }
    @parents[id].reject! { |x| x == parent }

    @delete_edge["#{id}\t#{parent}"] = 1
  end

  def add_edge(id, label, parent, leaf)
    @childs[parent].push id
    @parents[id].push parent
    @tree.push({ id: id, label: label, parent: parent, leaf: leaf }.compact)
  end

  def copy_sub_graph(parent_id, new_parent_id)
    @childs[parent_id].each do |id|
      new_child_id = id
      id = (m = id.match(/(.+)-\d+$/)) ? m.captures[0] : id # TODO: Ensure that - is not used in the id

      unless @leaves[id]
        @indices[id] += 1
        new_child_id = "#{id}-#{@indices[id]}"
        copy_sub_graph id, new_child_id
      end

      add_edge new_child_id, @labels[id], new_parent_id, @leaves[id]
    end
  end
end
