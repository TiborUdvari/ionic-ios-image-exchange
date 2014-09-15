// Ionic Starter App

// angular.module is a global place for creating, registering and retrieving Angular modules
// 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
// the 2nd parameter is an array of 'requires'
// 'starter.services' is found in services.js
// 'starter.controllers' is found in controllers.js
angular.module('starter', ['ionic', 'starter.controllers', 'starter.services', 'ngCordova'])

.run(function($ionicPlatform) {
  $ionicPlatform.ready(function() {
    // Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    // for form inputs)
    if(window.cordova && window.cordova.plugins.Keyboard) {
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
    }
    if(window.StatusBar) {
      // org.apache.cordova.statusbar required
      StatusBar.styleDefault();
    }
  });
})
.controller('MainCtrl', function($scope, $cordovaFile) {

  $scope.echo = function () {
    var echoString = "Hello from native code!";

    cordova.exec( function(result){
      alert(result);
    }, 
    function(err){
      console.log('Error getting message from native code ' + err.toString());
    }, "ImageExchange", "echo", [echoString]);
  }

  $scope.imageExchange = function () {
      var imgPath = "img/Lenna.png";
      var xhr = new XMLHttpRequest();
      xhr.open( "GET", imgPath, true );
      xhr.responseType = "arraybuffer";

      xhr.onload = function( e ) {
        var arrayBufferView = new Uint8Array( this.response );
        var blob = new Blob( [ arrayBufferView ], { type: "image/png" } );
        writeFileToFileSystem(blob, 'lenna.png');
      }
      xhr.send();
  }

  function writeFileToFileSystem(blob, fileName) {
    var fn = fileName;
    $cordovaFile.createFile(fileName, true).then(function(fileEntry) {
      fileEntry.createWriter(function(fileWriter) {
      
      fileWriter.onwriteend = function(e) {
        alert('Writing image completed.');
        
        cordova.exec( function(result){
          alert(result);
        }, 
        function(err){
          alert('Error creating UIImage');
        }, "ImageExchange", "treatImage", [fn]);

      };

      fileWriter.onerror = function(e) {
        console.log('Writing image failed ' + e.toString());
      };

      fileWriter.write(blob);
      
      }, function (errCode) {
        console.log('Erro has occured with code ' + errCode.toString()); });
      });
  }

});