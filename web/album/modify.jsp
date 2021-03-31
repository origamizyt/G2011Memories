<%@ page import="memo.misc.Utils, memo.user.User" %>
<%@ page import="java.util.Objects" %>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%
  User user = Utils.getSessionUser(session);
  String name = request.getParameter("name");
  if (Objects.requireNonNull(Utils.getOption("EnableAlbumLock")).getValue()
          && Utils.albumExists(name)
          && !Utils.isAlbumLocked(name)){
      Utils.lockAlbum(name, user);
  }
%>
<!DOCTYPE html>
<html>

<head>
  <title>Modify</title>
  <script src='/js/main.js'></script>
  <script src='/js/jquery-3.4.1.js'></script>
  <script src='/js/popper.js'></script>
  <script src='/js/bootstrap.js'></script>
  <script src='/js/vue.js'></script>
  <script src='/js/jquery.datetimepicker.full.min.js'></script>
  <script src="/js/cryptojs-core.js"></script>
  <script src="/js/cryptojs-enc-base64.js"></script>
  <script src='/js/cryptojs-typedarrays.js'></script>
  <link rel='stylesheet' href='/css/bootstrap.css'>
  <link rel='stylesheet' href='/css/main.css'>
  <link rel='stylesheet' href='/css/jquery.datetimepicker.css'>
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>

<body class='bg-light'>
<header>
  <nav class="navbar navbar-expand-md navbar-light fixed-top bg-light py-0 shadow">
    <div class='nav-cover text-center text-dark'>
      <b>修改相册</b>
    </div>
    <div class='container'>
        <span class="navbar-brand">
          <img src='/images/icon.png' alt='icon' height='60'>
        </span>
      <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarCollapse">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarCollapse">
        <ul class="navbar-nav nav-pills ml-auto">
          <li class="nav-item text-center">
            <a class="nav-link" href="/">
              <img src='/images/home-outline.png' alt='home' height='30'><br>
            </a>
          </li>
          <li class="nav-item text-center">
            <a class="nav-link" href="/article">
              <img src='/images/documents-outline.png' alt='article' height='30'>
            </a>
          </li>
          <li class="nav-item text-center active">
            <a class="nav-link" href="/album">
              <img src='/images/albums.png' alt='album' height='30'>
            </a>
          </li>
          <li class="nav-item text-center">
            <span class='nav-separator'></span>
          </li>
          <li class="nav-item text-center">
            <a class="nav-link" href="/login">
              <img src='/images/log-in-outline.png' alt='login' height='30'>
            </a>
          </li>
        </ul>
      </div>
    </div>
  </nav>
