#! /bin/sh
""":"
exec python $0 ${1+"$@"}
"""
__doc__ = """...Tester Script for pypi2port..."""

# -*- coding: utf-8 -*-
#! /usr/bin/env python

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

client = xmlrpclib.ServerProxy('http://pypi.python.org/pypi')

def list_all():
    list_packages = client.list_packages()
    for package in list_packages:
        print package

def search(pkg_name):
    print "\n"
    values=client.search({'name':pkg_name})
    for value in values:
        for key in value.keys():
            print key,'-->',value[key]
        print "\n"

def release_data(pkg_name,pkg_version):
    print "\n"
    if pkg_version:
        values = client.release_data(pkg_name,pkg_version)
        if values:
            for key in values.keys():
                print key,'-->',values[key]
        else:
            print "No such package found."
            print "Please specify the exact package name."
        print "\n"
        return
#    else :
#        pkg_version = client.package_releases(pkg_name, True)
#        print pkg_version
#        return
#    if not pkg_version:
#        print "No release available"
#        return
#    value = {}
#    for version in pkg_version:
#        print version
#        values = client.release_data(pkg_name,version)
#        if value:
#            for key in values.keys():
#                if not value[key] or value[key]=="":
#                    values.update(key,value[key])
#        values.update(value) 
#            value = values
#    if values:
#        for key in values.keys():
#            print key,'-->',values[key]
#    else:
#        print "No such package found."
#        print "Please specify the exact package name."
    print "\n"
    return

def fetch(pkg_name,dict):
    checksum_md5 = dict['md5_digest']
    parent_dir = './sources'
    src_dir = parent_dir + '/' + pkg_name
    if not os.path.exists(parent_dir):
        os.makedirs(parent_dir)
    if not os.path.exists(src_dir):
        os.makedirs(src_dir)

    url = dict['url']
    file_name = src_dir + '/' + dict['filename']

    u = urllib2.urlopen(url)
    f = open(file_name,'wb')
    meta = u.info()
    file_size = int(meta.getheaders("Content-Length")[0])

    widgets = ['Fetching: ', Percentage(), ' ', Bar(marker=RotatingMarker(),left='[',right=']'), ' ', ETA(), ' ', FileTransferSpeed()]
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
    print
    f.close()

    checksum_md5_calc = hashlib.md5(open(file_name).read()).hexdigest()
    if str(checksum_md5) == str(checksum_md5_calc):
        print 'Successfully fetched\n'
        ext = file_name.split('.')[-1]
        if ext == 'egg':
            zip = zipfile.ZipFile(file_name)
            for name in zip.namelist():
                if name.split("/")[0] == "EGG-INFO":
#                    print name
                    zip.extract(name,src_dir)
        print "\n"
        return file_name
    else:
        print 'Aborting due to inconsistency on checksums\n'
        try:
            os.remove(file_name)
        except OSError, e:
            print "Error: %s - %s." % (e.filename,e.strerror)
        print "\n"
        return False

def fetch_url(pkg_name,pkg_version,checksum=False,deps=False):
    values = client.release_urls(pkg_name,pkg_version)
    if checksum:
        for value in values:
            if value['filename'].split('.')[-1] == 'gz':
                return fetch(pkg_name,value)
            
#    elif deps:
#        for value in values:
#            if not value['filename'].split('.')[-1] == 'gz':
#                return fetch(pkg_name,value)        
    else:
        print "\n"
        for value in values:
            return fetch(pkg_name,value)        

