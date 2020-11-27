require 'yaml'

class TbbFile
  attr_accessor :filter
  attr_reader :size
  attr_reader :tables
  
  HEADER ||= [0x54, 0x42, 0x42, 0x31].pack('C*').freeze
  
  def initialize(binary, filter = nil)
    if binary.is_a?(String)
      binary = File.open(binary, 'rb') { |f| f.each_byte.to_a }
    end
    binary.shift(4)
    header_size = binary.shift(4).pack('C*').unpack('L<').first
    @size = binary.shift(4).pack('C*').unpack('L<').first
    rem_size = (16 - ((header_size + (@size * 4)) % 16))
    binary.shift(4)
    offsets = []
    @size.times { offsets << binary.shift(4).pack('C*').unpack('L<').first }
    binary.shift(rem_size)
    @tables = []
    @size.times { @tables << TbbTable.new(binary) }
    @filter = filter
    @filter.setup(self) if @filter
  end
  
  def method_missing(sym, *args, &block)
    if filter.respond_to?(sym)
      filter.send(sym, self, *args, &block)
    else
      super(sym, *args, &block)
    end
  end
  
  def to_s
    @filter.respond_to?(:to_string) ? @filter.to_string(self) : super
  end
  
  def header_size
    header = 16 + (@size * 4)
    if (extra = header % 16) > 0
      header += (16 - extra)
    end
    header
  end
  
  def header_padding_size
    pad = 0
    if (extra = (16 + (@size * 4)) % 16) > 0
      pad = 16 - extra
    end
    pad
  end
  
  def write(file)
    opened = false
    if file.is_a?(String)
      file = File.open(file, 'w+b')
      opened = true
    end
    tables = []
    @tables.each { |t| tables.concat(t.get_bytes) }
    file.write(HEADER)
    h_size = header_size
    file_size = h_size + tables.size
    file.write([0x10, @size, file_size].pack('L<*'))
    if @size > 1
      @tables.each_with_index do |tbl,i|
        s = h_size + (0...i).inject(0) { |v,t| v + 16 + @tables[t].byte_size }
        file.write([s].pack('L<'))
      end
    end
    file.write(([0] * header_padding_size).pack('C*'))
    file.write(tables.pack('C*'))
    file.close if opened
  end
end

class TbbTable
  attr_accessor :filter
  attr_reader :item_size
  attr_reader :data
  attr_reader :unknown_val
  
  HEADER ||= [0x54, 0x42, 0x4C, 0x31].pack('C*').freeze
  
  def initialize(binary, filter = nil)
    @filter = filter
    binary.shift(4)
    @unknown_val = binary.shift(4).pack('C*').unpack('L<').first
    size = binary.shift(4).pack('C*').unpack('L<').first
    @item_size = binary.shift(4).pack('C*').unpack('L<').first
    data = binary.shift(size)
    if (extra = size % 16) > 0
      binary.shift(16 - extra)
    end
    @data = []
    @data << data.shift(@item_size) until data.empty?
  end
  
  def method_missing(sym, *args, &block)
    if filter.respond_to?(sym)
      filter.send(sym, self, *args, &block)
    else
      super(sym, *args, &block)
    end
  end
  
  def byte_size
    bs = @data.flatten.size
    if (extra = bs % 16) > 0
      bs += (16 - extra)
    end
    bs
  end
  
  def size
    @data.size
  end
  
  def to_s
    @filter.respond_to?(:to_string) ? @filter.to_string(self) : super
  end
  
  def get_bytes
    bytes = []
    bytes.concat(HEADER.unpack('C*'))
    bytes.concat([@unknown_val, @data.size * @item_size, @item_size].pack('L<*').unpack('C*'))
    bytes.concat(@data.flatten)
    if (extra = @data.flatten.size % 16) > 0
      bytes.concat(([0] * (16 - extra)))
    end
    bytes
  end
  
  def write(file)
    opened = false
    if file.is_a?(String)
      file = File.open(file, 'w+b')
      opened = true
    end
    file.write(HEADER)
    file.write([@unknown_val, @data.size * @item_size, @item_size].pack('L<*'))
    file.write(@data.flatten.pack('C*'))
    if (extra = @data.flatten.size % 16) > 0
      file.write(([0] * (16 - extra)).pack('C*'))
    end
    file.close if opened
  end
end

class TbbFileFilter
  
  def initialize(options = {})
    @opt = options
  end
  
  def setup(file)
  end
end

class TbbTableFilter
  include Enumerable
  
  def initialize(options = {})
    @opt = options
  end
  
  def each(table, &block)
    table.data.each { |d| yield d }
  end
end

def to_hex_str(dat)
  dat = dat.collect { |b| ("%02x " % b).upcase }
  str = ''
  dat.each_with_index { |b,i| str << b; str << "\n" if (i + 1) % 16 == 0 }
  str
end

def to_hex_tbl(dat)
  dat = dat.collect { |b| ("%02x " % b).upcase }
  str = "|----------|-------------------------------------------------|\n"
  str << "|          | 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F |\n"
  str << "|----------|-------------------------------------------------|\n"
  dat.each_with_index do |b,i|
    str << "| #{"%07x" % (i / 16)}0 | ".upcase if i % 16 == 0
    str << b
    str << "|\n" if (i + 1) % 16 == 0
  end
  if (rem = dat.size % 16) != 0
    str << ('   ' * (16 - rem))
    str << "|\n"
  end
  str << "|----------|-------------------------------------------------|"
  str
end
