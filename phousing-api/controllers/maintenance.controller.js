const maintenanceService = require('../services/maintenance.service');
const { validate, maintenanceValidationRules } = require('../config/validator');
const { authMiddleware } = require('../config/middleware');
const { param, body } = require('express-validator'); // Add param and body imports
const { ApiError } = require('../utils/errorHandler');
const logger = require('../utils/errorHandler').logger;

exports.submitRequest = [
  authMiddleware('tenant'),
  body('propertyId').isUUID().withMessage('Property ID must be a valid UUID'),
  body('tenantId').isUUID().withMessage('Tenant ID must be a valid UUID'),
  body('description').isString().trim().notEmpty().withMessage('Description is required'),
  validate(),
  async (req, res) => {
    try {
      const requestData = req.body;
      const newRequest = await maintenanceService.submitRequest(requestData);
      logger.info('Submitted maintenance request successfully', { requestId: newRequest.id });
      res.status(201).json({ success: true, data: newRequest });
    } catch (error) {
      const apiError = error instanceof ApiError ? error : new ApiError('Failed to submit maintenance request', 400, { originalError: error.message });
      logger.error('Error submitting maintenance request', apiError.toJson());
      res.status(apiError.statusCode).json({ success: false, error: apiError.message, details: apiError.details });
    }
  },
];

exports.updateRequestStatus = [
  authMiddleware('landlord'),
  param('id').isUUID().withMessage('Invalid request ID'),
  body('status').isIn(['pending', 'in_progress', 'resolved']).withMessage('Status must be pending, in_progress, or resolved'),
  validate(),
  async (req, res) => {
    try {
      const { id } = req.params;
      const { status } = req.body;
      const updatedRequest = await maintenanceService.updateRequestStatus(id, status);
      logger.info('Updated maintenance request status successfully', { requestId: id, status });
      res.status(200).json({ success: true, data: updatedRequest });
    } catch (error) {
      const apiError = error instanceof ApiError ? error : new ApiError('Failed to update maintenance request status', 400, { originalError: error.message });
      logger.error('Error updating maintenance request status', apiError.toJson());
      res.status(apiError.statusCode).json({ success: false, error: apiError.message, details: apiError.details });
    }
  },
];