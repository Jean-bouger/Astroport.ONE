#!/bin/bash
########################################################################
# Version: 0.5
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
########################################################################
# PAD COCODING : https://pad.p2p.legal/s/G1PalPay
########################################################################
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
ME="${0##*/}"

. "${MY_PATH}/../tools/my.sh"

        CESIUM="https://g1.data.le-sou.org"
        GCHANGE="https://data.gchange.fr"

echo "(✜‿‿✜) G1PalPay : Receiving & Relaying payments to emails found in comment"
echo "$ME RUNNING"

########################################################################
# PALPAY SERVICE
########################################################################
# CHECK TODAY INCOMING PAYMENT
# IF COMMENT CONTAINS EMAIL ADDRESSES
# THEN CREATE VISA+TW AND SEND PAIMENT REMOVING FIRST FROM LIST
########################################################################
# this couls lead in several account creation sharing % of incomes each time
########################################################################

INDEX="$1"
[[ ! ${INDEX} ]] && INDEX="$HOME/.zen/game/players/.current/ipfs/moa/index.html"
[[ ! -s ${INDEX} ]] && echo "ERROR - Please provide path to source TW index.html" && exit 1
[[ ! -s ${INDEX} ]] && echo "ERROR - Fichier TW absent. ${INDEX}" && exit 1

PLAYER="$2"
[[ ! ${PLAYER} ]] && PLAYER="$(cat ~/.zen/game/players/.current/.player 2>/dev/null)"
[[ ! ${PLAYER} ]] && echo "ERROR - Please provide PLAYER" && exit 1

ASTONAUTENS=$(ipfs key list -l | grep -w ${PLAYER} | cut -d ' ' -f1)
[[ ! $ASTONAUTENS ]] && echo "ERROR - Clef IPNS ${PLAYER} introuvable!"  && exit 1

G1PUB=$(cat ~/.zen/game/players/${PLAYER}/.g1pub)
[[ ! $G1PUB ]] && echo "ERROR - G1PUB ${PLAYER} VIDE"  && exit 1

# Extract tag=tube from TW
MOATS="$3"
[[ ! $MOATS ]] && MOATS=$(date -u +"%Y%m%d%H%M%S%4N")

###################################################################
## CREATE APP NODE PLAYER PUBLICATION DIRECTORY
###################################################################
mkdir -p $HOME/.zen/tmp/${IPFSNODEID}/G1PalPay/${PLAYER}/
mkdir -p $HOME/.zen/game/players/${PLAYER}/G1PalPay/
mkdir -p $HOME/.zen/tmp/${MOATS}

~/.zen/Astroport.ONE/tools/timeout.sh -t 12 \
${MY_PATH}/../tools/jaklis/jaklis.py -k ~/.zen/game/players/${PLAYER}/secret.dunikey history -n 10 -j > $HOME/.zen/game/players/${PLAYER}/G1PalPay/$PLAYER.history.json

[[ ! -s $HOME/.zen/game/players/${PLAYER}/G1PalPay/$PLAYER.history.json ]] \
&& echo "NO PAYMENT HISTORY" \
&& exit 1

## DEBUG ## cat $HOME/.zen/game/players/${PLAYER}/G1PalPay/$PLAYER.history.json | jq -r
cat $HOME/.zen/game/players/${PLAYER}/G1PalPay/$PLAYER.history.json | jq -rc .[] | grep '@' > ~/.zen/tmp/${MOATS}/myPalPay.json

