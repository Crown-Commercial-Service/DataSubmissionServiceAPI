##
# Matcher for matching File objects against an array of paths:
#
# expect(an_array_of_files).to have_files_matching_paths('/path1/file.csv', 'path2/file.csv')
# expect(SomeClass).to have_received(:new).with files_matching_paths(expected_file_paths)
RSpec::Matchers.define :files_matching_paths do |file_paths|
  match do |actual|
    actual.all? { |arg| arg.kind_of?(File) } && actual.map(&:path) == file_paths
  end
end

RSpec::Matchers.alias_matcher :be_files_matching_paths, :files_matching_paths
