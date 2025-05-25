class Payment {
  constructor({ id, property_id, tenant_id, amount, payment_date, status, created_at, updated_at }) {
    this.id = id || null;
    this.propertyId = property_id || null;
    this.tenantId = tenant_id || null;
    this.amount = amount || 0.0;
    this.paymentDate = payment_date || new Date().toISOString();
    this.status = status || 'pending';
    this.createdAt = created_at || new Date().toISOString();
    this.updatedAt = updated_at || null;
  }

  static fromJson(json) {
    if (!json || typeof json !== 'object') throw new Error('Invalid payment data');
    const validStatuses = ['pending', 'completed', 'failed'];
    return new Payment({
      id: json.id,
      property_id: json.property_id,
      tenant_id: json.tenant_id,
      amount: parseFloat(json.amount),
      payment_date: json.payment_date,
      status: validStatuses.includes(json.status) ? json.status : 'pending',
      created_at: json.created_at,
      updated_at: json.updated_at,
    });
  }

  toJson() {
    return {
      id: this.id,
      property_id: this.propertyId,
      tenant_id: this.tenantId,
      amount: this.amount,
      payment_date: this.paymentDate,
      status: this.status,
      created_at: this.createdAt,
      updated_at: this.updatedAt,
    };
  }
}

module.exports = Payment;