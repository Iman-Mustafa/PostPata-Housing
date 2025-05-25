const supabase = require('../config/db');
const { normalizePhoneNumber } = require('../utils/helpers');

class AuthService {
  async login(emailOrPhone, password, isPhone) {
    try {
      const identifier = isPhone ? normalizePhoneNumber(emailOrPhone) : emailOrPhone;
      const response = isPhone
        ? await supabase.auth.signInWithPassword({ phone: identifier, password })
        : await supabase.auth.signInWithPassword({ email: identifier, password });
      if (!response.data.user) throw new Error('Invalid credentials');
      const { data, error } = await supabase
        .from('profiles')
        .select('id, full_name, email, phone, role')
        .eq('id', response.data.user.id)
        .single();
      if (error) throw error;
      return data;
    } catch (error) {
      throw new Error(error.message || 'Login failed');
    }
  }

  async register(fullName, emailOrPhone, password, role, isPhone) {
    try {
      const identifier = isPhone ? normalizePhoneNumber(emailOrPhone) : emailOrPhone;
      const { data, error } = await supabase.auth.signUp({
        [isPhone ? 'phone' : 'email']: identifier,
        password,
        options: { data: { full_name: fullName, role } },
      });
      if (error) throw error;
      return { id: data.user.id, fullName, role };
    } catch (error) {
      throw new Error(error.message || 'Registration failed');
    }
  }

  async verifyOtp(emailOrPhone, otp, isPhone) {
    try {
      const identifier = isPhone ? normalizePhoneNumber(emailOrPhone) : emailOrPhone;
      const { data, error } = await supabase.auth.verifyOtp({
        [isPhone ? 'phone' : 'email']: identifier,
        token: otp,
        type: 'sms',
      });
      if (error) throw error;
    } catch (error) {
      throw new Error(error.message || 'OTP verification failed');
    }
  }

  async logout() {
    try {
      await supabase.auth.signOut();
    } catch (error) {
      throw new Error(error.message || 'Logout failed');
    }
  }

  async getCurrentUser() {
    try {
      const session = await supabase.auth.getSession();
      if (!session.data.session) return null;
      const { data, error } = await supabase
        .from('profiles')
        .select('id, full_name, email, phone, role, is_verified')
        .eq('id', session.data.session.user.id)
        .single();
      if (error) throw error;
      return data;
    } catch (error) {
      throw new Error(error.message || 'Failed to fetch current user');
    }
  }

  async updateProfile(userId, updates) {
    try {
      const { fullName, emailOrPhone, isPhone } = updates;
      const identifier = isPhone ? normalizePhoneNumber(emailOrPhone) : emailOrPhone;
      const { data, error } = await supabase
        .from('profiles')
        .update({ full_name: fullName, [isPhone ? 'phone' : 'email']: identifier })
        .eq('id', userId)
        .select()
        .single();
      if (error) throw error;
      return data;
    } catch (error) {
      throw new Error(error.message || 'Failed to update profile');
    }
  }
}

module.exports = new AuthService();