# Captures the intent of a model definition in a block.  Usage:
# pc = ParameterCapture.new do |p|
#   p.whatever :some_value
#   p.another :one
#   p.or_list [1, 2]
#   p.or_range (1..2)
# end
# pc.parameters
# => {:whatever => :some_value, :another => :one, :or_list => [1,2], :or_range => (1..2)}
class ParameterCapture
  def initialize(&block)
    self.instance_eval &block
  end
  
  def parameters
    @parameters ||= OpenStruct.new
  end
  
  # Exposes the set keys
  def keys
    self.parameters.table.keys
  end
  
  # can be used in a data_frame filter.
  # @pc.filter(row) Using a Hash as a cast type for the filter.
  def filter(row)
    self.keys.each do |key|
      value = self.parameters.send(key)
      case value
      when Array
        return false unless value.include?(row[key])
      when Range
        return false unless value.include?(row[key])
      else
        return false unless value === row[key]
      end
    end
    return true
  end
  
  def method_missing(key, *values, &block)
    if self.parameters.table.keys.include?(key)
      self.parameters.send(key)
    elsif values.size == 1
      self.parameters.table[key] = values.first
    else
      self.parameters.table[key] = values
    end
  end
end
