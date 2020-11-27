module BinaryBlock
  BINARY_STRING_FILTER = [proc { |b| '%08b' % b },
                          proc { |s| s.to_i(2)  }]
  
  LOOKUP = {
    u8:   Hash.new { |h,k| h[k] = ('C' * k).freeze },
    s8:   Hash.new { |h,k| h[k] = ('c' * k).freeze },
    u16:  Hash.new { |h,k| h[k] = ('S<' * k).freeze },
    s16:  Hash.new { |h,k| h[k] = ('s<' * k).freeze },
    u32:  Hash.new { |h,k| h[k] = ('L<' * k).freeze },
    s32:  Hash.new { |h,k| h[k] = ('l<' * k).freeze },
  }
  
  def u8(name, size = 1, filter = nil)
    attr_accessor name
    (@__block_data ||= []) << [name, :u8, filter, size]
    @__defined_block_size ||= 0
    @__defined_block_size += size
  end
  
  def s8(name, size = 1, filter = nil)
    attr_accessor name
    (@__block_data ||= []) << [name, :s8, filter, size]
    @__defined_block_size ||= 0
    @__defined_block_size += size
  end
  
  def u16(name, size = 1, filter = nil)
    attr_accessor name
    (@__block_data ||= []) << [name, :u16, filter, size]
    @__defined_block_size ||= 0
    @__defined_block_size += (2 * size)
  end
  
  def u16b(name, size = 1, filter = nil)
    attr_accessor name
    (@__block_data ||= []) << [name, :u16b, filter, size]
    @__defined_block_size ||= 0
    @__defined_block_size += (2 * size)
  end
  
  def s16(name, size = 1, filter = nil)
    attr_accessor name
    (@__block_data ||= []) << [name, :s16, filter, size]
    @__defined_block_size ||= 0
    @__defined_block_size += (2 * size)
  end
  
  def u32(name, size = 1, filter = nil)
    attr_accessor name
    (@__block_data ||= []) << [name, :u32, filter, size]
    @__defined_block_size ||= 0
    @__defined_block_size += (4 * size)
  end
  
  def s32(name, size = 1, filter = nil)
    attr_accessor name
    (@__block_data ||= []) << [name, :s32, filter, size]
    @__defined_block_size ||= 0
    @__defined_block_size += (4 * size)
  end
  
  def block_size(size)
    @__block_size = size
  end
  
  def read_block(block, file)
    return unless @__block_data || @__block_size
    @__defined_block_size ||= 0
    (@__block_data ||= []).each do |b|
      value = case b[1]
      when :u8
        if b[3] == 1
          file.readbyte
        else
          file.read(b[3]).unpack(LOOKUP[:u8][b[3]])
        end
      when :s8
        if b[3] == 1
          file.read(1).unpack(LOOKUP[:s8][1]).first
        else
          file.read(b[3]).unpack(LOOKUP[:s8][b[3]])
        end
      when :u16
        if b[3] == 1
          file.read(2).unpack(LOOKUP[:u16][1]).first
        else
          file.read(b[3] * 2).unpack(LOOKUP[:u16][b[3]])
        end
      when :s16
        if b[3] == 1
          file.read(2).unpack(LOOKUP[:s16][1]).first
        else
          file.read(b[3] * 2).unpack(LOOKUP[:s16][b[3]])
        end
      when :u32
        if b[3] == 1
          file.read(4).unpack(LOOKUP[:u32][1]).first
        else
          file.read(b[3] * 4).unpack(LOOKUP[:u32][b[3]])
        end
      when :s32
        if b[3] == 1
          file.read(4).unpack(LOOKUP[:s32][1]).first
        else
          file.read(b[3] * 4).unpack(LOOKUP[:s32][b[3]])
        end
      end
      value = b[2][0].call(value) if b[2]
      block.send(:"#{b[0]}=", value)
    end
    if (rem = (@__block_size - @__defined_block_size)) > 0
      rem = file.read(rem).unpack('C*')
      block.instance_variable_set('@__remainder', rem)
    end
  end
  
  def write_block(block, file)
    return unless @__block_data
    values = []
    pack = []
    @__block_data.each do |b|
      value = block.send(b[0])
      value = b[2][1].call(value) if b[2]
      values << value
      p = LOOKUP[b[1]][b[3]]
      pack << p
    end
    file.write(values.flatten.pack(pack.join))
    if (rem = block.instance_variable_get(:@__remainder))
      file.write(rem.pack('C*'))
    end
  end
end