## GET @ in JSON INLINE
while read LINE; do

    echo "MATCHING IN COMMENT"
    JSON=$LINE
    IDATE=$(echo $JSON | jq -r .date)
    IPUBKEY=$(echo $JSON | jq -r .pubkey)
    IAMOUNT=$(echo $JSON | jq -r .amount)
    IAMOUNTUD=$(echo $JSON | jq -r .amountUD)
    COMMENT=$(echo $JSON | jq -r .comment)

    [[ $(cat ~/.zen/game/players/${PLAYER}/.idate) -ge $IDATE ]]  && echo "PalPay $IDATE from $IPUBKEY ALREADY TREATED - continue" && continue

    ## GET EMAILS FROM COMMENT
    ICOMMENT=($(echo "$COMMENT" | grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b"))

    ## DIVIDE INCOMING AMOUNT TO SHARE
    echo "N=${#ICOMMENT[@]}"
    N=${#ICOMMENT[@]}
    SHARE=$(echo "$IAMOUNT / $N" | bc -l | cut -d '.' -f 1) ## INTEGER ROUNDED VALUE

    echo $IDATE $IPUBKEY $IAMOUNT [$IAMOUNTUD] $ICOMMENT % $SHARE %

    for EMAIL in "${ICOMMENT[@]}"; do

        [[ $EMAIL == $PLAYER ]] && echo "My PalPay" && continue

        echo "EMAIL : ${EMAIL}"
        ASTROTW="" STAMP="" ASTROG1="" ASTROIPFS="" ASTROFEED=""

        $($MY_PATH/../tools/search_for_this_email_in_players.sh ${EMAIL}) ## export ASTROTW and more

        if [[ ! ${ASTROTW} ]]; then

            echo "# NEW VISA $(date)"
            SALT="" && PEPPER=""
            echo "VISA.new : \"$SALT\" \"$PEPPER\" \"${EMAIL}\" \"$PSEUDO\" \"${URL}\""

            if [[ ! $isLAN || $USER == "zen" ]]; then

                $(${MY_PATH}/../tools/VISA.new.sh "$SALT" "$PEPPER" "${EMAIL}" "$PSEUDO" "${URL}" | tail -n 1)
                # export ASTROTW=/ipns/$ASTRONAUTENS ASTROG1=$G1PUB ASTROMAIL=$EMAIL ASTROFEED=$FEEDNS

            else

                ## CREATE new PLAYER IN myASTROTUBE
                echo "https://astroport.cancer.copylaradio.com/?salt=0&pepper=0&g1pub=_URL_&email=${EMAIL}"
                curl -so ~/.zen/tmp/${MOATS}/astro.port "https://astroport.cancer.copylaradio.com/?salt=0&pepper=0&g1pub=_URL_&email=${EMAIL}"

                TELETUBE=$(cat ~/.zen/tmp/${MOATS}/astro.port | grep "(◕‿‿◕)" | cut -d ':' -f 2 | cut -d '/' -f 3)
                TELEPORT=$(cat ~/.zen/tmp/${MOATS}/astro.port | grep "(◕‿‿◕)" | cut -d ':' -f 3 | cut -d '"' -f 1)
                sleep 30

                curl -so ~/.zen/tmp/${MOATS}/astro.rep "http://$TELETUBE:$TELEPORT"
                $(cat ~/.zen/tmp/${MOATS}/astro.rep | tail -n 1) ## SOURCE LAST LINE (SEE SALT PEPPER EMAIL API RETURN)

            fi

            ######################################################

            ${MY_PATH}/../tools/mailjet.sh "${EMAIL}" "BRO. $PLAYER  VOUS A OFFERT CE TW : $(myIpfsGw)/$ASTROTW" ## WELCOME NEW PLAYER

        fi

        ## MAKE FRIENDS & SEND G1
        echo "Hello PalPay Friend $ASTROMAIL
        TW : $ASTROTW
        G1 : $ASTROG1
        ASTROIPFS : $ASTROIPFS
        RSS : $ASTROFEED"

        [[ ! $ASTROG1 ]] \
        && echo "MISSING ASTROG1" \
        && continue

        if [[ ${ASTROG1} != ${G1PUB} ]]; then

            ~/.zen/Astroport.ONE/tools/timeout.sh -t 12 \
            ${MY_PATH}/../tools/jaklis/jaklis.py -k ~/.zen/game/players/${PLAYER}/secret.dunikey pay -a ${SHARE} -p ${ASTROG1} -c "PalPay:$N:$IPUBKEY" -m > /dev/null 2>&1
            STAMP=$?

        else

            STAMP=0

        fi

        ## DONE STAMP IT
        [[ $STAMP == 0 ]] && echo "$IDATE" > ~/.zen/game/players/${PLAYER}/.idate ## MEMORIZE LAST IDATE

    done

done < ~/.zen/tmp/${MOATS}/myPalPay.json

#################################################################
#################################################################
### NEXT #####
### TIDDLERS with EMAIL in TAGS treatment
#################################################################
## SEARCH FOR TODAY MODIFIED TIDDLERS WITH MULTIPLE EMAILS IN TAG
#################################################################
echo "# EXTRACT TODAY TIDDLERS"
tiddlywiki --load $INDEX \
                 --output ~/.zen/game/players/${PLAYER}/G1CopierYoutube/${G1PUB}/ \
                 --render '.' "today.${PLAYER}.tiddlers.json" 'text/plain' '$:/core/templates/exporters/JsonFile' 'exportFilter' '[days:created[-1]]'

## FILTER MY OWN EMAIL
cat ~/.zen/game/players/${PLAYER}/G1CopierYoutube/${G1PUB}/today.${PLAYER}.tiddlers.json | jq -rc # LOG
cat ~/.zen/game/players/${PLAYER}/G1CopierYoutube/${G1PUB}/today.${PLAYER}.tiddlers.json | sed "s~${PLAYER}~ ~g" | jq -rc '.[] | select(.tags | contains("@"))' > ~/.zen/tmp/${MOATS}/@tags.json 2>/dev/null
[[ $? != 0 ]] && echo "NO EXTRA TIDDLERS TODAY" && exit 0

echo "******************TIDDLERS with EMAIL in TAGS treatment"
#~ cat ~/.zen/game/players/${PLAYER}/G1CopierYoutube/${G1PUB}/${PLAYER}.tiddlers.json | sed "s~${PLAYER}~ ~g" | jq -rc '.[] | select(.tags | contains("@"))' > ~/.zen/tmp/${MOATS}/@tags.json

## EXTRACT NOT MY EMAIL
while read LINE; do

    echo "---------------------------------- PalPAY for Tiddler"
    TCREATED=$(echo $LINE | jq -r .created)
    TTITLE=$(echo $LINE | jq -r .title)
    TTAGS=$(echo $LINE | jq -r .tags)
    echo "$TTITLE"

    ## Count emails found
    emails=($(echo "$TTAGS" | grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b"))
    nb=${#email[@]}

    ## Get first zmail
    ZMAIL="${email}"

    MSG="+ $nb G1 TO ${email[@]}"
    echo $MSG

    ASTROTW="" STAMP="" ASTROG1="" ASTROIPFS="" ASTROFEED=""
    $($MY_PATH/../tools/search_for_this_email_in_players.sh ${ZMAIL}) ## export ASTROTW and more

    if [[ ${ASTROG1} && ${ASTROG1} != ${G1PUB} ]]; then

        ## SEND nb JUNE TO ALL
        ~/.zen/Astroport.ONE/tools/timeout.sh -t 12 \
        ${MY_PATH}/../tools/jaklis/jaklis.py -k ~/.zen/game/players/${PLAYER}/secret.dunikey pay -a $nb -p ${ASTROG1} -c "${email[@]} $TTITLE" -m > /dev/null 2>&1 ## PalPay $nb G1
        ${MY_PATH}/../tools/mailjet.sh "${PLAYER}" "OK PalPay : $MSG"
        echo "PAYMENT SENT"

    else

        ${MY_PATH}/../tools/mailjet.sh "${PLAYER}" "ERREUR PalPay : ${TTITLE} : IMPOSSIBLE DE TROUVER ${email[@]}"
        echo "NO ACCOUNT FOUND"

    fi


done < ~/.zen/tmp/${MOATS}/@tags.json

echo "****************************************"

rm -Rf $HOME/.zen/tmp/${MOATS}

exit 0