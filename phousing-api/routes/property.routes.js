const express = require('express');
const router = express.Router();
const propertyController = require('../controllers/property.controller');
const { authenticate } = require('../config/middleware'); // Updated import
const { validate, paginationValidationRules, propertyFilterValidationRules } = require('../config/validator');
const { upload } = require('../services/storage.service');
const { param } = require('express-validator');

router.get('/featured', propertyController.getFeaturedProperties);
router.get('/all', validate([...paginationValidationRules, ...propertyFilterValidationRules]), propertyController.getAllProperties);
router.get('/:id', validate([param('id').isUUID().withMessage('Invalid property ID')]), propertyController.getPropertyById);
router.post('/add', authenticate(['landlord']), upload.single('image'), validate(propertyController.propertyValidationRules), propertyController.addProperty);
router.put('/:id', authenticate(['landlord']), validate([param('id').isUUID().withMessage('Invalid property ID')]), propertyController.updateProperty);
router.delete('/:id', authenticate(['landlord']), validate([param('id').isUUID().withMessage('Invalid property ID')]), propertyController.deleteProperty);

module.exports = router;