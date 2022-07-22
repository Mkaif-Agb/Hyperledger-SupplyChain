#!/bin/bash

function createOrg1() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/org1.manufacturer.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.manufacturer.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-org1 --tls.certfiles "${PWD}/organizations/fabric-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/peers/peer0.org1.manufacturer.com/msp" --csr.hosts peer0.org1.manufacturer.com --tls.certfiles "${PWD}/organizations/fabric-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/peers/peer0.org1.manufacturer.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/peers/peer0.org1.manufacturer.com/tls" --enrollment.profile tls --csr.hosts peer0.org1.manufacturer.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/peers/peer0.org1.manufacturer.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/peers/peer0.org1.manufacturer.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/peers/peer0.org1.manufacturer.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/peers/peer0.org1.manufacturer.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/peers/peer0.org1.manufacturer.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/peers/peer0.org1.manufacturer.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/peers/peer0.org1.manufacturer.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/peers/peer0.org1.manufacturer.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/tlsca/tlsca.org1.manufacturer.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/ca"
  cp "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/peers/peer0.org1.manufacturer.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/ca/ca.org1.manufacturer.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/users/User1@org1.manufacturer.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/users/User1@org1.manufacturer.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7054 --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/users/Admin@org1.manufacturer.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org1.manufacturer.com/users/Admin@org1.manufacturer.com/msp/config.yaml"
}

function createOrg2() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/org2.wholesaler.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org2.wholesaler.com/

  set -x
  fabric-ca-client enroll -u https://admin2:adminpw@localhost:8054 --caname ca-org2 --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-org2 -M "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/peers/peer0.org2.wholesaler.com/msp" --csr.hosts peer0.org2.wholesaler.com --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/peers/peer0.org2.wholesaler.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-org2 -M "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/peers/peer0.org2.wholesaler.com/tls" --enrollment.profile tls --csr.hosts peer0.org2.wholesaler.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/peers/peer0.org2.wholesaler.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/peers/peer0.org2.wholesaler.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/peers/peer0.org2.wholesaler.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/peers/peer0.org2.wholesaler.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/peers/peer0.org2.wholesaler.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/peers/peer0.org2.wholesaler.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/peers/peer0.org2.wholesaler.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/peers/peer0.org2.wholesaler.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/tlsca/tlsca.org2.wholesaler.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/ca"
  cp "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/peers/peer0.org2.wholesaler.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/ca/ca.org2.wholesaler.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-org2 -M "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/users/User1@org2.wholesaler.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/users/User1@org2.wholesaler.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org2admin:org2adminpw@localhost:8054 --caname ca-org2 -M "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/users/Admin@org2.wholesaler.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org2.wholesaler.com/users/Admin@org2.wholesaler.com/msp/config.yaml"
}

function createOrg3() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/org3.pharmacist.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org3.pharmacist.com/

  set -x
  fabric-ca-client enroll -u https://admin3:adminpw@localhost:6054 --caname ca-org3 --tls.certfiles "${PWD}/organizations/fabric-ca/org3/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-org3.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-org3.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-org3.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-org3.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-org3 --id.name peer3 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/org3/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org3 --id.name user3 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/org3/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org3 --id.name org3admin3 --id.secret org3adminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/org3/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:6054 --caname ca-org3 -M "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/peers/peer0.org3.pharmacist.com/msp" --csr.hosts peer0.org3.pharmacist.com --tls.certfiles "${PWD}/organizations/fabric-ca/org3/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/peers/peer0.org3.pharmacist.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:6054 --caname ca-org3 -M "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/peers/peer0.org3.pharmacist.com/tls" --enrollment.profile tls --csr.hosts peer0.org3.pharmacist.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/org3/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/peers/peer0.org3.pharmacist.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/peers/peer0.org3.pharmacist.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/peers/peer0.org3.pharmacist.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/peers/peer0.org3.pharmacist.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/peers/peer0.org3.pharmacist.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/peers/peer0.org3.pharmacist.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/peers/peer0.org3.pharmacist.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/peers/peer0.org3.pharmacist.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/tlsca/tlsca.org3.pharmacist.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/ca"
  cp "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/peers/peer0.org3.pharmacist.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/ca/ca.org3.pharmacist.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:6054 --caname ca-org3 -M "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/users/User1@org3.pharmacist.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org3/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/users/User1@org3.pharmacist.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org3admin3:org3adminpw@localhost:6054 --caname ca-org3 -M "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/users/Admin@org3.pharmacist.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org3/tls-cert.pem"
  { set +x; } 2>/dev/null 

  cp "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org3.pharmacist.com/users/Admin@org3.pharmacist.com/msp/config.yaml"
}

