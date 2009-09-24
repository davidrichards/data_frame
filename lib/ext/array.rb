class Array
  # Defines the number of dimensions:
  # [1,2,3] is 1-dimensional
  # [[1,2,3], [1,2,3]] is 2-dimensional
  # [[[1,2,3], [1,2,3]], [[1,2,3], [1,2,3], [[1,2,3], [1,2,3]]]] is 3-dimensional
  # So [[[1,2,3], [1,2,3]], [[1,2,3], [1,2,3], [[1,2,3], [1,2,3]]]].dimensions == 3
  def dimensions(n=0)
    n += 1
    self.first.is_a?(Array) ? self.first.dimensions(n) : n
  end
end