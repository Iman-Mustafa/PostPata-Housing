const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');

router.get('/properties', adminController.getAllPropertiesAdmin);
router.put('/properties/:id/featured', adminController.toggleFeaturedStatus);
router.post('/properties/approve', adminController.bulkApproveProperties);

module.exports = router;