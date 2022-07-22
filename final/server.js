const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const routes = require('./src/routes/index')
var cron = require('node-cron');
const { application } = require('express');

// const {call} = require('./cron');

//Connection
mongoose.connect('mongodb://localhost:27017/supplychain');
console.log("Connection Successful");

// MiddleWare
const app = express()
app.use(cookieParser())
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json())
app.use(routes)
console.log(routes);

app.listen(2000, ()=>{
    console.log('Server running on port 2000');
})