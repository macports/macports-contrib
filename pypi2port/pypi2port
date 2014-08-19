#! /bin/sh
""":"
exec python $0 ${1+"$@"}
"""
__doc__ = """...Script for pypi2port module written for "The Macports Project"
             participating in Google Summer of Code 2014..."""

# -*- coding: utf-8 -*-
# !/usr/bin/env python

import argparse
import sys
import os
import urllib2
import hashlib
import zipfile
from progressbar import *
try:
    import xmlrpclib
except ImportError:
    import xmlrpc.client as xmlrpclib
import textwrap
import string
import shutil
import re
import difflib
import subprocess
import requests
import shlex
import getpass

client = xmlrpclib.ServerProxy('http://pypi.python.org/pypi')


""" Lists all packages available in pypi database """


def list_all():
    list_packages = client.list_packages()
    for package in list_packages:
        print package


""" Searches for a particular package by the name classifier """


def search(pkg_name):
    values = client.search({'name': pkg_name})
    for value in values:
        for key in value.keys():
            print key, '-->', value[key]


""" Fetches the release data for a paticular package based on
    the package_name and package_version """


def release_data(pkg_name, pkg_version):
    if pkg_version:
        values = client.release_data(pkg_name, pkg_version)
        if values:
            for key in values.keys():
                print key, '-->', values[key]
        else:
            print "No such package found."
            print "Please specify the exact package name."
        return
    return


""" Fetches the distfile for a particular package name and release_url """


def fetch(pkg_name, dict):
    print "Fetching distfiles..."
    checksum_md5 = dict['md5_digest']
    parent_dir = './sources'
    home_dir = parent_dir + '/' + 'python'
    src_dir = home_dir + '/py-' + pkg_name
    if not os.path.exists(parent_dir):
        os.makedirs(parent_dir)
    if not os.path.exists(home_dir):
        os.makedirs(home_dir)
    if not os.path.exists(src_dir):
        os.makedirs(src_dir)

    url = dict['url']
    file_name = src_dir + '/' + dict['filename']

    u = urllib2.urlopen(url)
    with open(file_name, 'wb') as f:
        meta = u.info()
        file_size = int(meta.getheaders("Content-Length")[0])

        widgets = ['Fetching: ', Percentage(), ' ',
                   Bar(marker=RotatingMarker(), left='[', right=']'),
                   ' ', ETA(), ' ', FileTransferSpeed()]
        pbar = ProgressBar(widgets=widgets, maxval=int(file_size))
        pbar.start()

        file_size_dl = 0
        block_sz = 1024
        while True:
            buffer = u.read(block_sz)
            if not buffer:
                break

            file_size_dl += len(buffer)
            f.write(buffer)
            pbar.update(file_size_dl)

        pbar.finish()

    checksum_md5_calc = hashlib.md5(open(file_name).read()).hexdigest()
    if str(checksum_md5) == str(checksum_md5_calc):
        print 'Successfully fetched'
        ext = file_name.split('.')[-1]
        if ext == 'egg':
            zip = zipfile.ZipFile(file_name)
            for name in zip.namelist():
                if name.split("/")[0] == "EGG-INFO":
                    zip.extract(name, src_dir)
        return file_name
    else:
        print 'Aborting due to inconsistency on checksums\n'
        try:
            os.remove(file_name)
        except OSError, e:
            print "Error: %s - %s." % (e.filename, e.strerror)
        return False


""" Checks for the checksums and dependecies for a particular python package
    on the basis of package_name and package_version """


def fetch_url(pkg_name, pkg_version, checksum=False, deps=False):
    values = client.release_urls(pkg_name, pkg_version)
    if checksum:
#        print values
        for value in values:
            if value['filename'].split('.')[-1] == 'gz' or value['filename'].split('.')[-1] == 'zip':
                return fetch(pkg_name, value)
    else:
        for value in values:
            return fetch(pkg_name, value)


""" Finds dependencies for a particular package on the basis of
    package_name and package_version """


