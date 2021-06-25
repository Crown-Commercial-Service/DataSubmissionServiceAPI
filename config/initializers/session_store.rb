class SessionStore
  def self.the_array
    # rubocop:disable Style/ClassVars
    @@the_array ||= []
  end

  def self.add(element)
    @@the_array << element if element
  end

  def self.sessions_array_data
    @@the_array
  end

  the_array unless defined? @@the_array
  # rubocop:enable Style/ClassVars
end
