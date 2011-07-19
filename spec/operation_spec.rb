require 'spec_helper'

describe Sparse do
  context 'Operation' do
    before :each do
      @parser = Sparse.new
    end

    it 'simple addition' do
      @parser.parse('(+ 1 1)').should == [[:+, 1, 1]]
    end

    it 'empty addition' do
      @parser.parse('(+)').should == [[:+]]
    end
  end
end
