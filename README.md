Ionic/Cordova iOS image exchange
================================

Sample project highlighting the communication between ionic/cordova web app and custom native components.

How to run
----------

* Make sure you have *ionic* installed

  npm install -g cordova ionic

* To run on emulator

  ionic build ios 
  ionic emulate ios 

or alternatively launch on a physical device with 

  ionic run ios 

Glue code
---------
The glue code contains these 3 components

1. `ImageExchange` (objective-C class) in the platforms/ios/www/plugins folder 
2. Feature configuration in the config.xml file 
3. Calling the native code in `app.js`

Notes
-----

The ngCordova file override does not seem to be working, so the code
will fail at writing the file if there is one that already exists.

ROADMAP
-------
* Image treatement with Objective C code for illustration pourpouses  
