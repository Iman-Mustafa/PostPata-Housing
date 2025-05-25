const express = require('express');
const router = express.Router();
const maintenanceController = require('../controllers/maintenance.controller');

router.post('/requests', maintenanceController.submitRequest);
router.put('/requests/:id/status', maintenanceController.updateRequestStatus);

module.exports = router;