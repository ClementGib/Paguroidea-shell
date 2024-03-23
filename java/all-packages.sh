#!/bin/bash

#list all java packages in all-packages.txt file
grep '^import ' *.java |
	sed -e's/^import *//' -e's/;.*$//' |
	sort -u >all-packages.txt