</header>
<main id='app' class='main-low'>
  <transition name='fly' appear>
    <div v-if='showSpinner' class='mx-auto text-center'>
      <span class='spinner-grow text-info'></span><br>
      <span>请稍候...</span>
    </div>
  </transition>
  <transition name='slide-fade-vertical'>
    <div v-if='albumError' class='alert alert-danger container text-center'>
      获取相册错误。
    </div>
  </transition>
  <transition name='slide-fade-vertical'>
    <div v-if='albumLocked' class='alert alert-warning container text-center'>
      相册正在被其他用户编辑，请稍后再试。
    </div>
  </transition>
  <transition name='slide-fade-vertical' @after-enter='updateImageWidth'>
    <div v-if='albumReady'>
      <div class="container text-center">
        <h4>相册名称: {{album.name}}</h4>
        <span>上传时间: {{timestampToDate(album.date).toLocaleDateString()}}</span>
        <span>共 {{album.count}} 张照片</span><br>
        <span class='badge badge-secondary m-1' v-for='x in album.tags'>{{x}}</span>
        <a class='btn btn-outline-primary btn-block mt-3 form-submit-button' :href='albumDetailHref'>完成编辑</a>
        <hr>
      </div>
      <div class='container'>
        <div class='row'>
          <div class='col-md-8'>
            <div class='d-flex flex-wrap border rounded' id='album' v-if="hasImage">
              <div v-for='x in albumItems'>
                <div class='text-danger text-center' v-if='x.deleted' :style='{width: imageWidth + "px"}'>
                  <span>已删除</span>
                </div>
                <img :src='x.url' alt='thumbnail' class='m-1' :width='imageWidth' v-else @click='showImageDetails(x)' style='cursor: pointer'>
              </div>
            </div>
            <div v-else class='m-1 alert alert-warning text-center'>
              没有可以显示的照片。:(<br>
              请在右侧上传照片。
            </div>
          </div>
          <div class='col-md-4 border rounded p-2'>
            <ol class='list-group'>
              <li class='list-group-item p-0' v-if='queueEmpty'>
                <button type='button' class='btn btn-block btn-light' style='border: 2px dashed; height: 50px;' @click='selectImage'>+ 选择</button>
              </li>
              <li v-for='x in waitingFiles' class='list-group-item' v-else>
                <span>{{x.file.name}}</span>
                <span style='cursor: pointer' @click='deleteFile(x)'>&times;</span>
                <div class='progress' v-if='x.progress'>
                  <div class='progress-bar progress-bar-striped progress-bar-animated' :style="{width: x.percent + '%'}"></div>
                </div><br>
                <span>{{statusToMessage(x.status)}}</span>
              </li>
            </ol>
            <button class='btn btn-block btn-primary mt-2' :disabled='!canUpload' @click='uploadFiles'>上传</button>
            <button class='btn btn-block btn-secondary mt-2' :disabled='!filesRefresh && !imagesRefresh' @click='refreshImages'>刷新</button>
          </div>
        </div>
      </div>
    </div>
  </transition>
  <div class="modal fade" id="albumModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">图片 {{albumItems.indexOf(displayedItem)+1}}</h5>
          <button type="button" class="close" data-dismiss="modal">
            <span>&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <img :src='displayedItem.url' alt='cover' style='width: 100%;' class='rounded mb-2'>
          <button type='button' class='btn btn-danger mt-3 btn-block' @click='deleteImage' data-dismiss="modal">删除照片</button>
        </div>
      </div>
    </div>
  </div>
  <div class="modal fade" id="alertModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">无法进行此操作</h5>
          <button type="button" class="close" data-dismiss="modal">
            <span>&times;</span>
          </button>
        </div>
        <div class="modal-body">
          无法进行此操作，因为<span v-if='filesRefresh'>正在上传文件</span><span v-if='imagesRefresh'>删除图片</span>使得图片索引改变。<br>
          请刷新后再试。
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">取消</button>
          <button type="button" class="btn btn-primary" @click='refreshImages' data-dismiss="modal">刷新</button>
        </div>
      </div>
    </div>
  </div>
  <input type='file' multiple id='file' style='display: none' @change='fileSelected'>
</main>
<footer class='container border-top my-5 pt-5'>
  <div class='row text-center'>
    <div class="col-6 col-md border-right">
      <h5>功能</h5>
      <ul class="list-unstyled text-small">
        <li><a class="text-muted" href="/article">文章</a></li>
        <li><a class="text-muted" href="/album">相册</a></li>
      </ul>
    </div>
    <div class="col-6 col-md border-left">
      <h5>关于</h5>
      <ul class="list-unstyled text-small">
        <li><a class="text-muted" href="/about.jsp">此网站</a></li>
      </ul>
    </div>
  </div>
  <div class='col-4 col-md border-right'>
    <div style="width:300px;margin:0 auto; padding:20px 0;">
      <small>
	<a target="_blank" href="http://www.beian.gov.cn/portal/registerSystemInfo?recordcode=11010802034551" style="display:inline-block;text-decoration:none;height:20px;line-height:20px;"><img src="/images/beian_icon.png" style="float:left;"/><p style="float:left;height:20px;line-height:20px;margin: 0px 0px 0px 5px; color:#939393;">京公网安备 11010802034551号</p></a>
        <br>
        <span>京ICP备2021005322号-1</span>
      </small>
    </div>
  </div>
</footer>
<script>
    var indicator = null;
    $(() => {
        $("#albumModal").modal({
            show: false
        });
        $("#alertModal").modal({
            show: false,
            backdrop: 'static',
            keyboard: false
        })
        window.onbeforeunload = app.pageUnload;
    })
    var statusToMessage = (status, item) => {
        switch (status){
            case -1: return '上传错误: ' + item.error;
            case 0: return '就绪';
            case 1: return '读取中';
            case 2: return '读取完毕';
            case 3: return '上传中';
            case 4: return '上传完毕';
            default: return null;
        }
    };
    var codeToMessage = code => {
        switch (code) {
            case utils.ERROR_SUCCESS: return "";
            case utils.ERROR_INCORRECT_USER: return "用户名或密码不正确。"
            case utils.ERROR_NOT_LOGGED_YET: return "会话还未登录。"
            case utils.ERROR_ALREADY_LOGGED: return "此会话已经登陆。"
            case utils.ERROR_MISSING_ALBUM: return "未找到相册。"
            case utils.ERROR_INVALID_INDEX: return "索引错误。"
            case utils.ERROR_ALBUM_ALREADY_EXISTS: return "同名相册已经存在。"
            case utils.ERROR_FILENAME_USED: return "文件名已被使用。"
            case utils.ERROR_ACCESS_DENIED: return "访问被拒绝。"
            default: return null;
        }
    }
    function AlbumItem(url) {
        this.url = url;
        this.deleted = false;
    }
    function WaitingFile(file){
        this.file = file;
        this.status = 0;
        this.reader = new FileReader();
        this.progress = false;
        this.percent = 0;
        this.content = null;
        this.error = "";
        let _this = this;
        this.reader.onprogress = p => {
            _this.percent = p.loaded / _this.file.size * 100;
        }
        this.reader.onerror = () => {
            _this.status = -1;
        }
        this.reader.onload = () => {
            _this.status = 2;
            _this.progress = false;
            _this.content = _this.reader.result;
        }
    }
    WaitingFile.prototype.read = function read(){
        this.status = 1;
        this.progress = true;
        this.reader.readAsArrayBuffer(this.file);
    }
    var qs = utils.parseQueryString();
    var app = new Vue({
        el: "#app",
        data: {
            showSpinner: true,
            album: {},
            albumItems: [],
            albumReady: false,
            albumError: false,
            albumLocked: false,
            imageWidth: 70,
            displayedItem: {},
            albumName: qs.name,
            waitingFiles: [],
            filesRefresh: false,
            imagesRefresh: false
        },
        methods: {
            timestampToDate(ts) {
                return new Date(ts);
            },
            updateImageWidth(){
                this.imageWidth = $("#album").width() / 5 - 8;
            },
            showImageDetails(x){
                if (this.filesRefresh) {
                    $("#alertModal").modal('show');
                    return;
                }
                this.displayedItem = x;
                $("#albumModal").modal('show');
            },
            selectImage(){
                if (this.imagesRefresh) {
                    $("#alertModal").modal('show');
                    return;
                }
                $("#file").click();
            },
            fileSelected(){
                for (let f of $("#file")[0].files){
                    if (f.type.startsWith("image/")){
                        this.filesRefresh = true;
                        this.waitingFiles.push(new WaitingFile(f))
                    }
                }
                this.waitingFiles.forEach(f => f.status === 0 && f.read());
            },
            deleteImage(){
                if (!this.displayedItem) return;
                this.imagesRefresh = true;
                utils.deleteImage(this.albumName, this.albumItems.indexOf(this.displayedItem), data => {
                    if (data.success) {
                        app.albumItems.splice(app.albumItems.indexOf(app.displayedItem), 1);
                    }
                    else {
                        alert("无法删除照片: 功能已被管理员禁用。");
                    }
                });
            },
            refreshImages(){
                location.reload();
            },
            refreshImages2(){
                this.waitingFiles = [];
                this.filesRefresh = this.imagesRefresh = false;
                this.albumReady = false;
                this.showSpinner = true;
                utils.getAlbum(this.albumName, data => {
                    let _this = app;
                    _this.showSpinner = false;
                    if (data.success) {
                        let items = [];
                        for (let i = 0; i < data.album.count; i++) {
                            items.push(new AlbumItem("/album/album?type=index&name=" + data.album.name + "&index=" + i));
                        }
                        _this.album = data.album;
                        _this.albumItems = items;
                        _this.albumReady = true;
                    }
                    else {
                        _this.albumError = true;
                    }
                })
            },
            statusToMessage(status) {
                switch (status){
                    case -1: return '上传错误';
                    case 0: return '就绪';
                    case 1: return '读取中';
                    case 2: return '读取完毕';
                    case 3: return '上传中';
                    case 4: return '上传完毕';
                    default: return null;
                }
            },
            deleteFile(x){
                this.waitingFiles.splice(this.waitingFiles.indexOf(x), 1);
            },
            uploadFiles(x){
                let sockets = [];
                for (let f of this.waitingFiles){
                    while (sockets.length > 10) {}
                    f.percent = 0;
                    f.progress = true;
                    let count = Math.ceil(f.content.byteLength / 4096);
                    let socket = new WebSocket("ws://" + location.host + "/album/put");
                    sockets.push(socket);
                    socket.onopen = () => {
                        socket.send(JSON.stringify({
                            name: app.albumName,
                            file: f.file.name
                        }));
                    }
                    socket.onmessage = e => {
                        let data = JSON.parse(e.data);
                        if (!data.success){
                            f.status = -1;
                            f.progress = false;
                            f.percent = 0;
                            return;
                        }
                        f.percent += 100 / (count+1);
                        if (!f.content.byteLength) {
                            socket.close(1000);
                            sockets.splice(sockets.indexOf(socket), 1);
                            f.status = 3;
                            return;
                        }
                        let binaryData = f.content.slice(0, 4096);
                        f.content = f.content.slice(4096);
                        socket.send(utils.buffer2base64(binaryData));
                    }
                    socket.onclose = () => {
                        let index = sockets.indexOf(socket);
                        if (index !== -1) sockets.splice(index, 1);
                    }
                }
            },
            pageUnload(){
                return this.unsavedChanges ? '有未保存的更改。确定退出吗？' : undefined;
            }
        },
        computed: {
            queueEmpty(){
                return this.waitingFiles.length === 0;
            },
            canUpload(){
                return !this.queueEmpty && this.waitingFiles.every(f => f.status === -1 || f.status === 2);
            },
            hasImage(){
                return this.albumItems.length > 0;
            },
            unsavedChanges(){
                return !this.queueEmpty && !this.waitingFiles.every(f => f.status === -1 || f.status === 4)
            },
            albumDetailHref(){
                return "detail.jsp?name=" + this.albumName
            }
        }
    })
    if (qs.name){
        utils.checkLocked(qs.name, data => {
            app.showSpinner = false;
            if (!data.success){
                app.albumError = true;
            }
            else if (!data.result){
                app.refreshImages2();
                indicator = new WebSocket("ws://" + location.host + "/album/lock");
                indicator.onopen = () => {
                    window.onunload = () => {
                        indicator.close(4000);
                    }
                }
            }
            else {
                app.albumLocked = true;
            }
        });
    }
    else {
        app.showSpinner = false;
        app.albumError = true;
    }
</script>
</body>

</html>