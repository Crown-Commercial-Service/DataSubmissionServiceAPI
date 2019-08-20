module FrameworkLoader
  def self.[](framework_short_name)
    fdl_source = File.read(filename_for(framework_short_name))
    Framework::Definition::Generator.new(fdl_source).definition
  end

  def self.filename_for(framework_short_name)
    sanitized_short_name = framework_short_name.downcase.tr('/.', '_')
    File.expand_path("../../fixtures/#{sanitized_short_name}.fdl", __FILE__)
  end
end
