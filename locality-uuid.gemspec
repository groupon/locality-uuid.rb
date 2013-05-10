# encoding: utf-8

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

require File.expand_path('../lib/locality-uuid.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'autotest-standalone'
  gem.add_runtime_dependency 'macaddr'
  gem.add_runtime_dependency 'atomic'

  gem.authors = ["Peter Bakkum"]
  gem.bindir = 'bin'
  gem.description = %q{This is a UUID class intended to help control data locality when inserting into a distributed data system, such as MongoDB or HBase. There is also a Java implementation. This version does not conform to any external standard or spec. Developed at Groupon in Palo Alto by Peter Bakkum and Michael Craig.}
  gem.email = ['pbb7c@virginia.edu']
  gem.executables = ['locality-uuid']
  gem.extra_rdoc_files = ['README.md', 'LICENSE.md']
  gem.files = Dir['README.md', 'LICENSE.md', 'locality-uuid.gemspec', 'Gemfile', '.rspec', 'spec/**/*', 'lib/*', 'bin/*']
  gem.homepage = 'http://github.com/groupon/locality-uuid.rb'
  gem.name = 'locality-uuid'
  gem.rdoc_options = ["--charset=UTF-8"]
  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new(">= 1.3.6")
  gem.summary = %q{UUID for data locality in distributed systems.}
  gem.test_files = Dir['spec/**/*']
  gem.version = UUID::GEMVERSION
  gem.license = 'MIT'
end


