./network.sh down

./network.sh up createChannel -ca -s couchdb

./network.sh deployCC -ccn basic -ccp ../test-application/chaincode-javascript/ -ccl javascript