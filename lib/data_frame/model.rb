# Adds the model methods to the data frame.
class DataFrame
  
  # Returns a model if defined
  # Defines a model with a block, if given and not defined
  # Stores the model in the models container, which gives us access like:
  # df.models.new_model_name...
  def model(name=nil, &block)
    return self.models[name] if self.models.table.keys.include?(name)
    return false unless block
    @pc = ParameterCapture.new(&block)
    model = self.filter(Hash) do |row|
      @pc.filter(row)
    end
    self.models.table[name] = model
  end
  
  def models
    @models ||= OpenStruct.new
  end
  
end