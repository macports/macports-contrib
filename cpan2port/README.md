# NAME

cpan2port - A tool to generate MacPorts Portfiles from CPAN distributions

# VERSION

version 0.001001

# USAGE

cpan2port uses at least one flag and a list of module names. Module names can
also be read from stdin.

> cpan2port -t Net::LDAP Test::Harness

works.

> cpan2port -t < packages\_list

works too.

Flags tell cpan2port what to do

- -v

    By default, cpan2port doesn't print useless CPAN messages. Use -v if you want to show them.

- -t

    Generate portfiles from a list of modules.

    Go to your local MacPorts repository and type

    ```
    cpan2port -t Net::LDAP Test::Harness
    find .
    ```

    and you'll see

    ```
    ./perl
    ./perl/p5-perl-ldap
    ./perl/p5-perl-ldap/Portfile
    ./perl/p5-test-harness
    ./perl/p5-test-harness/Portfile
    ```

- -f

    Format output for all package names. For example

    ```
    cpan2port -f '#{port}' Net::LDAP
    ```

    will print

    ```
    p5-perl-ldap
    ```

    special format string YAML shows a yaml dump about packages

    ```
    cpan2port -f YAML Net::LDAP
    ```

    so it's easy to see what information is available.

# KNOWN BUGS AND TODO LIST

- Have to launch twice to generate packages? -v flag messes things up?
- Add perl version support to have a better dependencies grabbing

# AUTHOR

Marc Chantreux

# CONTRIBUTORS

- Dan Ports <dports@macports.org>
- David B. Evans <devans@macports.org>
- Frank Schima <mf2k@macports.org>
- Kurt Hindenburg <khindenburg@macports.org>
- Larry Gilbert <l2g@macports.org>
- Mojca Miklavec <mojca@macports.org>
- Ryan Schmidt <ryandesign@macports.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by BibLibre.

This is free software; permission to redistribute, modify, etc. is granted under the
terms of the WTFPL, which can be found in the COPYING file accompanying this program,
or on the Web at: http://sam.zoy.org/wtfpl/COPYING
