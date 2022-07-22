#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s/\${NAME}/$6/" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s/\${NAME}/$6/" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=1
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/org1.manufacturer.com/tlsca/tlsca.org1.manufacturer.com-cert.pem
CAPEM=organizations/peerOrganizations/org1.manufacturer.com/ca/ca.org1.manufacturer.com-cert.pem
NAME="manufacturer"

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $NAME)" > organizations/peerOrganizations/org1.manufacturer.com/connection-org1.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $NAME)" > organizations/peerOrganizations/org1.manufacturer.com/connection-org1.yaml

ORG=2
P0PORT=9051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/org2.wholesaler.com/tlsca/tlsca.org2.wholesaler.com-cert.pem
CAPEM=organizations/peerOrganizations/org2.wholesaler.com/ca/ca.org2.wholesaler.com-cert.pem
NAME="wholesaler"

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $NAME)" > organizations/peerOrganizations/org2.wholesaler.com/connection-org2.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $NAME)" > organizations/peerOrganizations/org2.wholesaler.com/connection-org2.yaml

ORG=3
P0PORT=11051
CAPORT=6054
PEERPEM=organizations/peerOrganizations/org3.pharmacist.com/tlsca/tlsca.org3.pharmacist.com-cert.pem
CAPEM=organizations/peerOrganizations/org3.pharmacist.com/ca/ca.org3.pharmacist.com-cert.pem
NAME="pharmacist"
echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $NAME)" > organizations/peerOrganizations/org3.pharmacist.com/connection-org3.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $NAME)" > organizations/peerOrganizations/org3.pharmacist.com/connection-org3.yaml

ORG=4
P0PORT=12051
CAPORT=5054
PEERPEM=organizations/peerOrganizations/org4.patient.com/tlsca/tlsca.org4.patient.com-cert.pem
CAPEM=organizations/peerOrganizations/org4.patient.com/ca/ca.org4.patient.com-cert.pem
NAME="patient"
echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $NAME)" > organizations/peerOrganizations/org4.patient.com/connection-org4.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $NAME)" > organizations/peerOrganizations/org4.patient.com/connection-org4.yaml

ORG=5
P0PORT=13051
CAPORT=4054
PEERPEM=organizations/peerOrganizations/org5.auditor.com/tlsca/tlsca.org5.auditor.com-cert.pem
CAPEM=organizations/peerOrganizations/org5.auditor.com/ca/ca.org5.auditor.com-cert.pem
NAME="auditor"
echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $NAME)" > organizations/peerOrganizations/org5.auditor.com/connection-org5.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $NAME)" > organizations/peerOrganizations/org5.auditor.com/connection-org5.yaml
