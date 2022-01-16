#!/bin/sh

source collections.sh

# This is based off if you're using the stack init docker method. Change this to what you're using.
localDbHost='localhost:27017'
localDbUser='root'
localDbPass='foobar'

for i in ${!collections[@]};
do
    collection=${collections[$i]}
    echo "Importing collection ${collection}..."
    mongoimport --uri="mongodb://${localDbUser}:${localDbPass}@${localDbHost}/ps2alerts?authSource=admin" --collection=${collection} --file=dumps/${collection}.json
    echo "Collection ${collection} imported!"
done