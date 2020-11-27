require 'yaml'

module DeSu2
  DATA = File.open('data.yml', 'r') { |f| YAML.load(f) }
  
  class CompendiumDemon
    # Offset 0x00, len 2
    attr_accessor :unk1
    # Offset 0x02, len 2
    attr_accessor :demon_id
    # Offset 0x04, len 1
    attr_accessor :registered
    # Offset 0x05, len 1
    attr_accessor :level
    # Offset 0x06, len 2
    attr_accessor :unk3
    # Offset 0x08, len 2
    attr_accessor :exp
    # Offset 0x0A, len 1
    attr_accessor :strength
    # Offset 0x0B, len 1
    attr_accessor :magic
    # Offset 0x0C, len 1
    attr_accessor :vitality
    # Offset 0x0D, len 1
    attr_accessor :agility
    # Offset 0x0E, len 2
    attr_accessor :hp
    # Offset 0x10, len 2
    attr_accessor :mp
    # Offset 0x12, len 1
    attr_accessor :skill1
    # Offset 0x13, len 1
    attr_accessor :skill2
    # Offset 0x14, len 1
    attr_accessor :skill3
    # Offset 0x15, len 1
    attr_accessor :passive1
    # Offset 0x16, len 1
    attr_accessor :passive2
    # Offset 0x17, len 1
    attr_accessor :passive3
    # Offset 0x18, len 1
    attr_accessor :racial
    # Offset 0x19, len 7
    attr_accessor :padding
    
    def initialize(file)
      @unk1 = file.read(2).unpack('S<').first
      @demon_id = file.read(2).unpack('S<').first
      if DATA[:demons][@demon_id]
        @demon_id = DATA[:demons][@demon_id]
      end
      @registered = (file.read(1).unpack('C').first == 0xFF)
      @level = file.read(1).unpack('C').first
      @unk3 = file.read(2).unpack('S<').first
      @exp = file.read(2).unpack('S<').first
      @strength = file.read(1).unpack('C').first
      @magic = file.read(1).unpack('C').first
      @vitality = file.read(1).unpack('C').first
      @agility = file.read(1).unpack('C').first
      @hp = file.read(2).unpack('S<').first
      @mp = file.read(2).unpack('S<').first
      @skill1 = DATA[:skills][file.read(1).unpack('C').first]
      @skill2 = DATA[:skills][file.read(1).unpack('C').first]
      @skill3 = DATA[:skills][file.read(1).unpack('C').first]
      @passive1 = DATA[:passives][file.read(1).unpack('C').first]
      @passive2 = DATA[:passives][file.read(1).unpack('C').first]
      @passive3 = DATA[:passives][file.read(1).unpack('C').first]
      @racial = file.read(1).unpack('C').first
      if DATA[:racials][@racial]
        @racial = DATA[:racials][@racial]
      end
      file.read(7)
    end
    
    def write(file)
      i = @demon_id.is_a?(String) ? DATA[:demons].invert[@demon_id] : @demon_id
      r = @racial.is_a?(String) ? DATA[:racials].invert[@racial] : @racial
      reg = @registered ? 0xFF : 0x00
      file.write([@unk1, i, reg].pack('L<S<C'))
      file.write([@level, @unk3, @exp].pack('CS<S<'))
      file.write([@strength, @magic, @vitality, @agility].pack('CCCC'))
      file.write([@hp, @mp].pack('S<S<'))
      file.write([DATA[:skills].index(@skill1),
                  DATA[:skills].index(@skill2),
                  DATA[:skills].index(@skill3)].pack('CCC'))
      file.write([DATA[:passives].index(@passive1),
                  DATA[:passives].index(@passive2),
                  DATA[:passives].index(@passive3)].pack('CCC'))
      file.write([r].pack('C'))
      file.seek(7, IO::SEEK_CUR)
    end
  end
  
  class SummonedDemon
    # Offset 0x00, len 4
    attr_accessor :unk1
    # Offset 0x04, len 2
    attr_accessor :unk2
    # Offset 0x06, len 2
    attr_accessor :demon_id
    # Offset 0x08, len 1
    attr_accessor :unk4
    # Offset 0x09, len 1
    attr_accessor :level
    # Offset 0x0A, len 2
    attr_accessor :unk5
    # Offset 0x0C, len 2
    attr_accessor :exp
    # Offset 0x0E, len 1
    attr_accessor :strength
    # Offset 0x0F, len 1
    attr_accessor :magic
    # Offset 0x10, len 1
    attr_accessor :vitality
    # Offset 0x11, len 1
    attr_accessor :agility
    # Offset 0x12, len 2
    attr_accessor :hp
    # Offset 0x13, len 2
    attr_accessor :mp
    # Offset 0x16, len 1
    attr_accessor :skill1
    # Offset 0x17, len 1
    attr_accessor :skill2
    # Offset 0x18, len 1
    attr_accessor :skill3
    # Offset 0x19, len 1
    attr_accessor :passive1
    # Offset 0x1A, len 1
    attr_accessor :passive2
    # Offset 0x1B, len 1
    attr_accessor :passive3
    # Offset 0x1C, len 1
    attr_accessor :racial
    # Offset 0x1D, len 1
    attr_accessor :unk6
    # Offset 0x1E, len 1
    attr_accessor :unk7
    # Offset 0x1F, len 1
    attr_accessor :unk8
    
    def initialize(file)
      @unk1 = file.read(4).unpack('L<').first
      @unk2 = file.read(2).unpack('S<').first
      @demon_id = file.read(2).unpack('S<').first
      if DATA[:demons][@demon_id]
        @demon_id = DATA[:demons][@demon_id]
      end
      @unk4 = file.read(1).unpack('C').first
      @level = file.read(1).unpack('C').first
      @unk5 = file.read(2).unpack('S<').first
      @exp = file.read(2).unpack('S<').first
      @strength = file.read(1).unpack('C').first
      @magic = file.read(1).unpack('C').first
      @vitality = file.read(1).unpack('C').first
      @agility = file.read(1).unpack('C').first
      @hp = file.read(2).unpack('S<').first
      @mp = file.read(2).unpack('S<').first
      @skill1 = DATA[:skills][file.read(1).unpack('C').first]
      @skill2 = DATA[:skills][file.read(1).unpack('C').first]
      @skill3 = DATA[:skills][file.read(1).unpack('C').first]
      @passive1 = DATA[:passives][file.read(1).unpack('C').first]
      @passive2 = DATA[:passives][file.read(1).unpack('C').first]
      @passive3 = DATA[:passives][file.read(1).unpack('C').first]
      @racial = file.read(1).unpack('C').first
      if DATA[:racials][@racial]
        @racial = DATA[:racials][@racial]
      end
      @unk6 = file.read(1).unpack('C').first
      @unk7 = file.read(1).unpack('C').first
      @unk8 = file.read(1).unpack('C').first
    end
    
    def write(file)
      i = @demon_id.is_a?(String) ? DATA[:demons].invert[@demon_id] : @demon_id
      r = @racial.is_a?(String) ? DATA[:racials].invert[@racial] : @racial
      file.write([@unk1, @unk2, i, @unk4].pack('L<S<S<C'))
      file.write([@level, @unk5, @exp].pack('CS<S<'))
      file.write([@strength, @magic, @vitality, @agility].pack('CCCC'))
      file.write([@hp, @mp].pack('S<S<'))
      file.write([DATA[:skills].index(@skill1),
                  DATA[:skills].index(@skill2),
                  DATA[:skills].index(@skill3)].pack('CCC'))
      file.write([DATA[:passives].index(@passive1),
                  DATA[:passives].index(@passive2),
                  DATA[:passives].index(@passive3)].pack('CCC'))
      file.write([r, @unk6, @unk7, @unk8].pack('CCCC'))
    end
  end
  
  class Save
    # Offset 0x2B0, len 32, 27 cnt
    attr_accessor :demons
    # Offset 0x6C4, len 4
    attr_accessor :money
    # Offset 0xA2C, len 6, 14 cnt
    attr_accessor :fate
    # Offset 0xCF0, len 32, ? cnt
    attr_accessor :compendium
    
    def initialize(file)
      file.read(0x2B0)
      @demons = []
      27.times { @demons << SummonedDemon.new(file) }
      file.read(0xB4)
      @money = file.read(4).unpack('L<').first
      @fate = []
      file.read(0x364)
      14.times { @fate << file.read(6).unpack('C*'); file.read(10) }
      @compendium = []
      file.read(0x1E4)
      while (file.seek(2, IO::SEEK_CUR) && file.read(2).unpack('S<').first != 0)
        file.seek(-4, IO::SEEK_CUR)
        @compendium << CompendiumDemon.new(file)
      end
    end
    
    def write(file)
      file.seek(0x6C4, IO::SEEK_SET)
      file.write([@money].pack('L<'))
      file.seek(0x2B0)
      @demons.each { |d| d.write(file) }
      file.seek(0xA2C)
      @fate.each { |f| file.write(f.pack('C*')); file.seek(10, IO::SEEK_CUR) }
    end
  end
end

case ARGV[0]
when '-x'
  File.open(ARGV[1], 'rb') do |f|
    save = DeSu2::Save.new(f)
    File.open("#{ARGV[1]}.yml", 'w+') { |f2| f2.write(YAML.dump(save)) }
  end
when '-c'
  save = File.open(ARGV[1], 'r') { |f| YAML.load(f) }
  File.open(ARGV[2], 'r+b') { |f| save.write(f) }
end
