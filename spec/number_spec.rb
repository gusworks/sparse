require 'spec_helper'

describe Sparse do
  context 'Boolean values' do
    before :each do
      @parser = Sparse.new
    end

    it 'should return a integer' do
      @parser.parse('(1)').should == [[1]]
    end

    it 'should return a decimal' do
      @parser.parse('(1.1)').should == [[1.1]]
    end

  end
end
