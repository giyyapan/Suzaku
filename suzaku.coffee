if not $
  console.warn "cannot find JQuery!  -- Suzaku"
  
class Suzaku
  constructor:()->
    console.log "init Suzaku" 
    @Widget = Widget
    @TemplateManager = TemplateManager
    @EventEmitter = EventEmitter
    @Utils = Utils
    @Key = null
    @Mouse = null
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
      ajaxManager.addRequest
        type:"get"
        url:url
        retry:5
        success:(data,textStatus,jqXHR)->
        fail:(err)->
      
    ajaxManager.start =>
      @emit.onload

class AjaxManager extends EventEmitter
  constructor:()->
    if not $
      console.error "ajax Manager needs Jquery!"
      return
    @reqs = []
    @ajaxTasks = {}
    @tidCounter = 0
  addRequest:(option)->
    option.type = option.type or 'get'
    if not option.url
      console.error "ajax need url!"
      return
    console.log "Add request:",option.type,"to",option.url,"--Suzaku.AjaxManager"
    @reqs.push option
  start:(callback)->

    id = @tidCounter += 1
    newAjaxTask = 
      id:id
      reqs:@reqs
      finishedNum:0
    @ajaxTasks[id] = newAjaxTask
    console.log "start request tasks",newAjaxTask
    @reqs = []
    ajaxManager = this
    for request,index in @ajaxTasks[id]
      option = request.option
      ajaxOpt = Utils.copy option
      delete ajaxOpt.retry
      ajaxOpt.success = (data,textStatus,req)=>
        @_ajaxSuccessFunc data,textStatus,req
      ajaxOpt.error = (req,textStatus,error)=>
        @_ajaxErrorFunc req,textStatus,error
        
      ajaxReq = $.ajax ajaxOpt
      ajaxReq.Suzaku_ajaxOpt = ajaxOpt
      ajaxReq.Suzaku_taskOpt = option
      ajaxReq.Suzaku_ajaxTask = newAjaxTask
      
    @on "finish",(taskId)=>
      delete @ajaxTasks[taskId]
      callback if typeof callback is "function"
      
  _ajaxSuccessFunc:(data,textStatus,req)->
    ajaxTask =  req.Suzaku_ajaxTask
    ajaxTask.finishedNum += 1
    ajaxTask.Suzaku_taskOpt.success data,textStatus,req if ajaxTask.Suzaku_taskOpt.success
    if ajaxTask.finishedNum is ajaxTask.reqs.length
      @emit "finish",ajaxTask.id
        
  _ajaxErrorFunc:(req,textStatus,error)->
    taskOpt = req.Suzaku_taskOpt
    retry = taskOpt.retry
    retried = req.Suzaku_retried or 0
    if retried < retry
      ajaxReq = $.ajax req.Suzaku_ajaxOpt
      ajaxReq.Suzaku_ajaxOpt = option
      ajaxReq.Suzaku_taskOpt = req.Suzaku_taskOpt
      ajaxReq.Suzaku_ajaxTask = newAjaxTask
      ajaxReq.Suzaku_retried = retried + 1
    else
      ajaxTask = req.Suzaku_ajaxTask
      ajaxTask.finishedNum += 1
      console.error "request failed!",req,textStatus,error
      ajaxTask.Suzaku_taskOpt.fail req,textStatus,error if ajaxTask.Suzaku_taskOpt.fail
      

window.Suzaku = new Suzaku
window.Suzaku.Utils =
  clone:(target,deepClone=false)->
    if target instanceof Array
      newArr = []
      for item,index in target
        newArr[index] = if deepClone then Utils.clone item,true else item
      return newArr
      
    if typeof target is 'object'
      newObj = {}
      for name,item of target
        newObj[name] = if deepClone then Utils.clone item,true else item
      return newObj

    return target
  compare:()->
    
  arrRemove:()->
  removeObjFromArr:()->
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


