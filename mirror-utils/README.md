# MacPorts mirror utilities #

## fetch-mirror-sites ##

Fetch a list of mirrors, extract the URLs of FTP and HTTP(S) mirrors,
and print them to standard output in a format suitable for
[`mirror_sites.tcl`][mirror_sites].

    fetch-mirror-sites [-a] [-K <curl config>] [--] <source>

*   `-a`: Output all URLs. By default, we "deduplicate" by outputting
    only one URL per [fully qualified domain name][fqdn], prioritizing
    HTTPS over HTTP over FTP. (This is a naïve attempt to avoid trying
    a single host multiple times, once per available protocol. URLs
    referring to the same host by different FQDNs must be culled
    manually.)

*   `-K`: Specify the path to a `curl(1)` config file to use when
    fetching the source (or `-` to read a config from standard input).
    The argument is passed directly to `curl --config`, so refer to the
    [`curl(1)` documentation][curl] for details.

*   `<source>`: The name of a supported mirror list.

    | Name                      | Location
    | ----                      | --------
    | `ctan`/`tex`/`tex_ctan`   | https://ctan.org/mirrors
    | `gentoo`                  | https://gentoo.org/downloads/mirrors
    | `gnu`                     | https://gnu.org/prep/ftp.html
    | `xorg`                    | https://x.org/wiki/Releases/Download

  [curl]: https://curl.haxx.se/docs/manpage.html
        'curl.1 the man page'
  [fqdn]: https://en.wikipedia.org/wiki/Fully_qualified_domain_name
        '"Fully qualified domain name" on the English Wikipedia'
  [mirror_sites]: https://trac.macports.org/browser/trunk/dports/_resources/port1.0/fetch/mirror_sites.tcl

## port-checkmirrors ##

Verify the integrity of ports' distfiles on all applicable mirrors.

    port-checkmirrors <port spec>

*   `port spec`: Any valid MacPorts port specification, including
    expressions and pseudo-portname selectors.

(Requires bash 4.)
