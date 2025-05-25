const multer = require('multer');
const supabase = require('../config/db');

const storage = multer.memoryStorage();
const upload = multer({ storage });

class StorageService {
  async uploadImage(propertyId, file) {
    try {
      const fileName = `${Date.now()}-${file.originalname}`;
      const { data, error } = await supabase.storage
        .from('property-images')
        .upload(`${propertyId}/${fileName}`, file.buffer, {
          contentType: file.mimetype,
          upsert: false,
        });
      if (error) throw error;
      return { path: data.path, url: this.getImageUrl(propertyId, fileName) };
    } catch (error) {
      throw new Error(error.message || 'Failed to upload image');
    }
  }

  async getImageUrl(propertyId, fileName) {
    try {
      const { data, error } = await supabase.storage
        .from('property-images')
        .getPublicUrl(`${propertyId}/${fileName}`);
      if (error) throw error;
      return data.publicUrl;
    } catch (error) {
      throw new Error(error.message || 'Failed to retrieve image URL');
    }
  }
}

module.exports = { StorageService: new StorageService(), upload };