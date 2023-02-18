#!/bin/bash

# Ports
CONSUL_PORT="8500"
VAULT_PORT="8200"
NOMAD_PORT="4646"

CONSUL_DOMAIN="inthepicture.photo"
NOMAD_DEMO_SERVICE="focus"

# Retrieve bootstrap location from roles var file
BOOT_LOC=$(grep bootstrap_location roles/common/vars/main.yml | cut -d/ -f4 | tr -d '"')

# Token directory
TOKENS_DIR="$HOME/$BOOT_LOC"

# Error counter
ERROR=0

# Screen width
WIDTH=$(echo -e "cols"|tput -S)

# Line
line() {
  printf '%0.s-' $(seq 1 $WIDTH)
}

# Output function
output() {
  PASS="\e[32m"
  FAIL="\e[31m"
  NEUT="\e[36m"
  ENDC="\e[0m"

  NR=$1
  DESC=$2
  RESULT=$3

  NR_LENGTH=${#NR}
  if [ $NR_LENGTH -eq 0 ]; then
    NR=""
    MINUS=0
  else
    NR="$NR. "
    MINUS=2
  fi
  DESC_LENGTH=${#DESC}
  RESULT_LENGTH=${#RESULT}
  MAX_RESULT_LENGTH=9

  DOT_LENGTH=$(($WIDTH-$NR_LENGTH-2-$DESC_LENGTH-$RESULT_LENGTH-$MINUS))
  DOTS=$(printf '%0.s.' $(seq 1 $DOT_LENGTH))

  if [ "$RESULT" == "SUCCEEDED" ]; then
    BEGC=$PASS
  elif [ "$RESULT" == "TRUE" ]; then
    BEGC=$PASS
  elif [ "$RESULT" == "DONE" ]; then
    BEGC=$PASS
  elif [ "$RESULT" == "STARTED" ]; then
    BEGC=$PASS
  elif [ "$RESULT" == "RUNNING" ]; then
    BEGC=$PASS
  elif [ "$RESULT" == "HEALTHY" ]; then
    BEGC=$PASS
  elif [ "$RESULT" == "ISO-3200" ]; then
    BEGC=$PASS
  elif [ "$RESULT" == "FAILED" ]; then
    BEGC=$FAIL
    ((ERROR=ERROR+1))
  elif [ "$RESULT" == "FALSE" ]; then
    BEGC=$FAIL
    ((ERROR=ERROR+1))
  elif [ "$RESULT" == "UNHEALTHY" ]; then
    BEGC=$FAIL
    ((ERROR=ERROR+1))
  elif [ "$RESULT" == "SKIPPED" ]; then
    BEGC=$NEUT
    ((ERROR=ERROR+1))
  elif [ "$RESULT" == "ISO-100" ]; then
    BEGC=$FAIL
  else
    BEGC=$ENDC
  fi

  echo -e "$NR$DESC$DOTS[$BEGC$RESULT$ENDC]"
  sleep 0.3
}

curl () {
  command curl --connect-timeout 1 --max-time 2 "$@"
}

portcheck() {
  STAT=$(nc -w 1 -z $1 $2; echo $?)
  if [ $STAT -eq 0 ]; then
    RES="SUCCEEDED"
  else
    RES="FAILED"
  fi
  echo $RES
}

## HEADER

echo ""
echo "              .,-:;//;:=,"
echo "          . :H@@@MM@M#H/.,+%;,"
echo "       ,/X+ +M@@M@MM%=,-%HMMM@X/,"
echo "     -+@MM; %M@@MH+-,;XMMMM@MMMM@+-"
echo "    ;@M@@M- XM@X;. -+XXXXXHHH@M@M#@/."
echo "  ,%MM@@MH ,@%=             .---=-=:=,."
echo  "  =@#@@@MX.,                 -%HXMM%%%:;"
echo " =-./@M@M$                   .;@MM%%@MM:"
echo " X@/ -%MM/    +----------+    . +MM@@@M$"
echo ",@M@H: :@:    | APERTURE |     . =X#@@@@-    HashiCorp Testing Tool"
echo ",@@@MMX, .    +----------+    /H- ;@M@M=     ----------------------"
echo ".H@@@@M@+,        v1.0        %MM+..%#$."
echo " /MMMM@MMH/.                  XM@MH; =;"
echo "  /%+%%XHH@$=              , .H@@@@MX,"
echo "   .=--------.           -%H.,@@@@@MX,"
echo "   .%MM@@@HHHXX%%$%+- .:%MMX =M@@MM%."
echo "     =XMMM@MM@MM#H;,-+HMM@M+ /MMMX="
echo "       =%@M@M#@%-.=%@MM@@@M; %M%="
echo "         ,:+$+-,/H#MMMMMMM@= =,"
echo "              =++%%%%+/:-."
echo ""

line
echo "[Preparations]"
line

i=1
# Read servers
output $i "Reading Consul servers from Ansible inventory" "DONE"
CONSUL_SERVERS_GROUP=$(ansible-inventory --list | jq -r ".consul_servers.hosts | .[]" 2>/dev/null)
CONSUL_SERVERS_GROUP_STATE=$(echo $?)
if [ $CONSUL_SERVERS_GROUP_STATE ]; then
  STAT="DONE"
else
  STAT="FAILED"
fi
((i=i+1))

output $i "Reading Consul clients from Ansible inventory" "DONE"
CONSUL_CLIENTS_GROUP=$(ansible-inventory --list | jq -r ".consul_clients.hosts | .[]" 2>/dev/null)
CONSUL_CLIENTS_GROUP_STATE=$(echo $?)
if [ $CONSUL_CLIENTS_GROUP_STATE ]; then
  STAT="DONE"
else
  STAT="FAILED"
fi
((i=i+1))

output $i "Reading Vault servers from Ansible inventory" "DONE"
VAULT_SERVERS_GROUP=$(ansible-inventory --list | jq -r ".vault_servers.hosts | .[]" 2>/dev/null)
VAULT_SERVERS_GROUP_STATE=$(echo $?)
if [ $VAULT_SERVERS_GROUP_STATE ]; then
  STAT="DONE"
else
  STAT="FAILED"
fi
((i=i+1))

output $i "Reading Nomad servers from Ansible inventory" "DONE"
NOMAD_SERVERS_GROUP=$(ansible-inventory --list | jq -r ".nomad_servers.hosts | .[]" 2>/dev/null)
NOMAD_SERVERS_GROUP_STATE=$(echo $?)
if [ $NOMAD_SERVERS_GROUP_STATE ]; then
  STAT="DONE"
else
  STAT="FAILED"
fi
((i=i+1))

# Servers
declare -a CONSUL_SERVERS=($(echo $CONSUL_SERVERS_GROUP))
declare -a CONSUL_CLIENTS=($(echo $CONSUL_CLIENTS_GROUP))
declare -a VAULT_SERVERS=($(echo $VAULT_SERVERS_GROUP))
declare -a NOMAD_SERVERS=($(echo $NOMAD_SERVERS_GROUP))

# Retrieve credentials
echo ""

CONSUL_TOKEN="$(awk '/SecretID/ {print $2}' $TOKENS_DIR/management.consul.token 2>/dev/null)"
CONSUL_TOKEN_STAT=$(echo $?)
if [ $CONSUL_TOKEN_STAT -eq 0 ]; then
  STAT="DONE"
else
  STAT="FAILED"
fi
output $i "Reading Consul token from token directory" "$STAT"
((i=i+1))

VAULT_USER="atcomputing"
VAULT_PASSWORD="$(cat $TOKENS_DIR/atcomputing.vault.password 2>/dev/null)"
VAULT_USERPASS_STAT=$(echo $?)
if [ $VAULT_USERPASS_STAT -eq 0 ]; then
  STAT="DONE"
else
  STAT="FAILED"
fi
output $i "Reading Vault username and password from token directory" "$STAT"
((i=i+1))

NOMAD_TOKEN="$(awk '/Secret ID/ {print $4}' $TOKENS_DIR/management.nomad.token 2>/dev/null)"
NOMAD_TOKEN_STAT=$(echo $?)
if [ $NOMAD_TOKEN_STAT -eq 0 ]; then
  STAT="DONE"
else
  STAT="FAILED"
fi
output $i "Reading Nomad token from token directory" "$STAT"
((i=i+1))

### CONSUL

function consul_checks() {
  echo ""
  line
  echo "[Consul]"
  line

  export CONSUL_HTTP_ADDR="http://${CONSUL_SERVERS[0]}:$CONSUL_PORT"
  i=1

  ## Port check
  for C_SERVER in "${CONSUL_SERVERS[@]}"
  do
    CONSUL_PORTCHECK=$(portcheck $C_SERVER $CONSUL_PORT)
    output $i "Testing connection to Consul server $C_SERVER on port tcp/$CONSUL_PORT (CLI netcat)" $CONSUL_PORTCHECK
    ((i=i+1))
  done

  ### Consul Clients
  echo ""
  for C_CLIENT in "${CONSUL_CLIENTS[@]}"
  do
    MEMBER=$(consul members 2>/dev/null | grep $C_CLIENT | wc -l)
    if [ $MEMBER -eq 1 ]; then
      STAT="SUCCEEDED"
    else
      STAT="FAILED"
    fi
    output $i "Checking registration for Consul client $C_CLIENT (CLI consul members)" $STAT
    ((i=i+1))
  done

  ### Vault services
  echo ""
  VAULT_SERVICES=$(curl -s -H "X-Consul-Token: $CONSUL_TOKEN" http://${CONSUL_SERVERS[0]}:$CONSUL_PORT/v1/health/checks/vault | jq -r ".[] | .Node" | uniq | wc -l)
  output $i "Retrieving number of Vault services (API GET /health/checks/vault)" $VAULT_SERVICES
  ((i=i+1))

  ### Nomad server services
  NOMAD_SERVER_SERVICES=$(curl -s -H "X-Consul-Token: $CONSUL_TOKEN" http://${CONSUL_SERVERS[0]}:$CONSUL_PORT/v1/health/checks/nomad | jq -r ".[] | .Node" | uniq | wc -l)
  output $i "Retrieving number of Nomad Server services (API GET /health/checks/nomad)" $NOMAD_SERVER_SERVICES
  ((i=i+1))

  ### Nomad client services
  NOMAD_CLIENT_SERVICES=$(curl -s -H "X-Consul-Token: $CONSUL_TOKEN" http://${CONSUL_SERVERS[0]}:$CONSUL_PORT/v1/health/checks/nomad-client | jq -r ".[] | .Node" | uniq | wc -l)
  output $i "Retrieving number of Nomad Client services (API GET /health/checks/nomad-client)" $NOMAD_CLIENT_SERVICES
  ((i=i+1))

  echo ""
}

### VAULT

function vault_checks() {
  line
  echo "[Vault]"
  line

  export VAULT_ADDR="https://${VAULT_SERVERS[0]}:$VAULT_PORT"
  i=1

  ## Port check
  for V_SERVER in "${VAULT_SERVERS[@]}"
  do
    VAULT_PORTCHECK=$(portcheck $V_SERVER $VAULT_PORT)
    output $i "Testing connection to Vault server $V_SERVER on port tcp/$VAULT_PORT (CLI netcat)" $VAULT_PORTCHECK
    ((i=i+1))
  done

  ### Vault initialization state
  echo ""
  for V in "${VAULT_SERVERS[@]}"
  do
    VAULT_INIT=$(curl -k -s -H "X-Vault-Token: $VAULT_TOKEN" https://${V}:$VAULT_PORT/v1/sys/health | jq -r .initialized)
    if [ "$VAULT_INIT" == "true" ]; then
      STAT="TRUE"
    else
      STAT="FALSE"
    fi
    output $i "Checking if Vault is initialized on $V (API GET /sys/health)" $STAT
    ((i=i+1))
  done

  ### Vault sealed state
  echo ""
  for V in "${VAULT_SERVERS[@]}"
  do
    VAULT_SEAL=$(curl -k -s -H "X-Vault-Token: $VAULT_TOKEN" https://${V}:$VAULT_PORT/v1/sys/health | jq -r .sealed)
    if [ "$VAULT_SEAL" == "false" ]; then
      STAT="TRUE"
    else
      STAT="FALSE"
    fi
    output $i "Checking if Vault is unsealed on $V (API GET /sys/health)" $STAT
    ((i=i+1))
  done

  ### Vault login with atcomputing user
  echo ""
  VAULT_LOGIN=$(curl -f -k -s --request POST --data "{\"password\": \"$VAULT_PASSWORD\"}" https://${VAULT_SERVERS[0]}:8200/v1/auth/userpass/login/$VAULT_USER) # | jq -r .auth.client_token)
  VAULT_LOGIN_STAT=$(echo $?)
  if [ $VAULT_LOGIN_STAT -eq 0 ]; then
    VAULT_TOKEN=$(echo $VAULT_LOGIN | jq -r .auth.client_token)
    STAT="SUCCEEDED"
    VSUC=1
  else
    VAULT_TOKEN="INVALID"
    STAT="FAILED"
    VSUC=0
  fi
  output $i "Log in with $VAULT_USER user (API POST /auth/userpass/login/$VAULT_USER)" $STAT
  ((i=i+1))

  ### Vault create KV/2 engine
  if [ $VSUC -eq 1 ]; then
    VAULT_KV=$(curl -f -k -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data "{\"type\": \"kv-v2\"}" https://${VAULT_SERVERS[0]}:8200/v1/sys/mounts/shutter 2>/dev/null ; echo $?)
    if [ $VAULT_KV -eq 0 ]; then
      STAT="SUCCEEDED"
    else
      STAT="FAILED"
    fi
  else
    STAT="SKIPPED"
  fi
  output $i "Mounting kv-v2 secrets engine 'shutter' (API POST /sys/mounts/shutter)" $STAT
  ((i=i+1))

  ### Vault create secret
  if [ $VSUC -eq 1 ]; then
    VAULT_CREATE_SECRET=$(curl -f -k -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data "{ \"options\": { \"cas\": 0 }, \"data\": { \"shutterspeed\": \"10s\" } }" https://${VAULT_SERVERS[0]}:8200/v1/shutter/data/speed 2>/dev/null)
    VAULT_CREATE_SECRET_STATUS=$(echo $?)
    if [ $VAULT_CREATE_SECRET_STATUS -eq 0 ]; then
      STAT="SUCCEEDED"
    else
      STAT="FAILED"
    fi
  else
    STAT="SKIPPED"
  fi
  output $i "Creating secret 'speed' in 'shutter' kv-v2 secrets engine (API POST /shutter/data/speed)" $STAT
  ((i=i+1))

  ### Vault read secret
  if [ $VSUC -eq 1 ]; then
    VAULT_READ_SECRET=$(curl -f -k -s --header "X-Vault-Token: $VAULT_TOKEN" https://${VAULT_SERVERS[0]}:8200/v1/shutter/data/speed 2>/dev/null | jq -jc .data.data | tr -d '{}')
    if [ "$VAULT_READ_SECRET" != ""  ]; then
      STAT=$VAULT_READ_SECRET
    else
      STAT="FAILED"
    fi
  else
    STAT="SKIPPED"
  fi
  output $i "Reading secret 'speed' from 'shutter' kv-v2 secrets engine (API GET /shutter/data/speed)" $STAT
  ((i=i+1))

  echo ""

}

### NOMAD

function nomad_checks() {
  line
  echo "[Nomad]"
  line

  export NOMAD_ADDR="https://${NOMAD_SERVERS[0]}:$NOMAD_PORT"
  i=1

  ## Port check
  for N_SERVER in "${NOMAD_SERVERS[@]}"
  do
    NOMAD_PORTCHECK=$(portcheck $N_SERVER $NOMAD_PORT)
    output $i "Testing connection to Nomad server $N_SERVER on port tcp/$NOMAD_PORT (CLI netcat)" $NOMAD_PORTCHECK
    ((i=i+1))
  done

  ### Nomad peers
  echo ""
  NOMAD_PEERS=$(curl -s -H "X-Nomad-Token: $NOMAD_TOKEN" https://${NOMAD_SERVERS[0]}:$NOMAD_PORT/v1/status/peers 2>/dev/null | jq -r ".[]" 2>/dev/null | wc -l 2>/dev/null)
  output $i "Retrieving number of Nomad peers (API GET /status/peers)" $NOMAD_PEERS
  ((i=i+1))

  ### Nomad nodes
  NOMAD_NODES=$(curl -s -H "X-Nomad-Token: $NOMAD_TOKEN" https://${NOMAD_SERVERS[0]}:$NOMAD_PORT/v1/nodes 2>/dev/null | jq -r ".[] | .Name" 2>/dev/null | wc -l 2>/dev/null)
  output $i "Retrieving number of Nomad nodes from (API GET /nodes)" $NOMAD_NODES
  ((i=i+1))

  ### Starting Nomad test job
  echo ""
  NOMAD_TEST_JOB=$(curl -s -H "X-Nomad-Token: $NOMAD_TOKEN" --request "POST" --data @focus/focus.json https://${NOMAD_SERVERS[0]}:$NOMAD_PORT/v1/jobs &> /dev/null; echo $?)
  if [ $NOMAD_TEST_JOB -eq 0 ]; then
    STAT="STARTED"
  else
    STAT="FAILED"
  fi
  output $i "Starting Focus test job (API POST /jobs)" $STAT
  if [ $NOMAD_TEST_JOB -eq 0 ]; then
    output "" "   Waiting" "20"
    sleep 0.7
    output "" "   Waiting" "19"
    sleep 0.7
    output "" "   Waiting" "18"
    sleep 0.7
    output "" "   Waiting" "17"
    sleep 0.7
    output "" "   Waiting" "16"
    sleep 0.7
    output "" "   Waiting" "15"
    sleep 0.7
    output "" "   Waiting" "14"
    sleep 0.7
    output "" "   Waiting" "13"
    sleep 0.7
    output "" "   Waiting" "12"
    sleep 0.7
    output "" "   Waiting" "11"
    sleep 0.7
    output "" "   Waiting" "10"
    sleep 0.7
    output "" "   Waiting" "9"
    sleep 0.7
    output "" "   Waiting" "8"
    sleep 0.7
    output "" "   Waiting" "7"
    sleep 0.7
    output "" "   Waiting" "6"
    sleep 0.7
    output "" "   Waiting" "5"
    sleep 0.7
    output "" "   Waiting" "4"
    sleep 0.7
    output "" "   Waiting" "3"
    sleep 0.7
    output "" "   Waiting" "2"
    sleep 0.7
    output "" "   Waiting" "1"
    sleep 0.7
  fi
  ((i=i+1))

  ### Reading Nomad test job
  NOMAD_READ_JOB=$(curl -s -H "X-Nomad-Token: $NOMAD_TOKEN" https://${NOMAD_SERVERS[0]}:$NOMAD_PORT/v1/job/$NOMAD_DEMO_SERVICE/summary 2>/dev/null | jq -r .Summary.focus.Running 2>/dev/null)
  if [ "$NOMAD_READ_JOB" == "1" ]; then
    STAT="RUNNING"
    SSUC=1
  else
    STAT="FAILED"
    SSUC=0
  fi
  output $i "Reading Focus job running status (API GET /job/$NOMAD_DEMO_SERVICE/summary)" $STAT
  ((i=i+1))

  ### Consul service for Focus
  if [ $SSUC -eq 1 ]; then
    NOMAD_JOB_CONSUL=$(curl -s -H "X-Consul-Token: $CONSUL_TOKEN" http://${CONSUL_SERVERS[0]}:$CONSUL_PORT/v1/health/checks/$NOMAD_DEMO_SERVICE 2>/dev/null | jq -r ".[] | .Status" 2>/dev/null)
    if [ "$NOMAD_JOB_CONSUL" == "passing" ]; then
      STAT="HEALTHY"
      SUC=1
    else
      STAT="UNHEALTHY"
      SUC=0
    fi
  else
    STAT="SKIPPED"
    SUC=0
  fi
  output $i "Checking Consul for registered Focus service and passing health check (API GET /health/checks/$NOMAD_DEMO_SERVICE)" $STAT
  ((i=i+1))

  ### Consul service record
  if [ $SSUC -eq 1 ]; then
    NOMAD_JOB_CONSUL_RECORD=$(dig +time=1 +tries=1 +short $NOMAD_DEMO_SERVICE.service.$CONSUL_DOMAIN)
    if [ "$NOMAD_JOB_CONSUL_RECORD" == "" ] || [ "$NOMAD_JOB_CONSUL_RECORD" == ";;" ]; then
      STAT="FAILED"
      SUC=0
    else
      STAT="$NOMAD_JOB_CONSUL_RECORD"
      SUC=1
    fi
  else
    STAT="SKIPPED"
    SUC=0
  fi
  output $i "Resolving Consul service DNS record (CLI dig +short $NOMAD_DEMO_SERVICE.service.$CONSUL_DOMAIN)" $STAT
  ((i=i+1))

  ### Consul service port
  if [ $SSUC -eq 1 ]; then
    NOMAD_JOB_CONSUL_PORT=$(dig +time=1 +tries=1 +short $NOMAD_DEMO_SERVICE.service.$CONSUL_DOMAIN SRV | awk '{print $3}')
    if [ "$NOMAD_JOB_CONSUL_PORT" == "" ]; then
      STAT="FAILED"
      PORT=""
    else
      STAT="$NOMAD_JOB_CONSUL_PORT"
      PORT=":$NOMAD_JOB_CONSUL_PORT"
    fi
  else
    STAT="SKIPPED"
    PORT=""
  fi
  output $i "Retrieving Consul service port (CLI dig +short $NOMAD_DEMO_SERVICE.service.$CONSUL_DOMAIN SRV)" $STAT
  ((i=i+1))

  ### Focus output
  if [ $SSUC -eq 1 ]; then
    FOCUS_OUTPUT="$(curl -s $NOMAD_JOB_CONSUL_RECORD:$NOMAD_JOB_CONSUL_PORT)"
  else
    FOCUS_OUTPUT="SKIPPED"
  fi
  output $i "Retrieving job output (CLI curl $NOMAD_DEMO_SERVICE.service.$CONSUL_DOMAIN$PORT)" "$FOCUS_OUTPUT"
  ((i=i+1))

}

function errors() {

  if [ $ERROR -eq 0 ]; then
    ISO="ISO-3200"
  else
    ISO="ISO-100"
  fi

  i=1
  echo ""
  line
  echo "[ISO]"
  line
  output $i "Current ISO Certification status ($ERROR stops)" "$ISO"
  echo ""
}

#consul_checks
#vault_checks
nomad_checks
#errors
