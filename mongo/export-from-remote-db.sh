#!/bin/sh

source collections.sh

urlencode() {
  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    case $c in
      [a-zA-Z0-9.~_-]) printf "$c" ;;
    *) printf "$c" | xxd -p -c1 | while read x;do printf "%%%s" "$x";done
  esac
done
}

if [ ! -d "dumps" ]; then
    mkdir dumps
fi

if [ ! $DBURL ]; then
    echo "Database password, please!"
    read password
    passwordSafe=$(urlencode $password)
    DBURL="mongodb://ps2alerts:${passwordSafe}@10.0.5.2:27017/ps2alerts?authMechanism=SCRAM-SHA-1&readPreference=primary&ssl=false&directConnection=true"
    exit 1
fi

# Change the username and hostname to suit you, I'm not doing everything for you. This is based off a local tunnel to the mongodb pod directly.
for i in ${!collections[@]};
do
    collection=${collections[$i]}
    echo "Exporting collection ${collection}..."
    mongoexport --uri=$DBURL --collection=$collection --out=dumps/temp/$collection.json
    echo "Collection ${collection} exported!"
done

echo "Moving from temp to real folder..."
mv dumps/temp/* dumps
echo "Done!"

ls -l dumps
