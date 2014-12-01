/*global $ */
(function() {
  var $ = window.jQuery;

  var MAX_TIMEOUT = 1500;
  // IE9 doesn't implement this.
  var BIN_DATA_SUPPORTED = typeof(window.Blob) === "function" && typeof(window.Uint8Array) === "function";

  var getBaseUrl = function() {
    var base = window.location.href;
    return base;
  };

  var _useIframeSizeHack = false;
  var useIframeSizeHack = function(b) {
    _useIframeSizeHack = b;
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

  var generateFullHtmlFromFragment = function (fragment) {
    return "<!DOCTYPE html>" +
      "<html>" +
        "<head>" +
          "<base href='" + fragment.base_url + "'>" +
          "<meta content='text/html;charset=utf-8' http-equiv='Content-Type'>" +
          "<title>content from " + fragment.base_url + "</title>" +
          fragment.css +
        "</head>" +
        "<body>" +
          fragment.content +
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

      // remove all script elements from the clone we don't want the html fragement
      // changing itself
      element.find("script").remove();

      if (arguments.length > 0) {
        var nestedIFrames = arguments;
        // This supports two cases:
        // - element itself is an iframe - .addBack('iframe')
        // - element descentands are iframes - .find('iframe')
        element.find("iframe").addBack("iframe").each(function(i, iframeElem) {
          // When iframe doesn't support Shutterbug, request will timeout and null will be received.
          // In such case just ignore this iframe, we won't be able to render it.
          if (nestedIFrames[i] == null) return;
          $(iframeElem).attr("src", "data:text/html," + generateFullHtmlFromFragment(nestedIFrames[i]));
        });
      }

      // .addBack('canvas') handles case when the element itself is a canvas.
      var replacementImgs = $element.find('canvas').addBack('canvas').map(function(i, elem) {
          var dataUrl = elem.toDataURL('image/png');
          var img = cloneDomItem($(elem), "<img>");
          img.attr('src', dataUrl);
          return img;
      });

      if (element.is('canvas')) {
        element = replacementImgs[0];
      } else {
        element.find('canvas').each(function(i, elem) {
          $(elem).replaceWith(replacementImgs[i]);
        });
      }

      element.css({
        'top':0,
        'left':0,
        'padding':0,
        'margin':0,
        'width':width,
        'height':height
      });

      // Due to a weird layout bug in PhantomJS, inner iframes sometimes don't render
      // unless we set the width small. This doesn't affect the actual output at all.
      if (_useIframeSizeHack) {
        width = 10;
      }

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
    this.timer = setInterval(function(t) {
      time = time + 1;
      counter.html(time);
    }, 1000);
    var tagName = $(this.element).prop("tagName");
    switch(tagName) {
      case "CANVAS":
        this.canvasSnapshot();
        break;
      default:
        this.basicSnapshot();
        break;
    }
  };

  var canvasSnapshot = function() {
    if (!BIN_DATA_SUPPORTED) {
      return this.basicSnapshot();
    }
    var self = this;
    $.ajax({
      type: 'GET',
      url: 'URL_PREFIX/img_upload_url'
    }).done(function(data) {
      self.directUpload(data);
    }).fail(function() {
      // Use basic snapshot as a fallback.
      // Direct upload is not supported on server side (e.g. due to used storage).
      self.basicSnapshot();
    });
  };

  function directUpload(options) {
    var $canvas = $(this.element);
    var dataURL = $canvas[0].toDataURL('image/png');
    var blob = dataURLtoBlob(dataURL);
    var self = this;
    $.ajax({
      type: 'PUT',
      url: options.put_url,
      data: blob,
      processData: false,
      contentType: false
    }).done(function(data) {
      self.success('<img src=' + options.get_url + '>');
    }).fail(function(jqXHR, textStatus, errorThrown) {
      self.fail(jqXHR, textStatus, errorThrown)
    });
  }

  function dataURLtoBlob(dataURL) {
    // Convert base64/URLEncoded data component to raw binary data held in a string.
    if (dataURL.split(',')[0].indexOf('base64') === -1) {
      throw new Error("expected base64 data");
    }
    var byteString = atob(dataURL.split(',')[1]);
    // Separate out the mime component.
    var mimeString = dataURL.split(',')[0].split(':')[1].split(';')[0];
    // Write the bytes of the string to a typed array.
    var ia = new Uint8Array(byteString.length);
    for (var i = 0; i < byteString.length; i++) {
      ia[i] = byteString.charCodeAt(i);
    }
    return new Blob([ia], {type: mimeString});
  }

  var basicSnapshot = function() {
    var self = this;
    // Ask for HTML fragment and render it on server.
    this.getHtmlFragment(function(html) {
      $.ajax({
        url: "URL_PREFIX/make_snapshot",
        type: "POST",
        data: html
      }).success(function(msg) {
        self.success(msg)
      }).fail(function(jqXHR, textStatus, errorThrown) {
        self.fail(jqXHR, textStatus, errorThrown);
      });
    });
  };

  var success = function(imageTag) {
    if (this.imgDst) {
      $(this.imgDst).html(imageTag);
    }
    if (this.callback) {
      this.callback(msg);
    }
    clearInterval(this.timer);
  }

  var fail = function(jqXHR, textStatus, errorThrown) {
    if (this.imgDst) {
      $(this.imgDst).html("snapshot failed");
    }
    if (this.failCallback) {
      this.failCallback(jqXHR, textStatus, errorThrown);
    }
    clearInterval(this.timer);
  }

  var requestHtmlFrag = function() {
    var destination = $(this.element)[0].contentWindow;
    var message  = {
      type: 'htmlFragRequest',
      id: this.id
    };
    destination.postMessage(JSON.stringify(message), "*");
  };

  var htmlSnap = function() {
    this.getHtmlFragment(function callback(fragment) {
      // FIXME btoa is not intended to encode text it is for for 8bit per char strings
      // so if you send it a UTF8 string with a special char in it, it will fail
      // this SO has a note about handling this:
      // http://stackoverflow.com/questions/246801/how-can-you-encode-a-string-to-base64-in-javascript
      // also note that btoa is only available in IE10+
      var encodedContent = btoa(generateFullHtmlFromFragment(fragment));
      window.open("data:text/html;base64," + encodedContent);
    });
  };

  var imageSnap = function() {
    var oldImgDst = this.imgDst,
        oldCallback = this.callback,
        self = this;
    this.imgDst = null;
    this.callback = function (msg){
      // extract the url out of the returned html fragment
      var imgUrl = msg.match(/src='([^']*)'/)[1]
      window.open(imgUrl);
      self.imgDst = oldImgDst;
      self.callback = oldCallback;
    }
    this.getDomSnapshot();
  };

  var setFailureCallback = function(failCallback) {
    this.failCallback = failCallback;
  };

  // TODO: Construct using opts instead of positional arguments.
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
      basicSnapshot: basicSnapshot,
      canvasSnapshot: canvasSnapshot,
      directUpload: directUpload,
      success: success,
      fail: fail,
      getHtmlFragment: getHtmlFragment,
      requestHtmlFrag: requestHtmlFrag,
      htmlSnap: htmlSnap,
      imageSnap: imageSnap,
      useIframeSizeHack: useIframeSizeHack,
      iframeReqTimeout: MAX_TIMEOUT,
      setFailureCallback: setFailureCallback
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
