#!/bin/bash
MYDIR="$(realpath $(dirname $(echo ${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]})))"

echo $MYDIR

# Set AOSP Path
if [ -z "$AOSP_SRC_PATH" ]; then
	echo "Enter AOSP src path:"
	read srcpath
	AOSP_SRC_PATH=$srcpath
    export AOSP_SRC_PATH=$AOSP_SRC_PATH
fi

echo "AOSP Source: $AOSP_SRC_PATH"

# find where is the patch lying
dirs=($(find . -name *.patch -exec dirname {} \; | sort -u ))

for dir in "${dirs[@]}"; do
	cd $dir
	PATCH_DIR=$(pwd)
	files=($(find . -type f -name '*.patch' | sort -n))
	count=($(find . -type f -name '*.patch' | wc -l ))
    if [ $count -gt 0 ]; then
        cd $AOSP_SRC_PATH/$dir
        for file in "${files[@]}"; do
            echo ""
            echo "applying patch@: $AOSP_SRC_PATH/$dir"
            echo "which patch: $file"
		    git am --signoff $PATCH_DIR/$file >> $PATCH_DIR/log 2>&1
		    if [ $? -eq 128 ]; then
			    echo "Patch Failed. Lookup $PATCH_DIR/log for more info. Aborting..."
			    git am --abort
		    fi
		done
	fi
	cd $MYDIR 
done


