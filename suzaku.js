(function() {
  var EventEmitter, Suzaku, TemplateManager, Widget, ajaxManager,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  if (!$) {
    console.warn("cannot find JQuery!  -- Suzaku");
  }

  Suzaku = (function() {

    function Suzaku() {
      console.log("init Suzaku");
      this.Widget = Widget;
      this.TemplateManager = TemplateManager;
      this.EventEmitter = EventEmitter;
      this.Utils = null;
      this.KeybordManager = null;
      this.WsServer = null;
      this.AjaxManager = AjaxManager;
      this.AnimationManager = null;
    }

    return Suzaku;

  })();

  EventEmitter = (function() {

    function EventEmitter() {
      this._events = {};
    }

    EventEmitter.prototype.on = function(event, callback) {
      if (!this._events[event]) {
        this._events[event] = [];
      }
      return this._events[event].push(callback);
    };

    EventEmitter.prototype.off = function(event) {
      var func, _i, _len, _ref;
      _ref = this._events[event];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        func = _ref[_i];
        func = null;
      }
      return delete this._events[event];
    };

    EventEmitter.prototype.emit = function(event, data) {
      var func, _i, _len, _ref, _results;
      if (!this._events[event]) {
        return;
      }
      _ref = this._events[event];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        func = _ref[_i];
        _results.push(func(data));
      }
      return _results;
    };

    return EventEmitter;

  })();

  Widget = (function(_super) {

    __extends(Widget, _super);

    function Widget(creator) {
      var did, dom, tempDiv, template, _i, _len, _ref;
      if (!creator) {
        console.error("need a creator! -- Suzaku.Widget");
        return;
      }
      this.J = null;
      this.dom = null;
      this.template = null;
      this.creator = creator;
      this.UI = [];
      if (creator instanceof String) {
        if (creator.indexOf("<") > -1 && creator.indexOf(">") > -1) {
          template = creator;
          tempDiv = document.createElement("div");
          tempDiv.innerHtml = template;
          this.dom = template.children[0];
          if ($) {
            this.J = $(this.dom);
          }
        } else {
          if ($) {
            this.J = $(creator);
          }
          this.dom = document.queryCreator(creator);
          if (this.dom.length === 0) {
            console.error("Wrong selector! cannot find element by this -- Suzaku.Widget");
            return;
          }
        }
      }
      if ($ && creator instanceof $) {
        this.J = creator;
        this.dom = this.J[0];
      }
      if (creator instanceof window.HTMLElement) {
        this.dom = creator;
        if ($) {
          this.J = $(dom);
        }
      }
      _ref = this.dom.children;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dom = _ref[_i];
        did = dom.getAttribute("data-id");
        if (did) {
          this.UI[did] = {
            dom: dom,
            J: $ ? $(dom) : null
          };
        }
      }
    }

    Widget.prototype.remove = function() {};

    Widget.prototype.beforBy = function(newElem) {};

    Widget.prototype.afterBy = function(newElem) {};

    Widget.prototype.replaceBy = function(newElem) {};

    return Widget;

  })(EventEmitter);

  TemplateManager = (function(_super) {

    __extends(TemplateManager, _super);

    function TemplateManager() {
      this.templates = {};
      this.tplNames = [];
    }

    TemplateManager.prototype.load = function() {
      var ajaxManager, item, loaclDir, name, url, _i, _j, _len, _len1,
        _this = this;
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        item = arguments[_i];
        this.targets.push(item);
      }
      loaclDir = "./templates/";
      ajaxManager = new AjaxManager;
      for (_j = 0, _len1 = tplNames.length; _j < _len1; _j++) {
        name = tplNames[_j];
        url = localDir + name;
        ajaxManager.addTask({
          type: "get",
          url: url,
          success: function(res) {},
          fail: function(err) {}
        });
      }
      return ajaxManager.start(function() {
        return _this.emit.onload;
      });
    };

    return TemplateManager;

  })(EventEmitter);

  ajaxManager = (function(_super) {

    __extends(ajaxManager, _super);

    function ajaxManager() {
      this.tasks = [];
      this.ajaxQueue = [];
      this.tidCounter = 1;
    }

    ajaxManager.prototype.addTask = function(option) {
      return this.tasks.push(option);
    };

    ajaxManager.prototype.start = function(callback) {
      var _this = this;
      this.ajaxQueue[this.tidCounter] = this.tasks;
      this.tidCounter += 1;
      this.tasks = [];
      return this.on("finish", function() {
        if (typeof callback === "function") {
          return callback;
        }
      });
    };

    return ajaxManager;

  })(EventEmitter);

  window.Suzaku = new Suzaku;

  window.Suzaku.Key = {
    0: 48,
    1: 49,
    2: 50,
    3: 51,
    4: 52,
    5: 53,
    6: 54,
    7: 55,
    8: 56,
    9: 57,
    a: 65,
    b: 66,
    c: 67,
    d: 68,
    e: 69,
    f: 70,
    g: 71,
    h: 72,
    i: 73,
    j: 74,
    k: 75,
    l: 76,
    m: 77,
    n: 78,
    o: 79,
    p: 80,
    q: 81,
    r: 82,
    s: 83,
    t: 84,
    u: 85,
    v: 86,
    w: 87,
    x: 88,
    y: 89,
    z: 90,
    space: 32,
    shift: 16,
    ctrl: 17,
    alt: 18,
    left: 37,
    right: 39,
    down: 40,
    enter: 13,
    backspace: 8,
    escape: 27,
    del: 46,
    esc: 27,
    pageup: 33,
    pagedown: 34,
    tab: 9
  };

  window.Suzaku.Mouse = {
    left: 0,
    middle: 1,
    right: 2
  };

}).call(this);
