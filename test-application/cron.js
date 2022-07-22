const {buildCCPOrg1, buildWallet} = require('./AppUtil');
const { Gateway, Wallets } = require('fabric-network');
const path = require('path');
const axios = require('axios');
const cron = require('node-cron');


const channelName = 'mychannel';
const chaincodeName = 'basic';
const mspOrg = 'Org1MSP';
const userid = 'admin';

const ccp = buildCCPOrg1();
const gateway = new Gateway();
const walletPath = path.join(__dirname, 'wallet');
let url = 'http://api.exchangeratesapi.io/v1/latest?access_key=b0907811d783bd67da9ceed252f3d649&symbols=USD,AUD,CAD,PLN,MXN'


function prettyJSONString(inputString) {
	return JSON.stringify(JSON.parse(inputString), null, 2);
}


// var request = require('request');
// function call(){
//     request('http://api.exchangeratesapi.io/v1/latest?access_key=b0907811d783bd67da9ceed252f3d649&symbols=USD,AUD,CAD,PLN,MXN', function (error, response, body) {
//         if (!error && response.statusCode === 200) {
//             body = JSON.parse(body)
//             console.log(body.rates); // Print the google web page.
//             return body.rates
//         };
//     });
// };


async function chaincode(rates){
    try{
            const wallet = await buildWallet(Wallets, walletPath);
            await gateway.connect(ccp, {
                wallet,
                identity: userid,
                discovery: {enabled: true, asLocalhost: true}
            });
            console.log("Inside function");
            const network = await gateway.getNetwork(channelName);
            const contract = network.getContract(chaincodeName);

            console.log('\n--> Submit Transaction: InitLedger, function creates the initial set of assets on the ledger');
            await contract.submitTransaction('InitLedger');
            console.log('*** Result: committed');

            console.log('\n--> Submit Transaction: AddApi, creates new asset with Id, Role and Name');
            let result = await contract.submitTransaction('addapi', JSON.stringify(rates));
            console.log('*** Result: committed');
            if (`${result}` !== '') {
                console.log(`*** Result: ${prettyJSONString(result.toString())}`);
            }

            console.log('\n--> Evaluate Transaction: GetAllAssets, function returns all the current assets on the ledger');
            result = await contract.evaluateTransaction('GetAllAssets');
            console.log(`*** Result: ${prettyJSONString(result.toString())}`);
            // return res.json({status:'ok', data:result.toString()});

        }catch(err){
            console.log(err)
            // res.json({status: "Error"});
        }
        finally{
            gateway.disconnect();
        }

    }


cron.schedule('* * * * *', () => {
    
    console.log('Cron has started at ', new Date());
    (async () => {
        try {
          const response = await axios.get(url)
          console.log(response.data.rates);
          chaincode(response.data.rates);
        } catch (error) {
          console.log(error.response);
        }
      })();
  }
);

