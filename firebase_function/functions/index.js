const functions = require("firebase-functions");
const request = require("request-promise");
const admin = require("firebase-admin");
const serviceAccount = require("./service-account.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const runtimeOpts = {
  timeoutSeconds: 300,
  memory: "2GB",
};

exports.createCustomToken = functions
  .region("asia-northeast1")
  .runWith(runtimeOpts)
  .https.onRequest((request, response) => {
    if (request.body.access_token === undefined) {
      const ret = {
        error_message: "AccessToken not found",
      };
      return response.status(400).send(ret);
    }

    return verifyLineToken(request.body)
      .then((customAuthToken) => {
        const ret = {
          firebase_token: customAuthToken,
        };
        return response.status(200).send(ret);
      })
      .catch((err) => {
        const ret = {
          error_message: `Authentication error: ${err}`,
        };
        return response.status(200).send(ret);
      });
  });

async function verifyLineToken(body) {
  const response = await request({
    method: "GET",
    uri: `https://api.line.me/oauth2/v2.1/verify?access_token=${body.access_token}`,
    json: true,
  });
  if (response.client_id !== functions.config().line.channelid) {
    return Promise.reject(new Error("LINE channel ID mismatched"));
  }
  const userRecord = await getFirebaseUser(body);
  const token = await admin.auth().createCustomToken(userRecord.uid);
  return token;
}

async function getFirebaseUser(body) {
  const firebaseUid = `line:${body.id}`;

  try {
    const userRecord = await admin
      .auth()
      .getUser(firebaseUid);
    return await admin.auth().updateUser(userRecord.uid, {
      displayName: body.name,
      photoURL: body.picture,
      email: body.email,
    });
  } catch (error) {
    if (error.code === "auth/user-not-found") {
      return admin.auth().createUser({
        uid: firebaseUid,
        displayName: body.name,
        photoURL: body.picture,
        email: body.email,
      });
    }
    return await Promise.reject(error);
  }
}
