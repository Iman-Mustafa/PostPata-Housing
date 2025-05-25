const propertyService = require('../services/property.service');
const { validate, paginationValidationRules } = require('../config/validator');
const { authMiddleware } = require('../config/middleware');
const { param, body } = require('express-validator'); // Add param and body imports
const { ApiError } = require('../utils/errorHandler');
const logger = require('../utils/errorHandler').logger;

exports.getAllPropertiesAdmin = [
  authMiddleware('admin'),
  validate(paginationValidationRules),
  async (req, res) => {
    try {
      const { page, limit } = req.query;
      const result = await propertyService.getAllProperties({ page: parseInt(page), limit: parseInt(limit), filters: {} });
      logger.info('Fetched all properties successfully', { page, limit, count: result.length });
      res.status(200).json({ success: true, data: result });
    } catch (error) {
      const apiError = error instanceof ApiError ? error : new ApiError('Failed to fetch properties', 400, { originalError: error.message });
      logger.error('Error fetching properties', apiError.toJson());
      res.status(apiError.statusCode).json({ success: false, error: apiError.message, details: apiError.details });
    }
  },
];

exports.toggleFeaturedStatus = [
  authMiddleware('admin'),
  param('id').isUUID().withMessage('Invalid property ID'),
  validate(),
  async (req, res) => {
    try {
      const { id } = req.params;
      await propertyService.toggleFeaturedStatus(id);
      logger.info('Toggled featured status successfully', { propertyId: id });
      res.status(200).json({ success: true, message: 'Featured status updated' });
    } catch (error) {
      const apiError = error instanceof ApiError ? error : new ApiError('Failed to toggle featured status', 400, { originalError: error.message });
      logger.error('Error toggling featured status', apiError.toJson());
      res.status(apiError.statusCode).json({ success: false, error: apiError.message, details: apiError.details });
    }
  },
];

exports.bulkApproveProperties = [
  authMiddleware('admin'),
  body('propertyIds').isArray({ min: 1 }).withMessage('At least one property ID is required'),
  body('propertyIds.*').isUUID().withMessage('Each property ID must be a valid UUID'),
  validate(),
  async (req, res) => {
    try {
      const { propertyIds } = req.body;
      await propertyService.bulkApproveProperties(propertyIds);
      logger.info('Bulk approved properties successfully', { propertyIds });
      res.status(200).json({ success: true, message: 'Properties approved' });
    } catch (error) {
      const apiError = error instanceof ApiError ? error : new ApiError('Failed to bulk approve properties', 400, { originalError: error.message });
      logger.error('Error bulk approving properties', apiError.toJson());
      res.status(apiError.statusCode).json({ success: false, error: apiError.message, details: apiError.details });
    }
  },
];