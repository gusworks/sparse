require 'spec_helper'

describe Sparse do
  context 'Special use of lists' do
    before :each do
      @parser = Sparse.new
    end

    it 'like nested lists should just work' do
      @parser.parse('(())').should == [[[]]]
    end

    it 'like sister lists should just work too' do
      @parser.parse('()()').should == [[], []]
    end

    it 'like nested sister lists should just work also' do
      @parser.parse('(()())').should == [[[], []]]
    end

  end
end
