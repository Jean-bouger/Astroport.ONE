################################################################################
# Author: Fred (support@qo-op.com)
# Version: 0.1
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
################################################################################
################################################################################
## API: SALT & PEPPER
################################################################################
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
. "${MY_PATH}/../tools/my.sh"

HTTPCORS="HTTP/1.1 200 OK
Access-Control-Allow-Origin: ${myASTROPORT}
Access-Control-Allow-Credentials: true
Access-Control-Allow-Methods: GET
Server: Astroport.ONE
Content-Type: text/html; charset=UTF-8

"

start=`date +%s`

PORT=$1 THAT=$2 AND=$3 THIS=$4  APPNAME=$5 WHAT=$6 OBJ=$7 VAL=$8 MOATS=$9
### transfer variables according to script
QRCODE=$THAT
URL=$THIS
TYPE=$WHAT

## GET TW
mkdir -p ~/.zen/tmp/${MOATS}/

ASTRONAUTENS=$(~/.zen/Astroport.ONE/tools/g1_to_ipfs.py ${QRCODE})
        [[ ! ${ASTRONAUTENS} ]] \
        && (echo "$HTTPCORS ERROR - ASTRONAUTENS !!"  | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) \
        && exit 1

echo "ipfs --timeout 120s cat  /ipns/$ASTRONAUTENS > ~/.zen/tmp/${MOATS}/index.html"
ipfs --timeout 120s cat  /ipns/$ASTRONAUTENS > ~/.zen/tmp/${MOATS}/index.html

if [[ -s ~/.zen/tmp/${MOATS}/index.html ]]; then

    tiddlywiki --load ~/.zen/tmp/${MOATS}/index.html --output ~/.zen/tmp/${MOATS} --render '.' "MadeInZion.json" 'text/plain' '$:/core/templates/exporters/JsonFile' 'exportFilter' 'MadeInZion'

    [[ ! -s ~/.zen/tmp/${MOATS}/MadeInZion.json ]] \
    && ( echo "~~~ NO /ipns/$ASTRONAUTENS (☓‿‿☓) CREATE A TW ~~~" | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 & ) \
    && exit 1

    GPLAYER=$(cat ~/.zen/tmp/${MOATS}/MadeInZion.json | jq -r .[].player)


    REPLACE="https://$myTUBE/ipns/${ASTRONAUTENS}" \

    ## REDIRECT TO TW OR GCHANGE PROFILE
    sed "s~_TWLINK_~${REPLACE}/~g" ~/.zen/Astroport.ONE/templates/index.302  > ~/.zen/tmp/${MOATS}/index.redirect
    echo "url='"${REPLACE}"'" >> ~/.zen/tmp/${MOATS}/index.redirect

    (
    cat ~/.zen/tmp/${MOATS}/index.redirect | nc -l -p ${PORT} -q 1 > /dev/null 2>&1
    ) &

    exit 0

fi

###################################################################################################
###################################################################################################
# API TWO : ?qrcode=G1PUB&url=____&type=____


        ## Astroport.ONE local use QRCODE Contains ${WHAT} G1PUB
        g1pubpath=$(grep $QRCODE ~/.zen/game/players/*/.g1pub | cut -d ':' -f 1 2>/dev/null)
        PLAYER=$(echo "$g1pubpath" | rev | cut -d '/' -f 2 | rev 2>/dev/null)

        ## FORCE LOCAL USE ONLY. Remove to open 1234 API
        [[ ! -d ~/.zen/game/players/${PLAYER} || ${PLAYER} == "" ]] \
        && (echo "$HTTPCORS ERROR - QRCODE - NO ${PLAYER} ON BOARD !!"  | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) \
        && exit 1

        ## Demande de copie d'une URL reçue.
        if [[ $URL ]]; then
             [[ ${TYPE} ]] && CHOICE="${TYPE}" || CHOICE="Youtube"

            ## CREATION TIDDLER "G1Voeu" G1CopierYoutube
            # CHOICE = "Video" Page MP3 Web
            ~/.zen/Astropor.ONE/ajouter_media.sh "${URL}" "$PLAYER" "$CHOICE" &

            echo "## Insertion tiddler : G1CopierYoutube"
            echo '[
  {
    "title": "'${MOATS}'",
    "type": "'text/vnd.tiddlywiki'",
    "text": "'${URL}'",
    "tags": "'CopierYoutube ${WHAT}'"
  }
]
' > ~/.zen/tmp/${WHAT}.${MOATS}.import.json

            ## TODO ASTROBOT "G1AstroAPI" READS ~/.zen/tmp/${WHAT}.${MOATS}.import.json

            (echo "$HTTPCORS OK - ~/.zen/tmp/${WHAT}.${MOATS}.import.json WORKS IF YOU MAKE THE WISH voeu 'AstroAPI'"   | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && exit 0

        else

            (echo "$HTTPCORS ERROR - ${AND} - ${THIS} UNKNOWN"   | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && exit 1

        fi
