#!/usr/bin/python    
import ConfigParser,sys
config = ConfigParser.RawConfigParser()
config.read('elb.properties')

section = sys.argv[1]
property = sys.argv[2]

if not ((config.has_section("Generic")) and (config.has_section("Listener")) and (config.has_section("Network")) and (config.has_section("Tags"))):  
	print "Error"


print config.get(section, property);
