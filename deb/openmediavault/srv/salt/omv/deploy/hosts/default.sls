# This file is part of OpenMediaVault.
#
# @license   http://www.gnu.org/licenses/gpl.html GPL Version 3
# @author    Volker Theile <volker.theile@openmediavault.org>
# @copyright Copyright (c) 2009-2018 Volker Theile
#
# OpenMediaVault is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# OpenMediaVault is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with OpenMediaVault. If not, see <http://www.gnu.org/licenses/>.

# Documentation/Howto:
# http://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_hostname_resolution

{% set interfaces = salt['omv_conf.get']('conf.system.network.interface') %}
{% set dns = salt['omv_conf.get']('conf.system.network.dns') %}
{% set fqdn = dns.hostname %}
{% set alias = "" %}
{% if dns.domainname %}
{% set fqdn = [dns.hostname, dns.domainname] | join('.') %}
{% set alias = dns.hostname %}
{% endif %}

configure_hosts:
  file.managed:
    - name: "/etc/hosts"
    - contents: |
        {{ pillar['headers']['auto_generated'] }}
        {{ pillar['headers']['warning'] }}
        127.0.0.1 localhost
        127.0.1.1 {{ fqdn }} {{ alias }}

        # The following lines are desirable for IPv6 capable hosts.
        ::1     ip6-localhost ip6-loopback
        fe00::0 ip6-localnet
        ff00::0 ip6-mcastprefix
        ff02::1 ip6-allnodes
        ff02::2 ip6-allrouters
        ff02::3 ip6-allhosts
    - user: root
    - group: root
    - mode: 644

{% for interface in interfaces %}

{% if interface.address | is_ipv4 %}
append_hosts_{{ interface.devicename }}_v4:
  host.only:
    - name: "{{ interface.address }}"
    - hostnames:
      - "{{ fqdn }}"
      - "{{ alias }}"
{% endif %}

{% if interface.address6 | is_ipv6 %}
append_hosts_{{ interface.devicename }}_v6:
  host.only:
    - name: "{{ interface.address6 }}"
    - hostnames:
      - "{{ fqdn }}"
      - "{{ alias }}"
{% endif %}

{% endfor %}
