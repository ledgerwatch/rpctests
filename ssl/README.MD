### Self-Signed TLS Certificate 

This certificate is used in communinication between server and a client.

Server does not need to know about certificate since nginx is handling it.
See [../web/tcp.conf](../web/tcp.conf)

In case names of the key and certificate is changed, change names in ../web/tcp.conf as well.