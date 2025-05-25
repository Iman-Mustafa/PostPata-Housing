const { body, param, query } = require('express-validator');
const { ApiError } = require('../utils/errorHandler');

const userValidationRules = [
  body('fullName')
    .isString()
    .trim()
    .isLength({ min: 3, max: 50 })
    .withMessage('Full name must be between 3 and 50 characters'),
  body('emailOrPhone')
    .trim()
    .custom((value) => {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      const phoneRegex = /^\+?[1-9]\d{8,14}$/;
      if (!emailRegex.test(value) && !phoneRegex.test(value)) {
        throw new Error('Must be a valid email or phone number');
      }
      return true;
    }),
  body('password')
    .isLength({ min: 6, max: 50 })
    .withMessage('Password must be between 6 and 50 characters')
    .matches(/[A-Za-z]/)
    .withMessage('Password must contain at least one letter')
    .matches(/\d/)
    .withMessage('Password must contain at least one number'),
  body('role')
    .isIn(['tenant', 'landlord', 'admin'])
    .withMessage('Role must be tenant, landlord, or admin'),
  body('isPhone')
    .isBoolean()
    .withMessage('isPhone must be a boolean'),
  body('updated_at')
    .optional()
    .isISO8601()
    .withMessage('updated_at must be a valid ISO 8601 date'),
];

// Other validation rules (property, maintenance, etc.) remain unchanged
const propertyValidationRules = [ /* ... */ ];
const maintenanceValidationRules = [ /* ... */ ];
const paymentValidationRules = [ /* ... */ ];
const bulkApproveValidationRules = [ /* ... */ ];
const paymentConfirmationValidationRules = [ /* ... */ ];
const paginationValidationRules = [ /* ... */ ];
const propertyFilterValidationRules = [ /* ... */ ];

const validate = (validations = []) => {
  return async (req, res, next) => {
    // Use provided validations or fall back to req.middlewareValidations
    const rulesToValidate = validations.length > 0 ? validations : (req.middlewareValidations || []);
    const result = await Promise.all(rulesToValidate.map(validation => validation.run(req)));
    const errors = result.filter(r => !r.isEmpty()).flatMap(r => r.array());
    if (errors.length > 0) {
      const error = new ApiError('Validation failed', 400, { errors });
      return res.status(error.statusCode).json({ success: false, error: error.message, details: error.details });
    }
    next();
  };
};

module.exports = {
  userValidationRules,
  propertyValidationRules,
  maintenanceValidationRules,
  paymentValidationRules,
  bulkApproveValidationRules,
  paymentConfirmationValidationRules,
  paginationValidationRules,
  propertyFilterValidationRules,
  validate,
};