# -*- coding: utf-8 -*-
#!/usr/bin/python

import sys
try:
    import xmlrpclib
except ImportError:
    import xmlrpc.client as xmlrpclib

client = xmlrpclib.ServerProxy('http://pypi.python.org/pypi')


def list_all():
    list_packages=client.list_packages()
    for package in list_packages:
	print package

def search(str):
    values=client.search({'name':str})[0]
    for key in values.keys():
        print key,'-->',values[key]

def data(str):
    version=client.search({'name':str})[0]['version']
    values=client.release_data(str,version)
    for key in values.keys():
        print key,'-->',values[key]

def main(argv):
    for opt in argv:
        if opt == 'list_all':
            list_all()
	    sys.exit()	
	elif opt == 'search':
	    name=argv[argv.index('search')+1]
	    search(name)
	    sys.exit()	
	elif opt=='data':
	    name=argv[argv.index('data')+1]
	    data(name)
	    sys.exit()	
	else:
            print 'usage: tester.py search <package_name>'

if __name__ == "__main__":
    main(sys.argv[1:])
