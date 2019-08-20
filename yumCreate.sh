#!/bin/bash

OPENSSH_VERSION=8.0p1

yum -y install wget epel-release yum-utils createrepo
yum -y install  rpm-build  gcc make
yum -y install  openssl  openssl-devel krb5-devel pam-devel libX11-devel xmkmf libXt-devel

# cd /root
wget http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${OPENSSH_VERSION}.tar.gz
tar -zxf  openssh-${OPENSSH_VERSION}.tar.gz
mkdir -p /root/rpmbuild/{SOURCES,SPECS}

cp ./openssh-${OPENSSH_VERSION}/contrib/redhat/openssh.spec /root/rpmbuild/SPECS/
cp openssh-${OPENSSH_VERSION}.tar.gz /root/rpmbuild/SOURCES/

cd /root/rpmbuild/SPECS/
sed -i -e "s/%define no_gnome_askpass 0/%define no_gnome_askpass 1/g" openssh.spec
sed -i -e "s/%define no_x11_askpass 0/%define no_x11_askpass 1/g" openssh.spec
sed -i -e "s/BuildPreReq/BuildRequires/g" openssh.spec
sed -i -e "s/BuildRequires: openssl-devel < 1.1/#BuildRequires: openssl-devel < 1.1/g" openssh.spec

rpmbuild -bb openssh.spec

ll /root/rpmbuild/RPMS/x86_64


mkdir -p /root/yum
repotrack openssl openssh openssh-server openssh-clients -p /root/yum

rm -f /root/yum/openssh-*
cp -r /root/rpmbuild/RPMS/x86_64/*.rpm  /root/yum

createrepo -v /root/yum
tar -zcf yum.tar.gz  /root/yum
mv yum.tar.gz  opensshUpgradeAnsiblePlaybook/roles/yum/files/
