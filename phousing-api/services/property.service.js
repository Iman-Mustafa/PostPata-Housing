const supabase = require('../config/db');
const { StorageService } = require('./storage.service');

class PropertyService {
  async getFeaturedProperties() {
    try {
      const { data, error } = await supabase
        .from('properties')
        .select('*')
        .eq('is_featured', true)
        .order('created_at', { ascending: false })
        .limit(5);
      if (error) throw error;
      return data;
    } catch (error) {
      throw new Error(error.message || 'Failed to fetch featured properties');
    }
  }

  async getAllProperties({ page = 1, limit = 10, filters = {} }) {
    try {
      let query = supabase
        .from('properties')
        .select('*', { count: 'exact' })
        .order('created_at', { ascending: false })
        .range((page - 1) * limit, page * limit - 1);

      if (filters.priceMin) query = query.gte('price', filters.priceMin);
      if (filters.priceMax) query = query.lte('price', filters.priceMax);
      if (filters.location) query = query.ilike('location', `%${filters.location}%`);
      if (filters.bedrooms) query = query.eq('bedrooms', filters.bedrooms);
      if (filters.isAvailable !== undefined) query = query.eq('is_available', filters.isAvailable);

      const { data, error, count } = await query;
      if (error) throw error;
      return { data, total: count, page, limit };
    } catch (error) {
      throw new Error(error.message || 'Failed to fetch properties');
    }
  }

  async getPropertyById(id) {
    try {
      const { data, error } = await supabase
        .from('properties')
        .select('*')
        .eq('id', id)
        .single();
      if (error) throw error;
      return data;
    } catch (error) {
      throw new Error(error.message || 'Property not found');
    }
  }

  async addProperty(property) {
    try {
      const { data, error } = await supabase
        .from('properties')
        .insert([property])
        .select()
        .single();
      if (error) throw error;
      return data;
    } catch (error) {
      throw new Error(error.message || 'Failed to add property');
    }
  }

  async updateProperty(id, property) {
    try {
      const { error } = await supabase
        .from('properties')
        .update(property)
        .eq('id', id);
      if (error) throw error;
    } catch (error) {
      throw new Error(error.message || 'Failed to update property');
    }
  }

  async deleteProperty(id) {
    try {
      const { error } = await supabase
        .from('properties')
        .delete()
        .eq('id', id);
      if (error) throw error;
    } catch (error) {
      throw new Error(error.message || 'Failed to delete property');
    }
  }

  async getPropertiesByLandlord(landlordId) {
    try {
      const { data, error } = await supabase
        .from('properties')
        .select('*')
        .eq('landlord_id', landlordId);
      if (error) throw error;
      return data;
    } catch (error) {
      throw new Error(error.message || 'Failed to fetch landlord properties');
    }
  }

  async getAvailableProperties({ page = 1, limit = 10, filters = {} }) {
    try {
      let query = supabase
        .from('properties')
        .select('*', { count: 'exact' })
        .eq('is_available', true)
        .range((page - 1) * limit, page * limit - 1);

      if (filters.priceMin) query = query.gte('price', filters.priceMin);
      if (filters.priceMax) query = query.lte('price', filters.priceMax);
      if (filters.location) query = query.ilike('location', `%${filters.location}%`);
      if (filters.bedrooms) query = query.eq('bedrooms', filters.bedrooms);

      const { data, error, count } = await query;
      if (error) throw error;
      return { data, total: count, page, limit };
    } catch (error) {
      throw new Error(error.message || 'Failed to fetch available properties');
    }
  }

  async toggleFeaturedStatus(id) {
    try {
      const { data, error } = await supabase
        .from('properties')
        .select('is_featured')
        .eq('id', id)
        .single();
      if (error) throw error;
      const newStatus = !data.is_featured;
      const { err } = await supabase
        .from('properties')
        .update({ is_featured: newStatus })
        .eq('id', id);
      if (err) throw err;
    } catch (error) {
      throw new Error(error.message || 'Failed to toggle featured status');
    }
  }

  async uploadImage(propertyId, file) {
    try {
      return await StorageService.uploadImage(propertyId, file);
    } catch (error) {
      throw new Error(error.message || 'Failed to upload image');
    }
  }

  async bulkApproveProperties(propertyIds) {
    try {
      const { error } = await supabase
        .from('properties')
        .update({ is_approved: true })
        .in('id', propertyIds);
      if (error) throw error;
    } catch (error) {
      throw new Error(error.message || 'Failed to approve properties');
    }
  }

  async setApprovalStatus(propertyId, isApproved) {
    try {
      const { error } = await supabase
        .from('properties')
        .update({ is_approved: isApproved })
        .eq('id', propertyId);
      if (error) throw error;
    } catch (error) {
      throw new Error(error.message || 'Failed to update approval status');
    }
  }
}

module.exports = new PropertyService();