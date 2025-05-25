const { v4: uuidv4 } = require('uuid');

class Helpers {
  static normalizePhoneNumber(phone) {
    if (!phone || typeof phone !== 'string') throw new Error('Invalid phone number');
    let normalized = phone.replace(/[^\d+]/g, '');
    if (!normalized.startsWith('+')) normalized = '+' + normalized;
    if (normalized.length < 9 || normalized.length > 15) throw new Error('Phone number must be between 9 and 15 digits');
    return normalized;
  }

  static formatDate(date, format = 'YYYY-MM-DD HH:mm:ss') {
    if (!(date instanceof Date)) date = new Date(date);
    if (isNaN(date.getTime())) throw new Error('Invalid date');
    const pad = (num) => String(num).padStart(2, '0');
    const year = date.getFullYear();
    const month = pad(date.getMonth() + 1);
    const day = pad(date.getDate());
    const hours = pad(date.getHours());
    const minutes = pad(date.getMinutes());
    const seconds = pad(date.getSeconds());
    return format
      .replace('YYYY', year)
      .replace('MM', month)
      .replace('DD', day)
      .replace('HH', hours)
      .replace('mm', minutes)
      .replace('ss', seconds);
  }

  static generateUUID() {
    return uuidv4();
  }

  static isValidEmail(email) {
    if (!email || typeof email !== 'string') return false;
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  static paginate(total, page, limit) {
    const totalPages = Math.ceil(total / limit);
    const currentPage = Math.max(1, Math.min(page, totalPages));
    const offset = (currentPage - 1) * limit;
    return { total, totalPages, currentPage, offset, limit };
  }
}

module.exports = Helpers;