This is an haproxy-based load balancer designed to work with the `fig
scale` command.  It will generate an haproxy configuration (and run
haproxy) based on the environment variables provided by `fig` in
response to `link` directives in your `fig.yml` file.

## Example

If you start with a `fig.yml` file like this:

    foo:
      image: larsks/simpleweb

    bar:
      image: larsks/simpleweb

    lb:
      image: larsks/figlb
      links:
        - foo
        - bar
      environment:
        - "SERVICES=--service FOO 80 9010 --service BAR 80 9020"
      ports:
        - "9010:9010"
        - "9020:9020"

And start things up like this:

    $ fig scale foo=3 bar=3
    $ fig up lb

You will end up with haproxy bound to ports 9010 and 9020 on your
host.  Port 9010 will direct traffic to one of the `foo` backends, and
port 9020 will direct traffic to one of the `bar` backends.  The
generated haproxy configuration will look like this:

    global
        daemon
        maxconn 4096
        pidfile /var/run/haproxy.pid

    defaults
        mode tcp
        timeout connect 5s
        timeout client 1m
        timeout server 1m
        option redispatch
        balance roundrobin

    listen stats :1936
        mode http
        stats enable
        stats hide-version
        stats uri /


    frontend FOO_80
        bind 0.0.0.0:9010
        mode tcp
        default_backend FOO_80

    frontend BAR_80
        bind 0.0.0.0:9020
        mode tcp
        default_backend BAR_80

    backend FOO_80
        balance roundrobin
        mode tcp
        server FOO_80_1 172.17.0.82:80
        server FOO_80_2 172.17.0.80:80
        server FOO_80_3 172.17.0.78:80
        
    backend BAR_80
        balance roundrobin
        mode tcp
        server BAR_80_1 172.17.0.72:80
        server BAR_80_2 172.17.0.76:80
        server BAR_80_3 172.17.0.74:80

