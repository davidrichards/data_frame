class Symbol # :nodoc:
  def to_underscore_sym
    self.to_s.titleize.gsub(/\s+/, '').underscore.to_sym
  end
end
