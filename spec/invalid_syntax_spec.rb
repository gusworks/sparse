require 'spec_helper'

describe Sparse do
  context 'Is an invalid syntax when it' do
    before :each do
      @parser = Sparse.new
    end

    it 'starts with a number' do
      lambda {@parser.parse '9'}.should raise_error SyntaxError
    end

    it 'starts with two quotes' do
      lambda {@parser.parse "''()"}.should raise_error SyntaxError
    end

    it 'has only a quote' do
      lambda {@parser.parse "'"}.should raise_error SyntaxError
    end

    it 'has one open bracket and zero close brackets' do
      lambda {@parser.parse "("}.should raise_error SyntaxError
    end

    it 'only close brackets' do
      lambda {@parser.parse ')'}.should raise_error SyntaxError
    end

    it 'has unbalanced number of open and close brackets' do
      lambda {@parser.parse '(()'}.should raise_error SyntaxError
    end

  end
end
