'use strict';
const { Wallets, WalletStore, Wallet } = require("fabric-network");
//const { Wallet } = require("fabric-network/src/impl/wallet/wallet.js")
const FabricCAServices = require('fabric-ca-client');
const walletSchema = require("../model_wallet");
const User = require('../model_user');
// const walletSchema = require("../model_user")
const { buildCAClient, enrollAdminMongo, userExist, registerAndEnrollUserMongo } = require("../CAUtil");
const { getCCP } = require("../buildCCP");
const fs = require("fs");
const { resolve } = require("path");
const JSONTransport = require("nodemailer/lib/json-transport");

const encoding = 'utf8';


class Mongowallet {
    //  let test = new WalletStore()
    // async delete(label: string): Promise < void > {…}
    // async get(label: string): Promise < Buffer | undefined > {…}
    // async list(): Promise < string[] > {…}
    // async put(label: string, data: Buffer): Promise < void > {…}
    /**
     * Create a wallet instance backed by a given store. This can be used to create a wallet using your own
     * custom store implementation.
     * @param {module:fabric-network.WalletStore} store Backing store implementation.
     */

    constructor() {
        //  this.providerRegistry = IdentityProviderRegistry.newDefaultProviderRegistry();
        //  this.store = store;
    }
    async delete(label) {

    }
    async get(id) {
        try {
            //  console.log("get  class ", id)
            // id = "61deae5d7fb245065785d893";
            let res = await walletSchema.find({ email: id });
            // console.log("res----------- ", res)
            // console.log("get result ----", res.length)
            if (res.length) {
                console.log("-------in if---------")
                    // let data = { message: true }
                    // return this.providerRegistry.getProvider(data.message).fromJson(data);
                console.log(JSON.stringify(res[0]), encoding)
                // return Buffer.from(JSON.stringify(res[0]));
                // return JSON.stringify(res[0], encoding);
                return Buffer.from(JSON.stringify(res[0]), encoding);
            }
            else{
                return undefined
            // await this.store.put(label, buffer);
            }

        } catch (err) {
            console.log("err getuser", err)
            return undefined;
        }
    }
    async list() {
        try {
            let res = await walletSchema.find()
                //   console.log("get all result ", res)
            return res;
        } catch (err) {
            console.log("err all getuser", err)
            return undefined;
        }
    }
    async put(label, data) {
        console.log("---------------- put -------------")
        //   console.log("============== put method custom start ", data.toString(encoding))
        data = data.toString(encoding);
        //   console.log("============== dtata====", label);
        let jsonData = JSON.parse(data)
        // console.log("============== pjsodata ===========", jsonData)
        let input
        if (label === "admin2") {
            // input = { email: "admin", role: "admin", org: jsonData.mspId, credentials: jsonData.credentials, mspId: jsonData.mspId, version: jsonData.version }
            input = { email: "admin2", role: "admin", org: jsonData.mspId, credentials: jsonData.credentials, mspId: jsonData.mspId, version: jsonData.version }
        } else {
            input = { email: label, role: "client", org: jsonData.mspId, credentials: jsonData.credentials, mspId: jsonData.mspId, version: jsonData.version }
        }
        //    console.log("input put method custom ", input)
        const user = new walletSchema(input);
        try {
            let res = await user.save()
            // To add wallet credentials to WalletDbID
            // let res = await user.save().then((result) =>{
            // User.findOne({userid: user.email}, (err, user)=>{ // Send the Feedback id into the User Database
            //     if (user){
                    
            //         console.log("-------------model" ,user)
            //         user.walletDbID.push(user); // User database can linked with this feedback
            //         user.save();
            //         console.log("----------later", user)
            //         }
            //     })
            // });
            // console.log("creted result ", res)
            return true;
        } catch (err) {
            console.log("err ", err)
            return false;
        }
    }
}

module.exports.Mongowallet = Mongowallet

/**
 * 
 * @param {*} param0 
 * @returns 
 */
module.exports.newUser = async function({ OrgMSP, userId }) {
    console.log("---userId----", userId)
    let org = Number(OrgMSP.match(/\d/g).join(""));

    let ccp = getCCP(org);
    const caClient = buildCAClient(FabricCAServices, ccp, `ca.org${org}.example.com`);
    // const caClient = {}
    // setup the wallet to hold the credentials of the application user
    // const wallet = await buildWallet(Wallets, walletPath);
    const store = new Mongowallet();
    const wallet = new Wallet(store);
    // console.log("wallet ", wallet)

    // in a real application this would be done on an administrative flow, and only once
    let checkAdmin = await enrollAdminMongo(caClient, wallet, OrgMSP);

    // in a real application this would be done only when a new user was required to be added
    // and would be part of an administrative flow
    let user = await registerAndEnrollUserMongo(caClient, wallet, OrgMSP, userId, `org${org}.department1`);
    // console.log(user);
    if (user === "User already present") {
        return { message: user }
    } else
        return {
            message: "data added"
        }
}

