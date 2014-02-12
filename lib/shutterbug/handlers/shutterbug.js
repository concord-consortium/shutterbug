/*global $ */
(function(){
  var $ = window.$;

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
    var $element = $(this.element);
    
    this._html_content = {
      nestedIFrames: []
    };
    this._expectedReplies = 0;
    this._getHtmlFragCallback = callback;

    var context = this;
    this._iframeRequest = [];
    this._expectedReplies = 0;
    // This supports two cases:
    // - element itself is an iframe - .addBack('iframe')
    // - element descentands are iframes - .find('iframe')
    $element.find('iframe').addBack("iframe").each(function(i, iframeElem) {
      var message  = {
        type: 'htmlFragRequest',
        id: context.id,
        reqId: context._expectedReplies
      };
      iframeElem.contentWindow.postMessage(JSON.stringify(message), "*");
      context._expectedReplies++;
    });

    this._getHtmlFragmentFinished();
  };

  var _getHtmlFragmentFinished = function() {
    if (this._expectedReplies > 0) {
      return;
    }

    var $element = $(this.element);

    $element.trigger('shutterbug-saycheese');

    var css     = $('<div>').append($('link[rel="stylesheet"]').clone()).append($('style').clone()).html();
    var width   = $element.width();
    var height  = $element.height();
    var element = $element.clone();

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

    if (this._html_content.nestedIFrames.length > 0) {
      var nestedIFrames = this._html_content.nestedIFrames;
      // This supports two cases:
      // - element itself is an iframe - .addBack('iframe')
      // - element descentands are iframes - .find('iframe')
      element.find("iframe").addBack("iframe").each(function(i, iframeElem) {
        $(iframeElem).attr("src", generateIFrameSrcData(nestedIFrames[i]));
      });
    }
 
    element.css({
      'top':0,
      'left':0,
      'margin':0,
      'width':width,
      'height':height
    });

    this._html_content.content = $('<div>').append(element).html();
    this._html_content.css = css;
    this._html_content.width = width;
    this._html_content.height = height;
    this._html_content.base_url = getBaseUrl();

    $element.trigger('shutterbug-asyouwere');

    this._getHtmlFragCallback(this._html_content);
  };

  var getPng = function(html) {
    if(typeof html === 'undefined') {
      this.getHtmlFragment($.proxy(this.getPng, this));
      return;
    }
    var self = this;
    var time = 0;
    var counter = $("<span>");
    counter.html(time);

    $(self.imgDst).html("creating snapshot: ").append(counter);
    var timer = setInterval(function(t) {
      time = time + 1;
      counter.html(time);
    }, 1000);

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
  };

  var requestHtmlFrag = function() {
    var destination = $(this.element)[0].contentWindow;
    var message  = {
      type: 'htmlFragRequest',
      id: this.id
    };
    destination.postMessage(JSON.stringify(message), "*");
  };

  window.Shutterbug = function(selector,imgDst,callback,id,jQuery) {
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
      getDomSnapshot: getPng,
      getPng: getPng,
      getHtmlFragment: getHtmlFragment,
      _getHtmlFragmentFinished: _getHtmlFragmentFinished,
      requestHtmlFrag: requestHtmlFrag
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
        shutterbugInstance.getHtmlFragment(function(html) {
          var response = {
            type: 'htmlFragResponse',
            value: html,
            reqId: data.reqId,
            id:    data.id // return to sender only...
          };
          message.source.postMessage(JSON.stringify(response), "*");
        });
      };
      handleMessage(message, 'htmlFragRequest', send_response);
    };

    var htmlFragResponseListen = function(message) {
      var send_response = function(data) {
        var html = null;
        if (data.id === shutterbugInstance.id) {
          html = data.value;
          shutterbugInstance._html_content.nestedIFrames[data.reqId] = html;
          shutterbugInstance._expectedReplies--;
          shutterbugInstance._getHtmlFragmentFinished();
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