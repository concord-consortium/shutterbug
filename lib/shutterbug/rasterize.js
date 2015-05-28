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
  cb6(hasIframes=false) <- no iframes found in inner iframe html so callback called immediately
  cb4(iframePage, iframeBase, hasIframes)

  // replace page iframe src with rendered image
  createPage(iframeHTML, iframeBase, cb7) <-- loaded in separate page so the updated iframe src is rendered correctly
  cb7(finalIFrame)
  updateIframeAndContinue(finalIFrame)
  drainIFrameQueue() <- outer page queue
  cb3(hasIframes=true)
  cb1(page, base, hasIframes)

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

// Main function, called once
function renderPage() {
    // this is the initial load of the html provided by phantom_job.rb
    loadPage(fs.read(filename), function (page, base, hasIframes) {
        // At this point the page has been "walked", and if it includes iframes, loadPage() has been called on each iframe.
        // The iframe srces have been updated to a data-uri that has an image taken of the iframe contents.
        if (hasIframes) {
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
        html = html.replace(baseRegEx, '');

    createPage(html, base, function (page) {
        processIframes(page, function (hasIframes) {
          callback(page, base, hasIframes);
        });
    });
}

// Creates the phantom page object using the passed in html and base and returns it in a callback
function createPage(html, base, callback) {
    var page = require('webpage').create();

    page.onLoadFinished = function(status) {
        if (status !== 'success') {
            console.log('Unable to load html!');
            phantom.exit();
        }

        window.setTimeout(function () {
          callback(page);
        }, 200);
    };

    page.viewportSize = viewportSize;
    page.setContent(html, base);
}

// Gets the source of each iframe and then loads that source in a separate page.
// The loaded iframe page is then rendered as a data-uri containing an img tag
// with its src being the base64 encoded png render of the iframe contents
function processIframes(page, callback) {

    var iframeSrc = getIframeSrc(page),
        iframePng = [],
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

          // This is the recursion down the iframes.  It restarts the entire process
          // of loading so we can handle an infinite number of embedded iframes.
          // The recursion stops when it completes a depth first search of all the iframes
          // starting at the root document.

          loadPage(iframeSrc[queueIndex], function (iFrame, base, hasIFrames) {
              // convert the iframe contents to a png and then set the src to it
              if (hasIFrames) {
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
                  }, queueIndex, renderIframeToImage(iFrame))
                  queueIndex++;
                  drainIFrameQueue();
              }
          });
      }
      else {
          callback(iframeSrc.length > 0);
      }
    }
}

// This is the data uri that is used as a replacement of the iframe src
function renderIframeToImage(iFrame) {
    return 'data:text/html,<html><head><style>body {margin: 0; padding: 0;}</style><body><img src="data:image/png;base64,' + iFrame.renderBase64('PNG') + '"></body></html>'
}

// Walks all the iframes in the current page and pushes their src onto an array that is returned.
// Phantom.js only allows simple types to cross the evaluate() boundary so the array is marshalled
// as a JSON string.
function getIframeSrc(page) {
    return JSON.parse(page.evaluate(function () {
        var iframes = document.getElementsByTagName('iframe'),
            src = [],
            mimeType = "data:text/html,",
            serializer = new XMLSerializer(),
            iframe, i;
        for (i = 0; i < iframes.length; i++) {
            iframe = iframes.item(i);
            if (iframe.src.substr(0, mimeType.length) == mimeType) {
                src.push(iframe.src.substr(mimeType.length));
            }
            else {
                try {
                  src.push(serializer.serializeToString(iframe.contentDocument));
                }
                catch (e) {
                  src.push('');
                }
            }
        }
        // only simple types can be returned...
        return JSON.stringify(src);
    }))
}
