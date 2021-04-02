<%@ page pageEncoding="UTF-8" import="memo.user.User, memo.misc.Utils, memo.user.AccessLevel"%>
<%
  User user = Utils.getSessionUser(session);
  String target = request.getParameter("target");
  if (user != null && target != null){
      AccessLevel level = Utils.getPageLevel(target);
      if (level != null && level.getValue() <= user.getLevel().getValue()) {
          response.sendRedirect(target);
          return;
      }
  }
%>
<!DOCTYPE html>
<html>

<head>
  <title>Login</title>
  <script src='/js/main.js'></script>
  <script src='/js/jquery-3.4.1.js'></script>
  <script src='/js/popper.js'></script>
  <script src='/js/bootstrap.js'></script>
  <script src='/js/vue.js'></script>
  <script src='/js/cryptojs-core.js'></script>
  <script src='/js/cryptojs-enc-base64.js'></script>
  <script src='/js/cryptojs-sha256.js'></script>
  <link rel='stylesheet' href='/css/bootstrap.css'>
  <link rel='stylesheet' href='/css/main.css'>
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>

<body class='bg-light'>
<header>
  <nav class="navbar navbar-expand-md navbar-light fixed-top bg-light py-0 shadow">
    <div class='nav-cover text-center text-dark'>
      <b>登录</b>
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
          <li class="nav-item">
            <a class="nav-link" href="/album">
              <img src='/images/albums-outline.png' alt='album' height='30'>
            </a>
          </li>
          <li class="nav-item">
            <span class='nav-separator'></span>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#">
              <img src='/images/log-in.png' alt='login' height='30'>
            </a>
          </li>
        </ul>
      </div>
    </div>
  </nav>
