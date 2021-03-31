<%@page pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>

<head>
  <title>Detail</title>
  <script src='/js/main.js'></script>
  <script src='/js/jquery-3.4.1.js'></script>
  <script src='/js/popper.js'></script>
  <script src='/js/bootstrap.js'></script>
  <script src='/js/vue.js'></script>
  <link rel='stylesheet' href='/css/bootstrap.css'>
  <link rel='stylesheet' href='/css/main.css'>
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>

<body class='bg-light'>
<header>
  <nav class="navbar navbar-expand-md navbar-light fixed-top bg-light py-0 shadow">
    <div class='nav-cover text-center text-dark'>
      <b>相册预览</b>
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
  <transition name='slide-fade-vertical' @after-enter='didShowAlbum'>
    <div v-if='albumReady'>
      <div class='container text-center'>
        <h4>相册名称: {{album.name}}</h4>
        <span>上传时间: {{timestampToDate(album.date).toLocaleDateString()}}</span>
        <span>共 {{album.count}} 张照片</span><br>
        <span class='badge badge-secondary m-1' v-for='x in album.tags'>{{x}}</span>
        <hr>
      </div>
      <div class='container'>
        <div class='row'>
          <div class='col-md-3'>
            <div class='bg-white border rounded p-2 mb-1'>
              <button class='btn btn-primary btn-block btn-lg' :disabled='!hasItem' @click='downloadAlbum'>下载</button>
              <a :href='albumModifyHref' class='btn btn-secondary btn-block btn-lg'
                 :class='{disabled: !canModifyAndDelete}'>修改</a>
              <button type='button' class='btn btn-danger btn-block btn-lg' @click='deleteAlbum'
                      :disabled='!canModifyAndDelete'>删除</button>
            </div>
          </div>
          <div class='col-md-9' v-if='hasItem'>
            <div id="carousel" class="carousel slide rounded border-dark border" data-ride="carousel" data-interval="">
              <div class="carousel-inner">
                <div class="carousel-item" :class='{ active: !x.id }' v-for='x in albumItems'>
                  <img :src="x.url" class="d-block w-100" alt="carousel">
                </div>
              </div>
              <a class="carousel-control-prev" href="#carousel" role="button" data-slide="prev">
                <span class="carousel-control-prev-icon"></span>
              </a>
              <a class="carousel-control-next" href="#carousel" role="button" data-slide="next">
                <span class="carousel-control-next-icon"></span>
              </a>
            </div>
            <div style='overflow-x: scroll; white-space: nowrap;'>
              <img :src='x.url' alt='thumbnail' style='cursor: pointer'
                   :class='{ "album-thumbnail-border": x.active }' class='border-dark m-1' v-for='x in albumItems'
                   @click='carouselTo(x.id)' height='50'>
            </div>
          </div>
          <div class='col-md-9' v-else>
            <div class='alert alert-warning text-center'>
              没有可以显示的图片。:(<br>
              点击左侧（上方）"修改"按钮以上传照片。
            </div>
          </div>
        </div>
      </div>
    </div>
  </transition>
  <div class="modal fade" id="selectModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">选择图片</h5>
          <button type="button" class="close" data-dismiss="modal">
            <span>&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <div class="form-group form-check">
            <input type="checkbox" class="form-check-input" v-model='selectAll' id='selectAll' @input='selectAllChanged'>
            <label class="form-check-label" for="selectAll">全选</label>
          </div>
          <div class='d-flex flex-wrap border rounded' id='selectDownload'>
            <img :src='x.url' :width='imageWidth' v-for='x in albumItems' alt='thumbnail' style='cursor: pointer'
                 :class='{ "album-thumbnail-border": x.selected }' class='border-dark m-1' @click='toggleSelect(x)'>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">取消</button>
          <button type="button" class="btn btn-primary" data-dismiss="modal" @click='downloadSelected' :disabled='!canDownload'>下载</button>
        </div>
      </div>
    </div>
  </div>
  <div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">删除相册请求</h5>
          <button type="button" class="close" data-dismiss="modal">
            <span>&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <span>删除相册请求: {{album.name}}</span><br>
          <textarea v-model='reason' placeholder='删除相册的原因 (少于30个字)' class='form-control my-2' style='resize: none' maxlength='30'></textarea>
          <span>确定要提交请求吗?</span>
        </div>
        <div class="modal-footer">
          <input type="button" class="btn btn-secondary" data-dismiss="modal" value='取消'>
          <input type="button" class="btn btn-primary" value='提交' @click='confirmDelete' :disabled='!canDelete'>
        </div>
      </div>
    </div>
  </div>
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
    $(() => {
        $("#selectModal").modal({
            show: false
        }).on("shown.bs.modal", () => {
            app.imageWidth = $("#selectDownload").width() / 5 - 8;
        })
        $("#deleteModal").modal({
            show: false
        })
    })
    function AlbumItem(url) {
        this.id = AlbumItem.id++;
        this.url = url;
        this.active = this.id === 0;
        this.selected = false;
    }
    AlbumItem.id = 0;
    AlbumItem.current = 0;
    var qs = utils.parseQueryString();
    var app = new Vue({
        el: "#app",
        data: {
            albumItems: [],
            albumReady: false,
            albumError: false,
            showSpinner: true,
            album: {},
            canModifyAndDelete: false,
            imageWidth: 84,
            selectAll: false,
            level: 0,
            reason: ""
        },
        methods: {
            carouselTo(index) {
                $("#carousel").carousel(index);
            },
            timestampToDate(ts) {
                return new Date(ts);
            },
            didShowAlbum() {
                $("#carousel").carousel({
                    interval: false
                }).on("slide.bs.carousel", e => {
                    let _this = app;
                    _this.albumItems[e.from].active = false;
                    _this.albumItems[e.to].active = true;
                })
            },
            deleteAlbum() {
                if (this.level === 3){
                    if (!confirm("确定要删除相册吗?")) return;
                    this.showSpinner = true;
                    utils.deleteAlbum(this.album.name, () => {
                        location.assign("/album");
                    });
                }
                else {
                    $("#deleteModal").modal('show');
                }
            },
            downloadAlbum(){
                $("#selectModal").modal('show');
            },
            selectAllChanged(e){
                this.selectAll = e.target.checked;
                this.albumItems.forEach(a => a.selected = app.selectAll);
            },
            toggleSelect(x){
                x.selected = !x.selected;
                this.selectAll = this.albumItems.every(a => a.selected);
            },
            downloadSelected(){
                if (this.selectAll){
                    window.open('/album/album?type=download&name=' + this.album.name);
                }
                else{
                    let indices = this.albumItems.filter(a => a.selected).map(a => a.id);
                    window.open('/album/album?type=download&name=' + this.album.name + '&indices=' + indices.join(','));
                }
            },
            confirmDelete(){
                utils.deleteAlbumRequest(this.album.name, this.reason, data => {
                    if (data.success) {
                        alert('提交请求成功! 您可以在"登录"页面中管理请求。');
                    }
                    else {
                        alert('提交请求失败: 功能已被管理员禁用。');
                    }
                    $("#deleteModal").modal('hide');
                })
            }
        },
        computed: {
            albumModifyHref() {
                return 'modify.jsp?name=' + this.album.name
            },
            hasItem() {
                return this.albumItems.length > 0;
            },
            canDownload() {
                return this.albumItems.some(a => a.selected);
            },
            canDelete(){
                return this.reason.trim().length > 0;
            }
        }
    });
    if (qs.name) {
        utils.getAlbum(qs.name, data => {
            app.showSpinner = false;
            if (data.success) {
                let items = [];
                for (let i = 0; i < data.album.count; i++) {
                    items.push(new AlbumItem("/album/album?type=index&name=" + data.album.name + "&index=" + i));
                }
                app.album = data.album;
                app.albumItems = items;
                app.albumReady = true;
            }
            else {
                app.albumError = true;
            }
        })
        utils.checkLogin(data => {
            if (data.result) {
                app.canModifyAndDelete = data.level >= 2;
                app.level = data.level;
            }
            else app.canModifyAndDelete = false;
        });
    }
    else {
        app.showSpinner = false;
        app.albumError = true;
    }
</script>
</body>

</html>