const authService = require('../services/auth.service');
const { validate, userValidationRules } = require('../config/validator');
const { authMiddleware } = require('../config/middleware');
const { ApiError } = require('../utils/errorHandler');
const logger = require('../utils/errorHandler').logger;

exports.getCurrentUser = [
  authMiddleware(),
  async (req, res) => {
    try {
      const user = await authService.getCurrentUser();
      if (!user) throw new ApiError('User not found', 404);
      logger.info('Fetched current user successfully', { userId: user.id });
      res.status(200).json({ success: true, data: user });
    } catch (error) {
      const apiError = error instanceof ApiError ? error : new ApiError('Failed to fetch current user', 400, { originalError: error.message });
      logger.error('Error fetching current user', apiError.toJson());
      res.status(apiError.statusCode).json({ success: false, error: apiError.message, details: apiError.details });
    }
  },
];

exports.updateProfile = [
  authMiddleware(),
  validate(userValidationRules.filter(rule => ['fullName', 'emailOrPhone'].includes(rule.path))),
  async (req, res) => {
    try {
      const { fullName, emailOrPhone, isPhone } = req.body;
      const userId = req.user.id;
      const updatedUser = await authService.updateProfile(userId, { fullName, emailOrPhone, isPhone });
      logger.info('Updated user profile successfully', { userId });
      res.status(200).json({ success: true, data: updatedUser });
    } catch (error) {
      const apiError = error instanceof ApiError ? error : new ApiError('Failed to update profile', 400, { originalError: error.message });
      logger.error('Error updating user profile', apiError.toJson());
      res.status(apiError.statusCode).json({ success: false, error: apiError.message, details: apiError.details });
    }
  },
];