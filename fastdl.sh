#!/bin/bash

rm -R /tmp/fastdltmp
rm garrysmod/lua/autorun/server/resources.lua

# Process all files in addons folder
for i in $(find garrysmod/addons); do
    FILEPATH="$i"
    RAWPATH=${FILEPATH#garrysmod/addons/*/}
    # Check if path is not a directory and is not part of lua, gamemodes or already compressed
    if [[ ! -d "$i" && "$i" != *"lua/"* && "$i" != *"gamemodes/"* && "$i" != *".bz2"* ]]; then
        echo "CURRENT FILE: $i"
        # Add to resources.lua
        if [ "$i" != *"maps/"* ]; then
            echo "CREATING 'resource.AddFile'"
            echo "resource.AddFile(\"$RAWPATH\")" >> garrysmod/lua/autorun/server/resources.lua
        fi
        
        # Compress file to .bz2
        echo "COMPRESSING"
        /bin/bzip2 -k -f -z $FILEPATH
        
        echo ""
    fi
done

# Make fastdltmp.tar.gz archive for faster upload to fastdl server
for i in $(find garrysmod/addons); do
    FILEPATH="$i"
    RAWPATH=${FILEPATH#garrysmod/addons/*/}
    if [[ ! -d "$i" && "$i" == *".bz2"* ]]; then
	    echo "COPYING $i"
        mkdir -p /tmp/fastdltmp/$(dirname $RAWPATH)
        cp "$i" /tmp/fastdltmp/$(dirname $RAWPATH)
    fi
done

echo "CREATING ARCHIVE"
/bin/tar cf fastdltmp.tar.gz /tmp/fastdltmp