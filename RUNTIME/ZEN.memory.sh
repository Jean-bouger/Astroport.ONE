################################################################################
# Author: Fred (support@qo-op.com)
# Version: 0.1
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
################################################################################
#~ ZEN.memory.sh
#~ Search for last "UPLANET:$1:..." in UPLANETG1PUB wallet history
#~ INTERCOM="UPLANET:${SECTOR}:${TODATE}:/ipfs/${IPFSPOP}" TX COMMENT are made during SECTOR.refresh.sh
#~ ~/.zen/tmp/${MOATS}/${SECTOR} <=> "/ipfs/$ipfs_pop"
################################################################################
################################################################################
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
. "${MY_PATH}/../tools/my.sh"
################################################################################

SECTOR="$1"
[[ $SECTOR == "" ]] && echo "MISSING SECTOR MEMORY ADRESS" && exit 1
MOATS="$2"

## CHECK FOR BAD PARAM
[[ ! -d ~/.zen/tmp/${MOATS-empty}/${SECTOR-empty}/ ]] \
    && echo "BAD ~/.zen/tmp/${MOATS}/${SECTOR}" \
    && exit 1

## STARTING
start=`date +%s`

## EXTRACT WORLDG1PUB HISTORY
${MY_PATH}/timeout.sh -t 20 $MY_PATH/jaklis/jaklis.py history -n 300 -p ${WORLDG1PUB} -j \
    > ~/.zen/tmp/${MOATS}/${WORLDG1PUB}.g1history.json

## SCAN FOR UPLANET:${SECTOR} in TX
if [[ -s ~/.zen/tmp/${MOATS}/${WORLDG1PUB}.g1history.json ]]; then

    intercom=$(jq -r '.[] | select(.comment | test("UPLANET:'"${SECTOR}"'")) | .comment' ~/.zen/tmp/${MOATS}/${WORLDG1PUB}.g1history.json)
    ipfs_pop=$(echo "$intercom" | grep -oP 'UPLANET:'"${SECTOR}"':/ipfs/\K[^"]+')
    todate=$(echo "$intercom" | grep -oP 'UPLANET:'"${SECTOR}"':\K[^:]*')
    echo "SYNC ~/.zen/tmp/${MOATS}/${SECTOR} <=> /ipfs/$ipfs_pop"

    if [[ $ipfs_pop ]]; then
        echo "from $todate memory slot"
        ipfs --timeout 90s get -o ~/.zen/tmp/${MOATS}/${SECTOR} /ipfs/$ipfs_pop
        end=`date +%s`
        echo "(${SECTOR}) ${todate} get time : "`expr $end - $start` seconds.
    else
        echo "WARNING cannot remember... scan for more TX ??!"
    fi

else
    echo "FATAL ERROR cannot access to WORLDG1PUB history"
    exit 1
fi

exit 0
