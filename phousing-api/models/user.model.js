class User {
  constructor({ id, full_name, email, phone, role, is_verified, created_at, updated_at }) {
    this.id = id || null;
    this.fullName = full_name || null;
    this.email = email || null;
    this.phone = phone || null;
    this.role = role || 'tenant';
    this.isVerified = is_verified || false;
    this.createdAt = created_at || new Date().toISOString();
    this.updatedAt = updated_at || null;
  }

  static fromJson(json) {
    if (!json || typeof json !== 'object') throw new Error('Invalid user data');
    return new User({
      id: json.id,
      full_name: json.full_name,
      email: json.email,
      phone: json.phone,
      role: json.role,
      is_verified: json.is_verified,
      created_at: json.created_at,
      updated_at: json.updated_at,
    });
  }

  toJson() {
    return {
      id: this.id,
      full_name: this.fullName,
      email: this.email,
      phone: this.phone,
      role: this.role,
      is_verified: this.isVerified,
      created_at: this.createdAt,
      updated_at: this.updatedAt,
    };
  }
}

module.exports = User;