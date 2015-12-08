console.log("Starting scrapper for Dolmetsch Online Music Dictionary...")

// These are the menu items' ids
var categoryLinkIds = [];
for (i = 235; i < 262; i++) {
  categoryLinkIds.push("el" + i);
}

var currentLinkIdIdx = 0;
var currentLinkId = categoryLinkIds[currentLinkIdIdx];
// First category's dropdown menu's id is "menu11"
var currentMenuIdInt = currentLinkIdIdx + 10;
var currentMenuId = "menu" + currentMenuIdInt;
var loadInProgress = false;

var page = require('webpage').create();

steps = [
  function() {
    page.evaluate(
      function(currentLinkId, currentMenuId) {
        
        function eventFire(el, etype) {
          if (el.fireEvent) {
            el.fireEvent('on' + etype);
          } else {
            var evObj = document.createEvent('Events');
            evObj.initEvent(etype, true, false);
            el.dispatchEvent(evObj);
          }
        }
        
        var categoryLink = document.getElementById(currentLinkId).children[0];
        console.log("Going to process category \"" + categoryLink.textContent + "\"");
        eventFire(categoryLink, "mouseover");
        
        var links = document.querySelectorAll("#" + currentMenuId + " table a");
        console.log("Category " + categoryLink.textContent + " has " + links.length + " links.");
      },
      currentLinkId,
      currentMenuId);
      currentLinkIdIdx++;
      
      if (currentLinkIdIdx == categoryLinkIds.length) {
        phantom.exit();
      }
      currentLinkId = categoryLinkIds[currentLinkIdIdx];
      currentMenuIdInt++;
      currentMenuId = "menu" + currentMenuIdInt;
  }
]

page.open("http://www.dolmetsch.com/musictheorydefs.htm", function(status) {
  if (status !== 'success') {
    console.log('Unable to access network ' + status);
  }
});

page.onPageCreated = function(newPage) {
  console.log("A new page was created: " + newPage.url);
  page = newPage;
  
  // Decorate
  page.onClosing = function(closingPage) {
    console.log("A page is closing: " + closingPage.url)
  };
  page.onLoadStarted = function() {
    loadInProgress = true;
    console.log("Load started on page");
  };
  page.onLoadFinished = function() {
    loadInProgress = false;
    console.log("Load finished on page");
  }
  page.onConsoleMessage = function(msg) {
    console.log(msg);
  };
};

page.onLoadStarted = function() {
  loadInProgress = true;
  console.log("Load started on page");
};
page.onLoadFinished = function() {
  loadInProgress = false;
  console.log("Load finished on page");
}
page.onConsoleMessage = function(msg) {
  console.log(msg);
};

var interval = setInterval(function() {
  
  if ((!loadInProgress)) {
    steps[0]();
  }
}, 1000)
