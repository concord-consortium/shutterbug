/*global $ */
(function(){
  var $ = window.$;

  var getBaseUrl = function() {
    var base = window.location.href;
    return base;
  };

  var cloneDomItem =function(elem, elemTag) {
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

  var getHtmlFragment = function() {
    var $element = $(this.element);

    $element.trigger('shutterbug-saycheese');

    var css     = $('<div>').append($('link[rel="stylesheet"]').clone()).append($('style').clone()).html();
    var width   = $element.width();
    var height  = $element.height();
    var element = null;
    var html_content;

    var replacementImgs = $element.find('canvas').map( function(count,elem) {
        var dataUrl = elem.toDataURL('image/png');
        var img = cloneDomItem($(elem),"<img>");
        img.attr('src', dataUrl);
        return img;
    });

    element = $element.clone();
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

    html_content = {
      content: $('<div>').append(element).html(),
      css: css,
      width: width,
      height: height,
      base_url: getBaseUrl()
    };

    $element.trigger('shutterbug-asyouwere');

    return html_content;
  };

  var getPng = function(html) {
    if(typeof html === 'undefined') {
      if($(this.element)[0] && $(this.element)[0].contentWindow) {
        this.requestHtmlFrag();
        return;
      }
      else {
        html = this.getHtmlFragment();
      }
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
    destination.postMessage(JSON.stringify(message),"*");
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
        var response = {
          type: 'htmlFragResponse',
          value: shutterbugInstance.getHtmlFragment(),
          id:    data.id // return to sender only...
        };
        message.source.postMessage(JSON.stringify(response),"*");
      };
      handleMessage(message, 'htmlFragRequest', send_response);
    };

    var htmlFragResponseListen = function(message) {
      var send_response = function(data) {
        var html = null;
        if(data.id === shutterbugInstance.id) {
          html = data.value;
          shutterbugInstance.getPng(data.value);
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