#
# Cookbook Name:: installUhuruOnWindows
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

windows_batch "Download_DEA_DotNet_InstallerFromLocalDepot" do
  
  code <<-EOH
  cd c:\FileChef
  wget http://10.1.1.241/DEAInstaller_x64.msi
  wget http://10.1.1.241/dotNetFx40_Full_x86_x64.exe
  EOH
  not_if {::File.exists?("c:/FileChef/DEAInstaller_x64.msi")}

end


#windows_feature "ISS" do
#  action :install
#end

#windows_package "install_DotNet4_for_windows" do
#  source "c:/FileChef/dotNetFx40_Full_x86_x64.exe"
#  action :install
#end

windows_path 'C:\FileChef' do
  action :add
end


windows_batch "Install_DotNET4" do
  
  code <<-EOH
  cd c:\FileChef
  dotNetFx40_Full_x86_x64.exe /q /norestart /ChainingPackage ADMINDEPLOYMENT
  EOH

end


if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
 nats_nodes = search(:node, "role:cloudfoundry_nats_server")
 nats_node = nats_nodes.first

 nats_user =  nats_node.nats_server.user
 nats_password = nats_node.nats_server.password
 nats_ip = nats_node.ipaddress
 nats_port= nats_node.nats_server.port


 cc_nodes = search(:node, "role:cloudfoundry_controller")
 cc_node = cc_nodes.first

 cc_ip= cc_node.ipaddress #To check !!
 filterPort_dea_cc = cc_node.cloudfoundry_dea.filter_port

end

Chef::Log.warn("#msiexec /i DEAInstaller.msi baseDir=C:\Droplets localRoute=192.168.1.1 filerPort=12345 messageBus=nats://user:password@192.168.1.100:4222/ secure=true maxMemory=4096")

Chef::Log.warn("msiexec /i DEAInstaller.msi baseDir=C:\Droplets localRoute=#{cc_ip} filerPort=#{filterPort_dea_cc} messageBus=nats://#{nats_user}:#{nats_password}@#{nats_ip}:#{nats_port}/ secure=true maxMemory=4096")



#windows_batch "Download_DEAInstallerFromLocalDepot" do
#  code <<-EOH
#  cd c:\FileChef
#  msiexec /i DEAInstaller.msi baseDir=C:\Droplets localRoute=#{cc_ip} filerPort=#{filterPort_dea_cc} messageBus=nats://#{nats_user}:#{nats_password}@#{nats_ip}:#{nats_port}/ secure=true maxMemory=4096 > msiexec_resulatat_chef.txt
#  EOH
#end