</header>
<main id='app' class='main-low'>
  <div class='text-center'>
    <img src='/images/icon.png' alt='icon' height='150'>
    <transition name='fly'>
      <div v-if='showUserBox' class='mt-3 container'>
        <h3>欢迎您, {{username}}!</h3>
        <div class='d-flex flex-wrap justify-content-center small-box mx-auto'>
          <a :href='target' class='btn btn-outline-primary m-2 flex-fill' :class='{ disabled: !levelSufficient }'>前往页面
            ({{target}})</a>
          <button type='button' class='btn btn-outline-danger m-2 flex-fill' @click='logout'>登出</button>
          <a href="/admin.jsp" class="btn btn-outline-primary m-2 flex-fill" v-if="level==3">管理员工具</a>
        </div>
        <span class='text-danger' v-if='!levelSufficient'>用户权限不足。</span>
        <div class='small-box mt-2 mx-auto' v-if="level >= 2">
          <button type='button' @click='changingPassword = !changingPassword' class='btn btn-outline-secondary mb-3'>
            {{changingPassword ? "收起" : "更改密码"}}
          </button>
          <transition name='slide-fade-vertical'>
            <form @submit='changePassword' v-if='changingPassword'>
              <input type='password' class='form-control input-list-head' placeholder="原密码" v-model='oldPassword' required>
              <input type='password' class='form-control input-list-foot' placeholder="新密码" v-model='newPassword' required>
              <input type='submit' class='form-submit-button my-3 btn btn-primary btn-block' value='更改密码'>
              <transition name='fly'>
                  <span v-if="showChangePasswordMessage"
                        :class='changePasswordError ? "text-danger" : "text-success"'>{{changePasswordMessage}}</span>
              </transition>
            </form>
          </transition>
        </div>
        <hr>
        <div v-if="isGuest" class="small-box mx-auto row">
          <div class="col-md-6">
            <span>访客具有如下权限:</span><br>
            <ol>
              <li>预览与下载任意文章</li>
              <li>预览与下载任意相册</li>
            </ol>
          </div>
          <div class="col-md-6">
            <span>访客不具有以下权限:</span><br>
            <ol>
              <li>编辑任何相册</li>
              <li>创建相册与文章</li>
              <li>提出删除相册与文章请求</li>
            </ol>
          </div>
        </div>
        <div v-if="level==0" class="small-box mx-auto alert alert-warning">
          您已被加入黑名单，请联系管理员。
        </div>
        <div class='row' v-if='recordsReady'>
          <div :class='{"col-md-6": level<3, "col-12": level==3}'>
            <h5>上传的文章</h5>
            <ol class='list-group mt-3' v-if='hasArticles'>
              <li v-for='x in articles' class='list-group-item'>
                <span>标题: {{x.title}}</span><br>
                <span>上传于: {{timestampToDateString(x.date)}}</span><hr>
                <span>阅读量: {{x.amount}}</span><br>
                <a :href='getArticleHref(x.id)'>浏览文章</a>
              </li>
            </ol>
            <div class='alert alert-warning mt-3' v-else>
              您还未上传任何文章。
            </div>
          </div>
          <div class='col-md-6' v-if="level<3">
            <h5>提交的请求</h5>
            <ol class='list-group mt-3' v-if='hasRequests'>
              <li v-for='x in requests' class='list-group-item'>
                <span>请求类型: {{categoryToMessage(x.req.type)}}请求</span><br>
                <span>请求时间: {{timestampToDateString(x.req.date)}}</span><hr>
                <div v-if='x.req.type == 1'>
                  <span>相册名称: {{x.req.name}}</span><br>
                  <span>请求原因: {{x.req.reason}}</span>
                </div>
                <div v-if='x.req.type == 2'>
                  <span>文章ID: {{x.req.id}}</span><br>
                  <span>请求原因: {{x.req.reason}}</span>
                </div>
                <button type='button' class='btn btn-link text-danger' @click='deleteRequest(x.id)' :disabled='deletingRequest'>删除请求</button>
              </li>
            </ol>
            <div class='alert alert-warning mt-3' v-else>
              您还未提交任何请求。
            </div>
          </div>
        </div>
      </div>
    </transition>
    <transition name='fly' appear>
      <div v-if='showSpinner' class='mt-3'>
        <span class='spinner-border text-info'></span>
      </div>
    </transition>
    <transition name='slide-fade-vertical' appear>
      <form action='login' class='small-box mt-3 mx-auto' @submit='formSubmit' v-if='showLoginBox'>
        <input class='form-control input-list-head' placeholder="用户名" type='text' required v-model='username'>
        <input class='form-control input-list-foot' placeholder="密码" type='password' required v-model='password'>
        <p class='my-3'>没有账号？G2011 以外的同学可以<a href='#' @click="guestLogin">使用访客登录</a>。</p>
        <input class='btn btn-block btn-primary form-submit-button mt-3' type='submit' value='登录'>
      </form>
    </transition>
    <transition name='fly'>
      <p class='text-danger mt-3' v-if='showLoginMessage'>{{loginMessage}}</p>
    </transition>
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
    };
    var qs = utils.parseQueryString();
    var app = new Vue({
        el: "#app",
        data: {
            username: "",
            password: "",
            showSpinner: true,
            loginMessage: "",
            showLoginMessage: false,
            showLoginBox: false,
            showUserBox: false,
            messageTimeoutHandle: null,
            target: qs.target ?? "/",
            level: -1,
            isGuest: false,
            requests: [],
            articles: [],
            recordsReady: false,
            deletingRequest: false,
            changingPassword: false,
            oldPassword: "",
            newPassword: "",
            changePasswordMessage: "",
            changePasswordError: false,
            showChangePasswordMessage: false
        },
        methods: {
            doShowLoginMessage() {
                this.showLoginMessage = true;
                this.messageTimeoutHandle = setTimeout(() => this.showLoginMessage = false, 5000);
            },
            doShowLoginBox() {
                this.showLoginBox = true;
            },
            doHideLoginBox() {
                this.showLoginBox = false;
            },
            doShowUserBox() {
                this.showUserBox = true;
                if (this.level >= 2) {
                    this.showSpinner = true;
                    utils.listRecords(data => {
                        let _this = app;
                        _this.showSpinner = false;
                        _this.requests = data.records.requests;
                        _this.articles = data.records.articles;
                        _this.recordsReady = true;
                    });
                }
            },
            doHideUserBox() {
                this.showUserBox = false;
            },
            formSubmit(e) {
                e.preventDefault();
                if (this.messageTimeoutHandle) {
                    clearTimeout(this.messageTimeoutHandle);
                    this.messageTimeoutHandle = null;
                    this.showLoginMessage = false;
                }
                this.showSpinner = true;
                utils.performLogin(this.username, this.password, data => {
                    console.log(data);
                    let _this = app;
                    _this.showSpinner = false;
                    if (data.success) {
                        _this.level = data.level;
                        _this.isGuest = false;
                        _this.doHideLoginBox();
                        _this.doShowUserBox();
                    }
                    else {
                        _this.loginMessage = codeToMessage(data.error);
                        _this.doShowLoginMessage();
                    }
                })
            },
            logout() {
                this.showSpinner = true;
                this.articles = [];
                this.requests = [];
                this.recordsReady = false;
                this.showChangePasswordMessage = false;
                utils.performLogout(() => {
                    let _this = app;
                    _this.showSpinner = false;
                    _this.password = "";
                    if (_this.isGuest) _this.username = "";
                    _this.level = -1;
                    _this.doHideUserBox();
                    _this.doShowLoginBox();
                });
            },
            guestLogin() {
                if (this.messageTimeoutHandle) {
                    clearTimeout(this.messageTimeoutHandle);
                    this.messageTimeoutHandle = null;
                    this.showLoginMessage = false;
                }
                this.showSpinner = true;
                utils.performGuest(data => {
                    let _this = app;
                    _this.showSpinner = false;
                    if (data.success) {
                        _this.username = "访客";
                        _this.level = 1;
                        _this.doHideLoginBox();
                        _this.doShowUserBox();
                        _this.isGuest = true;
                    }
                    else {
                        _this.loginMessage = codeToMessage(data.error);
                        _this.doShowLoginMessage();
                    }
                })
            },
            timestampToDateString(ts){
                return new Date(ts).toLocaleDateString();
            },
            getArticleHref(id){
                return "/article/detail.jsp?id=" + id;
            },
            categoryToMessage(c) {
                switch (c){
                    case 1: return "删除相册"
                    case 2: return "删除文章"
                    default: return null
                }
            },
            deleteRequest(id){
                this.deletingRequest = true;
                utils.deleteRequest(id, () => {
                    let _this = app;
                    _this.deletingRequest = false;
                    _this.requests.splice(_this.requests.findIndex(r => r.id === id), 1);
                })
            },
            changePassword(e){
                e.preventDefault();
                if (this.oldPassword === this.newPassword) {
                    this.changePasswordMessage = "原密码与新密码相同。";
                    this.changePasswordError = true;
                    this.doShowChangePasswordMessage();
                    return;
                }
                utils.changePassword(this.oldPassword, this.newPassword, data => {
                    let _this = app;
                    if (data.success){
                        _this.oldPassword = "";
                        _this.newPassword = "";
                        _this.changePasswordMessage = "更改密码成功。";
                        _this.changePasswordError = false;
                    }
                    else {
                        _this.changePasswordError = true;
                        if (data.error === utils.ERROR_INCORRECT_USER){
                            _this.changePasswordMessage = "原密码错误。";
                        }
                    }
                    _this.doShowChangePasswordMessage();
                });
            },
            doShowChangePasswordMessage(){
                if (this.messageTimeoutHandle) clearTimeout(this.messageTimeoutHandle);
                this.showChangePasswordMessage = true;
                this.messageTimeoutHandle = setTimeout(() => app.showChangePasswordMessage = false, 5000);
            }
        },
        watch: {
            username: function (value) {
                this.username = value.trim();
            }
        },
        computed: {
            levelSufficient() {
                return this.level >= utils.getPageLevel(this.target)
            },
            hasRequests(){
                return this.requests.length > 0;
            },
            hasArticles(){
                return this.articles.length > 0;
            }
        }
    })
    utils.checkLogin(data => {
      app.showSpinner = false;
      if (data.result) {
        app.username = data.username;
        app.level = data.level;
        app.isGuest = data.guest;
        app.doShowUserBox();
      }
      else {
        app.doShowLoginBox();
      }
    });
</script>
</body>

</html>