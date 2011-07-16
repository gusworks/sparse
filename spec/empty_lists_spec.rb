require 'spec_helper'

describe Sparse do
  context "An empty list" do
    before :each do
      @parser = Sparse.new
    end

    it 'should work with an empty string' do
      @parser.parse('').should be_empty
    end

    it 'could start with a parenthesis' do
      @parser.parse('()').should == [[]]
    end

    it 'could start with a parenthesis and contains a space' do
      @parser.parse('( )').should == [[]]
    end

    it 'could start with tab and contains space' do
      @parser.parse("\t( )").should == [[]]
    end

    it 'could start with space and contains space' do
      @parser.parse(" ( )").should == [[]]
    end

    it 'could start with linebreak and contains space' do
      @parser.parse(<<lisp

( )

lisp
      ).should == [[]]
    end

  end

end
