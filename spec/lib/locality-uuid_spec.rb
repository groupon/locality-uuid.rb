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

require 'spec_helper'
require 'locality-uuid'

describe UUID do
  it 'should have the correct structure' do
    r = /^[0-9a-zA-Z]{8}\-[0-9a-zA-Z]{4}\-b[0-9a-zA-Z]{3}\-[0-9a-zA-Z]{4}\-0[0-9a-zA-Z]{11}$/
    UUID.new.to_s.should =~ r
  end

  it 'should parse uuid values' do
    x1 = UUID.new
    x2 = UUID.new x1.to_s
    x1.should == x2
    x1.timestamp.should == x2.timestamp
    x1.bytes.should == x2.bytes

    expect {UUID.new 'aoeuaoeu'}.to raise_error
  end

  it 'should accept uuid in the constructor' do
    x1 = UUID.new
    x2 = UUID.new x1
    x1.should == x2
    x1.bytes.should == x2.bytes
  end

  it 'should switch modes' do
    n = 1000
    ids = []

    for i in 0..(n-1)
      ids << UUID.new.to_s
    end

    for i in 1..(n-1)
      ids[i-1][0].should_not == ids[i][0]
    end

    UUID.use_sequential_ids
    initial_counter = UUID.new.to_s.split('-')[0]
    UUID.use_variable_ids
    UUID.use_sequential_ids
    second_counter = UUID.new.to_s.split('-')[0]
    initial_counter.should == second_counter

    ids = []

    for i in 0..(n-1)
      ids << UUID.new.to_s
    end

    for i in 1..(n-1)
      ids[i-1][0].should == ids[i][0]
      ids[i-1][1].should == ids[i][1]
      ids[i-1][2].should == ids[i][2]
      
      a = ids[i-1][7].to_s
      b = ids[i][7].to_s

      (((a.ord + 1).chr == b) || (a == '9' && b == 'a') || (a == 'f' && b == '0')).should == true
    end

    UUID.use_variable_ids
    ids = []

    for i in 0..(n-1)
      ids << UUID.new.to_s
    end

    for i in 1..(n-1)
      ids[i-1][0].should_not == ids[i][0]
    end
  end

  it 'should be immutable' do
    x = UUID.new
    s1 = x.to_s
    b = x.bytes
    b[0] = 'x'
    b[1] = 'x'
    b[2] = 'x'
    b[3] = 'x'
    b[4] = 'x'

    s2 = x.to_s
    s1.should == s2
  end

  it 'should be immutable on the construction value' do
    str = '00000000-0000-0000-0000-000000000000'
    x = UUID.new str
    s1 = x.to_s
    str = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
    s1.should == x.to_s
  end

  it 'should return the UUID version' do
    UUID.new.version.should == 'b'
    UUID.new('20be0ffc-314a-bd53-7a50-013a65ca76d2').version.should == 'b'
    UUID.new('20be0ffc-314a-7d53-7a50-013a65ca76d2').version.should == '7'
  end

  it 'should return the UUID pid' do
    UUID.new.pid.should == $$ % 65536
    UUID.new('20be0ffc-314a-bd53-7a50-013a65ca76d2').pid.should == 12618
    expect {UUID.new('20be0ffc-314a-7d53-7a50-013a65ca76d2').pid}.to raise_error
  end

  it 'should return the UUID timestamp' do
    start = Time.now.utc.to_f.round(3)
    time = UUID.new.timestamp
    time.to_f.should be >= start - 0.01
    time.to_f.should be < start + 0.01
  end

  it 'should return the MAC address fragment' do
    UUID.new.mac.should == '_____' + Mac.addr[7..-1].gsub(/:/, '')
    UUID.new('20be0ffc-314a-bd53-7a50-013a65ca76d2').mac.should == '_____d537a50'
  end

  it 'should not generate dups' do
    n = 100000
    a = Array.new n
    s = Set.new

    for i in 0..n
      a[i] = UUID.new
    end

    a.each { |x| s.add x }

    a.size.should == s.size
  end

  it 'should handle concurrent generation' do
    n = 100000
    nthreads = 10
    effective_n = (n / nthreads).to_i * nthreads
    threads = []
    
    a = Array.new effective_n
    s = Set.new

    for i in 0..nthreads
      threads << Thread.new(i) do |i|
        for j in 0..(n / nthreads).to_i
          u = UUID.new
          a[nthreads * j + i] = u
        end
      end
    end

    threads.each { |thread| thread.join }
    a.each { |x| s.add x }

    s.size.should == a.size
  end

end
