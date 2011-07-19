require 'spec_helper'

describe Sparse do
  context 'Boolean values' do
    before :each do
      @parser = Sparse.new
    end

    it 'String should return as strings. duh.' do
      @parser.parse('("mimimi")').should == [['mimimi']]
    end
  end
end