def dependencies(pkg_name, pkg_version, deps=False):
    flag = False
    if not deps:
        return
    values = client.release_urls(pkg_name, pkg_version)
    for value in values:
        if not(value['filename'].split('.')[-1] == 'gz' or value['filename'].split('.')[-1] == 'zip'):
            fetch(pkg_name, value)
    try:
        with open('./sources/python/py-'
                  + pkg_name + '/EGG-INFO/requires.txt') as f:
            list = f.readlines()
            list = [x.strip('\n') for x in list]
        f.close()
        try:
            if flag:
                shutil.rmtree('./sources/python/py-' + pkg_name + '/EGG-INFO',
                              ignore_errors=True)
                items = os.listdir('./sources/python/py-' + pkg_name)
                for item in items[:]:
                    if not(item.split('.')[-1] == 'gz' or item.split('.')[-1] == 'zip'):
                        os.remove('./sources/python/py-'
                                  + pkg_name + '/' + item)
                        items.remove(item)
                if not items:
                    os.rmdir('./sources/python/py-' + pkg_name)
        except:
            pass
        return list
    except:
        try:
            if flag:
                shutil.rmtree('./sources/python/py-'+pkg_name+'/EGG-INFO',
                              ignore_errors=True)
                items = os.listdir('./sources/python/py-'+pkg_name)
                for item in items[:]:
                    if not(item.split('.')[-1] == 'gz' or item.split('.')[-1] == 'zip'):
                        os.remove('./sources/python/py-'+pkg_name+'/'+item)
                        items.remove(item)
                if not items:
                    os.rmdir('./sources/python/py-'+pkg_name)
        except:
            pass
        return False


""" Creates a diff file for an existent port """


def create_diff(old_file, new_file, diff_file):
    with open(old_file) as f:
        a = f.readlines()
#    a = open(old_file).readlines()
    with open(new_file) as f:
        b = f.readlines()
#    b = open(new_file).readlines()
    diff_string = difflib.unified_diff(a, b, "Portfile.orig", "Portfile")
    with open(diff_file, 'w') as d:
        try:
            while 1:
                d.write(diff_string.next())
        except:
            pass


""" Searches for an existent port by its name """


def search_port(name):
    try:
        command = "port file name:^py-" + name + "$"
        command = command.split()
        existing_portfile = \
            subprocess.check_output(command, stderr=subprocess.STDOUT).strip()
        return existing_portfile
    except Exception, e:
        return False


""" Generates checksums for a package on the basis of the distfile fetched by
    its package_name and package_version """


def checksums(pkg_name, pkg_version):
    flag = False
    print "Attempting to fetch distfiles..."
    file_name = fetch_url(pkg_name, pkg_version, True)
    if file_name:
        checksums = []
        try:
            print "Generating checksums..."
            command = "openssl rmd160 "+file_name
            command = command.split()
            rmd160 = subprocess.check_output(command, stderr=subprocess.STDOUT)
            rmd160 = rmd160.split('=')[1].strip()
            checksums.insert(0, rmd160)

            command = "openssl sha256 "+file_name
            command = command.split()
            sha256 = subprocess.check_output(command, stderr=subprocess.STDOUT)
            sha256 = sha256.split('=')[1].strip()
            checksums.insert(1, sha256)

            dir = '/'.join(file_name.split('/')[0:-1])
            if flag:
                os.remove(file_name)
            try:
                if flag:
                    os.rmdir(dir)
            except OSError as ex:
                pass
            return checksums
        except:
            print "Error\n"
            return


""" Searches if the distfile listed is present or not """


def search_distfile(name, version):
    try:
        url = client.release_urls(name, version)[0]['url']
        r = requests.get(url, verify=False)
        if not r.status_code == 200:
            raise Error('No distfile')
    except:
        print "No distfile found"
        print "Please set a DISTFILE env var before generating the portfile"
        sys.exit(0)


""" Maps the license passed to the already present list of
    licences available in Macports """


