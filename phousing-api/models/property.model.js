class Property {
  constructor({
    id,
    title,
    description,
    price,
    location,
    landlord_id,
    bedrooms,
    bathrooms,
    area,
    is_available,
    is_featured,
    is_approved,
    image_urls,
    created_at,
    updated_at,
  }) {
    this.id = id || null;
    this.title = title || null;
    this.description = description || null;
    this.price = price || 0.0;
    this.location = location || null;
    this.landlordId = landlord_id || null;
    this.bedrooms = bedrooms || 0;
    this.bathrooms = bathrooms || 0;
    this.area = area || 0.0;
    this.isAvailable = is_available || false;
    this.isFeatured = is_featured || false;
    this.isApproved = is_approved || false;
    this.imageUrls = image_urls || [];
    this.createdAt = created_at || new Date().toISOString();
    this.updatedAt = updated_at || null;
  }

  static fromJson(json) {
    if (!json || typeof json !== 'object') throw new Error('Invalid property data');
    return new Property({
      id: json.id,
      title: json.title,
      description: json.description,
      price: parseFloat(json.price),
      location: json.location,
      landlord_id: json.landlord_id,
      bedrooms: parseInt(json.bedrooms),
      bathrooms: parseInt(json.bathrooms),
      area: parseFloat(json.area),
      is_available: json.is_available,
      is_featured: json.is_featured,
      is_approved: json.is_approved,
      image_urls: Array.isArray(json.image_urls) ? json.image_urls : [],
      created_at: json.created_at,
      updated_at: json.updated_at,
    });
  }

  toJson() {
    return {
      id: this.id,
      title: this.title,
      description: this.description,
      price: this.price,
      location: this.location,
      landlord_id: this.landlordId,
      bedrooms: this.bedrooms,
      bathrooms: this.bathrooms,
      area: this.area,
      is_available: this.isAvailable,
      is_featured: this.isFeatured,
      is_approved: this.isApproved,
      image_urls: this.imageUrls,
      created_at: this.createdAt,
      updated_at: this.updatedAt,
    };
  }
}

module.exports = Property;