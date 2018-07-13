{% set config = salt['omv.get_config']('conf.service.ftp') %}

prereq_proftpd_mod_tls_certificates:
  salt.state:
    - tgt: '*'
    - sls: omv.deploy.certificates

configure_proftpd_mod_tls:
  file.managed:
    - name: "/etc/proftpd/tls.conf"
    - source:
      - salt://{{ slspath }}/files/mod_tls.j2
    - template: jinja
    - context:
        config: {{ config.modules.mod_tls | json }}
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: start_proftpd_service
