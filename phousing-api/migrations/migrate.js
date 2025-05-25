const supabase = require('../config/db');
const { ApiError } = require('../utils/errorHandler');
const { Helpers } = require('../utils/helpers');

async function migrate() {
  console.log('Starting migrations at', Helpers.formatDate(new Date(), 'YYYY-MM-DD HH:mm:ss'));

  try {
    // Create or update profiles table
    const createProfiles = await supabase.rpc('create_or_alter_table', {
      table_name: 'profiles',
      schema: {
        id: 'uuid PRIMARY KEY DEFAULT uuid_generate_v4()',
        full_name: 'text NOT NULL',
        email: 'text UNIQUE',
        phone: 'text UNIQUE',
        role: 'text NOT NULL CHECK (role IN (\'tenant\', \'landlord\', \'admin\')) DEFAULT \'tenant\'',
        is_verified: 'boolean DEFAULT false',
        created_at: 'timestamp with time zone DEFAULT now()',
        updated_at: 'timestamp with time zone DEFAULT null',
      },
    });
    if (createProfiles.error) throw new ApiError('Failed to create profiles table', 500, createProfiles.error);

    // Create or update properties table
    const createProperties = await supabase.rpc('create_or_alter_table', {
      table_name: 'properties',
      schema: {
        id: 'uuid PRIMARY KEY DEFAULT uuid_generate_v4()',
        title: 'text NOT NULL',
        description: 'text NOT NULL',
        price: 'numeric(10, 2) NOT NULL CHECK (price >= 0)',
        location: 'text NOT NULL',
        landlord_id: 'uuid REFERENCES profiles(id)',
        bedrooms: 'integer DEFAULT 0 CHECK (bedrooms >= 0)',
        bathrooms: 'integer DEFAULT 0 CHECK (bedrooms >= 0)',
        area: 'numeric(10, 2) DEFAULT 0 CHECK (area >= 0)',
        is_available: 'boolean DEFAULT true',
        is_featured: 'boolean DEFAULT false',
        is_approved: 'boolean DEFAULT false',
        image_urls: 'text[] DEFAULT ARRAY[]::text[]',
        created_at: 'timestamp with time zone DEFAULT now()',
        updated_at: 'timestamp with time zone DEFAULT null',
      },
    });
    if (createProperties.error) throw new ApiError('Failed to create properties table', 500, createProperties.error);

    // Create or update maintenance_requests table
    const createMaintenance = await supabase.rpc('create_or_alter_table', {
      table_name: 'maintenance_requests',
      schema: {
        id: 'uuid PRIMARY KEY DEFAULT uuid_generate_v4()',
        property_id: 'uuid REFERENCES properties(id)',
        tenant_id: 'uuid REFERENCES profiles(id)',
        description: 'text NOT NULL',
        status: 'text NOT NULL CHECK (status IN (\'pending\', \'in_progress\', \'resolved\')) DEFAULT \'pending\'',
        created_at: 'timestamp with time zone DEFAULT now()',
        updated_at: 'timestamp with time zone DEFAULT null',
      },
    });
    if (createMaintenance.error) throw new ApiError('Failed to create maintenance_requests table', 500, createMaintenance.error);

    // Create or update payments table
    const createPayments = await supabase.rpc('create_or_alter_table', {
      table_name: 'payments',
      schema: {
        id: 'uuid PRIMARY KEY DEFAULT uuid_generate_v4()',
        property_id: 'uuid REFERENCES properties(id)',
        tenant_id: 'uuid REFERENCES profiles(id)',
        amount: 'numeric(10, 2) NOT NULL CHECK (amount >= 0)',
        payment_date: 'timestamp with time zone NOT NULL DEFAULT now()',
        status: 'text NOT NULL CHECK (status IN (\'pending\', \'completed\', \'failed\')) DEFAULT \'pending\'',
        created_at: 'timestamp with time zone DEFAULT now()',
        updated_at: 'timestamp with time zone DEFAULT null',
      },
    });
    if (createPayments.error) throw new ApiError('Failed to create payments table', 500, createPayments.error);

    // Add indexes for performance
    const addIndexes = await Promise.all([
      supabase.rpc('create_index', { table_name: 'properties', index_name: 'idx_properties_landlord_id', columns: ['landlord_id'] }),
      supabase.rpc('create_index', { table_name: 'maintenance_requests', index_name: 'idx_maintenance_tenant_id', columns: ['tenant_id'] }),
      supabase.rpc('create_index', { table_name: 'maintenance_requests', index_name: 'idx_maintenance_property_id', columns: ['property_id'] }),
      supabase.rpc('create_index', { table_name: 'payments', index_name: 'idx_payments_tenant_id', columns: ['tenant_id'] }),
      supabase.rpc('create_index', { table_name: 'payments', index_name: 'idx_payments_property_id', columns: ['property_id'] }),
    ]);
    if (addIndexes.some(result => result.error)) throw new ApiError('Failed to create indexes', 500, addIndexes.find(r => r.error)?.error);

    // Seed data
    const seedData = await Promise.all([
      supabase.from('profiles').insert([
        { full_name: 'John Doe', email: 'john@example.com', role: 'landlord', is_verified: true },
        { full_name: 'Jane Smith', email: 'jane@example.com', role: 'tenant', is_verified: true },
        { full_name: 'Admin User', email: 'admin@example.com', role: 'admin', is_verified: true },
      ]),
      supabase.from('properties').insert([
        {
          title: 'Cozy Apartment',
          description: 'A nice 2-bedroom apartment',
          price: 1200.00,
          location: 'Nairobi',
          landlord_id: Helpers.generateUUID(), // Replace with actual landlord ID after seeding profiles
          bedrooms: 2,
          bathrooms: 1,
          area: 800.0,
          image_urls: ['https://example.com/image1.jpg'],
        },
      ]),
      supabase.from('maintenance_requests').insert({
        property_id: Helpers.generateUUID(), // Replace with actual property ID after seeding
        tenant_id: Helpers.generateUUID(), // Replace with actual tenant ID after seeding
        description: 'Fix leaking faucet',
      }),
      supabase.from('payments').insert({
        property_id: Helpers.generateUUID(), // Replace with actual property ID after seeding
        tenant_id: Helpers.generateUUID(), // Replace with actual tenant ID after seeding
        amount: 1200.00,
        payment_date: '2025-05-20T19:00:00Z',
      }),
    ]);
    if (seedData.some(result => result.error)) throw new ApiError('Failed to seed data', 500, seedData.find(r => r.error)?.error);

    console.log('Migrations completed successfully at', Helpers.formatDate(new Date(), 'YYYY-MM-DD HH:mm:ss'));
  } catch (error) {
    console.error('Migration failed:', error.toJson());
    process.exit(1);
  }
}

migrate();