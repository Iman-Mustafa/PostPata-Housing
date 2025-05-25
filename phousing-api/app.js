const express = require('express');
const morgan = require('morgan');
const { 
  cors, 
  corsOptions, 
  helmet, 
  rateLimiter, 
  authenticate,
  authorize 
} = require('./config/middleware');
const { errorHandler } = require('./utils/errorHandler');

const authRoutes = require('./routes/auth.routes');
const propertyRoutes = require('./routes/property.routes');
const userRoutes = require('./routes/user.routes');
const adminRoutes = require('./routes/admin.routes');
const landlordRoutes = require('./routes/landlord.routes');
const tenantRoutes = require('./routes/tenant.routes');
const maintenanceRoutes = require('./routes/maintenance.routes');
const paymentRoutes = require('./routes/payment.routes');

require('dotenv').config();

const app = express();

// Middleware
app.use(morgan('combined'));
app.use(helmet());
app.use(rateLimiter);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors(corsOptions));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/properties', propertyRoutes);
app.use('/api/users', userRoutes);
app.use('/api/admin', authenticate, authorize(['admin']), adminRoutes);
app.use('/api/landlords', authenticate, authorize(['landlord', 'admin']), landlordRoutes);
app.use('/api/tenants', authenticate, authorize(['tenant', 'admin']), tenantRoutes);
app.use('/api/maintenance', authenticate, maintenanceRoutes);
app.use('/api/payments', authenticate, paymentRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ success: true, message: 'API is healthy' });
});

// Global error handler (must be last middleware)
app.use(errorHandler);

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT} at ${new Date().toLocaleString('en-US', { timeZone: 'Africa/Nairobi' })}`);
});

// Process error handlers
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});