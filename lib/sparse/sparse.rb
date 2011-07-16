class Sparse
  def parse(text)
    @scanner = StringScanner.new(text)
    @line = 1
    @column = 1

    result = []
    until @scanner.eos?
      case
        when whitespace || comment
          # do nothing
        when open_parenthesis
          result << strip
        when quote
          result << :quote
          unless open_parenthesis
            blowup 'Expected list'
          end
          @scanner.unscan
        else
          blowup
      end

    end

    result

  end

  private
  def blowup(message = "Unexpected token #{@scanner.rest}")
    raise SyntaxError.new "#{message} in position #{@scanner.pos + 1}, line #{@line}, column #{@scanner.pos - @column + 1}"
  end

  def strip
    current = []
    until close_parenthesis
      start_rest = @scanner.rest



      case
        when whitespace || comment
          # do nothing
        when open_parenthesis
          current << strip
        when quote
          current << :quote
          unless open_parenthesis || symbol || number # || string
            blowup 'Expected a list, symbol or number'
          end
          @scanner.unscan
        when symbol
          sym = @scanner.matched
          current << (sym == '- ' ? '-' : sym).to_sym
        when number
          current << eval(@scanner.matched)
      end

      if start_rest == @scanner.rest
        blowup 'Unbalanced brackets'

      end

    end

    current
  end

  # singular: parenthesis
  # plural  : parentheses 
  def open_parenthesis
    @scanner.scan(/[(]/)
  end

  def close_parenthesis
    @scanner.scan(/[)]/)
  end

  def whitespace
    ret = @scanner.scan(/[ \t\n\r]/)
    if ret == "\n"
      @line += 1
      @column = @scanner.pos
    end

    ret
  end

  def quote
    @scanner.scan(/[']/)
  end

  def symbol
    @scanner.scan(/([-][^0-9]|[+*\/]|[a-zA-Z\$][a-zA-Z0-9\-\$]*)/)
  end

  def number
    @scanner.scan(/[-]?[0-9]+([.][0-9]+)?/)
  end

  def comment
    @scanner.scan(/^;.*$/)
  end

end