def search_license(license):
    license = license.lower()
    patterns = ['.*mit.*', '.*apache.*2', '.*apache.*', '.*bsd.*', '.*agpl.*3',
                '.*agpl.*2', '.*agpl.*', '.*affero.*3', '.*affero.*2',
                '.*affero.*', '.*lgpl.*3', '.*lgpl.*2', '.*lgpl.*', '.*gpl.*3',
                '.*gpl.*2', '.*gpl.*', '.*general.*public.*license.*3',
                '.*general.*public.*license.*2',
                '.*general.*public.*license.*', '.*mpl.*3', '.*mpl.*2',
                '.*mpl.*', '.*python.*license.*', '^python$', '.*']
    licenses = ['MIT', 'Apache-2', 'Apache', 'BSD', 'AGPL-3', 'AGPL-2', 'AGPL',
                'AGPL-3', 'AGPL-2', 'AGPL', 'LGPL-3', 'LGPL-2', 'LGPL',
                'GPL-3', 'GPL-2', 'GPL', 'GPL-3', 'GPL-2', 'GPL', 'MPL-3',
                'MPL-2', 'MPL', 'Python', 'Python', 'NULL']
    for i in range(len(patterns)):
        match = re.search(patterns[i], license)
        if match:
            return licenses[i]


""" Port Testing function for various phase implementations """


def port_testing(name, portv='27'):
    euid = os.geteuid()
    if euid:
        args = ['sudo', sys.executable] + sys.argv + [os.environ]
        os.execlpe('sudo', *args)

    for phase in [port_fetch, port_checksum, port_extract, port_configure,
                  port_build, port_destroot, port_clean]:
        print phase.__name__
        phase_output = phase(name, portv)
        if phase_output:
            print phase.__name__ + " - SUCCESS"
        else:
            print phase.__name__ + " FAILED"
            port_clean(name, portv)
            print "Exiting"
            sys.exit(1)

        euid = os.geteuid()
        if euid:
            args = ['sudo', sys.executable] + sys.argv + [os.environ]
            os.execlpe('sudo', *args)


""" Fetch phase implementation """


def port_fetch(name, portv='27'):
    try:
        command = "sudo port -t fetch dports/python/py-" + \
                  name + " subport=py" + portv + "-" + name
        command = command.split()
        phase_output = subprocess.check_call(command, stderr=subprocess.STDOUT)
        return True
    except:
        return False


""" Checksum phase implementation """


def port_checksum(name, portv='27'):
    try:
        command = "sudo port -t checksum dports/python/py-" + \
                  name + " subport=py" + portv + "-" + name
        command = command.split()
        phase_output = subprocess.check_call(command, stderr=subprocess.STDOUT)
        return True
    except:
        return False


""" Checksum phase implementation """


def port_extract(name, portv='27'):
    try:
        command = "sudo port -t extract dports/python/py-" + \
                  name + " subport=py" + portv + "-" + name
        command = command.split()
        phase_output = subprocess.check_call(command, stderr=subprocess.STDOUT)
        return True
    except:
        return False


""" Patch phase implementation """


def port_patch(name, portv='27'):
    try:
        command = "sudo port -t patch dports/python/py-" + \
                  name + " subport=py" + portv + "-" + name
        command = command.split()
        phase_output = subprocess.check_call(command, stderr=subprocess.STDOUT)
        return True
    except:
        return False


""" Configure phase implementation """


def port_configure(name, portv='27'):
    try:
        command = "sudo port -t configure dports/python/py-" + \
                  name + " subport=py" + portv + "-" + name
        command = command.split()
        phase_output = subprocess.check_call(command, stderr=subprocess.STDOUT)
        return True
    except:
        return False


""" Build phase implementation """


def port_build(name, portv='27'):
    try:
        command = "sudo port -t build dports/python/py-" + \
                  name + " subport=py" + portv + "-" + name
        command = command.split()
        phase_output = subprocess.check_call(command, stderr=subprocess.STDOUT)
        return True
    except:
        return False


""" Destroot phase implementation """


def port_destroot(name, portv='27'):
    try:
        command = "sudo port -t destroot dports/python/py-" + \
                  name + " subport=py" + portv + "-" + name
        command = command.split()
        phase_output = subprocess.check_call(command, stderr=subprocess.STDOUT)
        return True
    except:
        return False


