importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp( {
    apiKey: "AIzaSyBpHUWczANDziA-Gzxoh_ybGnEZq9JmKL4",
    authDomain: "nkust-ap-flutter.firebaseapp.com",
    databaseURL: "https://nkust-ap-flutter.firebaseio.com",
    projectId: "nkust-ap-flutter",
    storageBucket: "nkust-ap-flutter.appspot.com",
    messagingSenderId: "141403473068",
    appId: "1:141403473068:web:2804dce650446efef34b09",
    measurementId: "G-TSD51EKRLX"
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});