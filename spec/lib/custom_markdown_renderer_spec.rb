require 'rails_helper'
require 'custom_markdown_renderer'

RSpec.describe CustomMarkdownRenderer do
  let(:renderer) { described_class.new }
  let(:markdown) { Redcarpet::Markdown.new(renderer) }

  describe '#header' do
    it 'renders a level 1 header with the correct GOV.UK class' do
      expect(markdown.render('# Heading 1').strip).to eq('<h1 class="govuk-heading-xl">Heading 1</h1>')
    end

    it 'renders a level 2 header with the correct GOV.UK class' do
      expect(markdown.render('## Heading 2').strip).to eq('<h2 class="govuk-heading-l">Heading 2</h2>')
    end

    it 'renders a level 3 header with the correct GOV.UK class' do
      expect(markdown.render('### Heading 3').strip).to eq('<h3 class="govuk-heading-m">Heading 3</h3>')
    end

    it 'renders a level 4 header with the correct GOV.UK class' do
      expect(markdown.render('#### Heading 4').strip).to eq('<h4 class="govuk-heading-s">Heading 4</h4>')
    end
  end

  describe '#list' do
    it 'renders an unordered list with the GOV.UK bullet class' do
      input = "- Item 1\n- Item 2\n"
      output = '<ul class="govuk-list govuk-list--bullet"><li>Item 1</li><li>Item 2</li></ul>'
      expect(markdown.render(input).gsub("\n", '')).to eq(output)
    end

    it 'renders an ordered list with the GOV.UK number class' do
      input = "1. Item 1\n2. Item 2\n"
      output = '<ol class="govuk-list govuk-list--number"><li>Item 1</li><li>Item 2</li></ol>'
      expect(markdown.render(input).gsub("\n", '')).to eq(output)
    end
  end

  describe '#link' do
    it 'renders a link with the target "_blank" and rel attributes' do
      input = '[Example](https://www.example.com)'
      output = '<p class="govuk-body"><a href="https://www.example.com" title="" class="govuk-link" target="_blank">Example</a></p>'
      expect(markdown.render(input).strip).to eq(output)
    end

    it 'handles links with special characters in the text' do
      input = '[Click me!](https://example.com)'
      output = '<p class="govuk-body"><a href="https://example.com" title="" class="govuk-link" target="_blank">Click me!</a></p>'
      expect(markdown.render(input).strip).to eq(output)
    end
  end

  describe '#paragraph' do
    it 'renders a paragraph with GOV.UK body class' do
      input = 'This is a paragraph.'
      output = '<p class="govuk-body">This is a paragraph.</p>'
      expect(markdown.render(input).strip).to eq(output)
    end
  end

  describe 'edge cases' do
    it 'renders empty input without errors' do
      expect(markdown.render('').strip).to eq('')
    end

    it 'renders nested lists correctly' do
      input = "- Parent\n  - Child\n"
      output = '<ul class="govuk-list govuk-list--bullet"><li>Parent<ul class="govuk-list govuk-list--bullet"><li>Child</li></ul></li></ul>'
      expect(markdown.render(input).gsub("\n", '')).to eq(output)
    end
  end
end
