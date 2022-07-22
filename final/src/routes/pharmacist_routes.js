const express = require('express');
const router = express.Router();
const controller = require('../controller/pharmacist');
const Verify = require('../helper/authentication')


router.post('/registeradmin', controller.registeradmin);
router.post('/register', controller.register);
router.get('/login', controller.login);
router.get('/approve', Verify.adminAuth, controller.approveUser);

router.get('/addUser', Verify.auth ,controller.adduser);
router.get('/addBatch', Verify.auth ,controller.addbatch);
router.get('/addFactory', Verify.auth, controller.addfactory);

router.get('/addproductpharmacist', Verify.auth, controller.addproductpharmacist);

module.exports = router