def dependencies(pkg_name,pkg_version,deps=False):
    if not deps:
        return
    values = client.release_urls(pkg_name,pkg_version)
    for value in values:
        if not value['filename'].split('.')[-1] == 'gz':
            fetch(pkg_name,value)
    try:
        f = open('./sources/'+pkg_name+'/EGG-INFO/requires.txt')
        list = f.readlines()
        list = [x.strip('\n') for x in list]
        f.close()
        try:
            shutil.rmtree('./sources/'+pkg_name+'/EGG-INFO', ignore_errors=True)
            items = os.listdir('./sources/'+pkg_name)
            for item in items[:]:
                if not item.split('.')[-1] == 'gz':
                    os.remove('./sources/'+pkg_name+'/'+item)
                    items.remove(item)

            if not items:
                os.rmdir('./sources/'+pkg_name)
        except:
            print ""
        return list
    except:
        try:
            shutil.rmtree('./sources/'+pkg_name+'/EGG-INFO', ignore_errors=True)
            items = os.listdir('./sources/'+pkg_name)
            for item in items[:]:
                if not item.split('.')[-1] == 'gz':
                    os.remove('./sources/'+pkg_name+'/'+item)
                    items.remove(item)
            if not items:
                os.rmdir('./sources/'+pkg_name)
        except:
            print ""
        return False


def checksums(pkg_name,pkg_version):
    file_name = fetch_url(pkg_name,pkg_version,True)
    print file_name
    if file_name:
        checksums = []
        try:
            h = hashlib.new('ripemd160')
            f = open(file_name)
            h.update(f.read())
            checksums.insert(0,h.hexdigest())
            checksums.insert(1,hashlib.sha256(f.read()).hexdigest())
            f.close()
            dir = '/'.join(file_name.split('/')[0:-1])
            os.remove(file_name)
            try:
                os.rmdir(dir)
            except OSError as ex:
                print 
            return checksums
        except:
            print "Error\n"
            return


def create_portfile(dict,file_name,dict2):
    file = open(file_name, 'w')

    file.write('# -*- coding: utf-8; mode: tcl; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- vim:fenc=utf-8:ft=tcl:et:sw=4:ts=4:sts=4\n')
    file.write('# $Id$\n\n')
    file.write('PortSystem          1.0\n')
    file.write('PortGroup           python 1.0\n\n')

    file.write('name                '+dict['name']+'\n')
    file.write('version             '+dict['version']+'\n')
#    file.write('categories-append   replaceme\n\n')

    file.write('platforms           darwin\n')
    file.write('license             '+dict['license']+'\n')
    if dict['maintainer']:
        file.write('maintainers         ' + ' '.join(dict['maintainer']) + '\n\n')
    else:
        file.write('maintainers         nomaintainer\n\n')

        
    file.write('description         '+dict['summary']+'\n\n')
#    file.write('long_description    '+dict['description']+'\n\n')
    description = dict['description']
    if description:
        description = string.replace(description,';',' ')
        description = string.replace(description,'[',' ')
        description = string.replace(description,']',' ')
        description = string.replace(description,'{',' ')
        description = string.replace(description,'}',' ')
#        lines = textwrap.wrap(dict['description'],width=70)
        lines = textwrap.wrap(description,width=70)
        file.write('long_description    ')
        for line in lines:
            if line:
                if not lines.index(line)==0:
                    file.write('                    ')
                if line == lines[-1]:
                    file.write(line+"\n")
                else:
                    file.write(line + " \\\n")
    else:
        file.write('long_description    '+'${description}'+'\n\n')
    
    file.write('homepage            '+dict['home_page']+'\n')

    if dict2:
        master_site = '/'.join(dict2[0]['url'].split('/')[0:-1])
    else:
        master_site = ''
    file.write('master_sites        '+master_site+'\n')
    file.write('distname            py-'+dict['name']+dict['version']+'\n\n')
#    rmd160 = checksum_rmd160(dict['name'],dict['version'])
#    sha256 = checksum_sha256(dict['name'],dict['version'])
    checksums_values = checksums(dict['name'],dict['version'])
