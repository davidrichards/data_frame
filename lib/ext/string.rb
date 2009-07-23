class String # :nodoc:
  def to_underscore_sym
    self.titleize.gsub(/\s+/, '').underscore.to_sym
  end
end