const winston = require('winston');

// Configure logger
const logger = winston.createLogger({
  level: 'error',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log' }),
    new winston.transports.Console(),
  ],
});

class ApiError extends Error {
  constructor(message, statusCode = 500, details = {}) {
    super(message);
    this.name = 'ApiError';
    this.statusCode = statusCode;
    this.details = details;
    Error.captureStackTrace(this, this.constructor);
  }

  toJson() {
    return {
      error: this.message,
      statusCode: this.statusCode,
      details: this.details,
      stack: process.env.NODE_ENV === 'development' ? this.stack : undefined,
    };
  }
}

const errorHandler = (err, req, res, next) => {
  if (!(err instanceof ApiError)) {
    err = new ApiError(err.message || 'Internal Server Error', err.statusCode || 500, {
      originalError: err.message
    });
  }

  logger.error({
    timestamp: new Date().toISOString(),
    method: req.method,
    url: req.url,
    statusCode: err.statusCode,
    message: err.message,
    details: err.details,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
  });

  res.status(err.statusCode).json({
    success: false,
    error: err.message,
    details: err.details,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};

module.exports = {
  ApiError,
  errorHandler,
  logger
};