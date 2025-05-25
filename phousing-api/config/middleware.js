const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const jwt = require('jsonwebtoken');
const { ApiError } = require('../utils/errorHandler');
const logger = require('../utils/errorHandler').logger;
require('dotenv').config();

// CORS Configuration
const corsOptions = {
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  optionsSuccessStatus: 200,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
};

// Rate Limiter
const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX) || 100,
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});

// Combined Authentication and Authorization Middleware
const authenticate = (requiredRoles = []) => {
  return async (req, res, next) => {
    try {
      const authHeader = req.headers['authorization'];
      const token = authHeader?.split(' ')[1];
      
      if (!token) {
        throw new ApiError('Authorization token required', 401);
      }

      // Verify JWT token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = decoded;

      // Check roles if specified
      if (requiredRoles.length > 0 && !requiredRoles.includes(decoded.role)) {
        throw new ApiError(
          `Access denied. Required roles: ${requiredRoles.join(', ')}`, 
          403
        );
      }

      next();
    } catch (error) {
      const apiError = error instanceof ApiError 
        ? error 
        : new ApiError('Invalid or expired token', 401);
      
      logger.error('Authentication error', {
        error: apiError.message,
        stack: apiError.stack
      });

      res.status(apiError.statusCode).json({
        success: false,
        error: apiError.message
      });
    }
  };
};

module.exports = {
  cors,
  corsOptions,
  helmet,
  rateLimiter,
  authenticate
};