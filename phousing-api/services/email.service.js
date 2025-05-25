const nodemailer = require('nodemailer');
require('dotenv').config();

class EmailService {
  constructor() {
    this.transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });
  }

  async sendEmail(to, subject, text) {
    try {
      const mailOptions = {
        from: process.env.EMAIL_USER,
        to,
        subject,
        text,
      };
      await this.transporter.sendMail(mailOptions);
    } catch (error) {
      throw new Error(error.message || 'Failed to send email');
    }
  }

  async sendVerificationEmail(to, otp) {
    await this.sendEmail(to, 'PostPata Verification Code', `Your verification code is: ${otp}`);
  }

  async sendWelcomeEmail(to, fullName) {
    await this.sendEmail(to, 'Welcome to PostPata', `Hi ${fullName}, welcome to PostPata! Start exploring properties today.`);
  }

  async sendPaymentConfirmationEmail(to, amount, propertyId) {
    await this.sendEmail(to, 'Payment Confirmation', `Your payment of $${amount} for property ${propertyId} has been received.`);
  }
}

module.exports = new EmailService();