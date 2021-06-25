class Session_Store
  def self.the_array
    @@the_array ||= []
  end
  
  def self.add element
    @@the_array << element if element
  end

  def self.get_array
    @@the_array
  end

  self.the_array unless defined? @@the_array
end
