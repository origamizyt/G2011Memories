<%@page pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>

<head>
  <title>Albums</title>
  <script src='/js/main.js'></script>
  <script src='/js/jquery-3.4.1.js'></script>
  <script src='/js/popper.js'></script>
  <script src='/js/bootstrap.js'></script>
  <script src='/js/vue.js'></script>
  <script src='/js/jquery.datetimepicker.full.min.js'></script>
  <link rel='stylesheet' href='/css/bootstrap.css'>
  <link rel='stylesheet' href='/css/main.css'>
  <link rel='stylesheet' href='/css/jquery.datetimepicker.css'>
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>

<body class='bg-light'>
<header>
  <nav class="navbar navbar-expand-md navbar-light fixed-top bg-light py-0 shadow">
    <div class='nav-cover text-center text-dark'>
      <b>相册中心</b>
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
          <li class="nav-item">
            <a class="nav-link" href="/">
              <img src='/images/home-outline.png' alt='home' height='30'><br>
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="/article">
              <img src='/images/documents-outline.png' alt='article' height='30'>
            </a>
          </li>
          <li class="nav-item active">
            <a class="nav-link" href="#">
              <img src='/images/albums.png' alt='album' height='30'>
            </a>
          </li>
          <li class="nav-item">
            <span class='nav-separator'></span>
          </li>
          <li class="nav-item">
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
  <form @submit='formSubmit' class='small-box mx-auto'>
    <input type='text' v-model='searchString' placeholder="搜索相册" class='form-control input-list-head'>
    <div class='input-group'>
      <div class='input-group-prepend'>
        <span class='input-group-text input-list-body'>选择日期:</span>
      </div>
      <input type='text' class='form-control input-list-body' id='picker'>
    </div>
    <input type='text' v-model='tagString' placeholder="搜索标签" class='form-control input-list-foot'>
    <div class='d-flex flex-wrap justify-content-center mt-2'>
      <input type='button' class='btn btn-secondary m-1 flex-fill' @click='clearFilter' value='清空'>
      <input type='submit' class='btn btn-outline-primary m-1 flex-fill' value='确认'>
    </div>
  </form>
  <div class='container'>
    <div class='m-3'>
      <a class='btn btn-light btn-block' href='create.jsp'
         style='border: 2px dashed; height: 80px; font-size: 2.4rem'>+</a>
    </div>
    <hr>
  </div>
  <transition name='fly' appear>
    <div v-if='showSpinner' class='text-center mx-auto'>
      <span class='spinner-grow text-info'></span>
      <p>请稍候...</p>
    </div>
  </transition>
  <transition name='slide-fade-vertical' appear>
    <div class='container' v-if='albumReady'>
      <div class='alert alert-danger text-center' v-if='emptyAlbums'>
        没有符合要求的相册。<button type='button' class='btn btn-link' @click='clearFilter'>清空搜索</button>
      </div>
      <div v-for='g in groupedAlbums' v-else class="mt-3">
        <h4>时间: {{g[0]}}</h4>
        <div class='d-flex flex-wrap'>
          <div class='p-2 album-box' v-for='x in g[1]'>
            <div class='card shadow-hover' @click='showAlbum(x)'>
              <img :src="getAlbumCoverHref(x)" class="card-img-top" alt="cover" v-if='x.hasCover'>
              <div class="card-body">
                <h5 class="card-title">{{x.name}}</h5>
                <span class="card-text text-muted">{{x.count}} 张照片</span><br>
                <span class='badge badge-secondary m-1' v-for='t in x.tags'>{{t}}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </transition>
  <div class="modal fade" id="albumModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">相册: {{displayedAlbum.name}}</h5>
          <button type="button" class="close" data-dismiss="modal">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <img :src='coverImageHref' alt='cover' style='width: 100%;' class='rounded mb-2' v-if='displayedAlbum.hasCover'>
          <span>创建时间: {{timestampToDate(displayedAlbum.date).toLocaleDateString()}}</span><br>
          <span>共 {{displayedAlbum.count}} 张照片</span><br>
          <span>
              标签:
              <span class='badge badge-secondary m-1' v-for='t in displayedAlbum.tags'>{{t}}</span>
            </span><br>
          <a class='btn btn-primary mt-3 btn-block' :href='displayedAlbumHref'>查看相册</a>
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
    $.datetimepicker.setLocale('zh');
    $(() => {
        $("#picker").datetimepicker({
            timepicker: false,
            format: 'Y/m/d'
        });
        $("#albumModal").modal({
            show: false
        });
    });
    function Filter(title, date, tags) {
        this.title = title ? title : null;
        this.date = date ? new Date(date).toLocaleDateString() : null;
        this.tags = tags ? tags.split(',').map(s => s.trim()) : null;
    }
    Filter.prototype.filter = function (album) {
        f = this;
        if (f.title) {
            if (!album.name.includes(f.title)) return false;
        }
        if (f.date) {
            if (new Date(album.date).toLocaleDateString() !== f.date) return false;
        }
        if (f.tags) {
            if (!f.tags.every(tag => album.tags.indexOf(tag) >= 0)) return false;
        }
        return true;
    }
    function Album(obj){
        this.name = obj.name;
        this.tags = obj.tags;
        this.date = obj.date;
        this.count = obj.count;
        this.hasCover = obj.count > 0;
    }
    var app = new Vue({
        el: '#app',
        data: {
            searchString: "",
            tagString: "",
            dateSelection: "",
            showSpinner: true,
            albumReady: false,
            filteredAlbums: [],
            albums: [],
            displayedAlbum: {},
            filter: null
        },
        methods: {
            formSubmit(e) {
                e.preventDefault();
                this.dateSelection = $("#picker").val();
                this.filter = new Filter(this.searchString, this.dateSelection, this.tagString);
                this.filteredAlbums = this.albums.filter(a => this.filter.filter(a));
            },
            timestampToDate(ts) {
                return new Date(ts);
            },
            showAlbum(a) {
                this.displayedAlbum = a;
                $("#albumModal").modal('show');
            },
            clearFilter() {
                this.searchString = "";
                this.tagString = "";
                $("#picker").val("");
                this.filteredAlbums = this.albums;
            },
            getAlbumCoverHref(a) {
                return "album?type=index&name=" + a.name + "&index=0"
            },
            dateToTimestamp(dt){
                return new Date(dt).getTime();
            }
        },
        computed: {
            groupedAlbums() {
                let grouped = [];
                this.filteredAlbums.forEach(a => {
                    let date = this.timestampToDate(a.date).toLocaleDateString();
                    if (!grouped.some(g => g[0] === date)) grouped.push([date, []]);
                    grouped.find(g => g[0] === date)[1].push(a);
                });
                grouped = grouped.sort((a1, a2) => this.dateToTimestamp(a2[0]) - this.dateToTimestamp(a1[0]));
                return grouped;
            },
            displayedAlbumHref() {
                return this.displayedAlbum.name ? "detail.jsp?name=" + this.displayedAlbum.name : "";
            },
            emptyAlbums() {
                return this.filteredAlbums.length <= 0;
            },
            coverImageHref() {
                return this.displayedAlbum.name ? "album?type=index&name=" + this.displayedAlbum.name + "&index=0" : "";
            }
        },
        watch: {
            title(newTitle) {
                this.title = newTitle.trim();
            }
        }
    });
    utils.listAlbums(data => {
        app.showSpinner = false;
        app.albums = app.filteredAlbums = data.data.map(a => new Album(a));
        app.albumReady = true;
    });
</script>
</body>

</html>