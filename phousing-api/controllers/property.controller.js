const propertyService = require('../services/property.service');
const { validate, propertyValidationRules, paginationValidationRules, propertyFilterValidationRules } = require('../config/validator');
const { authenticate } = require('../config/middleware'); // Updated import
const { upload } = require('../services/storage.service');
const { param } = require('express-validator');
const { ApiError } = require('../utils/errorHandler');
const { Helpers } = require('../utils/helpers');
const logger = require('../utils/errorHandler').logger;

// ... (keep all your existing controller methods)

exports.addProperty = [
  authenticate(['landlord']), // Updated usage
  upload.single('image'),
  validate(propertyValidationRules),
  async (req, res) => {
    // ... keep your existing implementation
  }
];

exports.updateProperty = [
  authenticate(['landlord']), // Updated usage
  propertyIdValidation,
  validate([...propertyValidationRules, propertyIdValidation]),
  async (req, res) => {
    // ... keep your existing implementation
  }
];

exports.deleteProperty = [
  authenticate(['landlord']), // Updated usage
  propertyIdValidation,
  validate(),
  async (req, res) => {
    // ... keep your existing implementation
  }
];