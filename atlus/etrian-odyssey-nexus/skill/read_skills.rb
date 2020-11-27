require 'yaml'
require '../nametbl'
require '../binaryblock'

class Skill
  SUBH = Hash.new { |h,k| h[k] = '%04X' % k }
  SUBH.merge!(File.open('subh.yml') { |f| YAML.load(f) })
  SUBH_LOOKUP = Hash.new { |h,k| h[k] = k.to_i(16) }
  SUBH_LOOKUP.merge!(SUBH.invert)
  
  BUFF_T = Hash.new { |h,k| h[k] = '%02X' % k }
  BUFF_T.merge!({
    0 => 'None',
    1 => 'Buff',
    2 => 'Debuff'
  })
  BUFF_T_LOOKUP = Hash.new { |h,k| h[k] = k.to_i(16) }
  BUFF_T_LOOKUP.merge!(BUFF_T.invert)
  
  BUFF = Hash.new { |h,k| h[k] = '%02X' % k }
  BUFF.merge!({
    0x0000 => 'None',
    0x0003 => 'Attack',
    0x0006 => 'Defense',
    0x0009 => 'Regeneration',
    0x000C => 'Ailment Protection',
    0x001C => 'Element Damage Up + Imbue',
    0x001E => 'Max HP',
    0x070D => 'Recover x% of the damage taken this turn',
  })
  BUFF_LOOKUP = Hash.new { |h,k| h[k] = k.to_i(16) }
  BUFF_LOOKUP.merge!(BUFF.invert)
  
  BINARY_STRING_FILTER = [proc { |b| '%08b' % b }, proc { |s| s.to_i(2)  }]
  
  class << self; include BinaryBlock; end
  attr_accessor :name
  attr_accessor :id
  block_size 612
  u8  :max_level
  u16 :type
  u8  :zero0
  u8  :req1, 1, [
    proc do |b|
      hash = {}
      hash[:head]   = (b & 1) == 1
      hash[:arms]   = (b & 2) == 2
      hash[:legs]   = (b & 4) == 4
      hash[:sword]  = (b & 8) == 8
      hash[:bow]    = (b & 16) == 16
      hash[:katana] = (b & 32) == 32
      hash[:staff]  = (b & 64) == 64
      hash[:gun]    = (b & 128) == 128
      hash
    end,
    proc do |hash|
      out = 0
      out |= 1   if hash[:head]
      out |= 2   if hash[:arms]
      out |= 4   if hash[:legs]
      out |= 8   if hash[:sword]
      out |= 16  if hash[:bow]
      out |= 32  if hash[:katana]
      out |= 64  if hash[:staff]
      out |= 128 if hash[:gun]
      out
    end
  ]
  u8  :req2, 1, [
    proc do |b|
      hash = {}
      hash[:spear]         = (b & 1) == 1
      hash[:rapier]        = (b & 2) == 2
      hash[:knife]         = (b & 4) == 4
      hash[:'drive blade'] = (b & 8) == 8
      hash[:cestus]        = (b & 16) == 16
      hash[:scythe]        = (b & 32) == 32
      hash[:unused]        = (b & 64) == 64
      hash[:shield]        = (b & 128) == 128
      hash
    end,
    proc do |hash|
      out = 0
      out |= 1   if hash[:spear]
      out |= 2   if hash[:rapier]
      out |= 4   if hash[:knife]
      out |= 8   if hash[:'drive blade']
      out |= 16  if hash[:cestus]
      out |= 32  if hash[:scythe]
      out |= 64  if hash[:unused]
      out |= 128 if hash[:shield]
      out
    end
  ]
  u16 :zero1
  u8  :target_req
  u8  :range
  u16 :zero2
  u16 :icon
  u16 :zero3
  u8  :aoe
  u8  :side
  u8  :usable, 1, [
    proc do |b|
      hash = {}
      hash[:town]    = (b & 1) == 1
      hash[:dungeon] = (b & 2) == 2
      hash[:battle]  = (b & 4) == 4
      hash
    end,
    proc do |hash|
      out = 0
      out |= 1   if hash[:town]
      out |= 2   if hash[:dungeon]
      out |= 4   if hash[:battle]
      out
    end
  ]
  u8  :buff_t1, 1, [ proc { |b| BUFF_T[b] }, proc { |s| BUFF_T_LOOKUP[s] } ]
  u8  :buff_t2, 1, [ proc { |b| BUFF[b] }, proc { |s| BUFF_LOOKUP[s] } ]
  u8  :zero4
  u8  :buff_element1, 1, [
    proc do |b|
      hash = {}
      hash[:slash]   = (b & 1) == 1
      hash[:crush]   = (b & 2) == 2
      hash[:pierce]   = (b & 4) == 4
      hash[:fire]  = (b & 8) == 8
      hash[:ice]    = (b & 16) == 16
      hash[:volt] = (b & 32) == 32
      hash[:almighty]  = (b & 64) == 64
      hash[:ele8]    = (b & 128) == 128
      hash
    end,
    proc do |hash|
      out = 0
      out |= 1   if hash[:slash]
      out |= 2   if hash[:crush]
      out |= 4   if hash[:pierce]
      out |= 8   if hash[:fire]
      out |= 16  if hash[:ice]
      out |= 32  if hash[:volt]
      out |= 64  if hash[:almighty]
      out |= 128 if hash[:ele8]
      out
    end
  ]
  u8  :buff_element2, 1, BINARY_STRING_FILTER
  u8  :dmg_type1, 1, [
    proc do |b|
      hash = {}
      hash[:slash]    = (b & 1) == 1
      hash[:crush]    = (b & 2) == 2
      hash[:pierce]   = (b & 4) == 4
      hash[:fire]     = (b & 8) == 8
      hash[:ice]      = (b & 16) == 16
      hash[:volt]     = (b & 32) == 32
      hash[:almighty] = (b & 64) == 64
      hash[:ele8]     = (b & 128) == 128
      hash
    end,
    proc do |hash|
      out = 0
      out |= 1   if hash[:slash]
      out |= 2   if hash[:crush]
      out |= 4   if hash[:pierce]
      out |= 8   if hash[:fire]
      out |= 16  if hash[:ice]
      out |= 32  if hash[:volt]
      out |= 64  if hash[:almighty]
      out |= 128 if hash[:ele8]
      out
    end
  ]
  u8  :dmg_type2, 1, [
                       proc do |b|
                         hash = {}
                         hash[:ele9]                          = (b & 1) == 1
                         hash[:ele10]                         = (b & 2) == 2
                         hash[:ele11]                         = (b & 4) == 4
                         hash[:ele12]                         = (b & 8) == 8
                         hash[:ele13]                         = (b & 16) == 16
                         hash[:ele14]                         = (b & 32) == 32
                         hash[:ele15]                         = (b & 64) == 64
                         hash[:'ignore row/arm bind penalty'] = (b & 128) == 128
                         hash
                       end,
                       proc do |hash|
                         out = 0
                         out |= 1   if hash[:ele9]
                         out |= 2   if hash[:ele10]
                         out |= 4   if hash[:ele11]
                         out |= 8   if hash[:ele12]
                         out |= 16  if hash[:ele13]
                         out |= 32  if hash[:ele14]
                         out |= 64  if hash[:ele15]
                         out |= 128 if hash[:'ignore row/arm bind penalty']
                         out
                       end
                     ]
  u16 :ail_t
  u8  :ail_e1, 1, [
                    proc do |b|
                      hash = {}
                      hash[:'instant death'] = (b & 1) == 1
                      hash[:petrification]   = (b & 2) == 2
                      hash[:sleep]           = (b & 4) == 4
                      hash[:panic]           = (b & 8) == 8
                      hash[:decay]           = (b & 16) == 16
                      hash[:poison]          = (b & 32) == 32
                      hash[:blind]           = (b & 64) == 64
                      hash[:curse]           = (b & 128) == 128
                      hash
                    end,
                    proc do |hash|
                      out = 0
                      out |= 1   if hash[:'instant death']
                      out |= 2   if hash[:petrification]
                      out |= 4   if hash[:sleep]
                      out |= 8   if hash[:panic]
                      out |= 16  if hash[:decay]
                      out |= 32  if hash[:poison]
                      out |= 64  if hash[:blind]
                      out |= 128 if hash[:curse]
                      out
                    end
                  ]
  u8  :ail_e2, 1, [
                    proc do |b|
                      hash = {}
                      hash[:paralysis]       = (b & 1) == 1
                      hash[:stun]            = (b & 2) == 2
                      hash[:'head bind']     = (b & 4) == 4
                      hash[:'arm bind']      = (b & 8) == 8
                      hash[:'leg bind']      = (b & 16) == 16
                      hash[:fear]            = (b & 32) == 32
                      hash[:unk_ail2]        = (b & 64) == 64
                      hash[:unk_ail3]        = (b & 128) == 128
                      hash
                    end,
                    proc do |hash|
                      out = 0
                      out |= 1   if hash[:paralysis]
                      out |= 2   if hash[:stun]
                      out |= 4   if hash[:'head bind']
                      out |= 8   if hash[:'arm bind']
                      out |= 16  if hash[:'leg bind']
                      out |= 32  if hash[:fear]
                      out |= 64  if hash[:unk_ail2]
                      out |= 128 if hash[:unk_ail3]
                      out
                    end
                  ]
  u16 :zero5
  u8  :flags1, 1, BINARY_STRING_FILTER
  u8  :flags2, 1, BINARY_STRING_FILTER
  u16 :unk0
  s32 :subheader1, 1, [ proc { |b| SUBH[b] }, proc { |s| SUBH_LOOKUP[s] } ]
  s32 :data1, 11
  s32 :subheader2, 1, [ proc { |b| SUBH[b] }, proc { |s| SUBH_LOOKUP[s] } ]
  s32 :data2, 11
  s32 :subheader3, 1, [ proc { |b| SUBH[b] }, proc { |s| SUBH_LOOKUP[s] } ]
  s32 :data3, 11
  s32 :subheader4, 1, [ proc { |b| SUBH[b] }, proc { |s| SUBH_LOOKUP[s] } ]
  s32 :data4, 11
  s32 :subheader5, 1, [ proc { |b| SUBH[b] }, proc { |s| SUBH_LOOKUP[s] } ]
  s32 :data5, 11
  s32 :subheader6, 1, [ proc { |b| SUBH[b] }, proc { |s| SUBH_LOOKUP[s] } ]
  s32 :data6, 11
  s32 :subheader7, 1, [ proc { |b| SUBH[b] }, proc { |s| SUBH_LOOKUP[s] } ]
  s32 :data7, 11
  s32 :subheader8, 1, [ proc { |b| SUBH[b] }, proc { |s| SUBH_LOOKUP[s] } ]
  s32 :data8, 11
  s32 :subheader9, 1, [ proc { |b| SUBH[b] }, proc { |s| SUBH_LOOKUP[s] } ]
  s32 :data9, 11
  s32 :subheader10, 1, [ proc { |b| SUBH[b] }, proc { |s| SUBH_LOOKUP[s] } ]
  s32 :data10, 11
  s32 :subheader11, 1, [ proc { |b| SUBH[b] }, proc { |s| SUBH_LOOKUP[s] } ]
  s32 :data11, 11
  s32 :subheader12, 1, [ proc { |b| SUBH[b] }, proc { |s| SUBH_LOOKUP[s] } ]
  s32 :data12, 11
  
  def initialize(name, id, file)
    @id = id
    @name = name
    Skill.read_block(self, file)
  end
  
  def write(file)
    Skill.write_block(self, file)
  end
end

NAMESUB = ['SKILLTABLE', 'SKILLNAMETABLE']

case ARGV[0]
when '-u'
  nametbl = File.open(ARGV[1].sub(*NAMESUB), 'r') { |f| NameTable.new(f) }
  names = nametbl.names.dup
  skills = []
  file = File.open(ARGV[1], 'rb')
  i = -1
  skills << Skill.new(names.shift, i += 1, file) until file.eof?
  file.close
  File.open("#{ARGV[1].downcase}.yml", 'w+b') { |f| f.write(YAML.dump(skills)) }
when '-p'
  skills = File.open(ARGV[1]) { |f| YAML.load(f) }
  File.open(ARGV[2], 'w+b') { |f| skills.each { |s| s.write(f) } }
  names = NameTable.new(skills.collect { |s| s.name })
  t0 = Time.now
  File.open(ARGV[2].sub(*NAMESUB), 'w+b') { |f| names.write(f) }
  t1 = Time.now
  puts t1 - t0
end
