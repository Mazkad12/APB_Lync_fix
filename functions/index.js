const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.redirect = functions.region('asia-southeast2').https.onRequest(async (req, res) => {
  // Extract the short code from the URL path. 
  // Example path: /redirect/abcde -> code is "abcde"
  const pathParts = req.path.split('/').filter(Boolean);
  const shortCode = pathParts[0];

  if (!shortCode) {
    return res.status(400).send("Bad Request: Short code is missing.");
  }

  try {
    // Look up the code in the 'links' collection
    const linkDoc = await admin.firestore().collection('links').doc(shortCode).get();

    if (!linkDoc.exists) {
      return res.status(404).send("Not Found: The shortened link does not exist.");
    }

    const data = linkDoc.data();
    const originalUrl = data.originalUrl;

    if (!originalUrl) {
      return res.status(404).send("Not Found: Original URL is missing in the database.");
    }

    // Redirect to the original URL
    res.redirect(302, originalUrl);

  } catch (error) {
    console.error("Error fetching link:", error);
    res.status(500).send("Internal Server Error.");
  }
});
