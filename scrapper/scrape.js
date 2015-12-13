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
var processInProgress = false;

var globalLinks = [];
var globalLinkIdx = 0;
var allLinksGrabbed = false;
var shouldExit = false;

var webpage = require('webpage');
var fs = require('fs');
var folderPath = 'dict/';
var page = webpage.create();

steps = [
  function() {
    var links = page.evaluate(
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
        // console.log("Going to process category \"" + categoryLink.textContent + "\"");
        eventFire(categoryLink, "mouseover");

        var as = document.querySelectorAll("#" + currentMenuId + " table a");
        var links = [];
        for (i = 0; i < as.length; i++) {
          links.push(as[i].href);
        }
        console.log("Category " + categoryLink.textContent + " has " + links.length + " links.");

        return links;
      },
      currentLinkId,
      currentMenuId);

    globalLinks.push.apply(globalLinks, links);

    currentLinkIdIdx++;

    if (currentLinkIdIdx == categoryLinkIds.length) {
      allLinksGrabbed = true;
    } else {
      currentLinkId = categoryLinkIds[currentLinkIdIdx];
      currentMenuIdInt++;
      currentMenuId = "menu" + currentMenuIdInt;
    }
    
    processInProgress = false;
  },
  function() {
    var link = globalLinks[globalLinkIdx];
    page.open(link, function(status) {
      if (status !== 'success') {
        console.log('Unable to load link ' + link + '! Status: ' + status);
      } else {
        console.log('Opened link ' + link);
      }

      var dict = page.evaluate(
        function(link) {
          var contentTables = document.querySelectorAll("body > table");
          var tablesUnderP = document.querySelectorAll("p > table");
          if (contentTables.length <= 1 && tablesUnderP.length <= 1) {
            console.log("Link " + link + " doesn't have more than 1 table!");
            return {};
          } else {
            if (contentTables.length <= 1) {
              contentTables = tablesUnderP;
            }
            var contentTable;
            for (i = 0; i < contentTables.length; i++) {
              if (contentTables[i].getAttribute("width") == "100%") {
                contentTable = contentTables[i];
              }
            }
            var contentTableInner = contentTable.querySelector("table");
            var rows = contentTableInner.children[0].children;
            var numRows = rows.length;
            console.log("Processing " + numRows + " rows...")
            var dict = {};
            var key = undefined;
            var value = [];
            for (i = 0; i < numRows; i++) {
              var row = rows[i];
              var tds = row.children;
              if (tds.length == 2) {
                if (key !== undefined) {
                  if (dict[key] == undefined) {
                    dict[key] = [];
                  }
                  dict[key].push(value);
                }
                key = tds[0].textContent;
                value = [tds[1].innerHTML];
              } else {
                value.push(tds[0].innerHTML);
              }
            }
            return dict;
          }
        },
        link);

      fs.write(folderPath + globalLinkIdx + ".json", JSON.stringify(dict), 'w');
      
      processInProgress = false;
    });
      
    globalLinkIdx++;
    if (globalLinkIdx == globalLinks.length) {
      shouldExit = true;
    }
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
    processInProgress = true;
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
  
  if (!loadInProgress && !processInProgress) {
    if (!allLinksGrabbed) {
      steps[0]();
    } else if (!shouldExit) {
      steps[1]();
    } else {
      phantom.exit();
    }
  }
}, 200)
