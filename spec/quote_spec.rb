require 'spec_helper'

describe Sparse do
  context 'Quotes' do
    before :each do
      @parser = Sparse.new
    end

    it 'should be before a first level list' do
      @parser.parse("'()").should == [:quote, []]      
    end

    it 'should be before a first level list, in any position' do
      @parser.parse("()'()").should == [[], :quote, []]      
    end

    it 'should be before a nested list' do
      @parser.parse("('())").should == [[:quote, []]]
    end

    it 'should be before symbols' do
      @parser.parse("('a 'b 'c)").should == [[:quote, :a, :quote, :b, :quote, :c]]
    end

    it 'should be before symbols with more than one character' do
      @parser.parse("('abc 'def 'ghi)").should == [[:quote, :abc, :quote, :def, :quote, :ghi]]
    end

    it 'should be before numbers' do
      @parser.parse("('1 '2 '3)").should == [[:quote, 1, :quote, 2, :quote, 3]]
    end

    it 'should be before negative numbers' do
      @parser.parse("('-1 '-2 '-3)").should == [[:quote, -1, :quote, -2, :quote, -3]]
    end

    it 'should be before positive and negative decimal numbers' do
      @parser.parse("('-1.1 '2.2 '3.14159)").should == [[:quote, -1.1, :quote, 2.2, :quote, 3.14159]]
    end

    it 'should be before nested lists' do
      @parser.parse("(1 2 '(foo))").should == [[1, 2, :quote, [:foo]]]
    end

  end
end
