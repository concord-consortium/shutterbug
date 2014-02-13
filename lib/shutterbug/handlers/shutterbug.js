/*global $ */
(function(){
  var $ = window.$;

  var MAX_TIMEOUT = 1500;

  var getBaseUrl = function() {
    var base = window.location.href;
    return base;
  };

  var cloneDomItem = function(elem, elemTag) {
    var width   = elem.width();
    var height  = elem.height();
    var returnElm = $(elemTag);

    returnElm.addClass($(elem).attr("class"));
    returnElm.attr("style", $(elem).attr("style"));
    returnElm.css('background', $(elem).css("background"));
    returnElm.attr('width', width);
    returnElm.attr('height', height);
    return returnElm;
  };

  var generateIFrameSrcData = function (iframeDesc) {
    return "data:text/html," +
      "<!DOCTYPE html>" +
      "<html>" +
        "<head>" +
          "<base href='" + iframeDesc.base_url + "'>" +
          "<meta content='text/html;charset=utf-8' http-equiv='Content-Type'>" +
          "<title>content from " + iframeDesc.base_url + "</title>" +
          iframeDesc.css +
        "</head>" +
        "<body>" +
          iframeDesc.content +
        "</body>" +
      "</html>";
  };

  var getHtmlFragment = function(callback) {
    var self = this;
    var $element = $(this.element);
    // .find('iframe').addBack("iframe") handles two cases:
    // - element itself is an iframe - .addBack('iframe')
    // - element descentands are iframes - .find('iframe')
    var $iframes = $element.find('iframe').addBack("iframe");
    this._iframeContentRequests = [];
    
    $iframes.each(function(i, iframeElem) {
      var message  = {
        type:        'htmlFragRequest',
        id:          self.id,
        iframeReqId: i,
        // We have to provide smaller timeout while sending message to nested iframes.
        // Otherwise, when one of the nested iframes timeouts, then all will do the
        // same and we won't render anything - even iframes that support Shutterbug.
        iframeReqTimeout: self.iframeReqTimeout * 0.6
      };
      iframeElem.contentWindow.postMessage(JSON.stringify(message), "*");
      var requestDeffered = new $.Deferred();
      self._iframeContentRequests[i] = requestDeffered;
      setTimeout(function() {
        // It handles a situation in which iframe doesn't support Shutterbug. 
        // When we doesn't receive answer for some time, assume that we can't
        // render this particular iframe (provide null as iframe description).
        if (requestDeffered.state() !== "resolved") {
          requestDeffered.resolve(null);
        }
      }, self.iframeReqTimeout);
    });

    $.when.apply($, this._iframeContentRequests).done(function() {
      // This function is called when we receive responses from all nested iframes.
      // Nested iframes descriptions will be provided as arguments.
      $element.trigger('shutterbug-saycheese');

      var css     = $('<div>').append($('link[rel="stylesheet"]').clone()).append($('style').clone()).html();
      var width   = $element.width();
      var height  = $element.height();
      var element = $element.clone();

      if (arguments.length > 0) {
        var nestedIFrames = arguments;
        // This supports two cases:
        // - element itself is an iframe - .addBack('iframe')
        // - element descentands are iframes - .find('iframe')
        element.find("iframe").addBack("iframe").each(function(i, iframeElem) {
          // When iframe doesn't support Shutterbug, request will timeout and null will be received.
          // In such case just ignore this iframe, we won't be able to render it.
          if (nestedIFrames[i] == null) return;
          $(iframeElem).attr("src", generateIFrameSrcData(nestedIFrames[i]));
        });
      }

      var replacementImgs = $element.find('canvas').map( function(count,elem) {
          var dataUrl = elem.toDataURL('image/png');
          var img = cloneDomItem($(elem),"<img>");
          img.attr('src', dataUrl);
          return img;
      });

      element.find('canvas').each(function(i,elm) {
        var backgroundDiv = cloneDomItem($(elm),"<div>");
        // Add a backing (background) dom element for BG canvas property
        $(elm).replaceWith(replacementImgs[i]);
        backgroundDiv.insertBefore($(elm));
      });
   
      element.css({
        'top':0,
        'left':0,
        'margin':0,
        'width':width,
        'height':height
      });

      var html_content = {
        content: $('<div>').append(element).html(),
        css: css,
        width: width,
        height: height,
        base_url: getBaseUrl()
      };

      $element.trigger('shutterbug-asyouwere');

      callback(html_content);
    });
  };

  var getDomSnapshot = function() {
    // Start timer.
    var self = this;
    var time = 0;
    var counter = $("<span>");
    counter.html(time);
    $(self.imgDst).html("creating snapshot: ").append(counter);
    var timer = setInterval(function(t) {
      time = time + 1;
      counter.html(time);
    }, 1000);
    // Ask for HTML fragment and render it on server.
    this.getHtmlFragment(function(html) {
      $.ajax({
        url: "CONVERT_PATH",
        type: "POST",
        data: html
      }).success(function(msg) {
        if(self.imgDst) {
          $(self.imgDst).html(msg);
        }
        if (self.callback) {
          self.callback(msg);
        }
        clearInterval(timer);
      }).fail(function(e) {
        $(self.imgDst).html("snapshot failed");
        clearInterval(timer);
      });
    });
  };

  var requestHtmlFrag = function() {
    var destination = $(this.element)[0].contentWindow;
    var message  = {
      type: 'htmlFragRequest',
      id: this.id
    };
    destination.postMessage(JSON.stringify(message), "*");
  };

  window.Shutterbug = function(selector, imgDst, callback, id, jQuery) {
    if (typeof(jQuery) != "undefined" && jQuery != null) {
      $ = jQuery;
    }
    // If we still don't have a valid jQuery, try setting it from the global jQuery default.
    // This can happen if shutterbug.js is included before jquery.js
    if ((typeof($) == "undefined" || $ == null) && typeof(window.$) != "undefined" && window.$ != null) {
      $ = window.$;
    }

    var shutterbugInstance = {
      element: selector,
      imgDst: imgDst,
      callback: callback,
      id: id,
      getDomSnapshot: getDomSnapshot,
      getHtmlFragment: getHtmlFragment,
      requestHtmlFrag: requestHtmlFrag,
      iframeReqTimeout: MAX_TIMEOUT
    };

    var handleMessage = function(message, signature, func) {
      var data = message.data;
      if (typeof data === 'string') {
        try {
          data = JSON.parse(data);
          if (data.type === signature) {
            func(data);
          }
        } catch(e) {
          // Not a json message. Ignore it. We only speak json.
        }
      }
    };

    var htmlFragRequestListen = function(message) {
      var send_response = function(data) {
        // Update timeout. When we receive a request from parent, we have to finish nested iframes 
        // rendering in that time. Otherwise parent rendering will timeout. 
        // Backward compatibility: Shutterbug v0.1.x don't send iframeReqTimeout.
        shutterbugInstance.iframeReqTimeout = data.iframeReqTimeout != null ? data.iframeReqTimeout : MAX_TIMEOUT;
        shutterbugInstance.getHtmlFragment(function(html) {
          var response = {
            type:        'htmlFragResponse',
            value:       html,
            iframeReqId: data.iframeReqId,
            id:          data.id // return to sender only...
          };
          message.source.postMessage(JSON.stringify(response), "*");
        });
      };
      handleMessage(message, 'htmlFragRequest', send_response);
    };

    var htmlFragResponseListen = function(message) {
      var send_response = function(data) {
        if (data.id === shutterbugInstance.id) {
          // Backward compatibility: Shutterbug v0.1.x don't send iframeReqId.
          var ifeameReqId = data.iframeReqId != null ? data.iframeReqId : 0;
          shutterbugInstance._iframeContentRequests[ifeameReqId].resolve(data.value);
        }
      };
      handleMessage(message, 'htmlFragResponse', send_response);
    };

    $(document).ready(function () {
      window.addEventListener('message', htmlFragRequestListen, false);
      window.addEventListener('message', htmlFragResponseListen, false);
    });
    return shutterbugInstance;
  };
})();
