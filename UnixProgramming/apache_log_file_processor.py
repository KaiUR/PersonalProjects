#!/usr/bin/python3

import argparse
import os
import sys
from collections import Counter
from datetime import datetime

#
# This function counts the unique IP adresses in the logfile
#
def print_unique_ip(logfile):
	IPset = set()
	with open(logfile) as log:
		for line in log:
			head, sep, tail = line.partition(" ")
			if(len(head) > 1):
				IPset.add(head)
	
	log.close()
	print(len(IPset))
	return

#
# Find top N Ip adresses
#
def print_top_n_ip(N, logfile):
	IPlist = list()
	with open(logfile) as log:
		for line in log:
			head, sep, tail = line.partition(" ")
			if(len(head) > 1):
				IPlist.append(head)
	log.close()

	longest_string = 0
	for current_IP, current_Count in Counter(IPlist).most_common(N):
		if(len(current_IP) > longest_string):
			longest_string = len(current_IP)
	ipFormatted = 'IP'
	for index in range(longest_string - 2):
		ipFormatted += ' '
	print(ipFormatted, "Requests")
	for current_IP, current_Count in Counter(IPlist).most_common(N):
		print("{:{width}} {:0}".format(current_IP, current_Count, width=longest_string))

	return

#
# Finds the number of occurences of a certain IP adress in the log
#
def number_of_ocurrences(searchIP, logfile):
	IPAcessTimeList = list()
	previous_timestamp = datetime(2000, 1, 1)
	first_run = True
	count = 0
	with open(logfile) as log:
		for line in log:
			head, sep, tail = line.partition(" ")
			if(head == searchIP):
				head, sep, tail = tail.partition(" +")
				head, sep, tail = head.partition("[")
				current_timestamp = datetime.strptime(tail, '%d/%b/%Y:%H:%M:%S')
				if(first_run == True):
					first_run = False
					count += 1
					previous_timestamp = current_timestamp
				else:
					diff = previous_timestamp - current_timestamp
					previous_timestamp = current_timestamp
					if(diff.seconds > 3600):
						count += 1
	log.close()
	print(count)

	return

#
# List the requests for a IP adress
#	
def list_requests(searchIP, logfile):
	with open(logfile) as log:
		for line in log:
			head, sep, tail = line.partition(" ")
			if(head == searchIP):
				head, sep, tail = line.partition("] ")
				head, sep, tail = tail.partition("\"-\"")
				print(searchIP, "...", head, "...")
	log.close()

	return

#
# Checks for Hackers
#
def check_hackers(N, logfile):
	IPlist = list()
	with open(logfile) as log:
		for line in log:
			head, sep, tail = line.partition(" ")
			currentIPadress = head
			head, sep, tail = tail.partition("\"GET ")
			head, sep, tail = tail.partition("\"-\"")
			if(len(head) > 0):
				if(not('robots.txt ' in head or 'favicon.ico ' in head)):
					if(' 404 ' in head):
						IPlist.append(currentIPadress)
	log.close()

	print("Potential Threats:\n")
	longest_string = 0
	for current_IP, current_Count in Counter(IPlist).most_common(N):
		if(len(current_IP) > longest_string):
			longest_string = len(current_IP)
	ipFormatted = 'IP'
	for index in range(longest_string - 2):
		ipFormatted += ' '
	print(ipFormatted, "Failed Requests")
	for current_IP, current_Count in Counter(IPlist).most_common(N):
		print("{:{width}} {:0}".format(current_IP, current_Count, width=longest_string))
	return

#
# This is the main function of the program
#
def main():
	parser = argparse.ArgumentParser(description="An appache log file processor")
	parser.add_argument('-V', '--version', action='version', version='%(prog)s 1.0')
	
	group = parser.add_argument_group("Required")
	group.add_argument('-l', '--log-file',metavar = 'log-file', help='This is the log file to work on', required=True)
	optional = parser.add_argument_group("Options")
	optional.add_argument('-n', help='Displays the number of unique IP adresses', action='store_true')
	optional.add_argument('-t', metavar = 'N', help='Displays top N IP adresses', type=int)
	optional.add_argument('-v', metavar = 'IP-adress', help='Displays the number of visits of a IP adress')
	optional.add_argument('-L', metavar = 'IP-adress', help='Lists the number of requests of a IP adress')
	optional.add_argument('-s', metavar = 'N', help='Checks for potential hackers and displays top N potential IP adresses', type=int)

	
	arguments = parser.parse_args()

	if(not(os.path.isfile(arguments.log_file))):
		print('The file', arguments.log_file, 'does not exist')
		sys.exit(1)
	if(not(os.access(arguments.log_file, os.R_OK))):
		print(arguments.log_file, ': Permmisoin Denied')
		sys.exit(1)


	if(arguments.n == True):
		print_unique_ip(arguments.log_file)
	if(arguments.t):
		print_top_n_ip(arguments.t, arguments.log_file)
	if(arguments.v):
		number_of_ocurrences(arguments.v, arguments.log_file)
	if(arguments.L):
		list_requests(arguments.L, arguments.log_file)
	if(arguments.s):
		check_hackers(arguments.s, arguments.log_file)

	return
	

if __name__ == '__main__':
  main()
