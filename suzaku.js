(function() {
  var AjaxManager, EventEmitter, Suzaku, TemplateManager, Widget,
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
      this.Utils = Utils;
      this.Key = null;
      this.Mouse = null;
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
      var tempDiv, template;
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
      this.initUI();
    }

    Widget.prototype.initUI = function() {
      var did, dom, _i, _len, _ref, _results;
      _ref = this.dom.children;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dom = _ref[_i];
        did = dom.getAttribute("data-id");
        if (did) {
          _results.push(this.UI[did] = {
            dom: dom,
            J: $ ? $(dom) : null
          });
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Widget.prototype.remove = function() {
      return this.dom.parentElement.removeChild(this.dom);
    };

    Widget.prototype.before = function(target) {
      if (target instanceof Widget) {
        target = target.dom;
      }
      if ($ && target instanceof $) {
        target = target[0];
      }
      if (target instanceof HTMLElement) {
        return target.parentElement.insertBefore(this.dom, target);
      } else {
        return console.error("invaild target!  --Suzaku.Widget");
      }
    };

    Widget.prototype.after = function(target) {
      var dom, index, next, parent, _i, _len, _ref;
      if (target instanceof Widget) {
        target = target.dom;
      }
      if ($ && target instanceof $) {
        target = target[0];
      }
      if (target instanceof HTMLElement) {
        parent = target.parentElement;
        next = null;
        _ref = parent.children;
        for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
          dom = _ref[index];
          if (dom === target && index < parent.children.length - 1) {
            next = parent.children[index + 1];
          }
        }
        if (next) {
          return parent.insertBefore(this.dom, next);
        } else {
          return parent.appendChild(this.dom);
        }
      } else {
        return console.error("invaild target!  --Suzaku.Widget");
      }
    };

    Widget.prototype.replace = function(target) {
      this.before(target);
      if (target instanceof Widget) {
        target.remove();
      }
      if (target instanceof HTMLElement) {
        return target.parentElement.removeChild(target);
      }
    };

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
        ajaxManager.addRequest({
          type: "get",
          url: url,
          retry: 5,
          success: function(data, textStatus, jqXHR) {},
          fail: function(err) {}
        });
      }
      return ajaxManager.start(function() {
        return _this.emit.onload;
      });
    };

    return TemplateManager;

  })(EventEmitter);

  AjaxManager = (function(_super) {

    __extends(AjaxManager, _super);

    function AjaxManager() {
      if (!$) {
        console.error("ajax Manager needs Jquery!");
        return;
      }
      this.reqs = [];
      this.ajaxTasks = {};
      this.tidCounter = 0;
    }

    AjaxManager.prototype.addRequest = function(option) {
      option.type = option.type || 'get';
      if (!option.url) {
        console.error("ajax need url!");
        return;
      }
      console.log("Add request:", option.type, "to", option.url, "--Suzaku.AjaxManager");
      return this.reqs.push(option);
    };

    AjaxManager.prototype.start = function(callback) {
      var ajaxManager, ajaxOpt, ajaxReq, id, index, newAjaxTask, option, request, _i, _len, _ref,
        _this = this;
      id = this.tidCounter += 1;
      newAjaxTask = {
        id: id,
        reqs: this.reqs,
        finishedNum: 0
      };
      this.ajaxTasks[id] = newAjaxTask;
      console.log("start request tasks", newAjaxTask);
      this.reqs = [];
      ajaxManager = this;
      _ref = this.ajaxTasks[id];
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        request = _ref[index];
        option = request.option;
        ajaxOpt = Utils.copy(option);
        delete ajaxOpt.retry;
        ajaxOpt.success = function(data, textStatus, req) {
          return _this._ajaxSuccessFunc(data, textStatus, req);
        };
        ajaxOpt.error = function(req, textStatus, error) {
          return _this._ajaxErrorFunc(req, textStatus, error);
        };
        ajaxReq = $.ajax(ajaxOpt);
        ajaxReq.Suzaku_ajaxOpt = ajaxOpt;
        ajaxReq.Suzaku_taskOpt = option;
        ajaxReq.Suzaku_ajaxTask = newAjaxTask;
      }
      return this.on("finish", function(taskId) {
        delete _this.ajaxTasks[taskId];
        if (typeof callback === "function") {
          return callback;
        }
      });
    };

    AjaxManager.prototype._ajaxSuccessFunc = function(data, textStatus, req) {
      var ajaxTask;
      ajaxTask = req.Suzaku_ajaxTask;
      ajaxTask.finishedNum += 1;
      if (ajaxTask.Suzaku_taskOpt.success) {
        ajaxTask.Suzaku_taskOpt.success(data, textStatus, req);
      }
      if (ajaxTask.finishedNum === ajaxTask.reqs.length) {
        return this.emit("finish", ajaxTask.id);
      }
    };

    AjaxManager.prototype._ajaxErrorFunc = function(req, textStatus, error) {
      var ajaxReq, ajaxTask, retried, retry, taskOpt;
      taskOpt = req.Suzaku_taskOpt;
      retry = taskOpt.retry;
      retried = req.Suzaku_retried || 0;
      if (retried < retry) {
        ajaxReq = $.ajax(req.Suzaku_ajaxOpt);
        ajaxReq.Suzaku_ajaxOpt = option;
        ajaxReq.Suzaku_taskOpt = req.Suzaku_taskOpt;
        ajaxReq.Suzaku_ajaxTask = newAjaxTask;
        return ajaxReq.Suzaku_retried = retried + 1;
      } else {
        ajaxTask = req.Suzaku_ajaxTask;
        ajaxTask.finishedNum += 1;
        console.error("request failed!", req, textStatus, error);
        if (ajaxTask.Suzaku_taskOpt.fail) {
          return ajaxTask.Suzaku_taskOpt.fail(req, textStatus, error);
        }
      }
    };

    return AjaxManager;

  })(EventEmitter);

  window.Suzaku = new Suzaku;

  window.Suzaku.Utils = {
    clone: function(target, deepClone) {
      var index, item, name, newArr, newObj, _i, _len;
      if (deepClone == null) {
        deepClone = false;
      }
      if (target instanceof Array) {
        newArr = [];
        for (index = _i = 0, _len = target.length; _i < _len; index = ++_i) {
          item = target[index];
          newArr[index] = deepClone ? Utils.clone(item, true) : item;
        }
        return newArr;
      }
      if (typeof target === 'object') {
        newObj = {};
        for (name in target) {
          item = target[name];
          newObj[name] = deepClone ? Utils.clone(item, true) : item;
        }
        return newObj;
      }
      return target;
    },
    compare: function() {},
    arrRemove: function() {},
    removeObjFromArr: function() {}
  };

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
