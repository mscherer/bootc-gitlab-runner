FROM quay.io/bootc-devel/fedora-bootc-44-minimal@sha256:1a408bf6a0a2071070ecde5189642c039bf391e355aa58367ae939f156955782
#
# empty space for easier rebasing
#

# needed to start the various software at boot
COPY servers.preset /usr/lib/systemd/system-preset/01-servers.preset

# install bind9 and various stuff
RUN <<EORUN
# fix/workaround https://bugzilla.redhat.com/show_bug.cgi?id=2432642
dnf install -y --setopt=install_weak_deps=false bubblewrap

source /etc/os-release
curl "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/config_file.repo?os=${ID}&dist=${VERSION_ID}&source=script" > /etc/yum.repos.d/runner_gitlab-runner.repo
dnf install -y --setopt=install_weak_deps=false gitlab-runner git

# systemd-networkd-defaults pull systemd-networkd
dnf install -y --setopt=install_weak_deps=false openssh-server systemd-networkd-defaults

dnf clean all
rm -Rf /var/log/dnf5.log /var/lib/dnf/ /var/cache/ /run/dnf
EORUN

# disable the flood of message on the console
#COPY disable-flood.conf /usr/lib/sysctl.d/60-disable-flood.conf

RUN <<EORUN2
systemctl preset-all
EORUN2

RUN bootc container lint --fatal-warnings