function createOrg4() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/org4.patient.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org4.patient.com/

  set -x
  fabric-ca-client enroll -u https://admin4:adminpw@localhost:5054 --caname ca-org4 --tls.certfiles "${PWD}/organizations/fabric-ca/org4/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-5054-ca-org4.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-5054-ca-org4.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-5054-ca-org4.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-5054-ca-org4.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/org4.patient.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-org4 --id.name peer4 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/org4/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org4 --id.name user4 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/org4/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org4 --id.name org4admin4 --id.secret org4adminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/org4/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:5054 --caname ca-org4 -M "${PWD}/organizations/peerOrganizations/org4.patient.com/peers/peer0.org4.patient.com/msp" --csr.hosts peer0.org4.patient.com --tls.certfiles "${PWD}/organizations/fabric-ca/org4/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org4.patient.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org4.patient.com/peers/peer0.org4.patient.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:5054 --caname ca-org4 -M "${PWD}/organizations/peerOrganizations/org4.patient.com/peers/peer0.org4.patient.com/tls" --enrollment.profile tls --csr.hosts peer0.org4.patient.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/org4/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org4.patient.com/peers/peer0.org4.patient.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org4.patient.com/peers/peer0.org4.patient.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/org4.patient.com/peers/peer0.org4.patient.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/org4.patient.com/peers/peer0.org4.patient.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/org4.patient.com/peers/peer0.org4.patient.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/org4.patient.com/peers/peer0.org4.patient.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/org4.patient.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/org4.patient.com/peers/peer0.org4.patient.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org4.patient.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/org4.patient.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/org4.patient.com/peers/peer0.org4.patient.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org4.patient.com/tlsca/tlsca.org4.patient.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/org4.patient.com/ca"
  cp "${PWD}/organizations/peerOrganizations/org4.patient.com/peers/peer0.org4.patient.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/org4.patient.com/ca/ca.org4.patient.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:5054 --caname ca-org4 -M "${PWD}/organizations/peerOrganizations/org4.patient.com/users/User1@org4.patient.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org4/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org4.patient.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org4.patient.com/users/User1@org4.patient.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org4admin4:org4adminpw@localhost:5054 --caname ca-org4 -M "${PWD}/organizations/peerOrganizations/org4.patient.com/users/Admin@org4.patient.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org4/tls-cert.pem"
  { set +x; } 2>/dev/null 

  cp "${PWD}/organizations/peerOrganizations/org4.patient.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org4.patient.com/users/Admin@org4.patient.com/msp/config.yaml"
}

function createOrg5() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/org5.auditor.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org5.auditor.com/

  set -x
  fabric-ca-client enroll -u https://admin5:adminpw@localhost:4054 --caname ca-org5 --tls.certfiles "${PWD}/organizations/fabric-ca/org5/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-4054-ca-org5.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-4054-ca-org5.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-4054-ca-org5.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-4054-ca-org5.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/org5.auditor.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-org5 --id.name peer5 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/org5/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org5 --id.name user5 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/org5/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org5 --id.name org5admin5 --id.secret org5adminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/org5/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:4054 --caname ca-org5 -M "${PWD}/organizations/peerOrganizations/org5.auditor.com/peers/peer0.org5.auditor.com/msp" --csr.hosts peer0.org5.auditor.com --tls.certfiles "${PWD}/organizations/fabric-ca/org5/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org5.auditor.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org5.auditor.com/peers/peer0.org5.auditor.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:4054 --caname ca-org5 -M "${PWD}/organizations/peerOrganizations/org5.auditor.com/peers/peer0.org5.auditor.com/tls" --enrollment.profile tls --csr.hosts peer0.org5.auditor.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/org5/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org5.auditor.com/peers/peer0.org5.auditor.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org5.auditor.com/peers/peer0.org5.auditor.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/org5.auditor.com/peers/peer0.org5.auditor.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/org5.auditor.com/peers/peer0.org5.auditor.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/org5.auditor.com/peers/peer0.org5.auditor.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/org5.auditor.com/peers/peer0.org5.auditor.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/org5.auditor.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/org5.auditor.com/peers/peer0.org5.auditor.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org5.auditor.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/org5.auditor.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/org5.auditor.com/peers/peer0.org5.auditor.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org5.auditor.com/tlsca/tlsca.org5.auditor.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/org5.auditor.com/ca"
  cp "${PWD}/organizations/peerOrganizations/org5.auditor.com/peers/peer0.org5.auditor.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/org5.auditor.com/ca/ca.org5.auditor.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:4054 --caname ca-org5 -M "${PWD}/organizations/peerOrganizations/org5.auditor.com/users/User1@org5.auditor.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org5/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org5.auditor.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org5.auditor.com/users/User1@org5.auditor.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org5admin5:org5adminpw@localhost:4054 --caname ca-org5 -M "${PWD}/organizations/peerOrganizations/org5.auditor.com/users/Admin@org5.auditor.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org5/tls-cert.pem"
  { set +x; } 2>/dev/null 

  cp "${PWD}/organizations/peerOrganizations/org5.auditor.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org5.auditor.com/users/Admin@org5.auditor.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  # Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp" --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls" --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"

  # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
}
