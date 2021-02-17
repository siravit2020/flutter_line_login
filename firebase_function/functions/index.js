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
// const runtimeOpts = {
// 	timeoutSeconds: 300,
// 	memory: '2GB'
// }

// exports.createCustomToken = functions.region('asia-northeast1').runWith(runtimeOpts).https.onRequest((request, response) => {
//   var decoded = jwt_decode(request.query.id);
//   var access = request.query.access;
//   if (request.query.id === undefined) {
//     const ret = {
//       error_message: 'AccessToken not found',
//     };
//     return response.status(400).send(ret);
//   }

//   return verifyLineToken(decoded,access)
//     .then((customAuthToken) => {
//       const ret = {
//         firebase_token: customAuthToken,
//       };
//       return response.status(200).send(ret);
//     }).catch((err) => {
//       const ret = {
//         error_message: `Authentication error: ${err}`,
//       };
//       return response.status(200).send(ret);
//     });
// });
// exports.addMessage = functions.https.onCall((data, context) => {
//   const text = data.text;
//   functions.logger.info(text, {structuredData: true});

// });
// function verifyLineToken(body,access) {
//   return request({
//     method: 'GET',
//     uri: `https://api.line.me/oauth2/v2.1/verify?access_token=${access}`,
//     json: true
//   }).then((response) => {
//     if (response.client_id !== functions.config().line.channelid) {
//       return Promise.reject(new Error('LINE channel ID mismatched'));
//     }
//     return getFirebaseUser(body);
//   }).then((userRecord) => {
//     return admin.auth().createCustomToken(userRecord.uid);
//   }).then((token) => {
//     return token;
//   });
// }
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   var decoded = jwt_decode(request.query.id);
//   response.send("Hello from Firebase!" + decoded.email + request.query.access);
// });

// function getFirebaseUser(body) {
//   const firebaseUid = `line:${body.sub}`;

//   return admin.auth().getUser(firebaseUid).then(function(userRecord) {
//     return userRecord;
//   }).catch((error) => {
//     if (error.code === 'auth/user-not-found') {
//         return admin.auth().createUser({
//           uid: firebaseUid,
//           displayName: body.name,
//           photoURL: body.picture,
//           email: body.email
//         });
//     }
//     return Promise.reject(error);
//   });
// }
