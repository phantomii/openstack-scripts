#!/usr/bin/python

import sys, ConfigParser

config = ConfigParser.RawConfigParser()

for file_name in sys.argv[1:]:
	if file_name == '-':
		config.readfp(sys.stdin)
	else:
		config.read(file_name)

config.write(sys.stdout)
