#!/usr/bin/env python

# populate.py
# Simulates multiple users submitting realistic data
# Uses curl to submit sample data and test rails submission code

import random
import string
import uuid
import json
import subprocess
import time
from ports import port_list

max_users = 250
max_ports_per_user = 500

url_testdeploy = 'http://statsdeploy.heroku.com/submissions'
url_dev    = 'http://127.0.0.1:3000/submissions' 

macports_versions = ['1.9.2', '1.9.99', '2.0']
osx_versions = ['10.4', '10.5', '10.6']
os_archs = ['i386', 'ppc']
os_platforms = ['darwin']
build_archs = ['x86_32', 'x86_64']
gcc_versions = ['4.2.1', '4.3.6', '4.4.6', '4.5.3', '4.6.1']
xcode_versions = ['2.5', '3.0', '3.1', '3.2', '4.0']

# Generated user ids
users = []

# The probability that a new user will be added starts at prob_new_user
prob_new_user = 95 # 95 %

# Randomly choose entries for each category
def build_os():
	os = {}
	os['macports_version'] = random.choice(macports_versions)
	os['osx_version'] = random.choice(osx_versions)
	os['os_arch'] = random.choice(os_archs)
	os['os_platform'] = random.choice(os_platforms)
	os['build_arch'] = random.choice(build_archs)
	os['gcc_version'] = random.choice(gcc_versions)
	os['xcode_version'] = random.choice(xcode_versions)
	return os

# Build up a space separated list of variants
# It selects a random number of variants to include from a list of valid variants
# for a port
def build_variants(variants):
	varlist = variants.split()
	
	size = random.randint(0, len(varlist))
	randomlist = random.sample(varlist, size)
	
	return " ".join(randomlist)

# Generate a list of ports for this user.
def build_ports():
	ports = []
	
	# Choose a random number between 0 and max_ports_per_user
	n_ports = random.randint(0, max_ports_per_user)
	
	# Generate n_port ports
	for i in range(n_ports):
		
		# Choose a random port from the list of all ports
		port = random.choice(port_list)
		
		# Generate random version strings by appending a digit to the existing version
		# eg: 2.2 -> 2.2_6
		# Only append once, check if this port's version has already been modified
		if not 'mod' in port:
			append = ''.join(random.choice(string.digits) for i in xrange(1))
			port['version'] = port['version'] + '_' + append
			port['mod'] = True # Flag that this port's version has been modified
		
		# Build up a list of variants from all valid variants for this port
		port['variants'] = build_variants(port['variants'])
		
		# Append to the list of ports to submit for this user
		ports.append(port)
	return ports

def decay_probability():
	global prob_new_user
	
	# Over time the probability that a new user will be added decreases as more users participate
	decay_factor = 0.0001
	n_users = len(users)
	prob_decay = n_users * decay_factor
	prob = prob_new_user - prob_decay
	
	prob_new_user = prob
	
	# Always keep a minimum 5% chance of growth to simulate users new to 
	# macports users coming in and participating
	if prob <= 5:
		prob_new_user = 5

def generate_uuid():
	idstr = str(uuid.uuid4())
	users.append(idstr)
	
	return idstr

def get_uuid():
	# Check if there are any available uuids
	if len(users) == 0:
		return generate_uuid()
	
	decay_probability()
	
	# Add a new user 'prob_new_user' percent of the time
	# This simulates a new user deciding to participate
	x = random.uniform(1,100)
	print str(prob_new_user) + " n_users = " + str(len(users))
	if x <= prob_new_user:
		return generate_uuid()
	else:
		# Get a random uuid from the list (simulate an existing user updating their info)
		uuid = random.choice(users)
		return uuid

def submit():
	#url = url_testdeploy
	url = url_dev
	idstr = get_uuid()
	
	data = {}
	
	data['id'] = idstr
	data['os'] = build_os()
	data['active_ports'] = build_ports()
	
	json_enc = json.dumps(data)
	args = "-d \'submission[data]=%s\'" % json_enc
	pid = subprocess.Popen('curl ' + args + ' ' + url, shell=True)
	pid.wait()

def main():
	random.seed()
	for x in range(max_users):
		submit()
		time.sleep(0.005)

if __name__ == '__main__':
	main()
