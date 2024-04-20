#!/bin/sh

cd raw

# First get dictionaries
wget -O sippl04puw3.dct  https://data.nber.org/sipp/2004/sippl04puw3.dct
wget -O sippl04puw4.dct  https://data.nber.org/sipp/2004/sippl04puw4.dct
wget -O sippp04putm3.dct https://data.nber.org/sipp/2004/sippp04putm3.dct
wget -O sippp04putm4.dct https://data.nber.org/sipp/2004/sippp04putm4.dct

# Then get DAT files
wget -O l04puw3.zip  https://data.nber.org/sipp/2004/l04puw3.zip
wget -O l04puw4.zip  https://data.nber.org/sipp/2004/l04puw4.zip
wget -O p04putm3.zip https://data.nber.org/sipp/2004/p04putm3.zip
wget -O p04putm4.zip https://data.nber.org/sipp/2004/p04putm4.zip

# Then get do files
wget -O wave3cr.do https://data.nber.org/sipp/2004/sippl04puw3.do
wget -O wave4cr.do https://data.nber.org/sipp/2004/sippl04puw4.do
wget -O wave3tm.do https://data.nber.org/sipp/2004/sippp04putm3.do
wget -O wave4tm.do https://data.nber.org/sipp/2004/sippp04putm4.do

# Unzip the raw files
unzip -o l04puw3.zip
unzip -o l04puw4.zip
unzip -o p04putm3.zip
unzip -o p04putm4.zip

# Get rid of path in dictionary files (since this path is specific to NBER's servers)
for f in *.dct ; do
    # extract modification date and time of file
    MODTIME=`stat -c %Y "$f"`
    HMODTIME=`date -d @"$MODTIME"`
    # make the replacement with sed and update file
    sed -i '1d' $f
    sed -i '1s/^/infile dictionary { \n/' $f
    touch -d @$MODTIME "$f"
    echo "Modified: " "$f"
    echo "Modification date/time: " $HMODTIME "(sec since epoch: "$MODTIME")"
done

# Uncomment rows of dictionary files that are commented
for f in *.dct ; do
    # extract modification date and time of file
    MODTIME=`stat -c %Y "$f"`
    HMODTIME=`date -d @"$MODTIME"`
    # make the replacement with sed and update file
    sed -i 's|*#||ig' $f
    touch -d @$MODTIME "$f"
    echo "Modified: " "$f"
    echo "Modification date/time: " $HMODTIME "(sec since epoch: "$MODTIME")"
done

# Now edit do files using sed
for f in wave*tm.do ; do
    # extract modification date and time of file
    MODTIME=`stat -c %Y "$f"`
    HMODTIME=`date -d @"$MODTIME"`
    # make the replacement with sed and update file
    sed -i '2d' $f
    touch -d @$MODTIME "$f"
    echo "Modified: " "$f"
    echo "Modification date/time: " $HMODTIME "(sec since epoch: "$MODTIME")"
done

for f in wave3tm.do ; do
    # extract modification date and time of file
    MODTIME=`stat -c %Y "$f"`
    HMODTIME=`date -d @"$MODTIME"`
    # make the replacement with sed and update file
    sed -i '4633iegen id   = group(ssuid epppnum)' $f
    sed -i '4634iegen hhid = group(ssuid shhadid)' $f
    touch -d @$MODTIME "$f"
    echo "Modified: " "$f"
    echo "Modification date/time: " $HMODTIME "(sec since epoch: "$MODTIME")"
done

for f in wave4tm.do ; do
    # extract modification date and time of file
    MODTIME=`stat -c %Y "$f"`
    HMODTIME=`date -d @"$MODTIME"`
    # make the replacement with sed and update file
    sed -i '10790iegen id   = group(ssuid epppnum)' $f
    sed -i '10791iegen hhid = group(ssuid shhadid)' $f
    touch -d @$MODTIME "$f"
    echo "Modified: " "$f"
    echo "Modification date/time: " $HMODTIME "(sec since epoch: "$MODTIME")"
done

for f in wave*cr.do ; do
    # extract modification date and time of file
    MODTIME=`stat -c %Y "$f"`
    HMODTIME=`date -d @"$MODTIME"`
    # make the replacement with sed and update file
    sed -i '9464iegen id   = group(ssuid epppnum)' $f
    sed -i '9465iegen hhid = group(ssuid shhadid)' $f
    touch -d @$MODTIME "$f"
    echo "Modified: " "$f"
    echo "Modification date/time: " $HMODTIME "(sec since epoch: "$MODTIME")"
done

for f in wave*.do ; do
    # extract modification date and time of file
    MODTIME=`stat -c %Y "$f"`
    HMODTIME=`date -d @"$MODTIME"`
    # make the replacement with sed and update file
    sed -i 's|/homes/data/sipp/2004/||ig' $f
    sed -i 's|saveold|save|ig' $f
    touch -d @$MODTIME "$f"
    echo "Modified: " "$f"
    echo "Modification date/time: " $HMODTIME "(sec since epoch: "$MODTIME")"
done

cd ..
