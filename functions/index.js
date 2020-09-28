const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();
const storage = admin.storage();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
exports.createDatabase = functions.auth.user().onCreate(user => {
    console.log('creating db with uid ' + user.uid);
    db.doc('users/' + user.uid).create({});

    const bucket = storage.bucket(user.uid.toLowerCase());
    if (!bucket.exists()) {
        storage.createBucket(user.uid.toLowerCase());
    }
})
