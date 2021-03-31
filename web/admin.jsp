<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>

<head>
  <title>Admin Tools</title>
  <script src='/js/main.js'></script>
  <script src='/js/jquery-3.4.1.js'></script>
  <script src='/js/popper.js'></script>
  <script src='/js/bootstrap.js'></script>
  <script src='/js/vue.js'></script>
  <link rel='stylesheet' href='/css/bootstrap.css'>
  <link rel='stylesheet' href='/css/main.css'>
  <style>
    #pageNav {
      position: sticky;
      top: 90px;
    }
    #pageNav li.nav-item a.nav-link.active {
      border: 2px solid rgba(0, 0, 0, .5);
      border-left: 10px solid rgba(0, 0, 0, .5);
      border-right: 10px solid rgba(0, 0, 0, .5);
      border-radius: .25rem;
    }
    #resourceView {
      width: 100%;
      max-height: 400px;
      overflow: hidden;
      overflow-y: scroll;
    }
  </style>
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>

<body class='bg-light'>
<header>
  <nav class="navbar navbar-expand-md navbar-light fixed-top bg-light py-0 shadow">
    <div class='nav-cover text-center text-dark'>
      <b>管理员工具</b>
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
              <img src='/images/albums-outline.png' alt='album' height='30'>
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
  <div class='container text-center'>
    <span>提示: 管理员操作无法撤回，且可能会对网站造成不良后果，请谨慎操作。</span><hr>
    <div class='row'>
      <div class='col-md-3'>
        <ul class="nav text-center flex-column border rounded my-1" id='pageNav'>
          <li class="nav-item">
            <a class="nav-link active text-dark" data-toggle="tab" href="#user">
              <img src='/images/people-outline.png' alt='user' height='25'>
              管理用户
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link text-dark" data-toggle="tab" href="#reqs">
              <img src='/images/hand-left-outline.png' alt='request' height='25'>
              管理请求
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link text-dark" data-toggle="tab" href="#carousels">
              <img src='/images/images-outline.png' alt='carousel' height="25">
              管理轮播
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link text-dark" data-toggle="tab" href="#domains">
              <img src='/images/open-outline.png' alt='domain' height="25">
              管理子域
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link text-dark" data-toggle="tab" href="#options">
              <img src='/images/options-outline.png' alt='option' height="25">
              网站设置
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link text-dark" data-toggle="tab" href="#resources">
              <img src='/images/cube-outline.png' alt='resource' height="25">
              查看资源
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link text-dark" data-toggle="tab" href="#files">
              <img src='/images/folder-outline.png' alt='resource' height="25">
              管理文件
            </a>
          </li>
        </ul>
      </div>
      <div class='col-md-9 text-left'>
        <div class='tab-content my-1'>
          <div class="tab-pane fade show active" id="user">
            <transition name='fly' appear>
              <div v-if='!userReady' class='text-center'>
                <span class='spinner-grow text-info'></span><br>
                <span>请稍候...</span>
              </div>
            </transition>
            <transition name='slide-fade-vertical'>
              <div v-if='userReady'>
                <h5>用户列表:</h5>
                <ul class='list-group'>
                  <li v-for='x in users' class='list-group-item d-flex'>
                    <div class='flex-grow-1'>
                      <span>{{x.username}}</span><br>
                      <span>用户级别: {{x.level}} ({{levelToMessage(x.level)}})</span>
                    </div>
                    <button type='button' class='btn btn-link text-danger' :disabled='!canBlacklist(x)'
                            @click='blacklistUser(x)'>加入黑名单</button>
                    <button type='button' class='btn btn-link text-success' :disabled='!canWhitelist(x)'
                            @click='whitelistUser(x)'>移出黑名单</button>
                  </li>
                </ul><br>
                <div class='d-flex justify-content-between'>
                  <h5 class='m-0'>黑名单:</h5>
                  <button type='button' class='btn btn-outline-danger' :disabled='!hasBlacklist'
                          @click='clearBlacklist'>清空黑名单</button>
                </div>
                <ul class='list-group mt-2'>
                  <li v-if='!hasBlacklist' class='list-group-item'>
                    黑名单内没有用户。
                  </li>
                  <li v-for='x in blacklist' class='list-group-item d-flex'>
                    <span class='flex-grow-1 py-2'>{{x.username}}</span>
                    <button type='button' class='btn btn-link text-success' :disabled='!canWhitelist(x)'
                            @click='whitelistUser(x)'>移出黑名单</button>
                  </li>
                </ul>
              </div>
            </transition>
          </div>
          <div class="tab-pane fade" id="reqs">
            <transition name='fly' appear>
              <div v-if='!requestReady' class='text-center'>
                <span class='spinner-grow text-info'></span><br>
                <span>请稍候...</span>
              </div>
            </transition>
            <transition name='slide-fade-vertical'>
              <div v-if='requestReady'>
                <div v-if='!hasRequest' class='alert alert-warning'>
                  目前没有任何请求。
                </div>
                <div v-else class='d-flex flex-wrap'>
                  <div class='p-2 flex-fill small-box' v-for='x in requests'>
                    <div class='card shadow-hover text-center'>
                      <div class='card-header'>
                        <span style='font-size: 1.5rem'>请求类型: {{categoryToMessage(x.req.type)}}</span><br>
                        <span>请求用户: {{x.req.user}}</span>
                      </div>
                      <div class='card-body'>
                        <span>请求时间: {{timestampToDateString(x.req.date)}}</span>
                        <hr>
                        <div v-if='x.req.type === 1'>
                          <span>相册名称: {{x.req.name}}</span><br>
                          <span>请求原因: {{x.req.reason}}</span>
                        </div>
                        <div v-if='x.req.type === 2'>
                          <span>文章ID: {{x.req.id}}</span><br>
                          <span>请求原因: {{x.req.reason}}</span>
                        </div>
                      </div>
                      <div class='card-footer d-flex flex-wrap justify-content-around'>
                        <button type='button' class='btn btn-link text-primary'
                                @click='fulfillRequest(x)'>同意请求</button>
                        <button type='button' class='btn btn-link text-danger' @click='deleteRequest(x)'>删除请求</button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </transition>
          </div>
          <div class='tab-pane fade' id='carousels'>
            <transition name='fly' appear>
              <div v-if='!carouselReady' class='text-center'>
                <span class='spinner-grow text-info'></span><br>
                <span>请稍候...</span>
              </div>
            </transition>
            <transition name='slide-fade-vertical'>
              <div v-if='carouselReady'>
                <h5>轮播项:</h5>
                <ul class='list-group'>
                  <li class='list-group-item p-0'>
                    <button class='btn btn-block btn-light' style='border: 2px dashed; font-size: 2rem'
                            @click='selectImage'>+</button>
                  </li>
                  <li class='list-group-item d-flex' v-for='x in carousels'>
                    <img :src='getCarouselHref(x)' alt='carousel' class='reactive-image border rounded mr-3'>
                    <div class='d-flex flex-column justify-content-between'>
                      <h5># {{x.title}} #</h5>
                      <span>{{x.desc}}</span>
                    </div>
                    <button type='button' class='btn btn-link text-danger ml-auto'
                            @click='deleteCarousel(x)'>删除</button>
                  </li>
                </ul>
              </div>
            </transition>
          </div>
          <div class='tab-pane fade' id='domains'>
            <transition name='fly' appear>
              <div v-if='!domainReady' class='text-center'>
                <span class='spinner-grow text-info'></span><br>
                <span>请稍候...</span>
              </div>
            </transition>
            <transition name='slide-fade-vertical'>
              <div v-if='domainReady'>
                <div class='d-flex justify-content-between'>
                  <h5 class='mt-2'>子域列表:</h5>
                  <button type='button' class='btn btn-link text-primary dropdown-toggle' data-toggle='dropdown'>添加子域</button>
                  <div class="dropdown-menu p-2">
                    <form @submit='addDomain'>
                      <input class='form-control input-list-head' placeholder="子域名称" v-model='domainName' spellcheck="false">
                      <input class='form-control input-list-foot' placeholder="重定向位置" v-model='domainPath' spellcheck="false">
                      <div class="form-check mt-2">
                        <input class="form-check-input" type="checkbox" id="checkSpace" v-model='domainSpace'>
                        <label class="form-check-label" for="checkSpace">
                          是否为空间
                        </label>
                      </div>
                      <input type='submit' class='btn btn-primary mt-2 btn-block form-submit-button' value='添加'>
                    </form>
                  </div>
                </div>
                <ul class='list-group'>
                  <li v-for='x in domains' class='list-group-item d-flex'>
                    <div class='flex-grow-1'>
                      <span class='bold'>{{getFullDomain(x)}}</span><br>
                      <span>将重定向至: {{x.path}}</span><br>
                      <span>是否为空间: {{x.space?"是":"否"}}</span>
                    </div>
                    <div class='d-flex flex-column justify-content-around'>
                      <button type='button' class='btn btn-link text-danger' @click='deleteDomain(x)'>删除</button>
                    </div>
                  </li>
                </ul>
              </div>
            </transition>
          </div>
          <div class='tab-pane fade' id='options'>
            <transition name='fly' appear>
              <div v-if='!optionReady' class='text-center'>
                <span class='spinner-grow text-info'></span><br>
                <span>请稍候...</span>
              </div>
            </transition>
            <transition name='slide-fade-vertical'>
              <div v-if='optionReady'>
                <h5>设置列表:</h5>
                <ul class='list-group'>
                  <li v-for='x in options' class='list-group-item d-flex'>
                    <div class='flex-grow-1'>
                      <span class='bold'>{{x.name}}</span><br>
                      <span>描述: {{x.desc}}</span><br>
                      <span>是否开启: {{x.value?"是":"否"}}</span>
                    </div>
                    <div class='d-flex justify-content-around border rounded p-1 my-2'>
                      <button class='btn' :class='x.value ? ["btn-primary"] : ["btn-link", "text-primary"]' @click='toggleOption(x, true)'>开启</button>
                      <button class='btn' :class='x.value ? ["btn-link", "text-danger"] : ["btn-danger"]' @click='toggleOption(x, false)'>关闭</button>
                    </div>
                  </li>
                </ul>
              </div>
            </transition>
          </div>
          <div class='tab-pane fade' id='resources'>
            <transition name='fly' appear>
              <div v-if='!resourceReady' class='text-center'>
                <span class='spinner-grow text-info'></span><br>
                <span>请稍候...</span>
              </div>
            </transition>
            <transition name='slide-fade-vertical'>
              <div v-if='resourceReady'>
                <h5>资源列表</h5>
                <span>注: 此处显示的可能不是最新的资源。<span class='btn-link text-primary' style='cursor: pointer' @click='refreshResource'>刷新</span></span>
                <ul class='list-group mt-2'>
                  <li v-for='x in resources' class='list-group-item text-center'>
                    <div class='border-right pr-3 d-flex flex-column'>
                      <span class='bold'>{{x.name}}</span>
                      <span>资源组: {{x.groups.length}}</span>
                    </div>
                    <hr>
                    <div class='btn-group' style='overflow-x: auto; width: 100%'>
                      <button v-for='g in x.groups' @click='displayResource(g)' class='btn btn-secondary'>
                        查看组 {{g.name}}
                      </button>
                    </div>
                  </li>
                </ul>
              </div>
            </transition>
          </div>
          <div class='tab-pane fade' id='files'>
            <transition name='fly' appear>
              <div v-if='!fileReady' class='text-center'>
                <span class='spinner-grow text-info'></span><br>
                <span>请稍候...</span>
              </div>
            </transition>
            <transition name='slide-fade-vertical'>
              <div v-if='fileReady'>
                <h5>单个文件列表</h5>
                <ul class='list-group mt-2' v-if="hasSingleFile">
                  <li v-for='x in files.files' class='list-group-item'>
                    <div class="d-flex">
                      <div class="flex-grow-1">
                        <span>文件名: {{x.name}}</span><br>
                        <span>MD5 哈希摘要: {{x.digest}}</span><br>
                        <span>是否已加密: {{x.encrypted ? "是" : "否"}}</span><br>
                        <span>标签: <span class="badge badge-secondary">{{x.tag}}</span></span>
                      </div>
                      <div class="d-flex flex-column justify-content-center">
                        <button type="button" class="btn btn-link text-danger" @click="deleteFile(x)">
                          删除文件
                        </button>
                      </div>
                    </div>
                  </li>
                </ul>
                <div class="alert alert-warning" v-else>
                  没有任何单个的文件。
                </div>
                <div v-for="s in files.series" class="mt-3">
                  <h5>系列: {{s.name}}</h5>
                  <ul class='list-group mt-2'>
                    <li v-for='x in s.files' class='list-group-item'>
                      <div class="d-flex">
                        <div class="flex-grow-1">
                          <span>文件名: {{x.name}}</span><br>
                          <span>MD5 哈希摘要: {{x.digest}}</span><br>
                          <span>是否已加密: {{x.encrypted ? "是" : "否"}}</span><br>
                          <span>标签: <span class="badge badge-secondary">{{x.tag}}</span></span>
                        </div>
                        <div class="d-flex flex-column justify-content-center">
                          <button type="button" class="btn btn-link text-danger" @click="deleteFile(x, s)">
                            删除文件
                          </button>
                        </div>
                      </div>
                    </li>
                  </ul>
                </div>
              </div>
            </transition>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="modal fade" id="imageModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">添加轮播</h5>
          <button type="button" class="close" data-dismiss="modal">
            <span>&times;</span>
          </button>
        </div>
        <div class="modal-body pt-2">
          <div v-if='!imageReady && !imageError'>
            <span class='spinner-border text-info'></span><br>
            <span>正在读取...</span>
          </div>
          <span v-if='imageError' class='text-danger'>
              读取图片错误。
            </span>
          <div v-if='imageReady'>
            <img :src='imageData' alt='carousel' style='max-width: 100%'>
            <input type='text' placeholder='标题' v-model='title' class='form-control input-list-head mt-3'>
            <input type='text' placeholder='描述' v-model='desc' class='form-control input-list-foot'>
          </div>
        </div>
        <div class="modal-footer">
          <input type="button" class="btn btn-secondary" data-dismiss="modal" value='取消'>
          <input type="button" class="btn btn-primary" value='提交' :disabled='!canUploadCarousel'
                 @click='uploadCarousel' data-dismiss="modal">
        </div>
      </div>
    </div>
  </div>
  <div class="modal fade" id="resourceModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">查看资源</h5>
          <button type="button" class="close" data-dismiss="modal">
            <span>&times;</span>
          </button>
        </div>
        <div class="modal-body pt-2">
          <span>组名: {{displayingResource.name}}</span>
          <div id='resourceView' class='border rounded mt-3' v-if='hasResource'>
            <div class='d-flex flex-column border' v-for='x in displayingResource.res'>
                <span v-for='i in resourceItems(x)' class='pl-2 m-1' style='border-left: 5px solid rgba(0, 0, 0, .5)'>
                  <span>键: {{i[0]}}</span><br>
                  <span>值: {{i[1]}}</span>
                </span>
            </div>
          </div>
          <div class='mt-3 alert alert-warning' v-if='!hasResource'>
            没有可以显示的项目。
          </div>
        </div>
        <div class="modal-footer">
          <input type="button" class="btn btn-secondary" data-dismiss="modal" value='关闭'>
        </div>
      </div>
    </div>
  </div>
  <input type='file' style='display: none' @change='imageSelected' id='file'>
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
        $("#imageModal").modal({
            show: false
        })
        $("#resourceModal").modal({
            show: false
        })
    })
    var app = new Vue({
        el: "#app",
        data: {
            users: [],
            userReady: false,
            requests: [],
            requestReady: false,
            carousels: [],
            carouselReady: false,
            imageReady: false,
            imageData: "",
            imageFile: null,
            imageError: false,
            title: "",
            desc: "",
            domainReady: false,
            domains: [],
            optionReady: false,
            options: [],
            domainName: "",
            domainPath: "",
            domainSpace: false,
            resourceReady: false,
            resources: [],
            displayingResource: {},
            fileReady: false,
            files: []
        },
        methods: {
            levelToMessage(level) {
                switch (level) {
                    case 0: return "黑名单";
                    case 1: return "访客";
                    case 2: return "成员";
                    case 3: return "管理员";
                }
            },
            canBlacklist(x) {
                return x.level === 2 || x.level === 1;
            },
            canWhitelist(x) {
                return x.level === 0;
            },
            blacklistUser(x) {
                utils.blacklist(x.username, data => {
                    x.level = 0;
                });
            },
            whitelistUser(x) {
                utils.whitelist(x.username, data => {
                    x.level = data.original;
                })
            },
            timestampToDateString(ts) {
                return new Date(ts).toLocaleDateString();
            },
            categoryToMessage(c) {
                switch (c) {
                    case 1: return "删除相册"
                    case 2: return "删除文章"
                    default: return null
                }
            },
            fulfillRequest(x) {
                if (!confirm("确定要同意请求吗？同意后，所有同样的请求都会被删除。")) return;
                utils.fulfillRequest(x.id, data => {
                    app.requests = app.requests.filter(r => {
                        if (r.req.type !== x.req.type) return true;
                        if (x.req.type === 1) return r.req.name !== x.req.name;
                        if (x.req.type === 2) return r.req.id !== x.req.id;
                    })
                })
            },
            deleteRequest(x) {
                utils.deleteRequest(x.id, data => {
                    app.requests.splice(app.requests.indexOf(x), 1);
                })
            },
            clearBlacklist() {
                this.users.filter(u => u.level === 0).forEach(u => this.whitelistUser(u));
            },
            getCarouselHref(x) {
                return "/misc?type=image_carousel&id=" + x.id;
            },
            imageSelected() {
                let f = $("#file");
                let file = f[0].files[0];
                if (!file.type.startsWith('image/')) return;
                this.imageFile = file;
                f.val("");
                let reader = new FileReader();
                this.imageReady = this.imageError = false;
                reader.onload = () => {
                    let _this = app;
                    _this.imageData = reader.result;
                    _this.imageReady = true;
                }
                reader.onerror = () => {
                    app.imageError = true;
                }
                reader.readAsDataURL(file);
                $("#imageModal").modal('show');
            },
            selectImage() {
                $("#file").click();
            },
            uploadCarousel() {
                utils.putCarousel(this.title, this.desc, this.imageFile.name, this.imageData.split(',', 2)[1], data => {
                    app.updateCarousels();
                    app.title = app.desc = "";
                    app.imageFile = null;
                    app.imageData = "";
                });
            },
            updateCarousels() {
                utils.getCarousels(data => {
                    app.carousels = data.data;
                    app.carouselReady = true;
                })
            },
            deleteCarousel(x) {
                utils.deleteCarousel(x.id, data => {
                    app.carousels.splice(app.carousels.indexOf(x), 1);
                })
            },
            getFullDomain(x){
                return x.name + ".g2011.team";
            },
            getDomainPath(x){
                return "www.g2011.team" + x.path;
            },
            addDomain(e){
                e.preventDefault();
                if (this.domainName.trim() === "" || this.domainPath.trim() === "") return;
                utils.addDomain(this.domainName, this.domainPath, this.domainSpace, () => {
                    let _this = app;
                    _this.domains.push({
                        name: _this.domainName,
                        path: _this.domainPath,
                        space: _this.domainSpace
                    });
                    _this.domainName = _this.domainPath = "";
                    _this.domainSpace = false;
                });
            },
            deleteDomain(x){
                utils.deleteDomain(x.name, () => {
                    app.domains.splice(app.domains.indexOf(x), 1);
                })
            },
            toggleOption(x, val){
                if (x.value === val) return;
                utils.toggleOption(x.name, val, () => {
                    x.value = val;
                })
            },
            displayResource(g){
                this.displayingResource = g;
                $("#resourceModal").modal('show');
            },
            resourceItems(r){
                let result = [];
                for (let key in r){
                    result.push([key, r[key]]);
                }
                return result;
            },
            refreshResource(){
                this.resourceReady = false;
                utils.listResources(data => {
                    app.resources = data.data;
                    app.resourceReady = true;
                })
            },
            deleteFile(x, s){
                utils.deleteFile(x.name, () => {
                    if (s !== undefined) {
                        s.files.splice(s.files.indexOf(x), 1);
                        if (s.files.length <= 0) app.files.series.splice(app.files.series.indexOf(s), 1);
                    }
                    else app.files.files.splice(app.files.files.indexOf(x), 1);
                })
            }
        },
        computed: {
            blacklist() {
                return this.users.filter(u => u.level === 0);
            },
            hasBlacklist() {
                return this.users.some(u => u.level === 0);
            },
            hasRequest() {
                return this.requests.length > 0;
            },
            canUploadCarousel() {
                return this.title.trim() !== "" && this.desc.trim() !== "";
            },
            hasResource(){
                return this.displayingResource.res && this.displayingResource.res.length > 0;
            },
            hasSingleFile(){
                return this.files.files.length > 0;
            }
        }
    })
    utils.getUsers(data => {
        app.users = data.data;
        app.userReady = true;
    });
    utils.listRequests(data => {
        app.requests = data.data;
        app.requestReady = true;
    });
    app.updateCarousels();
    utils.listDomains(data => {
        app.domains = data.data;
        app.domainReady = true;
    })
    utils.listOptions(data => {
        app.options = data.data;
        app.optionReady = true;
    })
    utils.listFiles(data => {
        app.fileReady = true;
        app.files = data.data;
    })
    app.refreshResource();
</script>
</body>

</html>