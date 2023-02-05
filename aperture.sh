#!/bin/bash

# Servers
CONSUL_SERVERS=( server1 server2 server3 )
CONSUL_CLIENTS=( client1 client2 client3 client4 )
VAULT_SERVERS=( server1 server2 server3 )
NOMAD_SERVERS=( server1 server2 server3 )
DOCKER_SERVER="client1"

# Ports
CONSUL_PORT="8500"
VAULT_PORT="8200"
NOMAD_PORT="4646"

# Retrieve credentials
TOKENS_DIR="$HOME/hashi-tokens"
CONSUL_TOKEN="$(awk '/SecretID/ {print $2}' $TOKENS_DIR/management.consul.token)"
NOMAD_TOKEN="$(awk '/Secret ID/ {print $4}' $TOKENS_DIR/management.nomad.token)"
VAULT_USERNAME="atcomputing"
VAULT_PASSWORD="$(cat $TOKENS_DIR/atcomputing.vault.password)"

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
  DESC_LENGTH=${#DESC}
  RESULT_LENGTH=${#RESULT}
  MAX_RESULT_LENGTH=9

  DOT_LENGTH=$(($WIDTH-$NR_LENGTH-2-$DESC_LENGTH-$RESULT_LENGTH-2))
  DOTS=$(printf '%0.s.' $(seq 1 $DOT_LENGTH))

  if [ $RESULT == "SUCCEEDED" ]; then
    BEGC=$PASS
  elif [ $RESULT == "FAILED" ]; then
    BEGC=$FAIL
  elif [ $RESULT == "TRUE" ]; then
    BEGC=$PASS
  elif [ $RESULT == "STARTED" ]; then
    BEGC=$PASS
  elif [ $RESULT == "RUNNING" ]; then
    BEGC=$PASS
  elif [ $RESULT == "HEALTHY" ]; then
    BEGC=$PASS
  elif [ $RESULT == "FALSE" ]; then
    BEGC=$FAIL
  elif [ $RESULT == "UNHEALTHY" ]; then
    BEGC=$FAIL
  elif [ $RESULT == "STOPPED" ]; then
    BEGC=$NEUT
  elif [ $RESULT -eq 0 ]; then
    BEGC=$NEUT
  else
    BEGC=$ENDC
  fi

  echo -e "$NR. $DESC$DOTS[$BEGC$RESULT$ENDC]"
}

portcheck() {
  STAT=$(nc -z $1 $2; echo $?)
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

### CONSUL

function consul_checks() {
  line
  echo "[Consul]"
  line
  
  export CONSUL_HTTP_ADDR="http://${CONSUL_SERVERS[0]}:$CONSUL_PORT"
  i=1

  ## Port check
  for C_SERVER in "${CONSUL_SERVERS[@]}"
  do
    CONSUL_PORTCHECK=$(portcheck $C_SERVER $CONSUL_PORT)
    output $i "Testing connection to Consul server $C_SERVER on port tcp/$CONSUL_PORT (netcat)" $CONSUL_PORTCHECK
    ((i=i+1))
  done
  
  ### Consul Clients
  echo ""
  for C_CLIENT in "${CONSUL_CLIENTS[@]}"
  do
    MEMBER=$(consul members | grep $C_CLIENT | wc -l)
    if [ $MEMBER -eq 1 ]; then
      STAT="SUCCEEDED"
    else
      STAT="FAILED"
    fi
    output $i "Checking membership for Consul client $C_CLIENT (consul members)" $STAT
    ((i=i+1))
  done

  ### Vault services
  echo ""
  VAULT_SERVICES=$(curl -s -H "X-Consul-Token: $CONSUL_TOKEN" http://${CONSUL_SERVERS[0]}:$CONSUL_PORT/v1/health/checks/vault | jq -r ".[] | .Node" | uniq | wc -l)
  output $i "Retrieving number of Vault services (API /health/checks/vault)" $VAULT_SERVICES
  ((i=i+1))
  
  ### Nomad server services
  NOMAD_SERVER_SERVICES=$(curl -s -H "X-Consul-Token: $CONSUL_TOKEN" http://${CONSUL_SERVERS[0]}:$CONSUL_PORT/v1/health/checks/nomad | jq -r ".[] | .Node" | uniq | wc -l)
  output $i "Retrieving number of Nomad Server services (API /health/checks/nomad)" $NOMAD_SERVER_SERVICES
  ((i=i+1))
  
  ### Nomad client services
  NOMAD_CLIENT_SERVICES=$(curl -s -H "X-Consul-Token: $CONSUL_TOKEN" http://${CONSUL_SERVERS[0]}:$CONSUL_PORT/v1/health/checks/nomad-client | jq -r ".[] | .Node" | uniq | wc -l)
  output $i "Retrieving number of Nomad Client services (API /health/checks/nomad-client)" $NOMAD_CLIENT_SERVICES
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
    output $i "Testing connection to Vault server $V_SERVER on port tcp/$VAULT_PORT (netcat)" $VAULT_PORTCHECK
    ((i=i+1))
  done
  
  ### Vault initialization state
  echo ""
  for V in "${VAULT_SERVERS[@]}"
  do
    VAULT_INIT=$(curl -k -s -H "X-Vault-Token: $VAULT_TOKEN" https://${V}:$VAULT_PORT/v1/sys/health | jq -r .initialized)
    if [ "$VAULT_INIT" = "true" ]; then
      STAT="TRUE"
    else
      STAT="FALSE"
    fi
    output $i "Checking if Vault is initialized on $V (API /sys/health)" $STAT
    ((i=i+1))
  done

  ### Vault sealed state
  echo ""
  for V in "${VAULT_SERVERS[@]}"
  do
    VAULT_SEAL=$(curl -k -s -H "X-Vault-Token: $VAULT_TOKEN" https://${V}:$VAULT_PORT/v1/sys/health | jq -r .sealed)
    if [ "$VAULT_SEAL" = "false" ]; then
      STAT="TRUE"
    else
      STAT="FALSE"
    fi
    output $i "Checking if Vault is unsealed on $V (API /sys/health)" $STAT
    ((i=i+1))
  done

  echo ""

} 

### NOMADV

function nomad_checks() {
  line
  echo "[Nomad]"
  line
  
  export NOMAD_ADDR="http://${NOMAD_SERVERS[0]}:$NOMAD_PORT"
  i=1

  ## Port check
  for N_SERVER in "${NOMAD_SERVERS[@]}"
  do
    NOMAD_PORTCHECK=$(portcheck $N_SERVER $NOMAD_PORT)
    output $i "Testing connection to Nomad server $N_SERVER on port tcp/$NOMAD_PORT (netcat)" $NOMAD_PORTCHECK
    ((i=i+1))
  done
  
  ### Nomad peers
  echo ""
  NOMAD_PEERS=$(curl -s -H "X-Nomad-Token: $NOMAD_TOKEN" http://${NOMAD_SERVERS[0]}:$NOMAD_PORT/v1/status/peers | jq -r ".[]" | wc -l)
  output $i "Retrieving number of Nomad peers (API /status/peers)" $NOMAD_PEERS
  ((i=i+1))

  ### Nomad nodes
  NOMAD_NODES=$(curl -s -H "X-Nomad-Token: $NOMAD_TOKEN" http://${NOMAD_SERVERS[0]}:$NOMAD_PORT/v1/nodes | jq -r ".[] | .Name" | wc -l)
  output $i "Retrieving number of Nomad nodes from (API /nodes)" $NOMAD_NODES
  ((i=i+1))

  ### Starting Nomad test job
  echo ""
  NOMAD_TEST_JOB=$(curl -s -H "X-Nomad-Token: $NOMAD_TOKEN" --request "POST" --data @focus/focus.json http://${NOMAD_SERVERS[0]}:$NOMAD_PORT/v1/jobs &> /dev/null; echo $?)
  if [ $NOMAD_TEST_JOB -eq 0 ]; then
    STAT="STARTED"
  else
    STAT="FAILED"
  fi
  output $i "Starting Focus test job (API /jobs)" $STAT
  ((i=i+1))

  sleep 5

  ### Reading Nomad test job
  NOMAD_READ_JOB=$(curl -s -H "X-Nomad-Token: $NOMAD_TOKEN" http://${NOMAD_SERVERS[0]}:$NOMAD_PORT/v1/job/focus/summary | jq -r .Summary.focus.Running)
  if [ $NOMAD_READ_JOB -eq 1 ]; then
    STAT="RUNNING"
  else
    STAT="FAILED"
  fi
  output $i "Reading Focus job running status (API /job/focus/summary)" $STAT
  ((i=i+1))

  sleep 5

  ### Consul service for Focus
  NOMAD_JOB_CONSUL=$(curl -s -H "X-Consul-Token: $CONSUL_TOKEN" http://${CONSUL_SERVERS[0]}:$CONSUL_PORT/v1/health/checks/focus | jq -r ".[] | .Status" )
  if [ "$NOMAD_JOB_CONSUL" = "passing" ]; then
    STAT="HEALTHY"
  else
    STAT="UNHEALTHY"
  fi
  output $i "Checking Consul for registered Focus service and passing health check (API /health/checks/focus)" $STAT
  ((i=i+1))

  ### Delete Focus job
  NOMAD_DELETE_JOB=$(curl -s -H "X-Nomad-Token: $NOMAD_TOKEN" --request DELETE http://${NOMAD_SERVERS[0]}:$NOMAD_PORT/v1/job/focus?purge=true | jq -r)
  output $i "Deleting Focus nomad job" "STOPPED"
  ((i=i+1))

  echo ""

} 

consul_checks
vault_checks
nomad_checks
