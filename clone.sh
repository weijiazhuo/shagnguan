克隆一台kvm机子
在有kvm的机子执行，比如真机
rhel6.5 是 kvm 中存在的机子名称。 /etc/libvirt/qemu/rhel6.5.xml
CG -- > 克隆出来的机子的名称
#!/bin/bash

read -p "请输入主机的名称:" CG


if  [ -f /etc/libvirt/qemu/$CG.xml ]
then
  virsh destroy $CG
  virsh undefine $CG
  rm -fr /var/lib/libvirt/images/$CG.*
fi

  virt-clone -o rhel6.5 -n $CG -f /var/lib/libvirt/images/$CG.img
  sed -i "s/domain-rhel6.5/domain-$CG/" /etc/libvirt/qemu/$CG.xml
  virsh define /etc/libvirt/qemu/$CG.xml
  virsh start $CG
