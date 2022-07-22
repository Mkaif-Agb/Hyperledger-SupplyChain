const stringify  = require('json-stringify-deterministic');
const sortKeysRecursive  = require('sort-keys-recursive');
const { Contract } = require('fabric-contract-api');


class testContract extends Contract {
    async InitLedger(ctx) {
        const Customer = [
            {
                CustomerId: '1',
                Email: "mkaifagb@gmail.com",
                Phone: "9769669165",
                Name: "Mkaif",
                Type: "Manufacturer"
            },
            {
                CustomerId: '2',
                Role: 'Customer',
                Name: 'yyxx',
            },
            {
               CustomerId: '3',
                Role: 'Customer',
                Name: 'xyxy',
            },
            {
                CustomerId: '4',
                Role: 'Customer',
                Name: 'yxyx',
            },
            {
                Name: 'xyyx',
                CustomerId: '5',
                Role: 'Customer',
            },
            {
                CustomerId: '6',
                Role: 'Customer',
                Name: 'yxxy',
            },
        ];

        for (const customer of Customer) {
            customer.docType = 'customer';
            await ctx.stub.putState(customer.CustomerId, Buffer.from(stringify(sortKeysRecursive(customer))));
        }
    }

    async getAllResults(iterator) {
        const allResults = [];
        while (true) {
            const res = await iterator.next();
            if (res.value) {
                // if not a getHistoryForKey iterator then key is contained in res.value.key
                console.log(res)
                allResults.push(res.value.value.toString('utf8'));
            }
    
            // check to see if we have reached then end
            if (res.done) {
                // explicitly close the iterator            
                await iterator.close();
                return allResults;
            }
        }
    }

    async addUser(ctx,userId,email,phone,name,type) { 
        
        let orgid = ctx.clientIdentity.getMSPID();
        console.log(orgid);
        const user={
         UserId:userId, 
         Email:email,
         Phone:phone,
         Name:name,
         Type:type
         }; 
        await ctx.stub.putState(userId,Buffer.from(JSON.stringify(user))); 
        console.log('User added To the ledger Succesfully..'); 
        return JSON.stringify(user);
    }


    async addFactory(ctx,factoryId,description,location) { 
        let factory={
         FactoryId:factoryId, 
         Description:description,
         Location:location 
         }; 
        await ctx.stub.putState(factoryId,Buffer.from(JSON.stringify(factory))); 
        console.log('factory added To the ledger Succesfully..');
        return JSON.stringify(factory);
    }

    async addBatch(ctx,batchId,batchQty,batchDate, batchMfgFactory) { 
        const clientMSPID = ctx.clientIdentity.getMSPID();
        console.log(clientMSPID);
        if (clientMSPID !== 'Org1MSP') {
            throw new Error('Client is not authorized to make changes to batch data');
            // return JSON.stringify("Client is not authorized to make changes to batch data")
        }

        let batch={
         BatchId:batchId, 
         BatchQty:batchQty,
         BatchDate: batchDate,
         BatchMfgFactory: batchMfgFactory
         }; 
        await ctx.stub.putState(batchId,Buffer.from(JSON.stringify(batch))); 
        console.log('Batch added To the ledger Succesfully..'); 
        return JSON.stringify(batch);
    }

    async addProduct(ctx, productId, productName, mfgDate, extDate, currentOwner, batchId){

        const clientMSPID = ctx.clientIdentity.getMSPID();
        console.log(clientMSPID);
        if (clientMSPID !== 'Org1MSP') {
            throw new Error('Client is not authorized to make changes to batch data');
        }
        let product = {
            ProductID: productId,
            ProductName: productName,
            MFGdate: mfgDate,
            EXTdate: extDate,
            CurrentOwner: currentOwner,
            BatchID: batchId
        }
        await ctx.stub.putState(productId, Buffer.from(JSON.stringify(product)));
        console.log("Product added To the ledger Successfully...");
        return JSON.stringify(product);

    }


    async addProduct_auditor(ctx,productId, qualityAudit){

        const clientMSPID = ctx.clientIdentity.getMSPID();
        console.log(clientMSPID);
        if (clientMSPID !== 'Org5MSP') {
            throw new Error('Client is not authorized to make changes to batch data');
        }
        
        let product = {
            ProductID: productId,
            QualityAudit: qualityAudit,
            }
        await ctx.stub.putState(productId, Buffer.from(JSON.stringify(product)));
        console.log("Product changes made to the ledger by Auditor...");
        return JSON.stringify(product);
    }


