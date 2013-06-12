if not $
  console.warn "cannot find JQuery!  -- Suzaku"
  
class Suzaku
  constructor:()->
    console.log "init Suzaku" 
    @Widget = Widget
    @TemplateManager = TemplateManager
    @EventEmitter = EventEmitter
    @Utils = null
    @KeybordManager = null
    @WsServer = null
    @AjaxManager = AjaxManager
    @AnimationManager = null

class EventEmitter
  constructor:()->
    @_events = {}
  on:(event,callback)->
    @_events[event] = [] if not @_events[event]
    @_events[event].push callback
  off:(event)->
    for func in @_events[event]
      func = null
    delete @_events[event]
  emit:(event,data)->
    return if !@_events[event]
    for func in @_events[event]
      func(data)
      
class Widget extends EventEmitter
  constructor:(creator)->
    if not creator
      console.error "need a creator! -- Suzaku.Widget"
      return
    @J = null
    @dom = null
    @template = null
    @creator = creator
    @UI = []
    if creator instanceof String
      if creator.indexOf("<")> -1 and creator.indexOf(">")>-1
        template = creator
        tempDiv = document.createElement "div"
        tempDiv.innerHtml = template
        @dom = template.children[0]
        @J = $ @dom if $
      else
        @J = $ creator if $
        @dom = document.queryCreator creator
        if @dom.length is 0
          console.error "Wrong selector! cannot find element by this -- Suzaku.Widget"
          return
    if $ and creator instanceof $
      @J = creator
      @dom = @J[0]
    if creator instanceof window.HTMLElement
      @dom = creator
      @J = $ dom if $
    @initUI()
  initUI:()->
    for dom in @dom.children
      did = dom.getAttribute "data-id"
      if did then @UI[did] =
        dom:dom
        J:if $ then $ dom else null
  remove:()->
    @dom.parentElement.removeChild @dom
  before:(target)->
    if target instanceof Widget
      target = target.dom
    if $ and target instanceof $
      target = target[0]
    if target instanceof HTMLElement
      target.parentElement.insertBefore @dom,target
    else
      console.error "invaild target!  --Suzaku.Widget"
  after:(target)->
    if target instanceof Widget
      target = target.dom
    if $ and target instanceof $
      target = target[0]
    if target instanceof HTMLElement
      parent = target.parentElement
      next = null
      for dom,index in parent.children 
        if dom is target and index < parent.children.length - 1
          next = parent.children[index+1]
      if next then parent.insertBefore @dom,next
      else parent.appendChild @dom
    else
      console.error "invaild target!  --Suzaku.Widget"
  replace:(target)->
    @before target
    if target instanceof Widget then target.remove()
    if target instanceof HTMLElement then target.parentElement.removeChild target
          
class TemplateManager extends EventEmitter
  constructor:()->
    @templates = {}
    @tplNames = []
  load:()->
    for item in arguments
      @targets.push item
    loaclDir = "./templates/"
    ajaxManager = new AjaxManager
    for name in tplNames
      url = localDir+name
      ajaxManager.addTask
        type:"get"
        url:url
        success:(res)->
        fail:(err)->
      
    ajaxManager.start =>
      @emit.onload

class ajaxManager extends EventEmitter
  constructor:()->
    @tasks = []
    @ajaxQueue = []
    @tidCounter = 1
  addTask:(option)->
    @tasks.push option
  start:(callback)->
    @ajaxQueue[@tidCounter] = @tasks
    @tidCounter += 1
    @tasks = []
    @on "finish",=>
      callback if typeof callback is "function"
      
window.Suzaku = new Suzaku      
window.Suzaku.Key =
  0:48
  1:49
  2:50
  3:51
  4:52
  5:53
  6:54
  7:55
  8:56
  9:57
  a:65
  b:66
  c:67
  d:68
  e:69
  f:70
  g:71
  h:72
  i:73
  j:74
  k:75
  l:76
  m:77
  n:78
  o:79
  p:80
  q:81
  r:82
  s:83
  t:84
  u:85
  v:86
  w:87
  x:88
  y:89
  z:90
  space:32
  shift:16
  ctrl:17
  alt:18
  left:37
  right:39
  down:40
  enter:13
  backspace:8
  escape:27
  del:46
  esc:27
  pageup:33
  pagedown:34
  tab:9
window.Suzaku.Mouse =
  left:0
  middle:1
  right:2


