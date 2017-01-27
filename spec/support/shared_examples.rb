#--------------------------
#
# @file shared.rb
#
# @desc Shared examples and common methods for the RSpec tests
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   1/20/17
#
#
#--------------------------



# alias shared example call for readability
RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_will, 'it will'
end

#- - - - - - - - - -
RSpec.shared_examples 'use doc directory' do |desc, options|

  it "#{desc}" do
    doc_dir = File.absolute_path(File.join(__dir__, '..', '..', 'doc'))

    FileUtils.rm_r(doc_dir) if Dir.exist? doc_dir

    expect { AASM_StateChart::AASM_StateCharts.new(options).run }.not_to raise_error
    expect(Dir).to exist(doc_dir)
    expect(File).to exist(File.join(doc_dir, "#{DEFAULT_MODEL}.png"))

    FileUtils.rm_r(doc_dir)
  end

end


RSpec.shared_examples 'have attributes = given config' do |item_name, item, options={}|

  item_attribs = item.each_attribute(true) { |a| a }

  options.each do |k, v|
    # GraphViz returns the keys as strings
    it "#{item_name} #{k.to_s}" do
      expect(item_attribs.fetch(k.to_s, nil)).not_to be_nil # will be something like a GraphViz::Types::EscString
      expect(item_attribs.fetch(k.to_s, '').to_s).to eq("\"#{v}\"") #('"Courier New"')
    end

  end

end


RSpec.shared_examples 'have graph attributes = given config' do |item, options={}|

  item_attribs = item.each_attribute { |a| a }

  options.each do |k, v|

    # GraphViz returns the keys as strings

    it "graph #{k.to_s}" do

      expect(item_attribs.fetch(k.to_s, nil)).not_to be_nil # will be something like a GraphViz::Types::EscString
      expect(item_attribs.fetch(k.to_s, '').to_s).to eq("\"#{v}\"") #('"Courier New"')

    end

  end

end


RSpec.shared_examples 'raise error' do |desc, error, options|
  it desc do
    expect { AASM_StateChart::AASM_StateCharts.new(options).run }.to raise_error(error)
  end
end


RSpec.shared_examples 'not raise an error' do |desc, options|
  it desc do
    expect { AASM_StateChart::AASM_StateCharts.new(options).run }.not_to raise_error
  end
end

