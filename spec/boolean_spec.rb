require 'spec_helper'

describe Sparse do
  context 'Boolean values' do
    before :each do
      @parser = Sparse.new
    end

    it 'true should be true' do
      @parser.parse('(true)').should == [[:true]]
    end

    it 'false should be false' do
      @parser.parse('(false)').should == [[:false]]
    end

  end

end
