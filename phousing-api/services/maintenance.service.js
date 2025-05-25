const supabase = require('../config/db');

class MaintenanceService {
  async createRequest(request) {
    try {
      const { propertyId, tenantId, description, status } = request;
      const { data, error } = await supabase
        .from('maintenance_requests')
        .insert([{ property_id: propertyId, tenant_id: tenantId, description, status }])
        .select()
        .single();
      if (error) throw error;
      return data;
    } catch (error) {
      throw new Error(error.message || 'Failed to create maintenance request');
    }
  }

  async getRequestsByTenant(tenantId) {
    try {
      const { data, error } = await supabase
        .from('maintenance_requests')
        .select('*')
        .eq('tenant_id', tenantId);
      if (error) throw error;
      return data;
    } catch (error) {
      throw new Error(error.message || 'Failed to fetch tenant requests');
    }
  }

  async getRequestsByProperty(propertyId) {
    try {
      const { data, error } = await supabase
        .from('maintenance_requests')
        .select('*')
        .eq('property_id', propertyId);
      if (error) throw error;
      return data;
    } catch (error) {
      throw new Error(error.message || 'Failed to fetch property requests');
    }
  }

  async updateRequestStatus(id, status) {
    try {
      const { error } = await supabase
        .from('maintenance_requests')
        .update({ status })
        .eq('id', id);
      if (error) throw error;
    } catch (error) {
      throw new Error(error.message || 'Failed to update request status');
    }
  }
}

module.exports = new MaintenanceService();