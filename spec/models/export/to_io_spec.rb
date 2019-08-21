require 'rails_helper'
require 'csv'

RSpec.describe Export::ToIO do
  before do
    FactoryBot.create_list(:supplier, 2)
  end

  let(:relation) { Supplier.order(name: :asc) }
  let!(:result) { subclass.new(relation, StringIO.new).run }

  # An example subclass of Export::ToIO, whose rows use a class variable to
  # keep track of the passed cache values
  let(:subclass) do
    Class.new(Export::ToIO) do
      const_set(:HEADER, [])

      row_class = Class.new(Export::CsvRow) do
        class << self
          attr_accessor :latest_cache
        end

        def initialize(_model, cache)
          self.class.latest_cache = cache
          cache[cache.count] = true
        end

        def row_values
          []
        end
      end

      const_set(:Row, row_class)
    end
  end

  it 'passes an empty hash as cache to the first row and passes cache between rows' do
    expect(subclass::Row.latest_cache).to eq(0 => true, 1 => true)
  end
end
