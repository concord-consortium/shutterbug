/*
  Loads an html page and does a depth-first walk of its iframes.  As the walk returns to the root each iframe's
  src is set to the base64 png rendering of its contents. At the root the updated page content is rendered to an image.

  This code uses two recursive methods: drainIFrameQueue() in processIframes() and loadPage(). drainIFrameQueue() is simply an async
  for loop over the iframes found in processIframes().  loadPage() recurses in a somewhat oblique manner via processIFrames().

  Here is a sample flattened call trace for a invocation on a page containing 1 iframe which itself contains no iframes:

  // main entry point
  renderPage()

  // load page html
  loadPage(pageHtml, cb1)
  createPage(pageHtml, pageBase, cb2)
  cb2(page)

  // process page iframes
  processIFrames(page, cb3)
  getIFrameSrc()
  drainIFrameQueue() <- outer page queue

  // load page iframe html
  loadPage(iframeHTML, cb4) <- 1 iframe found in page html so that iframe is loaded as a page
  createPage(iframeHTML, iframeBase, cb5)
  cb5(iframePage)

  // process page iframe inner iframes
  processIFrames(iframePage, cb6)
  getIFrameSrc()
  drainIFrameQueue() <- inner frame queue
  cb6(hasChangedIframes=false) <- no iframes found in inner iframe html so callback called immediately
  cb4(iframePage, iframeBase, hasChangedIframes)

  // replace page iframe src with rendered image
  createPage(iframeHTML, iframeBase, cb7) <-- loaded in separate page so the updated iframe src is rendered correctly
  cb7(finalIFrame)
  updateIframeAndContinue(finalIFrame)
  drainIFrameQueue() <- outer page queue
  cb3(hasChangedIframes=true)
  cb1(page, base, hasChangedIframes)

  // render page
  createPage(pageHtml, pageBase, cb8)
  cb8(finalPage)
  finalPage.render()
  phantom.exit();
*/

/*global phantom */
var system = require('system'),
    fs = require('fs'),
    baseRegEx = /<\s*base[^>]+href\s*=\s*['"]([^'"]*)['"][^>]*>/i,
    baseFixupRegEx = /(&((amp;)*)lt;\s*base\s+href\s*=\s*)(['"])([^'"]*)(['"])([^&]*&((amp;)*)gt;)/gi,
    metaFixupRegEx = /(&((amp;)*)lt;\s*meta\s+content\s*=\s*)(['"])([^'"]*)(['"])(\s+http-equiv\s*=\s*)(['"])([^'"]*)(['"])([^&]*&(((amp;))*)gt;)/gi,
    viewportSize = { width: 1000, height: 700 },
    filename, output, quality, size, base, html;

if (system.args.length < 3 || system.args.length > 5) {
    console.log('Usage: rasterize.js URL filename width*height quality(0-100)');
    phantom.exit(1);
}

// get the options
filename = system.args[1];
output = system.args[2];
if (system.args.length > 3) {
    size = system.args[3].split('*');
    viewportSize = { width: size[0], height: size[1] };
    quality = system.args[4];
}

// let 'er rip!
renderPage();

// converts &quot; to &amp;quot; based on the number of already escaped amps found in the fixup regex
function escapeQuote(allAmps) {
  var quote = "&quot;",
      numEscapes = allAmps.split("amp").length - 1,  // &('')lt; => 1 - 1 = 0 => &quot;, &(amp;)lt; => 2 - 1 = 1 => &amp;quot;, &(amp;amp;)lt; => 3 - 1 = 2 => &amp;amp;quot;
      i;
  for (i = 0; i < numEscapes; i++) {
    quote = quote.replace('&', '&amp;');
  }
  return quote;
}

function fixupBase($0,$beforeQuote,$allAmps,$innerAmps,$leftQuote,$insideQuote,$rightQuote,$afterQuote) {
  var escapedQuote = escapeQuote($allAmps);
  // 2015-09-04 HACK FIXME: For reasons we don't yet understand, iframes
  // with base hrefs  without hash (#) symbols can sometimes cause the
  // data-urls to decode incorrectly.
  // Our Longterm solution will be to base64 encode iFrame data-urls.
  return [$beforeQuote, escapedQuote, decodeURIComponent($insideQuote), '#', escapedQuote, $afterQuote].join('');
}

