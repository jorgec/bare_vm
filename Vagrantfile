# -*- mode: ruby -*-
# vi: set ft=ruby :

# |
# | Require YAML module
# |
require 'yaml'

# |
# | Get dir path
# |
dir = File.dirname(File.expand_path(__FILE__))

# |
# | Read YAML files
# |
servers       = YAML.load_file("#{dir}/CONFIG.yaml")

# |
# | Set values for message
# |
$wpDomain     = servers['wpDomain']

# | ············································································
# | Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
# | ············································································
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    servers["vms"].each do |server|
        config.vm.define server["name"] do |srv|

            # |
            # | :::::: Box
            # |
            srv.vm.box = server["box"]

            if server["box_version"]
                srv.vm.box_version = server["box_version"]
            end

            if server["box_check_update"]
                srv.vm.box_check_update = server["box_check_update"]
            end


            # | ············································································
            # | :::::: Vm Setup
            # | ············································································

            srv.vm.provider :virtualbox do |vb|
                vb.name     = server["name"]

                if server["gui"]
                    vb.gui      = server["gui"]
                end

                vb.customize ["modifyvm", :id, "--usb", "off"]
                vb.customize ["modifyvm", :id, "--usbehci", "off"]

                # change the network card hardware for better performance
                vb.customize ["modifyvm", :id, "--nictype1", "virtio" ]
                vb.customize ["modifyvm", :id, "--nictype2", "virtio" ]

                # suggested fix for slow network performance
                # see https://github.com/mitchellh/vagrant/issues/1807
                vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]


                if server["ram"] == "auto"
                    host = RbConfig::CONFIG['host_os']
                    # Give VM 1/4 system memory & access to all cpu cores on the host
                    if host =~ /darwin/
                        mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4
                    elsif host =~ /linux/
                        mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
                    else # sorry Windows folks, I can't help you
                        mem = 1024
                    end
                    vb.memory = mem
                else
                     vb.memory = server["ram"]
                end


                if server["cpus"] == "auto"
                    host = RbConfig::CONFIG['host_os']
                    # Give VM 1/4 system memory & access to all cpu cores on the host
                    if host =~ /darwin/
                        cpus = `sysctl -n hw.ncpu`.to_i
                    elsif host =~ /linux/
                        cpus = `nproc`.to_i
                    else # sorry Windows folks, I can't help you
                        cpus = 2
                    end
                    vb.cpus   = cpus
                else
                    vb.cpus   = server["cpus"]
                end


            end


            # |
            # | :::::: Networdk
            # |

            if server["private_network"]["ip_private"] && server["private_network"]["auto_config"]
                srv.vm.network "private_network",
                    ip:          server["private_network"]["ip_private"],
                    auto_config: server["private_network"]["auto_config"]
            elsif server["private_network"]["ip_private"]
                srv.vm.network "private_network",
                    ip:     server["private_network"]["ip_private"]
            else server["private_network"]["type"]
                srv.vm.network "private_network",
                    type: server["private_network"]["type"]
            end


            if defined? server["public_network"]["ip_public"]
                if server["public_network"]["ip_public"] == "auto"
                    srv.vm.network "public_network"
                elsif server["public_network"]["ip_public"] == "true"
                    srv.vm.network "public_network",
                        use_dhcp_assigned_default_route: true
                elsif server["public_network"]["ip_public"] && server["public_network"]["bridge"]
                    srv.vm.network "public_network",
                        ip:     server["public_network"]["ip_public"],
                        bridge: server["public_network"]["bridge"]
                else
                    srv.vm.network "public_network",
                        ip: server["public_network"]["ip_public"]
                end
            end

            # |
            # | :::::: Ports forwarded
            # |

            if server["ports"]
                server['ports'].each do |ports|
                    srv.vm.network "forwarded_port",
                    guest: ports["guest"],
                    host: ports["host"],
                    auto_correct: true
                end
            end

            # |
            # | :::::: Folder Sync
            # |

            if server["syncDir"]
                server['syncDir'].each do |syncDir|
                    if syncDir["owner"] && syncDir["group"]
                        srv.vm.synced_folder syncDir["host"],
                        syncDir["guest"],
                        owner: "#{syncDir["owner"]}",
                        group: "#{syncDir["group"]}",
                        mount_options:["dmode=#{syncDir["dmode"]}",
                        "fmode=#{syncDir["fmode"]}"],
                        create: true
                    else
                        srv.vm.synced_folder syncDir['host'],
                        syncDir['guest'],
                        create: true
                    end
                end
            end





# | ············································································
# | :::::: Provisions
# | ············································································

            # |
            # | :::::: Provisions - Bash
            # |
            if server["bash"]
                srv.vm.provision :shell, :path => server["bash"]
            end

            #srv.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/me.pub"
            #srv.vm.boot_timeout = 240


# | ············································································
# | :::::: Vagrant Message
# | ············································································

            srv.vm.post_up_message = " \e[0;37m
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░  VAGRANT VM                                            ░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

  Vm Name    : \e[0;33m#{server['name']}\e[0;37m
  Private ip : \e[0;33m#{server["private_network"]["ip_private"]}\e[0;37m

░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
\e[32m"

        end
    end
end
