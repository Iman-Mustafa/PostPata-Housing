const express = require('express');
const router = express.Router();
const landlordController = require('../controllers/landlord.controller');

router.post('/properties', landlordController.addProperty);
router.put('/properties/:id', landlordController.updateProperty);

module.exports = router;