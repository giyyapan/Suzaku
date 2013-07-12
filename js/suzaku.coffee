if not $
  console.warn "cannot find JQuery!  -- Suzaku"
  
class Suzaku
  constructor:()->
    console.log "init Suzaku" 
    @Widget = Widget
    @TemplateManager = TemplateManager
    @EventEmitter = EventEmitter
    @AjaxManager = AjaxManager
    @ApiManager = ApiManager
    
    @KeybordManager = null    
    @AnimationManager = null
    @Utils = null
    @Key = null
    @Mouse = null
    @WsServer = null
    

class EventEmitter
  constructor:()->
    @_events = {}
  on:(event,callback)->
    console.log this
    @_events[event] = [] if not @_events[event]
    @_events[event].push callback
  off:(event)->
    for func in @_events[event]
      func = null
    delete @_events[event]
  emit:(event)->
    return if !@_events[event]
    for func in @_events[event]
      func.apply func,Array.prototype.slice.call arguments,1
      
class Widget extends EventEmitter
  constructor:(creator)->
    super()
    if not creator
      console.error "need a creator! -- Suzaku.Widget"
      return
    @J = null
    @dom = null
    @template = null
    @creator = creator
    @UI = {}
    if typeof creator is 'string'
      if creator.indexOf("<")> -1 and creator.indexOf(">")>-1
        template = creator
        tempDiv = document.createElement "div"
        tempDiv.innerHtml = template
        @dom = template.children[0]
        @J = $ @dom if $
      else
        @J = $ creator if $
        @dom = document.querySelector creator
        if not @dom
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
    console.log this
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
    super();
    @templates = {}
    @tplNames = []
  use:()->
    for item in arguments
      @tplNames.push item
  start:()->
    ajaxManager = new AjaxManager
    localDir = "./templates/"
    for name in @tplNames
      url = if name.indexOf(".html")>-1 then localDir+name else localDir+name+".html"
      req = ajaxManager.addGetRequest url,null,(data,textStatus,req)=>
        @templates[req.Suzaku_tplName] = data
      req.Suzaku_tplName = name
    ajaxManager.start =>
      console.log "template loaded"
      @emit "load",@templates

class AjaxManager extends EventEmitter
  constructor:()->
    return console.error "ajax Manager needs Jquery!" if not $
    super()
    @reqs = []
    @ajaxMissions = {}
    @tidCounter = 0
  addRequest:(option)->
    option.type = option.type or 'get'
    return console.error "ajax need url!" if not option.url
    console.log "Add request:",option.type,"to",option.url,"--Suzaku.AjaxManager"
    option.externPort = {}
    @reqs.push option
    return option.externPort
  addGetRequest:(url,data,success,dataType)->
    return @addRequest
      type:"get"
      url:url
      data:data
      dataType:dataType
      success:success
  addPostRequest:(url,data,success,dataType)->
    return @addRequest
      type:"post"
      url:url
      data:data
      dataType:dataType
      success:success
  start:(callback)->
    id = @tidCounter += 1
    newAjaxTask = 
      id:id
      reqs:@reqs
      finishedNum:0
      callback:callback
    @ajaxMissions[id] = newAjaxTask
    console.log "start request tasks",newAjaxTask
    @reqs = []
    ajaxManager = this
    for taskOpt,index in @ajaxMissions[id].reqs
      JAjaxReqOpt = Utils.clone taskOpt
      delete JAjaxReqOpt.retry
      delete JAjaxReqOpt.externPort
      JAjaxReqOpt.success = (data,textStatus,req)=>
        @_ajaxSuccess.apply this,arguments
      JAjaxReqOpt.error = (req,textStatus,error)=>
        @_ajaxError.apply this,arguments
        
      ajaxReq = $.ajax JAjaxReqOpt
      ajaxReq.Suzaku_JAjaxReqOpt = JAjaxReqOpt #Suzaku_JAjaxReqOpt is option for Jquery ajax request
      ajaxReq.Suzaku_taskOpt = taskOpt #Suzaku_taskOpt is option added by Suzaku_ajaxManager
      ajaxReq.Suzaku_ajaxMission = newAjaxTask #Suzaku_ajaxMission is 
      ajaxReq[name] = value for name,value of taskOpt.externPort
      console.log ajaxReq
      
    @on "finish",(taskId)=>
      callback = @ajaxMissions[taskId].callback
      delete @ajaxMissions[taskId]
      callback() if typeof callback is "function"
      
  _ajaxSuccess:(data,textStatus,req)->
    #console.log "ajax surceess",data
    ajaxMission =  req.Suzaku_ajaxMission
    ajaxMission.finishedNum += 1
    req.Suzaku_taskOpt.success data,textStatus,req if req.Suzaku_taskOpt.success
    if ajaxMission.finishedNum is ajaxMission.reqs.length
      console.log "finish",this
      @emit "finish",ajaxMission.id
        
  _ajaxError:(req,textStatus,error)->
    console.log "ajax error",error
    taskOpt = req.Suzaku_taskOpt
    retry = taskOpt.retry
    retried = req.Suzaku_retried or 0
    if retried < retry
      ajaxReq = $.ajax req.Suzaku_JAjaxReqOpt
      ajaxReq.Suzaku_JAjaxReqOpt = req.Suzaku_JAjaxReqOpt
      ajaxReq.Suzaku_taskOpt = req.Suzaku_taskOpt
      ajaxReq.Suzaku_ajaxMission = req.Suzaku_ajaxMission
      ajaxReq[name] = value for name,value of req.Suzaku_taskOpt.externPort
      ajaxReq.Suzaku_retried = retried + 1
    else
      ajaxMission = req.Suzaku_ajaxMission
      ajaxMission.finishedNum += 1
      console.error "request failed!",req,textStatus,error
      req.Suzaku_taskOpt.fail req,textStatus,error if req.Suzaku_taskOpt.fail
      if ajaxMission.finishedNum is ajaxMission.reqs.length
        @emit "finish",ajaxMission.id

