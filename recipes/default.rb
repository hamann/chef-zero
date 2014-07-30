#
# Cookbook Name:: chef-zero
# Recipe:: default
#
# Copyright 2013, Seth Vargo <sethvargo@gmail.com>
# Copyright 2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'build-essential'
include_recipe 'runit'

# This is a chef_gem because we actually want to run this from inside Chef
chef_gem 'chef-zero' do
  version   node['chef-zero']['version']
  only_if   { node['chef-zero']['install'] }
end

bin_path = File.expand_path(File.join(
  node['chef_packages']['chef']['chef_root'],
  '..', '..', '..', '..',
  '..', '..', '..', '..', 'bin')
)

cookbook_file "#{bin_path}/chef-zero-persist" do
  owner 'root'
  group 'root'
  mode '0755'
  only_if { node['chef-zero']['persist'] }
end

directory node['chef-zero']['repository_path'] do
  recursive true
  only_if { node['chef-zero']['persist'] }
end

runit_service node['chef-zero']['daemon'] do
  run_template_name 'sv-cz-run.erb'
  log_template_name 'sv-cz-log.erb'
  options({ command: ChefZeroCookbook::Herlpers.command(node)})
  action [:enable, :start]
  only_if { node['chef-zero']['start'] }
end
