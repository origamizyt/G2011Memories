<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>

<head>
  <title>404 Error</title>
  <script src='/js/main.js'></script>
  <script src='/js/jquery-3.4.1.js'></script>
  <script src='/js/popper.js'></script>
  <script src='/js/bootstrap.js'></script>
  <script src='/js/vue.js'></script>
  <link rel='stylesheet' href='/css/bootstrap.css'>
  <link rel='stylesheet' href='/css/main.css'>
</head>

<body class='bg-light'>
<header>
  <nav class="navbar navbar-expand-md navbar-light fixed-top bg-light py-0 shadow">
    <div class='nav-cover text-center text-dark'>
      <b>Oops!</b>
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
  <div class='text-center small-box mx-auto'>
    <img src='/images/404.png' alt='404' style='max-width: 100%;'><hr>
    <span>额@_@...你想访问哪里呢? (笑</span><br>
    <span>G2011 可没有这样的地方呢</span><br>
    <button type='button' class='btn btn-link text-primary mt-2' data-toggle='collapse' data-target='#commonLinks' @click='toggleLinks'>
      {{showLinks ? "收起常用功能" : "展开常用功能"}}
    </button>
    <ul class='list-group mt-3 collapse' id='commonLinks'>
      <li class='list-group-item d-flex justify-content-between'>
        <span>主页</span>
        <a href='http://www.g2011.team'>www.g2011.team</a>
      </li>
      <li class='list-group-item d-flex justify-content-between'>
        <span>文章</span>
        <a href='http://www.g2011.team/article'>www.g2011.team/article</a>
      </li>
      <li class='list-group-item d-flex justify-content-between'>
        <span>相册</span>
        <a href='http://www.g2011.team/album'>www.g2011.team/album</a>
      </li>
      <li class='list-group-item d-flex justify-content-between'>
        <span>登录</span>
        <a href='http://www.g2011.team/login'>www.g2011.team/login</a>
      </li>
      <li class='list-group-item d-flex justify-content-between'>
        <span>管理员工具 (需要管理员权限)</span>
        <a href='http://admin.g2011.team'>admin.g2011.team</a>
      </li>
      <li class='list-group-item d-flex justify-content-between'>
        <span>公共空间</span>
        <a href='http://space.g2011.team'>space.g2011.team</a>
      </li>
    </ul>
  </div>
</main>
<footer class='container border-top my-5 pt-5'>
  <div class='row text-center'>
    <div class='col-4 col-md border-right'>
      		 	<div style="width:300px;margin:0 auto; padding:20px 0;"><small>
		 		<a target="_blank" href="http://www.beian.gov.cn/portal/registerSystemInfo?recordcode=11010802034551" style="display:inline-block;text-decoration:none;height:20px;line-height:20px;"><img src="/images/beian_icon.png" style="float:left;"/><p style="float:left;height:20px;line-height:20px;margin: 0px 0px 0px 5px; color:#939393;">京公网安备 11010802034551号</p></a>
                                                                                                                <br><span>京ICP备2021005322号-1</span>
		 	</small></div>
    </div>
    <div class="col-4 col-md border-left border-right">
      <h5>功能</h5>
      <ul class="list-unstyled text-small">
        <li><a class="text-muted" href="/article">文章</a></li>
        <li><a class="text-muted" href="/album">相册</a></li>
      </ul>
    </div>
    <div class="col-4 col-md border-left">
      <h5>关于</h5>
      <ul class="list-unstyled text-small">
        <li><a class="text-muted" href="/about.jsp">开发者</a></li>
      </ul>
    </div>
  </div>
</footer>
<script>
    var app = new Vue({
        el: "#app",
        data: {
            showLinks: false
        },
        methods: {
            toggleLinks(){
                this.showLinks = !this.showLinks;
            }
        }
    })
</script>
</body>

</html>