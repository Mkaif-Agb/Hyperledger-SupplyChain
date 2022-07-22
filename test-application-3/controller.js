const User = require('./model_user');
const Wallet_Model = require('./model_wallet');
const bcrypt = require('bcryptjs')
const Verify = require('./authentication');
const {registerAdmin, registerUser, userExist} = require('./registerUser');
const {buildCCPOrg1, buildCCPOrg2, buildCCPOrg3, buildCCPOrg4, buildCCPOrg5, buildWallet} = require('./AppUtil');
const { Gateway, Wallets, Wallet } = require('fabric-network');
const { Mongowallet, newUser } = require('./wallet/wallet');
const {getCCP} = require('./buildCCP')
const fs = require('fs');
const { registerAndEnrollUserMongo } = require('./CAUtil');
const path = require('path');
const { request } = require('http');
const { channel } = require('diagnostics_channel');
global.atob = require('atob')
require('dotenv').config()



const channelName = 'supplychain';
const chaincodeName = 'basic';
const mspOrg = 'Org3MSP';

parseJwt = function(token) {
    var base64Url = token.split('.')[1];
    var base64 = base64Url.replace('-', '+').replace('_', '/');
    return JSON.parse(atob(base64));
  }


function prettyJSONString(inputString) {
	return JSON.stringify(JSON.parse(inputString), null, 2);
}



exports.registeradmin = async (req, res)=>{

    // Extract the required Fields
    const {userName ,email, password, mspOrg} = req.body;
    // const userName = 'admin';
    // const email = 'admin@gmail.com';
    // const password = 'adminpw';

    var user = await User.findOne({email});
    var enc_password = await bcrypt.hash(password, 10);
     // If User found, following error would be provided
    if(user){
        return res.json({status:'error', error:'Admin Already Exists'});
      }


    // If all correct Insert the user into our Database
    try {
        const response = await User.create({
            userName, 
            email,
            password: enc_password,
            org:mspOrg, 
            isAdmin: true,
            approved: true
        });
        const userId = response._id.toString()
        result = await registerAdmin({ OrgMSP: mspOrg, userId: userId })
    } catch (error) {
        console.log(error);
        // alert("An error has been Occured");
        return res.json({status:'error'});
    }
    
    // Response Provided
    res.json({message:`${userName} with Email: ${email} and organisation: ${mspOrg} as an Admin registered with our database.`});
};

exports.register = async (req, res)=>{

    // Extract the required Fields
    const {userName ,email, password, phone, usertype, org} = req.body;
    var user = await User.findOne({email});
    var enc_password = await bcrypt.hash(password, 10);
     // If User found, following error would be provided
    if(user){
        return res.json({status:'error', error:'Email already exists'});
      }


    // If all correct Insert the user into our Database
    try {
        const response = await User.create({
            userName, 
            email,
            phone,
            password: enc_password,
            userType: usertype,
            org: org
        });
        const userId = response._id.toString()
        // result_w = await registerUser({ OrgMSP: mspOrg, userId: userId })
        result = await newUser({OrgMSP: org, userId: userId})
        
    } catch (error) {
        console.log(error);
        return res.json({status:'error'});
    }
    
    // Response Provided
    res.json({message:`${userName} with Email: ${email} and organisation: ${org} registered with our database.`});
};

exports.login = async(req, res)=>{

    // Getting Required Fields from the user
    const {email, password} = req.body;

    var user = await User.findOne({email});

    // If no User found, following error would be provided
    if(!user){
      return res.json({status:'error', error:'Invalid Email/Password'});
    }
    
    // If Found then compare the user provided password || database password
    if (await bcrypt.compare(password, user.password)){

      token = await Verify.createtoken(user)  // Generate JWT token from authentication middleware
      res.cookie('jwt', token); // Save the JWT in cookies for futher use
      console.log("Logged in");
      return res.json({status:'ok', data:{user, 
        token
      }});
    };
  
    res.json({status:'error', error:'Invalid Username/Password'});
  }

exports.adduser = async(req, res) => {
    data = parseJwt(req.cookies.jwt);
    console.log(data);
    const {userId, email, phone, name, type} = req.body;
    // console.log('---------x', userId, email, phone, name, type)
    const db = await User.find({email: data.email});
    const orgmsp = db[0].org
    // const orgmsp = "Org1MSP";
    let userid = db[0]._id.toString();
    console.log(userid)

    let num = Number(orgmsp.match(/\d/g).join(""));
    const ccp = await getCCP(num);
    console.log(num)

    const store = new Mongowallet();
    const wallet = new Wallet(store);
    const gateway = new Gateway();

    try{

        await gateway.connect(ccp, {
            wallet,
            identity: userid,
            discovery: {enabled: true, asLocalhost: true}
        });

        const network = await gateway.getNetwork(channelName);
        const contract = network.getContract(chaincodeName);

        console.log('\n--> Submit Transaction: AddUser, creates new asset with Id, Role and Name');
        let result = await contract.submitTransaction('addUser', userId, email, phone, name, type);
        console.log('*** Result: committed');
        if (`${result}` !== '') {
            console.log(`*** Result: ${prettyJSONString(result.toString())}`);
        }

        return res.json({status:'ok', data:result.toString()});
    }catch{
        
        res.json({status: "Error"});
    }
    finally{
        gateway.disconnect();
    }

}