""" Clean phase implementation """


def port_clean(name, portv='27'):
    try:
        command = "sudo port -t clean dports/python/py-" + \
                  name + " subport=py" + portv + "-" + name
        command = command.split()
        phase_output = subprocess.check_call(command, stderr=subprocess.STDOUT)
        return True
    except:
        return False


""" Creates a portfile on the basis of the release_data and release_url fetched
    on the basis of package_name and package_version """


def create_portfile(dict, file_name, dict2):
    search_distfile(dict['name'], dict['version'])
    print "Creating Portfile for pypi package " + dict['name'] + "..."
    with open(file_name, 'w') as file:
        file.write('# -*- coding: utf-8; mode: tcl; tab-width: 4; ')
        file.write('indent-tabs-mode: nil; c-basic-offset: 4 ')
        file.write('-*- vim:fenc=utf-8:ft=tcl:et:sw=4:ts=4:sts=4\n')
        file.write('# $Id$\n\n')
        file.write('PortSystem          1.0\n')
        file.write('PortGroup           python 1.0\n\n')

        file.write('name                py-{0}\n'.format(dict['name']))
        file.write('version             {0}\n'.format(dict['version']))

        file.write('platforms           darwin\n')
        license = dict['license']
        license = search_license(license)
        file.write('license             {0}\n'.format(license))

        if dict['maintainer']:
            maintainers = ' '.join(dict['maintainer'])
            if not maintainers == "UNKNOWN":
                file.write('maintainers         {0}\n\n'.format(maintainers))
            else:
                file.write('maintainers         {0}\n\n'.format(
                           os.getenv('maintainer', 'nomaintainer')))
        else:
            print "No maintainers found..."
            print "Looking for maintainers in environment variables..."
            file.write('maintainers         {0}\n\n'.format(
                       os.getenv('maintainer', 'nomaintainer')))

        summary = dict['summary']
        if summary:
            summary = re.sub(r'[\[\]\{\}\;\:\$\t\"\'\`\=(--)]+',
                             ' ', summary)
            summary = re.sub(r'\s(\s)+', ' ', summary)
            summary = summary.encode('utf-8')
            summary = filter(lambda x: x in string.printable, summary)
            sum_lines = textwrap.wrap(summary)
            file.write('description         ')
            for sum_line in sum_lines:
                if sum_line:
                    if not sum_lines.index(sum_line) == 0:
                        file.write('                    ')
                    if sum_line == sum_lines[-1]:
                        file.write("{0}\n".format(sum_line))
                    else:
                        file.write("{0} \\\n".format(sum_line))
        else:
            file.write('description         None\n\n')
        description = dict['description']
#        if description:
#            description = description.encode('utf-8')
#            description = filter(lambda x: x in string.printable, description)
#            description = re.sub(r'[\[\]\{\}\;\:\$\t\"\'\`\=(--)]+',
#                                 ' ', description)
#            description = re.sub(r'\s(\s)+', ' ', description)
#            lines = textwrap.wrap(description, width=70)
#            file.write('long_description    ')
#            for line in lines:
#                if line and lines.index(line) < 4:
#                    if not lines.index(line) == 0:
#                        file.write('                    ')
#                    if lines.index(line) >= 3:
#                        file.write("{0}...\n".format(line))
#                    elif line == lines[-1]:
#                        file.write("{0}\n".format(line))
#                    else:
#                        file.write("{0} \\\n".format(line))
#        else:
#            file.write('long_description    ${description}\n\n')
        file.write('long_description    ${description}\n\n')
        home_page = dict['home_page']

        if home_page and not home_page == 'UNKNOWN':
            file.write('homepage            {0}\n'.format(home_page))
        else:
            print "No homepage found..."
            print "Looking for homepage in environment variables..."
            file.write('homepage            {0}\n'.format(
                       os.getenv('home_page', '')))

