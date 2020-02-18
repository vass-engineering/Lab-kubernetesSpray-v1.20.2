DNS:


;#Kuberneter v1.16.6
master01.k8s    IN      A       10.0.5.31
master02.k8s    IN      A       10.0.5.32
master03.k8s    IN      A       10.0.5.33
worker01.k8s    IN      A       10.0.5.34
worker02.k8s    IN      A       10.0.5.35
worker03.k8s    IN      A       10.0.5.36

;# Kuberneter v1.16.6
31      IN      PTR     master01.k8s.labs.vass.es.
32      IN      PTR     master02.k8s.labs.vass.es.
33      IN      PTR     master03.k8s.labs.vass.es.
34      IN      PTR     worker01.k8s.labs.vass.es.
35      IN      PTR     worker02.k8s.labs.vass.es.
36      IN      PTR     worker03.k8s.labs.vass.es.

Gateway: 10.0.2.24
DNS: 10.0.5.5
255.255.0.0