class Api extends EventEmitter
  constructor:(name,params,url,method)->
    super()
    if not params or not (params instanceof Array)
      return console.error "Illegel arguments #{name} #{params}! --Suzaku.ApiGenerator"
    @name = name
    @url = url
    @method = method
    @params = []
    console.log @name
    @_initParams(params)
  _initParams:(params)->
    for param in params
      arr = param.split ":"
      name = arr[0]
      type = arr[1]
      @params.push
        name:name
        type:type.split '/'
        force:if type.indexOf('?')>-1 then false else true
  _checkParams:->
    return true
  send:->
    return if not @_checkParams()
    data = {}
    data[@params[index]] = arg for arg,index in arguments
    opt =
      type:@method
      url:@url
      data:data
      success:(data,textStatus,req)=>
        @onsuccess data if typeof @onsuccess is "function"
        @onsuccess = null
        evtData =
          successed:true
          data:data
          textStatus:textStatus
          JAjaxReq:req
        @emit "success",evtData
        @emit "finish",evtData
      error:(req,textStatus,error)=>
        console.error "Api ajax error:#{error} --Suzaku.API"
        @onfail error,textStatus if typeof @onfail is "function"
        @onfail = null
        evtData =
          successed:false
          JAjaxReq:req
          textStatus:textStatus
          error:error
        @emit "error",evtData
        @emit "finish",evtData
    req = $.ajax opt
  respond:(callback)->
    @success callback
  success:(callback)->
    @onsuccess = callback
  fail:(callback)->
    @onfail = callback
    
class ApiManager extends EventEmitter
  constructor:()->
    super()
    @API = {}                   #This is a Interface for api calling
    @_apis = {}                 #Api data structure saved here
    @method = "get"
    @path = ""
  setPath:(path)->
    if typeof path isnt "string"
      return console.error "Illegal Path: #{path} --Suzaku.ApiManager"
    arr = path.split ''
    if arr[arr.length-1] is "/"
      arr[arr.length-1] = ""
    path = arr.join ''
    console.log path
    @path = path
  setMethod:(method)->
    if method isnt "get" and method isnt "post"
      return console.error "Illegal method #{method} --Suzaku.ApiManager"
    @method = method
  generate:(name,params)->
    newApi= new Api name,params,"#{@path}/#{name}",@method
    @_apis[name] = newApi
    @API[name] = ()=>
      newApi.send.apply newApi,arguments
      return newApi
      
    

window.Suzaku = new Suzaku
window.Suzaku.Utils = Utils = 
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
    return if target
    
  compare:(a,b)->
    if a is b then return true
    if typeof a is "number" and typeof b is "number"
      if Math.abs(a-b) < 0.0001 then return true
    if typeof a is "object" and typeof b is "object"
      for name,value of a
        if not Utils.compare b[name],value then return false
      for name,value of b
        if not Utils.compare a[name],value then return false
      return true
    return false
    
  removeItem:(source,target)->
    if source instanceof Array and typeof target is 'number'
      return source.splice target,1
      
    if typeof source is 'object'
      if typeof target is 'string' or typeof target is 'number'
        return delete source[target]
        
      if typeof target is 'object'
        for name,item of source
          if item is target then return Utils.removeItem source,name
          found = true
          for keyname,keyvalue of target
            if Utils.compare item[keyname],keyvalue
              continue
            else
              found = false
              break
          if found then return Utils.removeItem source,name
          
  findItem:(source,key,value)->
    if typeof key is 'string' and typeof value isnt 'undefined'
      target = {key:value}
    else target = key
    for name,item of source
      if item is target then return {target:target,index:null}
      found = true
      for keyname,keyvalue of target
        if Utils.compare item[keyname],keyvalue
          continue
        else
          found = false
          break
      if found then return {target:target,index:name}
        
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

