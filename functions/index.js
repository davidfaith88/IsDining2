const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const nodemailer = require("nodemailer");

// TODO: Replace with your email credentials or use SendGrid
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "your-email@gmail.com",        // Change this
    pass: "your-app-password",           // Change this
  },
});

exports.notifyRestaurantOwner = functions.firestore
  .document("owner_notifications/{docId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const restaurantName = data.restaurantName || "a restaurant";

    const mailOptions = {
      from: "IsDining <your-email@gmail.com>",
      to: "owner@example.com", // In real version, pull from Google Places or input
      subject: `Your customers are planning dinners at ${restaurantName}`,
      text: `Hi,

Several of your customers are using IsDining to coordinate dinners at your restaurant.

IsDining is a free app that helps friends find each other for meals and lets owners see upcoming plans and send incentives.

Would you like a quick demo? It only takes 2 minutes to claim your listing.

Best,
The IsDining Team`,
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log("Notification email sent for", restaurantName);
    } catch (error) {
      console.error("Error sending email:", error);
    }
  });