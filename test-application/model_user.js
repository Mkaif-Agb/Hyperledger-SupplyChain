const { number } = require('joi');
const mongoose = require('mongoose');



const userSchema = new mongoose.Schema({
    // id:{type: Number, required:true, unique:true},
    userName: {type:String,required:true, unique:true},
    email: {type:String, required:true, unique:true},
    password:{type:String},
    phone:{type: Number},
    userType:{type:String},
    walletDbID:[
        {
            type: mongoose.Schema.Types.ObjectId,
            ref: "wallet",
        }
    ],
    date: {type:Date, default:Date.now()},
    status: {type:String, default:"new"},
    org:{type:String},
    // isAdmin:  {type:String, default:false},
});





const model = mongoose.model('user', userSchema);
module.exports = model