function fixupMeta($0,$beforeQuotes,$allAmps,$innerAmps,$leftFirstQuote,$insideFirstQuote,$rightFirstQuote,$betweenQuotes,$leftSecondQuote,$insideSecondQuote,$rightSecondQuote,$afterQuotes) {
  var escapedQuote = escapeQuote($allAmps);
  return [$beforeQuotes, escapedQuote, decodeURIComponent($insideFirstQuote), escapedQuote, $betweenQuotes, escapedQuote, decodeURIComponent($insideSecondQuote), escapedQuote, $afterQuotes].join('');
}

function testFixup(regex, fixup, src, fixed) {
  var result = src.replace(regex, fixup);
  if (result !== fixed) {
    console.log("Expected '" + fixed + "' got '" + result + "'")
  }
}

// Main function, called once
function renderPage() {
    var contents = fs.read(filename);

    // change to true for testing
    if (false) {
      console.log("Testing base fixup...");
      testFixup(baseFixupRegEx, fixupBase, "&lt;base href='http://concord-consortium.github.io/lara-interactive-api/'&gt;", "&lt;base href=&quot;http://concord-consortium.github.io/lara-interactive-api/&quot;&gt;");
      testFixup(baseFixupRegEx, fixupBase, "&amp;lt;base href='http://concord-consortium.github.io/lara-interactive-api/'&amp;gt;", "&amp;lt;base href=&amp;quot;http://concord-consortium.github.io/lara-interactive-api/&amp;quot;&amp;gt;");
      testFixup(baseFixupRegEx, fixupBase, "&amp;amp;lt;base href='http://concord-consortium.github.io/lara-interactive-api/'&amp;amp;gt;", "&amp;amp;lt;base href=&amp;amp;quot;http://concord-consortium.github.io/lara-interactive-api/&amp;amp;quot;&amp;amp;gt;");
      console.log("Testing meta fixup...");
      testFixup(metaFixupRegEx, fixupMeta, "&lt;meta content='text/html;charset=utf-8' http-equiv='Content-Type'&gt;", "&lt;meta content=&quot;text/html;charset=utf-8&quot; http-equiv=&quot;Content-Type&quot;&gt;");
      testFixup(metaFixupRegEx, fixupMeta, "&amp;lt;meta content='text/html;charset=utf-8' http-equiv='Content-Type'&amp;gt;", "&amp;lt;meta content=&amp;quot;text/html;charset=utf-8&amp;quot; http-equiv=&amp;quot;Content-Type&amp;quot;&amp;gt;");
      testFixup(metaFixupRegEx, fixupMeta, "&amp;amp;lt;meta content='text/html;charset=utf-8' http-equiv='Content-Type'&amp;amp;gt;", "&amp;amp;lt;meta content=&amp;amp;quot;text/html;charset=utf-8&amp;amp;quot; http-equiv=&amp;amp;quot;Content-Type&amp;amp;quot;&amp;amp;gt;");
    }

    // fixup old clients that send single quoted escaped attributes in the metadata
    // the single quoted escaped text causes phantom to incorrectly parse the html
    contents = contents.replace(baseFixupRegEx, fixupBase).replace(metaFixupRegEx, fixupMeta);

    // this is the initial load of the html provided by phantom_job.rb
    loadPage(contents, function (page, base, hasChangedIframes) {
        // At this point the page has been "walked", and if it includes iframes, loadPage() has been called on each iframe.
        // The iframe srces have been updated to a data-uri that has an image taken of the iframe contents.
        if (hasChangedIframes) {
          // phantom does not seem to want to render changed iframe content when the src parameter is modified
          // so we need to reload it in another page
          createPage(page.content, base, function (finalPage) {
              finalPage.render(output, {quality: quality});
              phantom.exit();
          });
        }
        else {
          page.render(output, {quality: quality});
          phantom.exit();
        }
    });
}

// This function is called recursively via processIFrames() for each iframe in the page.
// The base tag is removed from the html and passed to createPage() which uses phantom's
// setContent() method to load the page.  The base is removed because if it is present
// svg gradients are not rendered correctly as their fill ids are based on the base tag
// and not the local document.
function loadPage(html, callback) {
    var m = html.match(baseRegEx),
        base = m ? m[1] : '',
        baselessHtml = html.replace(baseRegEx, '');

    createPage(baselessHtml, base, function (page) {
        processIframes(page, function (hasChangedIframes) {
          callback(page, base, hasChangedIframes);
        });
    });
}

