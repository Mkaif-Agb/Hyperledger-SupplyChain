// const manufacturer = require('./manufacturer_routes');
// const wholesaler = require('./wholesaler_routes');
// const patient = require('./patient_routes');
// const pharmacist = require('./pharmacist_routes');
// const auditor = require('./auditor_routes');



// module.exports = manufacturer
// module.exports = wholesaler
// module.exports = patient
// module.exports = pharmacist
// module.exports = auditor


var express = require('express');
var router = express.Router();

router.use('/manufacture', require('./manufacturer_routes'));

module.exports = router;