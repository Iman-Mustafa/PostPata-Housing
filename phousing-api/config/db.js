const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

// Validate environment variables
const requiredEnvVars = ['SUPABASE_URL', 'SUPABASE_SERVICE_ROLE_KEY'];
requiredEnvVars.forEach((envVar) => {
  if (!process.env[envVar]) {
    throw new Error(`Missing required environment variable: ${envVar}`);
  }
});

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
  global: {
    fetch: (...args) => fetch(...args), // Ensure fetch is available
  },
  db: {
    schema: 'public',
    pool: {
      max: 10, // Maximum number of connections
      min: 2,  // Minimum number of connections
      idleTimeoutMillis: 30000, // Close idle connections after 30 seconds
    },
  },
});

// Test the connection on startup
(async () => {
  try {
    const { data, error } = await supabase.from('properties').select('id').limit(1);
    if (error) throw error;
    console.log('Successfully connected to Supabase');
  } catch (error) {
    console.error('Failed to connect to Supabase:', error.message);
    process.exit(1);
  }
})();

module.exports = supabase;