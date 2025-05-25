const propertyService = require('../services/property.service');
const { validate } = require('../config/validator');
const { authMiddleware } = require('../config/middleware');
const { param, body } = require('express-validator'); // Add param and body imports
const { ApiError } = require('../utils/errorHandler');
const logger = require('../utils/errorHandler').logger;

exports.addProperty = [
  authMiddleware('landlord'),
  body('title').isString().trim().notEmpty().withMessage('Title is required'),
  body('description').isString().trim().notEmpty().withMessage('Description is required'),
  body('price').isFloat({ min: 0, max: 1000000 }).withMessage('Price must be between 0 and 1,000,000'),
  body('location').isString().trim().notEmpty().withMessage('Location is required'),
  body('landlordId').isUUID().withMessage('Landlord ID must be a valid UUID'),
  validate(),
  async (req, res) => {
    try {
      const propertyData = req.body;
      const newProperty = await propertyService.addProperty(propertyData);
      logger.info('Added property successfully', { propertyId: newProperty.id });
      res.status(201).json({ success: true, data: newProperty });
    } catch (error) {
      const apiError = error instanceof ApiError ? error : new ApiError('Failed to add property', 400, { originalError: error.message });
      logger.error('Error adding property', apiError.toJson());
      res.status(apiError.statusCode).json({ success: false, error: apiError.message, details: apiError.details });
    }
  },
];

exports.updateProperty = [
  authMiddleware('landlord'),
  param('id').isUUID().withMessage('Invalid property ID'),
  body('title').optional().isString().trim().notEmpty().withMessage('Title is required'),
  body('description').optional().isString().trim().notEmpty().withMessage('Description is required'),
  body('price').optional().isFloat({ min: 0, max: 1000000 }).withMessage('Price must be between 0 and 1,000,000'),
  body('location').optional().isString().trim().notEmpty().withMessage('Location is required'),
  validate(),
  async (req, res) => {
    try {
      const { id } = req.params;
      const updates = req.body;
      const updatedProperty = await propertyService.updateProperty(id, updates);
      logger.info('Updated property successfully', { propertyId: id });
      res.status(200).json({ success: true, data: updatedProperty });
    } catch (error) {
      const apiError = error instanceof ApiError ? error : new ApiError('Failed to update property', 400, { originalError: error.message });
      logger.error('Error updating property', apiError.toJson());
      res.status(apiError.statusCode).json({ success: false, error: apiError.message, details: apiError.details });
    }
  },
];