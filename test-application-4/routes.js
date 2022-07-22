const express = require('express');
const router = express.Router();
const controller = require('./controller');
const Verify = require('./authentication')


router.post('/registeradmin', controller.registeradmin);
router.post('/register', controller.register);
router.get('/login', controller.login);
router.get('/approve', Verify.adminAuth, controller.approveUser);

router.get('/adduser', Verify.auth ,controller.adduser);
router.get('/addBatch', Verify.auth ,controller.addBatch);
router.get('/addFactory', Verify.auth, controller.addfactory);

module.exports = router