#    if rmd160 and sha256:
    if checksums_values:
        file.write('checksums           rmd160  '+checksums_values[0]+' \\\n')
        file.write('                    sha256  '+checksums_values[1]+'\n\n')

    python_vers = dict['requires_python']
    if python_vers:
        file.write('python.versions     25 26 27 '+dict['requires_python']+'\n\n')
    else:
        file.write('python.versions     25 26 27\n\n')
    
    file.write('if {${name} ne ${subport}} {\n')
    file.write('    depends_build       port:py${python.version}-setuptools\n')
    deps = dependencies(dict['name'],dict['version'],True)
    if deps:
        for dep in deps:
            file.write('                        port:py-'+dep+'\n')
    file.write('\n')
    file.write('    livecheck.type      none\n')
    file.write('} else {\n')
    file.write('    livecheck.type      regex\n')
    file.write('    livecheck.url       ${master_sites}\n')
#    file.write('    livecheck.regex     \n')
    file.write('}\n')

#    file.write('    post-destroot {\n')


    file.close()


def print_portfile(pkg_name,pkg_version=None):
    print "\n"
    root_dir = os.path.abspath("./sources")
    port_dir = os.path.join(root_dir,'Python')
    home_dir = os.path.join(port_dir,pkg_name)
#    src_dir = os.path.join(home_dir,"PortFile")
    if not os.path.exists(root_dir):
        os.makedirs(root_dir)
    if not os.path.exists(port_dir):
        os.makedirs(port_dir)
    if not os.path.exists(home_dir):
        os.makedirs(home_dir)

    dict = client.release_data(pkg_name,pkg_version)
    dict2 = client.release_urls(pkg_name,pkg_version)

    file_name = os.path.join(home_dir,"Portfile")
#    try:
#        create_portfile(dict,file_name,dict2)
#        print "SUCCESS\n"
    create_portfile(dict,file_name,dict2)
    print "SUCCESS\n"
#    except:
#        print "ERROR"

def main(argv):
    parser = argparse.ArgumentParser(description="Pypi2Port Tester")
    parser.add_argument('-l', '--list', action='store_true', dest='list',
                        default=False, required=False,
                        help='List all packages')
    parser.add_argument('-s', '--search', action='store', type=str,
                        dest='packages_search', nargs='*', required=False, 
                        help='Search for a package by <package_name>')
    parser.add_argument('-d', '--data', action='store',
                        dest='packages_data', nargs='*', type=str,
                        help='Releases data for a package by <package_name>')
    parser.add_argument('-f', '--fetch', action='store', type=str,
                        dest='package_fetch', nargs=2, required=False, 
                        help='Fetches distfiles for a package by <package_name> and <package_version>')
    parser.add_argument('-p', '--portfile', action='store', type=str,
                        dest='package_portfile', nargs='*', required=False, 
                        help='Prints the portfile for a package by <package_name> and <package_version>')
    options = parser.parse_args()
#    print options

    if options.list == True:
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
            release_data(pkg_name,pkg_version)
        else:
            if client.package_releases(pkg_name):
                pkg_version = client.package_releases(pkg_name)[0]
                release_data(pkg_name,pkg_version)
#            release_data(pkg_name)
        return

    if options.package_fetch:
        pkg_name = options.package_fetch[0]
        if len(options.package_fetch) > 1:
            pkg_version = options.package_fetch[1]
            fetch_url(pkg_name,pkg_version)
        else:
            if client.package_releases(pkg_name):
                pkg_version = client.packages_releases(pkg_name)[0]
                fetch_url(pkg_name,pkg_version)
        return

    if options.package_portfile:
        pkg_name = options.package_portfile[0]
        if len(options.package_portfile) > 1:
            pkg_version = options.package_portfile[1]
#            print "PORTFILE %s %s\n" % (pkg_name,pkg_version)
            print_portfile(pkg_name,pkg_version)
        else:
            vers = client.package_releases(pkg_name)
            if vers:
                pkg_version = vers[0]
#                print "PORTFILE %s %s\n" % (pkg_name,pkg_version)
                print_portfile(pkg_name,pkg_version)
        return

    parser.print_help()
    parser.error("No input specified")

if __name__ == "__main__":
    main(sys.argv[1:])