#        for item in dict2:
#            if item['python_version'] == 'source':
#                master_var = item['url']
#                break
#        print master_var
#        master_site = '/'.join(master_var.split('/')[0:-1])
#        print master_site
#        sys.exit(1)

        try:
#                print dict2
#                print dict2['url']
                for item in dict2:
                    if item['python_version'] == 'source':
                        master_var = item['url']
                        break
#                print master_var
                master_site = '/'.join(master_var.split('/')[0:-1])
                ext = master_var.split('/')[-1].split('.')[-1]
                if ext == 'zip':
                    zip_set = True
                else:
                    zip_set = False
#                print master_site
        except:
            if dict['release_url']:
                master_site = dict['release_url']
#                print master_site
            else:
                print "No master site found..."
                print "Looking for master site in environment variables..."
                master_site = os.getenv('master_site', '')
        if master_site:
            file.write('master_sites        {0}\n'.format(master_site))
            master_site_exists = True
        else:
            master_site_exists = False

        if zip_set:
            file.write('use_zip             yes\n')
            file.write('extract.mkdir       yes\n')

        file.write('distname            {0}-{1}\n\n'.format(
                   dict['name'], dict['version']))

        print "Attempting to generate checksums for " + dict['name'] + "..."
        checksums_values = checksums(dict['name'], dict['version'])
        if checksums_values:
            file.write('checksums           rmd160  {0} \\\n'.format(
                       checksums_values[0]))
            file.write('                    sha256  {0}\n\n'.format(
                       checksums_values[1]))

        python_vers = dict['requires_python']
        if python_vers:
            file.write('python.versions     25 26 27 {0}\n\n'.format(
                       dict['requires_python']))
        else:
            file.write('python.versions     25 26 27 32 33 34\n\n')

        print "Finding dependencies..."
        file.write('if {${name} ne ${subport}} {\n')
        file.write('    depends_build-append \\\n')
        file.write('                        ' +
                   'port:py${python.version}-setuptools\n')
        deps = dependencies(dict['name'], dict['version'], True)
        if deps:
            for i,dep in enumerate(deps):
                dep = dep.split('>')[0].split('=')[0]
                dep = dep.replace('[','').replace(']','')
                deps[i] = dep
#            print deps
            for dep in deps:
                if dep in ['setuptools', '', '\n']:
                    while deps.count(dep) > 0:
                        deps.remove(dep)


#            for dep in deps:
#                dep = dep.split('>')[0].split('=')[0]
#                dep = dep.replace('[','').replace(']','')
#            for item in ['setuptools', '', '\n']:
#                while deps.count(item) > 0:
#                    deps.remove(item)
            if len(deps) > 0:
                file.write('    depends_run-append \\\n')
#                file.write('                        ' +
#                           'port:py${python.version}-setuptools')
#                file.write(" \\\n")
                for dep in deps[:-1]:
                    file.write('                        ' +
                               'port:py${python.version}-' +
                               dep + ' \\\n')
                else:
                    file.write('                        ' +
                               'port:py${python.version}-' +
                               deps[-1] + '\n')
            else:
                file.write("\n")
        file.write('\n')
        file.write('    livecheck.type      none\n')
        if master_site_exists:
            file.write('} else {\n')
            file.write('    livecheck.type      regex\n')
            file.write('    livecheck.url       ${master_sites}\n')
            file.write('}\n')
        else:
            file.write('}\n')
    print "Searching for existent port..."
    port_exists = search_port(dict['name'])
    if port_exists:
        print "Creating diff..."
        old_file = port_exists
        new_file = './dports/python/py-'+dict['name']+'/Portfile'
        diff_file = './dports/python/py-'+dict['name']+'/patch.Portfile.diff'
        create_diff(old_file, new_file, diff_file)
        print str(os.path.abspath(diff_file))+"\n"
#        with open(diff_file) as diff:
#            print diff.read()
        print "\nIf you want to open a new ticket. Please visit"
        print "https://trac.macports.org/auth/login/?next=/newticket"
        print "to open a new ticket after logging in with your credentials."
    else:
        print "No port found."


""" Creates the directories and other commands necessary
    for a development environment """