// Creates the phantom page object using the passed in html and base and returns it in a callback
function createPage(html, base, callback) {
    var page = require('webpage').create(),
        resourceCount = 0;

    // onLoadFinished is signaled before all the contained iframe documents are loaded
    // so we need to keep a count of the resources requested to make sure they load before we continue on
    page.onResourceRequested = function() {
      resourceCount++;
    };
    page.onResourceReceived = function(response) {
      // phantom sends this for each chunk (4k in testing, the end is signaled with the stage variable)
      if (response.stage == "end") {
        resourceCount--;
      }
    };
    page.onResourceError = function() {
      resourceCount--;
    };

    page.onLoadFinished = function(status) {
        var loadTime = (new Date()).getTime();

        if (status !== 'success') {
            console.log('Unable to load html!');
            phantom.exit();
        }

        // wait until the next tick for any contained iframes to finish making their requests
        window.setTimeout(function () {
            // then wait for resourceCount to be zero or the timeout to hit
            waitForAllResourcesToLoadOrTimeout();
        }, 0);

        function waitForAllResourcesToLoadOrTimeout() {
          var now = (new Date()).getTime();
          if ((resourceCount === 0) || (now - loadTime > 10000)) {
              callback(page);
          }
          else {
              window.setTimeout(waitForAllResourcesToLoadOrTimeout, 0)
          }
        }
    };

    page.viewportSize = viewportSize;
    page.setContent(html, base);
}

// Gets the source of each iframe and then loads that source in a separate page.
// The loaded iframe page is then rendered as a data-uri containing an img tag
// with its src being the base64 encoded png render of the iframe contents
function processIframes(page, callback) {

    var iframeSrc = getIframeDataUriSrc(page),
        iframePng = [],
        changedFrameCount = 0,
        queueIndex = 0;

    // Since this is async we can't loop but instead recursivly call drainIFrameQueue()
    // until all the iframes have been processed.  Once they have all been processed
    // the callback is invoked passing a flag if iframe were found in the page.
    // The flag is used to see if we need to reload the final updated html in another
    // page for rendering as phantomjs doesn't seem to reflow the document when the
    // pages iframe src attribute is updated.
    drainIFrameQueue();

    function drainIFrameQueue() {
      if (queueIndex < iframeSrc.length) {

          // getIframeSrc returns null for frames that don't use data-uris in the src
          // it doesn't just skip them so that we can maintain the queueIndex
          if (iframeSrc[queueIndex] === null) {
            queueIndex++;
            drainIFrameQueue();
            return;
          }

          changedFrameCount++;

          // This is the recursion down the iframes.  It restarts the entire process
          // of loading so we can handle an infinite number of embedded iframes.
          // The recursion stops when it completes a depth first search of all the iframes
          // starting at the root document.

          loadPage(iframeSrc[queueIndex], function (iFrame, base, hasChangedIframes) {
              // convert the iframe contents to a png and then set the src to it
              if (hasChangedIframes) {
                  // reload the iframe so the src is used
                  createPage(iFrame.content, base, function (finalIFrame) {
                      updateIframeAndContinue(finalIFrame);
                  });
              }
              else {
                  updateIframeAndContinue(iFrame);
              }

              // renders the iframe to an image, updates the iframe src and then
              // calls drainIFrameQueue() to process the rest of the page's iframes in the queue
              function updateIframeAndContinue(iFrame) {
                  page.evaluate(function (queueIndex, src) {
                      document.getElementsByTagName('iframe').item(queueIndex).src = src;
                  }, queueIndex, renderIframeToImage(iFrame));
                  queueIndex++;
                  drainIFrameQueue();
              }
          });
      }
      else {
          callback(changedFrameCount > 0);
      }
    }
}

// This is the data uri that is used as a replacement of the iframe src
function renderIframeToImage(iFrame) {
    return 'data:text/html,<html><head><style>body {margin: 0; padding: 0;}</style><body><img src="data:image/png;base64,' + iFrame.renderBase64('PNG') + '"></body></html>';
}

// Walks all the iframes in the current page and pushes their src onto an array that is returned.
// Phantom.js only allows simple types to cross the evaluate() boundary so the array is marshalled
// as a JSON string.
function getIframeDataUriSrc(page) {
    return JSON.parse(page.evaluate(function () {
        var iframes = document.getElementsByTagName('iframe'),
            src = [],
            mimeType = "data:text/html,",
            iframe, i;
        for (i = 0; i < iframes.length; i++) {
            iframe = iframes.item(i);
            if (iframe.src.substr(0, mimeType.length) == mimeType) {
                src.push(iframe.src.substr(mimeType.length));
            }
            else {
                // null is used to signify that the iframe doesn't use data uris
                src.push(null);
            }
        }
        // only simple types can be returned...
        return JSON.stringify(src);
    }));
}
