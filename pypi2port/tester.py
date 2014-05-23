# -*- coding: utf-8 -*-
#! /usr/bin/env python

import urllib
import hashlib
import argparse
import sys
try:
    import xmlrpclib
except ImportError:
    import xmlrpc.client as xmlrpclib

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

def data(pkg_name,pkg_versions=None):
    print "\n"
    if not pkg_versions:
        version = client.search({'name':pkg_name})[0]['version']
        values = client.release_data(pkg_name,version)
#        print values
        if values:
            for key in values.keys():
                print key,'-->',values[key]
        else:
            print "No such package found."
            print "Please specify the exact package name."
    else:
        for version in pkg_versions:
            values = client.release_data(pkg_name,version)
#            print values
            if values:
                for key in values.keys():
                    print key,'-->',values[key]
            else:
                print "No such package found."
                print "Please specify the exact package name."
    print "\n"

def fetch(url):
    checksum_md5 = url.split('#')[-1].split('=')[-1]
    dir = './sources/'
    file_name = dir + url.split('/')[-1].split('#')[0]
    urllib.urlretrieve(url,file_name)
    checksum_md5_calc = hashlib.md5(open(file_name).read()).hexdigest()
    print "HASHES"
    print checksum_md5_calc
    print checksum_md5
    if str(checksum_md5_calc) == str(checksum_md5):
        print 'CORRECT'
    else:
        print 'ABORT'

def main(args=None):
    parser = argparse.ArgumentParser(description='pip2port tester script.')

    parser.add_argument('package_name', 
                       metavar='package_name', type=str, nargs='?', 
                       help='Package_Name')
    parser.add_argument('package_version', 
                       metavar='package_version', type=str, nargs='*', 
                       help='Package_Version(s)')
    parser.add_argument('package_url', 
                       metavar='package_url', type=str, nargs='?', 
                       help='Package_Url')
    parser.add_argument('-l', '--list_packages', action='store_const', 
                       dest='action', const='list_packages', required=False,
                       help='List all packages')
    parser.add_argument('-s', '--search', action='store_const',
                       dest='action', const='search', required=False,
                       help='Search for a package by <package_name>')
    parser.add_argument('-d', '--data', action='store_const',
                       dest='action', const='data', required=False,
                       help='Releases data for a package by <package_name>')
    parser.add_argument('-f', '--fetch', action='store_const',
                       dest='action', const='fetch', required=False,
                       help='Fetches distfile for a package by <package_url>')
    

    options=parser.parse_args()
#    print options

    if options.action == 'list_packages':
        list_all()
        return

    if options.action == 'search':
        if options.package_name == None:
            parser.error("No package name specified")
        else:
            search(options.package_name)
        return

    if options.action == 'data':
        if options.package_name == None:
            parser.error("No package name specified")
        else:
            if options.package_version == None:
                data(options.package_name)
            else:
                data(options.package_name,options.package_version)
        return

    if options.action == 'fetch':
        print options,"\n"
        if options.package_name == None:
            parser.error("No url specified")
        else:
            print options
            fetch(options.package_name)
        return
    else:
        parser.print_help()
        parser.error("No input specified")


if __name__ == "__main__":
    main()
