require 'docx'
require 'pry'

FILE_PATH = ''

class DocParser
  LISTING_REGEX = 'Listing (\d).(\d)'
  CODE_END = '^(\s\d{1,4}|\d{1,4})'

  def initialize(path)
    @doc = Docx::Document.open(path)
    @name = "7"
    @code_blocks = []
  end

  def listing_start?(paragraph)
    paragraph.text.match(/#{LISTING_REGEX}/)
  end

  # Use gsub! here which either returns nil or the substituted string to skip a regex step
  def code_text?(paragraph)
    paragraph.text.gsub!(/#{CODE_END}/, '')
  end

  def parse!
    capture = false
    @doc.paragraphs.each do |p|
      is_start = listing_start? p

      if is_start
        @code_blocks.push("# #{p.text}")
        capture = true
        next
      end

      code_text = code_text?(p)
      if code_text && capture
        @code_blocks.push code_text
      else
        capture = false
      end
    end
    check!
  end

  def check!
    File.open("#{@name}.rb", 'w') do |f|
      f.write(@code_blocks.join("\n"))
    end
    puts `ruby -c #{@name}.rb`
    `rm ./#{@name}.rb`
  end
end

DocParser.new(FILE_PATH).parse_and_check!

