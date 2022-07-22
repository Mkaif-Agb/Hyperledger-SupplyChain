const { string } = require('joi');
const mongoose = require('mongoose');



const walletSchema = new mongoose.Schema({
    // id:{type: Number, required:true, unique:true},
    // affiliation: {type:String,required:true, unique:true},
    email: {type:String, required:true, unique:true},
    role: {type:String, required:true, default:"client"},
    credentials:{
        type: Object,
        required: true},
    type:{type: String, default:"X.509"},
    mspId:{type:String, required:true},
    // org:{type:String},
    version:{type:Number}
});

const model = mongoose.model('wallet', walletSchema);
module.exports = model
