<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
  <title>Create</title>
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
      <b>创建相册</b>
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
  <form class='small-box mx-auto text-center' @submit='formSubmit'>
    <h5>相册信息:</h5>
    <div v-if='hasTag'>
          <span v-for='x in tags' class='badge badge-secondary m-1'>
            <span v-if='x.usageReady'>{{x.name}}: 正在被 {{x.usage}} 个相册使用</span>
            <span v-else>{{x.name}}</span>
            <span style='cursor: pointer' @click='removeTag(x)'>&times;</span>
          </span>
    </div>
    <div v-else>
      <span class='text-warning'><b>无标签</b></span>
      <br>提示: 标签可以让相册更容易寻找
    </div>
    <input type='text' class='form-control input-list-head mt-2' placeholder="相册名称" v-model='albumName' required>
    <input type='text' class='form-control input-list-body' placeholder="拍摄日期" id="picker" required>
    <div class='input-group'>
      <input type='text' class='form-control input-list-foot' placeholder="标签" v-model='tagString'>
      <div class='input-group-append'>
        <input type='button' class='btn btn-outline-primary input-list-foot' value='添加标签' @click='addTag'>
      </div>
    </div>
    <input type='button' class='btn btn-secondary form-submit-button btn-block mt-3' value='清空' @click='clearAlbum'>
    <input type='submit' class='btn btn-primary form-submit-button btn-block mt-1' value='创建相册'>
  </form>
  <transition name='fly'>
    <div class='mx-auto text-center mt-3' v-if='showSpinner'>
      <span class='spinner-grow text-info'></span><br>
      <span>请稍候...</span>
    </div>
  </transition>
  <transition name='slide-fade'>
    <div class='alert alert-danger container mx-auto mt-3 text-center' v-if='error'>
      创建相册错误: {{errorMessage}}
    </div>
  </transition>
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
    function Tag(name){
        this.name = name;
        this.usage = 0;
        this.usageReady = false;
        let _this = this;
        utils.getTagUsage(name, data => {
            _this.usageReady = true;
            _this.usage = data.result;
        });
    }
    var app = new Vue({
        el: "#app",
        data: {
            albumName: "",
            tags: [],
            tagString: "",
            showSpinner: false,
            error: false,
            errorMessage: "",
            errorTimeoutHandle: null
        },
        methods: {
            addTag(){
                if (this.tagString.trim() === "") return;
                if (this.tags.indexOf(this.tagString) >= 0) return;
                this.tags.push(new Tag(this.tagString));
                this.tagString = "";
            },
            removeTag(x){
                this.tags.splice(this.tags.indexOf(x), 1);
            },
            formSubmit(e){
                e.preventDefault();
                if (this.errorTimeoutHandle != null){
                    clearTimeout(this.errorTimeoutHandle);
                    this.errorTimeoutHandle = null;
                }
                this.error = false;
                let name = this.albumName;
                let date = new Date($("#picker").val()).getTime();
                let tags = this.tags.map(t => t.name).join(",");
                this.showSpinner = true;
                utils.createAlbum(name, date, tags, data => {
                    console.log(data);
                    let _this = app;
                    _this.showSpinner = false;
                    if (data.success){
                        location.assign("modify.jsp?name=" + name);
                    }
                    else{
                        _this.errorMessage = codeToMessage(data.error);
                        _this.error = true;
                        _this.errorTimeoutHandle = setTimeout(() => _this.error = false, 5000);
                    }
                })
            },
            clearAlbum(){
                this.albumName = this.tagString = "";
                this.tags = [];
                $("#picker").val("");
            }
        },
        computed: {
            hasTag(){
                return this.tags.length > 0;
            }
        },
        watch: {
            tagString(newValue) {
                this.tagString = newValue.replace(",", "").replace(" ", "");
            }
        }
    })
    $.datetimepicker.setLocale('zh');
    $(() => {
        $("#picker").datetimepicker({
            timepicker: false,
            format: 'Y/m/d'
        });
    });
</script>
</body>
</html>