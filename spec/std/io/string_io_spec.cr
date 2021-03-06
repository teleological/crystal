require "spec"

describe "StringIO" do
  it "appends a char" do
    str = String.build do |io|
      io << 'a'
    end
    str.should eq("a")
  end

  it "appends a string" do
    str = String.build do |io|
      io << "hello"
    end
    str.should eq("hello")
  end

  it "writes to a buffer with count" do
    str = String.build do |io|
      io.write Slice.new("hello".cstr, 3)
    end
    str.should eq("hel")
  end

  it "appends a byte" do
    str = String.build do |io|
      io.write_byte 'a'.ord.to_u8
    end
    str.should eq("a")
  end

  it "appends to another buffer" do
    s1 = StringIO.new
    s1 << "hello"

    s2 = StringIO.new
    s1.to_s(s2)
    s2.to_s.should eq("hello")
  end

  it "writes" do
    io = StringIO.new
    io << "foo" << "bar"
    io.to_s.should eq("foobar")
  end

  it "puts" do
    io = StringIO.new
    io.puts "foo"
    io.to_s.should eq("foo\n")

    io = StringIO.new
    io.puts
    io.to_s.should eq("\n")
  end

  it "puts several arguments" do
    io = StringIO.new
    io.puts(1, "aaa", "\n")
    lines = io.each_line

    lines.next.should eq("1\n")
    lines.next.should eq("aaa\n")
    lines.next.should eq("\n")
    lines.next.should be_a(Iterator::Stop)
  end

  it "print" do
    io = StringIO.new
    io.print "foo"
    io.to_s.should eq("foo")
  end

  it "prints several arguments" do
    io = StringIO.new
    io.print "foo", "bar", "baz"
    io.to_s.should eq("foobarbaz")
  end

  it "reads single line content" do
    io = StringIO.new("foo")
    io.gets.should eq("foo")
  end

  it "reads each line" do
    io = StringIO.new("foo\r\nbar\r\n")
    io.gets.should eq("foo\r\n")
    io.gets.should eq("bar\r\n")
    io.gets.should eq(nil)
  end

  it "gets with char as delimiter" do
    io = StringIO.new("hello world")
    io.gets('w').should eq("hello w")
    io.gets('r').should eq("or")
    io.gets('r').should eq("ld")
    io.gets('r').should eq(nil)
  end

  it "gets with string as delimiter" do
    io = StringIO.new("hello world")
    io.gets("lo").should eq("hello")
    io.gets("rl").should eq(" worl")
    io.gets("foo").should eq("d")
  end

  it "gets with empty string as delimiter" do
    io = StringIO.new("hello\nworld\n")
    io.gets("").should eq("hello\nworld\n")
  end

  it "gets with single byte string as delimiter" do
    io = StringIO.new("hello\nworld\nbye")
    io.gets("\n").should eq("hello\n")
    io.gets("\n").should eq("world\n")
    io.gets("\n").should eq("bye")
  end

  it "reads all remaining content" do
    io = StringIO.new("foo\nbar\nbaz\n")
    io.gets.should eq("foo\n")
    io.read.should eq("bar\nbaz\n")
  end

  it "reads utf-8 string" do
    io = StringIO.new("há日本語")
    io.gets.should eq("há日本語")
  end

  it "reads N chars" do
    io = StringIO.new("foobarbaz")
    io.read(3).should eq("foo")
    io.read(50).should eq("barbaz")
  end

  it "write single byte" do
    io = StringIO.new
    io.write_byte 97_u8
    io.to_s.should eq("a")
  end

  it "writes and reads" do
    io = StringIO.new
    io << "foo" << "bar"
    io.gets.should eq("foobar")
  end

  it "read chars from UTF-8 string" do
    io = StringIO.new("há日本語")
    io.read_char.should eq('h')
    io.read_char.should eq('á')
    io.read_char.should eq('日')
    io.read_char.should eq('本')
    io.read_char.should eq('語')
    io.read_char.should eq(nil)
  end

  it "does each_line" do
    io = StringIO.new("a\nbb\ncc")
    counter = 0
    io.each_line do |line|
      case counter
      when 0
        line.should eq("a\n")
      when 1
        line.should eq("bb\n")
      when 2
        line.should eq("cc")
      end
      counter += 1
    end
    counter.should eq(3)
  end

  it "writes an array of bytes" do
    str = String.build do |io|
      bytes = ['a'.ord.to_u8, 'b'.ord.to_u8]
      io.write bytes
    end
    str.should eq("ab")
  end

  it "raises on EOF with read_line" do
    str = StringIO.new("hello")
    str.read_line.should eq("hello")

    expect_raises IO::EOFError, "end of file reached" do
      str.read_line
    end
  end

  it "raises on EOF with readline and delimiter" do
    str = StringIO.new("hello")
    str.read_line('e').should eq("he")
    str.read_line('e').should eq("llo")

    expect_raises IO::EOFError, "end of file reached" do
      str.read_line
    end
  end

  it "writes with printf" do
    str = StringIO.new
    str.printf "Hello %d", 123
    str.to_s.should eq("Hello 123")
  end

  it "writes with printf as an array" do
    str = StringIO.new
    str.printf "Hello %d", [123]
    str.to_s.should eq("Hello 123")
  end
end
