# Copyright (c) 2013, Groupon, Inc.
# All rights reserved. 
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met: 
# 
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer. 
# 
# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution. 
# 
# Neither the name of GROUPON nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'macaddr'
require 'atomic'
require 'digest/md5'

class UUID
  GEMVERSION      = '1.0.0'
  @@VERSION       = 'b'
  @@MAC           = Mac.addr[7..-1].gsub(/:/, '')
  @@MIDDLE        = @@VERSION + @@MAC
  @@PRIME         = 198491317
  @@COUNTER_MAX   = 4294967295
  @@PID_MAX       = 65536
  @@PID           = $$ % @@PID_MAX
  @@REGEX         = /^[0-9a-zA-Z]{8}\-[0-9a-zA-Z]{4}\-[0-9a-zA-Z]{4}\-[0-9a-zA-Z]{4}\-[0-9a-zA-Z]{12}$/

  @@sequential    = false
  @@counter       = Atomic.new(Random.rand(@@COUNTER_MAX))
  
  def initialize input = nil
    if input == nil
      generate
    elsif input.is_a? String
      parse input
    elsif input.is_a? UUID
      @content = input.bytes
    else
      raise "could not construct UUID with input #{input}"
    end
  end

  def self.use_sequential_ids
    if !@@sequential
      # get a string that changes every 10 minutes
      String date = Time.now.utc.strftime("%Y%m%d%H%M").slice(0, 11)

      # run an md5 hash of the string, no reason this needs to be secure
      digest = Digest::MD5.hexdigest date

      # get first 4 bytes of digest, reverse, and turn into int
      x = [digest[0...8]].pack("H*").unpack("l")[0]
      @@counter.update { |curr| x }
    end
    @@sequential = true
  end

  def self.use_variable_ids
    @@sequential = false
  end

  def bytes
    String.new @content
  end

  def to_s
    s = @content.unpack('H*')[0]
    x = '________-____-____-____-____________'
    x[0 ] = s[0 ]
    x[1 ] = s[1 ]
    x[2 ] = s[2 ]
    x[3 ] = s[3 ]
    x[4 ] = s[4 ]
    x[5 ] = s[5 ]
    x[6 ] = s[6 ]
    x[7 ] = s[7 ]
    
    x[9 ] = s[8 ]
    x[10] = s[9 ]
    x[11] = s[10]
    x[12] = s[11]

    x[14] = s[12]
    x[15] = s[13]
    x[16] = s[14]
    x[17] = s[15]

    x[19] = s[16]
    x[20] = s[17]
    x[21] = s[18]
    x[22] = s[19]

    x[24] = s[20]
    x[25] = s[21]
    x[26] = s[22]
    x[27] = s[23]
    x[28] = s[24]
    x[29] = s[25]
    x[30] = s[26]
    x[31] = s[27]
    x[32] = s[28]
    x[33] = s[29]
    x[34] = s[30]
    x[35] = s[31]
    return x
  end

  def == other
    return false unless other && other.is_a?(UUID)
    return (self.bytes == other.bytes)
  end

  def version
    @content[6].unpack('H')[0]
  end

  def pid
    raise "incorrect UUID version: #{version}" unless version == @@VERSION
    @content[4..5].unpack('S>')[0]
  end

  def timestamp
    i = ("\x00\x00" + @content[10..15]).unpack('Q>')[0]
    Time.at((i / 1000), (i % 1000 * 1000)).utc
  end

  def mac
    '_____' + @content[6..9].unpack('H*')[0][1..-1]
  end

  private

  def generate
    time = (Time.now.utc.to_f * 1000).to_i
    count = 0

    if !@@sequential
      countn = @@counter.update do |x| 
        c = x + @@PRIME
        (c >= @@COUNTER_MAX ? c - @@COUNTER_MAX : c)
      end

      count  = (((countn & 0xF) << 28) | ((countn & 0xF0) << 20))
      count |= (((countn & 0xF00) << 12) | ((countn & 0xF000) << 4))
      count |= (((countn & 0xF0000) >> 4) | ((countn & 0xF00000) >> 12))
      count |= (((countn & 0xF000000) >> 20) | ((countn & 0xF0000000) >> 28))
    else
      countn = @@counter.update do |x| 
        c = x + 1
        (c >= @@COUNTER_MAX ? 0 : c)
      end

      count = countn
    end

    @content = [count, @@PID, @@MIDDLE, time >> 32, time].pack('NS>H*S>N')
  end

  def parse input
    raise 'input must be a string' unless input.is_a? String
    raise "invalid uuid: #{input}" unless input =~ @@REGEX

    input = input.gsub(/\-/, '')
    @content = [input].pack('H*')
  end
end
