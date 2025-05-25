const propertyService = require('../services/property.service');
const { validate, paginationValidationRules, propertyFilterValidationRules } = require('../config/validator');

exports.getAvailableProperties = [
  validate([...paginationValidationRules, ...propertyFilterValidationRules]),
  async (req, res) => {
    try {
      const { page, limit, priceMin, priceMax, location, bedrooms } = req.query;
      const filters = { priceMin, priceMax, location, bedrooms };
      const result = await propertyService.getAvailableProperties({ page: parseInt(page), limit: parseInt(limit), filters });
      res.status(200).json({ success: true, data: result });
    } catch (error) {
      res.status(400).json({ success: false, error: error.message });
    }
  },
];