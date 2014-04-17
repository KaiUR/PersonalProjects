#! /bin/bash

#
# Name: Kai-Uwe Rathjen
# Student Number: 12343046
# E-mail: kai-uwe.rathjen@ucdconnect.ie
#


#
# This checks that exactly two arguments are entered
#
if [ $# != 2 ]; then
	echo "Usage:" $0 "source_path destination_path"
	exit 1
fi

#
# This checks that the source exists
#
if [ ! -e $1 ]; then
	echo "Error: directory" $1 "not found"
	exit 1
fi

#
# This checks if the destination exists, and if it does
# it removes it. If the permmission to remove it is denied
# then an error message is printed
#
if [ -e $2 ]; then
	rm -rf $2 &>/dev/null
	if [ ! $? -eq 0  ]; then
         echo "Error: directory" $2 "not writable"
         exit 1
    fi
fi

#
# This goes into the directory to be read, then gests the current
# working directory and saves it in a varible, then it returns to
# the original directory.
# if premission is denied then an error message is printed
#
currentDirectory=$(pwd)
cd $1 &>/dev/null
if [ ! $? -eq 0  ]; then
         echo "Error: directory" $1 "Premission Denied"
         exit 1
fi

soucrce=$(pwd)
cd $currentDirectory

#
# This copies the source to the destination. If permission is denied 
# then an error message is printed
#
cp -R $soucrce $2 &>/dev/null
if [ ! $? -eq 0 ]; then
    echo "Error: directory" $2 "not writable"
    exit 1
fi

#
# Goes to the destination
#
cd $2

#
# This loops through every file. Then if it is a *.png file
# it is converted to a *.jpg file. The old *.png file is removed then.
# any other file is removed
#
for current in $(find . -type f); do
	if [[ ${current: -4}  == ".png" ]]; then
		current=$( echo $current | sed s/\.png//)
		convert $current.png $current.jpg
		rm -f $current.png &>/dev/null
		if [ ! $? -eq 0 ]; then
    		echo "Error: directory" $2 "not writable"
    		exit 1
		fi
	else
		rm -f $current &>/dev/null
		if [ ! $? -eq 0 ]; then
    		echo "Error: directory" $2 "not writable"
    		exit 1
		fi
	fi
done

#
# Exits normally
#
exit 0
