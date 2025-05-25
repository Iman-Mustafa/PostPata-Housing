class Maintenance {
  constructor({ id, property_id, tenant_id, description, status, created_at, updated_at }) {
    this.id = id || null;
    this.propertyId = property_id || null;
    this.tenantId = tenant_id || null;
    this.description = description || null;
    this.status = status || 'pending';
    this.createdAt = created_at || new Date().toISOString();
    this.updatedAt = updated_at || null;
  }

  static fromJson(json) {
    if (!json || typeof json !== 'object') throw new Error('Invalid maintenance data');
    const validStatuses = ['pending', 'in_progress', 'resolved'];
    return new Maintenance({
      id: json.id,
      property_id: json.property_id,
      tenant_id: json.tenant_id,
      description: json.description,
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
      description: this.description,
      status: this.status,
      created_at: this.createdAt,
      updated_at: this.updatedAt,
    };
  }
}

module.exports = Maintenance;