const jwt = require('jsonwebtoken');
const authService = require('../services/auth.service');
const { validate, userValidationRules } = require('../config/validator');
const { authMiddleware } = require('../config/middleware');

exports.login = [
  ...userValidationRules.filter(rule => ['emailOrPhone', 'password'].includes(rule.path)),
  validate(userValidationRules.filter(rule => ['emailOrPhone', 'password'].includes(rule.path))),
  async (req, res) => {
    try {
      const { emailOrPhone, password, isPhone } = req.body;
      const user = await authService.login(emailOrPhone, password, isPhone);
      const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET || 'your_jwt_secret', {
        expiresIn: '1h',
      });
      res.status(200).json({ success: true, data: { user, token } });
    } catch (error) {
      res.status(400).json({ success: false, error: error.message });
    }
  },
];

exports.register = [
  validate(userValidationRules),
  async (req, res) => {
    try {
      const { fullName, emailOrPhone, password, role, isPhone } = req.body;
      const user = await authService.register(fullName, emailOrPhone, password, role, isPhone);
      const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET || 'your_jwt_secret', {
        expiresIn: '1h',
      });
      res.status(201).json({ success: true, data: { user, token } });
    } catch (error) {
      res.status(400).json({ success: false, error: error.message });
    }
  },
];

exports.verifyOtp = [
  body('emailOrPhone').notEmpty().withMessage('Email or phone is required'),
  body('otp').notEmpty().withMessage('OTP is required'),
  validate([body('emailOrPhone'), body('otp')]),
  async (req, res) => {
    try {
      const { emailOrPhone, otp, isPhone } = req.body;
      await authService.verifyOtp(emailOrPhone, otp, isPhone);
      res.status(200).json({ success: true, message: 'OTP verified' });
    } catch (error) {
      res.status(400).json({ success: false, error: error.message });
    }
  },
];

exports.logout = [
  authMiddleware(),
  async (req, res) => {
    try {
      await authService.logout();
      res.status(200).json({ success: true, message: 'Logged out successfully' });
    } catch (error) {
      res.status(400).json({ success: false, error: error.message });
    }
  },
];