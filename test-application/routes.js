const express = require('express');
const router = express.Router();
const controller = require('./controller');
const Verify = require('./authentication')


router.post('/registeradmin', controller.registeradmin);
router.post('/register', controller.register);
router.get('/login', controller.login);
router.get('/approve', Verify.adminAuth, controller.approveUser);

router.get('/addUser', Verify.auth ,controller.adduser);
router.get('/addProduct', Verify.auth, controller.addproduct);
router.get('/addBatch', Verify.auth ,controller.addbatch);
router.get('/addFactory', Verify.auth ,controller.addfactory);

router.get('/getallassets', Verify.auth, controller.getallassets);

module.exports = router