def print_portfile(pkg_name, pkg_version=None):
    root_dir = os.path.abspath("./dports")
    port_dir = os.path.join(root_dir, 'python')
    home_dir = os.path.join(port_dir, 'py-'+pkg_name)
    if not os.path.exists(root_dir):
        os.makedirs(root_dir)
        try:
            command = 'portindex dports/'
            command = command.split()
            subprocess.call(command, stderr=subprocess.STDOUT)
        except:
            pass
    if not os.path.exists(port_dir):
        os.makedirs(port_dir)
    if not os.path.exists(home_dir):
        os.makedirs(home_dir)

    print "Attempting to fetch data from pypi..."

    dict = client.release_data(pkg_name, pkg_version)
    dict2 = client.release_urls(pkg_name, pkg_version)
    if dict and dict2:
        print "Data fetched successfully."
    elif dict:
        print "Release Data fetched successfully."
    elif dict2:
        print "Release url fetched successfully."
    else:
        print "No data found."

    file_name = os.path.join(home_dir, "Portfile")
    create_portfile(dict, file_name, dict2)
    print "SUCCESS\n"


""" Main function - Argument Parser """


def main(argv):
    parser = argparse.ArgumentParser(description="Pypi2Port Tester")
# Calls list_all() which lists al available python packages
    parser.add_argument('-l', '--list', action='store_true', dest='list',
                        default=False, required=False,
                        help='List all packages')
# Calls search with the package_name
    parser.add_argument('-s', '--search', action='store', type=str,
                        dest='packages_search', nargs='*', required=False,
                        help='Search for a package')
# Calls release_data with package_name and package_version
    parser.add_argument('-d', '--data', action='store',
                        dest='packages_data', nargs='*', type=str,
                        help='Releases data for a package')
# Calls fetch_url with the various package_releases
    parser.add_argument('-f', '--fetch', action='store', type=str,
                        dest='package_fetch', nargs='*', required=False,
                        help='Fetches distfiles for a package')
# Calls print_portfile with the release data available
    parser.add_argument('-p', '--portfile', action='store', type=str,
                        dest='package_portfile', nargs='*', required=False,
                        help='Prints the portfile for a package')
# Calls port_testing
    parser.add_argument('-t', '--test', action='store', type=str,
                        dest='package_test', nargs='*', required=False,
                        help='Tests the portfile for various phase tests')
    options = parser.parse_args()

    if options.list:
        list_all()
        return


    if options.packages_search:
        for pkg_name in options.packages_search:
            search(pkg_name)
        return


    if options.packages_data:
        pkg_name = options.packages_data[0]
        if len(options.packages_data) > 1:
            pkg_version = options.packages_data[1]
            release_data(pkg_name, pkg_version)
        else:
            if client.package_releases(pkg_name):
                pkg_version = client.package_releases(pkg_name)[0]
                release_data(pkg_name, pkg_version)
            else:
                print "No release found\n"
        return


    if options.package_fetch:
        pkg_name = options.package_fetch[0]
        if len(options.package_fetch) > 1:
            pkg_version = options.package_fetch[1]
            fetch_url(pkg_name, pkg_version)
        else:
            releases = client.package_releases(pkg_name)
            if releases:
                pkg_version = releases[0]
                fetch_url(pkg_name, pkg_version)
            else:
                print "No release found\n"
        return


    if options.package_portfile:
        pkg_name = options.package_portfile[0]
        if len(options.package_portfile) > 1:
            pkg_version = options.package_portfile[1]
            print_portfile(pkg_name, pkg_version)
        else:
            vers = client.package_releases(pkg_name)
            if vers:
                pkg_version = vers[0]
                print_portfile(pkg_name, pkg_version)
            else:
                print "No release found\n"
        return


    if options.package_test:
        if len(options.package_test) > 0:
            pkg_name = options.package_test[0]
            port_testing(pkg_name)
        else:
            print "No package name specified\n"
        return

    parser.print_help()
    parser.error("No input specified")

if __name__ == "__main__":
    main(sys.argv[1:])
