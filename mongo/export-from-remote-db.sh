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

echo "Database password, please!"
read password
passwordSafe=$(urlencode $password)

# Change the username and hostname to suit you, I'm not doing everything for you. This is based off a local tunnel to the mongodb pod directly.
for i in ${!collections[@]};
do
    collection=${collections[$i]}
    echo "Exporting collection ${collection}..."
    mongoexport --uri="mongodb://ps2alerts:${passwordSafe}@localhost:27018/ps2alerts?authSource=admin" --collection=$collection --out=dumps/temp/$collection.json
    echo "Collection ${collection} exported!"
done

echo "Moving from temp to real folder..."
mv dumps/temp/* dumps
echo "Done!"

ls -l dumps