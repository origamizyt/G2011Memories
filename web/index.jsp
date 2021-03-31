<%@page pageEncoding="UTF-8"%>
<html>

<head>
  <title>G2011 Memories</title>
  <script src='js/jquery-3.4.1.js'></script>
  <script src='js/popper.js'></script>
  <script src='js/bootstrap.js'></script>
  <script src='js/vue.js'></script>
  <script src='js/main.js'></script>
  <link rel='stylesheet' href='css/bootstrap.css'>
  <link rel='stylesheet' href='css/main.css'>
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>

<body class='bg-light'>
<header>
  <nav class="navbar navbar-expand-md navbar-light fixed-top bg-light py-0 shadow">
    <div class='nav-cover text-center text-dark'>
      <b>Memories Of G2011</b>
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
            <a class="nav-link" href="#">
              <img src='/images/home.png' alt='home' height='30'><br>
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
            <a class="nav-link" href="/login">
              <img src='/images/log-in-outline.png' alt='login' height='30'>
            </a>
          </li>
        </ul>
      </div>
    </div>
  </nav>
</header>
<main id='app' class='main'>
  <transition name="slide-fade-vertical" @after-enter="initCarousel">
    <div v-if="allReady">
      <div class='bg-secondary'>
        <div id="title-carousel" class="carousel slide carousel-fade mx-auto round-corner" data-ride="carousel">
          <ul class="carousel-indicators">
            <li v-for='x in carousel' data-target="#title-carousel" :data-slide-to="x.id" :class="{ active: !x.id }"></li>
          </ul>
          <div class="carousel-inner">
            <div v-for='x in carousel' class="carousel-item" :class="{ active: !x.id }">
              <img :src="x.url" :alt='x.title'>
              <div class='carousel-caption'>
                <transition name='slide-fade' appear>
                  <h3 v-if='x.visible'># {{x.title}} #</h3>
                </transition>
                <transition name='slide-fade' appear>
                  <p v-if='x.visible'>{{x.text}}</p>
                </transition>
              </div>
            </div>
          </div>
          <a class="carousel-control-prev" href="#title-carousel" data-slide="prev">
            <span class="carousel-control-prev-icon"></span>
          </a>
          <a class="carousel-control-next" href="#title-carousel" data-slide="next">
            <span class="carousel-control-next-icon"></span>
          </a>
        </div>
      </div>
      <div style='background-image: url("/images/back2.png"); padding: 30px;' class='text-white text-center'>
        <h3>班级形象</h3>
        <span>
          G2011 是一个开放的班级。<br>
          我们欢迎任何同学来到本班交流，讨论学术或生活问题。<br>
        </span>
        <a href='/space' class='btn btn-warning mt-3'>公共空间</a><br><br>
        <span>
          我们仰望星空，脚踏实地；我们一起优秀，各自精彩。<br>
          我们将用理想与坚持去铸就新的辉煌。<br>
        </span>
      </div>
      <div class='container text-center mt-3'>
        <div class='d-flex flex-wrap justify-content-center'>
          <div class='p-2 flex-fill main-card'>
            <div class='card shadow-hover'>
              <img class='card-img-top' :src='articleCoverHref' alt='article-thumbnail'>
              <hr class='m-0'>
              <div class='card-body bg-light'>
                <h4 class='card-title'>最新文章: {{latestArticle.title}}</h4>
                <p class='card-text'>发布时间: {{timestampToDateString(latestArticle.date)}}</p>
                <a :href='articleDetailHref' class='card-link'>更多信息</a>
              </div>
            </div>
          </div>
          <div class='p-2 flex-fill main-card'>
            <div class='card shadow-hover'>
              <img class='card-img-top' :src='albumCoverHref' alt='album-cover'>
              <hr class='m-0'>
              <div class='card-body bg-light'>
                <h4 class='card-title'>最新相册: {{latestAlbum.name}}</h4>
                <p class='card-text'>发布时间: {{timestampToDateString(latestAlbum.date)}}</p>
                <a :href='albumDetailHref' class='card-link'>更多信息</a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </transition>
  <transition name="fly" appear>
    <div v-if="!allReady" class="small-box text-center mx-auto">
      <span class="spinner-grow text-info"></span><br>
      <span>请稍候...</span>
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
    function CarouselItem(url, title, text) {
        this.url = url;
        this.title = title;
        this.text = text;
        this.id = CarouselItem.id++;
        this.visible = !this.id;
    }
    CarouselItem.id = 0;
    var app = new Vue({
        el: "#app",
        data: {
            carousel: [],
            latestAlbum: {},
            latestArticle: {},
            albumReady: false,
            articleReady: false,
            carouselReady: false
        },
        methods: {
            timestampToDateString(ts){
                return new Date(ts).toLocaleDateString();
            },
            initCarousel(){
                $("#title-carousel").carousel({
                    interval: 5000
                }).on("slide.bs.carousel", function (e) {
                    app.carousel[e.from].visible = false;
                    app.carousel[e.to].visible = true;
                }).carousel('cycle');
            }
        },
        computed: {
            allReady(){
                return this.albumReady && this.articleReady && this.carouselReady;
            },
            albumDetailHref(){
                return "album/detail.jsp?name=" + this.latestAlbum.name;
            },
            articleDetailHref(){
                return "article/detail.jsp?id=" + this.latestArticle.id;
            },
            albumCoverHref(){
                return this.latestAlbum.count > 0 ? "album/album?type=index&name=" + this.latestAlbum.name + "&index=0" : "/images/icon.png";
            },
            articleCoverHref(){
                return this.latestArticle.image_count > 0 ? "article/article?type=index&id=" + this.latestArticle.id + "&index=0" : "/images/icon.png";
            }
        }
    });
    utils.latestAlbum(data => {
        app.latestAlbum = data.album;
        app.albumReady = true;
    })
    utils.latestArticle(data => {
        app.latestArticle = data.article;
        app.articleReady = true;
    })
    utils.getCarousels(data => {
        app.carousel = data.data.map(c => new CarouselItem(
            "/misc?type=image_carousel&id=" + c.id,
            c.title,
            c.desc
        ));
        app.carouselReady = true;
    })
</script>
</body>

</html>