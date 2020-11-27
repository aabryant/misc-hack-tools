require 'nkf'

module SJIS
  CONVERT = ['０-９ａ-ｚＡ-Ｚ’　−', '0-9a-zA-Z\' -']
    
  def self.full_to_half(string)
    NKF.nkf('-X -w', string).tr(CONVERT[0], CONVERT[1])
  end
  
  def self.half_to_full(string)
    NKF.nkf('-X -w', string).tr(CONVERT[1], CONVERT[0]).encode('shift_jis')
  end
end

class NameTable
  attr_accessor :names
  
  def initialize(file)
    if file.is_a?(IO)
      read_from_file(file)
    elsif file.is_a?(String)
      File.open(file, 'rb') { |f| read_from_file(f) }
    elsif file.is_a?(Array)
      @names = file
    end
  end
  
  def read_from_file(file)
    count = file.read(2).unpack('S<').first
    lens = file.read(count * 2).unpack('S<*')
    @names = Array.new(count) do |i|
      len = (i == 0 ? lens[i] : lens[i] - lens[i - 1]) - 1
      name = SJIS.full_to_half(file.read(len).force_encoding('sjis'))
      file.readbyte unless file.eof?
      name.encode('utf-8')
    end
  end
  
  def write(file)
    names = @names.collect { |n| SJIS.half_to_full(n).bytes << 0 }
    file.write([@names.size].pack('S<'))
    lens = Array.new(names.size) { 0 }
    names.each_with_index { |n,i| lens[i] = n.size + lens[i - 1] }
    file.write(lens.pack('S<*'))
    file.write(names.flatten.pack('C*'))
  end
  
  def size
    @names.size
  end
  
  def each(&block)
    @names.each(&block)
  end
  
  def [](idx)
    @names[idx]
  end
end
