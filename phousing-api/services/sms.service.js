const twilio = require('twilio');
require('dotenv').config();

const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const client = twilio(accountSid, authToken);

class SMSService {
  async sendSMS(to, body) {
    try {
      await client.messages.create({
        body,
        from: process.env.TWILIO_PHONE_NUMBER,
        to,
      });
    } catch (error) {
      throw new Error(error.message || 'Failed to send SMS');
    }
  }

  async sendVerificationSMS(to, otp) {
    await this.sendSMS(to, `Your PostPata verification code is: ${otp}`);
  }

  async sendPaymentAlertSMS(to, amount, propertyId) {
    await this.sendSMS(to, `Payment of $${amount} for property ${propertyId} confirmed.`);
  }
}

module.exports = new SMSService();