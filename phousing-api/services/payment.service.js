const supabase = require('../config/db');

class PaymentService {
  async addPayment(payment) {
    try {
      const { data, error } = await supabase
        .from('payments')
        .insert([payment])
        .select()
        .single();
      if (error) throw error;
      return data;
    } catch (error) {
      throw new Error(error.message || 'Failed to add payment');
    }
  }

  async getPaymentsByTenant(tenantId) {
    try {
      const { data, error } = await supabase
        .from('payments')
        .select('*')
        .eq('tenant_id', tenantId)
        .order('payment_date', { ascending: false });
      if (error) throw error;
      return data;
    } catch (error) {
      throw new Error(error.message || 'Failed to fetch tenant payments');
    }
  }

  async getPaymentsByProperty(propertyId) {
    try {
      const { data, error } = await supabase
        .from('payments')
        .select('*')
        .eq('property_id', propertyId)
        .order('payment_date', { ascending: false });
      if (error) throw error;
      return data;
    } catch (error) {
      throw new Error(error.message || 'Failed to fetch property payments');
    }
  }

  async confirmPayment(paymentId) {
    try {
      const { error } = await supabase
        .from('payments')
        .update({ status: 'completed' })
        .eq('id', paymentId);
      if (error) throw error;
    } catch (error) {
      throw new Error(error.message || 'Failed to confirm payment');
    }
  }
}

module.exports = new PaymentService();