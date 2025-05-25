class Response {
  constructor({ success, data, message, error }) {
    this.success = success !== undefined ? success : true;
    this.data = data || null;
    this.message = message || null;
    this.error = error || null;
  }

  static fromJson(json) {
    if (!json || typeof json !== 'object') throw new Error('Invalid response data');
    return new Response({
      success: json.success,
      data: json.data,
      message: json.message,
      error: json.error,
    });
  }

  toJson() {
    return {
      success: this.success,
      data: this.data,
      message: this.message,
      error: this.error,
    };
  }
}

module.exports = Response;