    async addProduct_manufacturer(ctx, productId,shiptowholesalerdate){

        
        const clientMSPID = ctx.clientIdentity.getMSPID();
        console.log(clientMSPID);
        if (clientMSPID !== 'Org1MSP') {
            throw new Error('Client is not authorized to make changes to batch data');
            // return JSON.stringify("Client is not authorized to make changes to batch data")
        }
        let product = {
        ProductID: productId,
        Shiptowholesalerdate: shiptowholesalerdate,
        }
        await ctx.stub.putState(productId, Buffer.from(JSON.stringify(product)));
        console.log("Product changes made to the ledger by Manufacturer...");
        return JSON.stringify(product);

}




    async addProduct_wholesaler(ctx, productId,wholesalerId, shiptoretailerdate, retailerId){

        const clientMSPID = ctx.clientIdentity.getMSPID();
        console.log(clientMSPID);
        if (clientMSPID !== 'Org2MSP') {
            throw new Error('Client is not authorized to make changes to batch data');
            // return JSON.stringify("Client is not authorized to make changes to batch data")
        }

        let product = {
        ProductID: productId,
        WholesalerId: wholesalerId,
        Shiptoretailerdate: shiptoretailerdate,
        RetailerID: retailerId,
        }
        await ctx.stub.putState(productId, Buffer.from(JSON.stringify(product)));
        console.log("Product changes made to the ledger by Wholesaler...");
        return JSON.stringify(product);

}

    async addProduct_pharmacist(ctx, productId, saleDate, patientId){

        const clientMSPID = ctx.clientIdentity.getMSPID();
        console.log(clientMSPID);
        if (clientMSPID !== 'Org3MSP') {
            throw new Error('Client is not authorized to make changes to batch data');
            // return JSON.stringify("Client is not authorized to make changes to batch data")
        }

        let product = {
        ProductID: productId,
        SaleDate: saleDate,
        PatientID: patientId
        }
        await ctx.stub.putState(productId, Buffer.from(JSON.stringify(product)));
        console.log("Product changes made to the ledger by Pharmacist...");
        return JSON.stringify(product);
}





    async queryCustomer(ctx, query){
        let customerAsBytes = await ctx.stub.getQueryResult(query);
        let results = await this.getAllResults(customerAsBytes);
        if (!customerAsBytes || customerAsBytes.toString().length <= 0) { 
          throw new Error('Customer with this Id/Role does not exist: '); 
            }                               
        return results; 
    }

    async queryInsurance(ctx,insuranceId){
        let insuranceAsBytes = await ctx.stub.getState(insuranceId); 
        if (!insuranceAsBytes || insuranceAsBytes.toString().length <= 0) { 
          throw new Error('Insurance with this Id does not exist: '); 
            } 
        let insurance=JSON.parse(insuranceAsBytes.toString()); 
        return JSON.stringify(insurance); 
    }

    async InsuranceExists(ctx, id) {
        const assetJSON = await ctx.stub.getState(id);
        return assetJSON && assetJSON.length > 0;
    }

    async DeleteAsset(ctx, id) {
        const exists = await this.InsuranceExists(ctx, id);
        if (!exists) {
            throw new Error(`The asset ${id} does not exist`);
        }
        return ctx.stub.deleteState(id);
    }

    async txid(ctx){
        const txid = await ctx.stub.getTxID(); // Transaction Hash 
        console.log(txid)
        return JSON.stringify(txid)
    }

    async  CreateInsuranceObject(ctx, insuranceid, type, status , amount, documentation,
        customerId, insuCompanyid, bankId){
        let exists = await this.InsuranceExists(ctx, insuranceid);
        if (!exists) {
        throw new Error(`The asset ${insuranceid} does not exist`);
        }
        console.log("Yes it Exists");
        if (status == "0") {
        console.log(' customer add the settlement request');
        } else if (status == "1") {
        console.log(' updated by insurance company after the visiting to the customer home and clicking picture of the car');
        } else if (status == "2") {
        console.log('bank will pay the insurance money to customer');
        } else {
        console.log('updated staus by insuarance comapny for rejection of settlemet damageImages: NO')
        }
        const InsuranceObject = {
        InsuranceId: insuranceid,
        Type: type,
        Status: status,
        Amount: amount,
        Documentation : documentation,
        CustomerId : customerId,
        InsuCompanyId: insuCompanyid,
        BankId: bankId
        };
        //we insert data in alphabetic order using 'json-stringify-deterministic' and 'sort-keys-recursive'
        await ctx.stub.putState(insuranceid, Buffer.from(stringify(sortKeysRecursive(InsuranceObject))));
        return JSON.stringify(InsuranceObject);
        }

    async GetAllAssets(ctx) {
        const allResults = [];
        // range query with empty string for startKey and endKey does an open-ended query of all assets in the chaincode namespace.
        const iterator = await ctx.stub.getStateByRange('', '');
        let result = await iterator.next();
        while (!result.done) {
            const strValue = Buffer.from(result.value.value.toString()).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push(record);
            result = await iterator.next();
        }
        return JSON.stringify(allResults);
    }  
}

module.exports = testContract;