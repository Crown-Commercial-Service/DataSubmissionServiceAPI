Result = Struct.new(:success) do
  def success?
    success == true
  end

  def failure?
    !success
  end
end