exports.addfactory = async(req, res) => {
    data = parseJwt(req.cookies.jwt);
    console.log(data);
    const {factoryId, description, location} = req.body;
    // console.log('---------x', userId, email, phone, name, type)
    const db = await User.find({email: data.email});
    const orgmsp = db[0].org
    // const orgmsp = "Org1MSP";
    let userid = db[0]._id.toString();
    console.log(userid)

    let num = Number(orgmsp.match(/\d/g).join(""));
    const ccp = await getCCP(num);
    console.log(num)

    const store = new Mongowallet();
    const wallet = new Wallet(store);
    const gateway = new Gateway();

    try{

        await gateway.connect(ccp, {
            wallet,
            identity: userid,
            discovery: {enabled: true, asLocalhost: true}
        });

        const network = await gateway.getNetwork(channelName);
        const contract = network.getContract(chaincodeName);

        console.log('\n--> Submit Transaction: AddUser, creates new asset with Id, Role and Name');
        let result = await contract.submitTransaction('addFactory', factoryId, description, location);
        console.log('*** Result: committed');
        if (`${result}` !== '') {
            console.log(`*** Result: ${prettyJSONString(result.toString())}`);
        }

        return res.json({status:'ok', data:result.toString()});
    }catch{
        
        res.json({status: "Error"});
    }
    finally{
        gateway.disconnect();
    }

}


exports.addproductpharmacist = async(req, res) => {
    data = parseJwt(req.cookies.jwt);
    console.log(data);
    const {productId, saleDate, patientId} = req.body;
    // console.log('---------x', userId, email, phone, name, type)
    const db = await User.find({email: data.email});
    const orgmsp = db[0].org
    // const orgmsp = "Org1MSP";
    let userid = db[0]._id.toString();
    console.log(userid)

    let num = Number(orgmsp.match(/\d/g).join(""));
    const ccp = await getCCP(num);
    console.log(num)

    const store = new Mongowallet();
    const wallet = new Wallet(store);
    const gateway = new Gateway();

    try{

        await gateway.connect(ccp, {
            wallet,
            identity: userid,
            discovery: {enabled: true, asLocalhost: true}
        });

        const network = await gateway.getNetwork(channelName);
        const contract = network.getContract(chaincodeName);

        console.log('\n--> Submit Transaction: Changes to Product by Pharmacist');
        let result = await contract.submitTransaction('addProduct_pharmacist', productId, saleDate, patientId);
        console.log('*** Result: committed');
        if (`${result}` !== '') {
            console.log(`*** Result: ${prettyJSONString(result.toString())}`);
        }

        return res.json({status:'ok', data:result.toString()});
    }catch{
        
        res.json({status: "Error"});
    }
    finally{
        gateway.disconnect();
    }

}



exports.approveUser = async (req, res) =>{

    const {email} = req.body;
    const db = await User.find({email: email});
    if (db[0].status === 'new'){
        return res.json({status:"error", message:"wallet has already been generated"})
        }
    else{
        const userId = db[0]._id.toString()
        const mspOrg = db[0].org
        User.updateOne({email:{$eq: email}}, 
            {status:"approved"}, function (err, docs) {
            if (err){
                console.log(err)
            }
            else{
                console.log("Updated Docs : ", docs);
            }
        });
        result = await registerUser({ OrgMSP: mspOrg, userId: userId });
        return res.json({status:'ok', message:'Wallet has been generated'});
        }
};

exports.addbatch = async(req, res) =>{

    data = parseJwt(req.cookies.jwt);
    console.log(data);
    const {batchId, batchQty, batchDate, batchMfgFactory} = req.body;
    console.log('-----------------------x',batchId, batchQty, batchDate, batchMfgFactory)
    const db = await User.find({email: data.email});
    const orgmsp = db[0].org
    // const orgmsp = "Org1MSP";
    let userid = db[0]._id.toString();

    // let num = Number(db[0].org.match(/\d/g).join(""));
    let num = Number(orgmsp.match(/\d/g).join(""));
    const ccp = await getCCP(num);
    console.log(num)


    console.log(userid)
    const store = new Mongowallet();
    const wallet = new Wallet(store);
    const gateway = new Gateway();

    try{

        await gateway.connect(ccp, {
            wallet,
            identity: userid,
            discovery: {enabled: true, asLocalhost: true}
        });

        const network = await gateway.getNetwork(channelName);
        const contract = network.getContract(chaincodeName);

        console.log('\n--> Submit Transaction: AddBatch, creates new asset with Id, Role and Name');
        let result = await contract.submitTransaction('addBatch', batchId, batchQty, batchDate, batchMfgFactory);
        console.log('*** Result: committed');
        if (`${result}` !== '') {
            console.log(`*** Result: ${prettyJSONString(result.toString())}`);
        }

        return res.json({status:'ok', data:result.toString()});

    }catch{
        
        res.json({status: "Error"});
    }
    finally{
        gateway.disconnect();
    }
}