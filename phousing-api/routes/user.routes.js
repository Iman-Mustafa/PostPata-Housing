const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { authMiddleware } = require('../config/middleware');
const { validate, userValidationRules } = require('../config/validator');
const { param } = require('express-validator');
const { ApiError } = require('../utils/errorHandler');
const logger = require('../utils/errorHandler').logger;

// GET /api/users/current - Fetch current user
router.get('/current', authMiddleware(), async (req, res, next) => {
  try {
    await userController.getCurrentUser(req, res);
    // Logging handled by controller
  } catch (error) {
    const apiError = error instanceof ApiError ? error : new ApiError('Failed to fetch current user', 400, { originalError: error.message });
    logger.error('Error fetching current user at route level', { userId: req.user?.id, error: apiError.toJson() });
    if (!res.headersSent) {
      res.status(apiError.statusCode).json({ success: false, error: apiError.message, details: apiError.details });
    }
  }
});

// PUT /api/users/profile - Update user profile
router.put('/profile', authMiddleware(), validate(userValidationRules.filter(rule => ['fullName', 'emailOrPhone'].includes(rule.path))), async (req, res, next) => {
  try {
    await userController.updateProfile(req, res);
    // Logging handled by controller
  } catch (error) {
    const apiError = error instanceof ApiError ? error : new ApiError('Failed to update profile', 400, { originalError: error.message });
    logger.error('Error updating user profile at route level', { userId: req.user?.id, error: apiError.toJson() });
    if (!res.headersSent) {
      res.status(apiError.statusCode).json({ success: false, error: apiError.message, details: apiError.details });
    }
  }
});

// DELETE /api/users/profile/:id - Delete user profile
router.delete('/profile/:id', [
  authMiddleware(),
  param('id').isUUID().withMessage('Invalid user ID'),
  validate(),
], async (req, res, next) => {
  try {
    const { id } = req.params;
    await userController.deleteProfile(req, res, id); // Assuming a deleteProfile method exists
    logger.info('Deleted user profile successfully', { userId: id });
  } catch (error) {
    const apiError = error instanceof ApiError ? error : new ApiError('Failed to delete user profile', 400, { originalError: error.message });
    logger.error('Error deleting user profile at route level', { userId: req.params.id, error: apiError.toJson() });
    if (!res.headersSent) {
      res.status(apiError.statusCode).json({ success: false, error: apiError.message, details: apiError.details });
    }
  }
});

module.exports = router;