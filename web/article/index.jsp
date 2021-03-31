<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>

<head>
  <title>Articles</title>
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
      <b>文章中心</b>
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
            <a class="nav-link" href="#">
              <img src='/images/documents.png' alt='article' height='30'>
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
  <transition name='fly' appear>
    <div v-if='showSpinner' class='text-center mx-auto'>
      <span class='spinner-grow text-info'></span>
      <p>请稍候...</p>
    </div>
  </transition>
  <transition name='slide-fade-vertical'>
    <div class='container' v-if='articlesReady'>
      <div class='row'>
        <div class='col-md-3'>
          <div class='border rounded bg-white p-3 m-1'>
            <form @submit='filterArticle'>
              <input type='text' placeholder="搜索标题" class='form-control input-list-head' v-model='titleFilter'>
              <input type='text' placeholder="搜索作者" class='form-control input-list-foot' v-model='authorFilter'>
              <div class="form-check mt-2">
                <input class="form-check-input" type="radio" name='sort' id="radio1" value='byTime' v-model='sortBy'>
                <label class="form-check-label" for="radio1">
                  按时间排序
                </label>
              </div>
              <div class="form-check">
                <input class="form-check-input" type="radio" name='sort' id="radio2" value='byAmount'v-model='sortBy'>
                <label class="form-check-label" for="radio2">
                  按阅读量排序
                </label>
              </div>
              <input type='submit' class='btn btn-block btn-primary form-submit-button mt-3' value='确认'>
              <input type='button' class='btn btn-block btn-secondary form-submit-button mt-1' value='清空' @click='clearFilter'>
            </form>
          </div>
        </div>
        <div class='col-md-9'>
          <div class='border rounded bg-white p-3 m-1'>
            <a class='btn btn-light btn-block' href='post.jsp'
               style='border: 2px dashed; height: 60px; font-size: 1.8rem'>+</a>
            <div v-if='hasArticle'>
              <div v-for='x in filteredArticles'>
                <hr>
                <a :href='getArticleHref(x)'>
                  <span style='font-size: 20px'>{{x.title}}</span>
                </a><br>
                <span>文章 ID: {{x.id}}</span>
                <span class='desc-link' @click='linkArticle(x)'>
                    <img src='/images/attach-outline.png' alt='link' height='20'>
                  </span><br>
                <span class='desc-item'>{{x.date.toLocaleDateString()}}</span>
                <span class='desc-item'>阅读量 {{x.amount}}</span>
                <span class='desc-item'>作者: {{x.author}}</span>
              </div>
            </div>
            <div class='alert alert-danger mt-3 mb-0' v-else>
              没有符合要求的文章。
            </div>
          </div>
        </div>
      </div>
    </div>
  </transition>
  <div class="modal fade" id="linkModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">链接此文章</h5>
          <button type="button" class="close" data-dismiss="modal">
            <span>&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <span>要在您的页面中使用此文章，请复制下方链接:</span>
          <textarea rows='2' class='form-control mt-2' style='resize: none; word-wrap: break-word;' readonly>{{linkingArticleLink}}</textarea>
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
    function ArticleItem(obj){
        this.id = obj.id;
        this.author = obj.author;
        this.title = obj.title;
        this.amount = obj.amount;
        this.date = new Date(obj.date);
    }
    function Filter(title, author){
        this.title = title;
        this.author = author;
    }
    Filter.prototype.filter = function filter(a){
        if (this.title){
            if (!a.title.includes(this.title)) return false;
        }
        if (this.author){
            if (this.author.toLowerCase() !== a.author.toLowerCase()) return false;
        }
        return true;
    }
    $(() => {
        $("#linkModal").modal({
            show: false
        })
    })
    var app = new Vue({
        el: "#app",
        data: {
            showSpinner: true,
            articlesReady: false,
            articles: [],
            filteredArticles: [],
            filter: new Filter("", ""),
            titleFilter: "",
            authorFilter: "",
            sortBy: "",
            linkingArticle: {}
        },
        methods: {
            getArticleHref(x){
                return "/article/detail.jsp?id=" + x.id
            },
            filterArticle(e){
                e.preventDefault();
                this.filter.title = this.titleFilter;
                this.filter.author = this.authorFilter;
                this.filteredArticles = this.articles.filter(a => app.filter.filter(a));
                if (this.sortBy === "byTime"){
                    this.filteredArticles.sort((a, b) => b.date.getTime() - a.date.getTime());
                }
                if (this.sortBy === "byAmount"){
                    this.filteredArticles.sort((a, b) => b.amount - a.amount);
                }
            },
            clearFilter(){
                this.filter = new Filter("", "");
                this.filteredArticles = this.articles;
                this.sortBy = "";
                this.titleFilter = this.authorFilter = "";
            },
            linkArticle(x){
                this.linkingArticle = x;
                $("#linkModal").modal('show');
            }
        },
        computed: {
            hasArticle(){
                return this.filteredArticles.length > 0;
            },
            linkingArticleLink(){
                return "http://www.g2011.team/article/detail.jsp?id=" + this.linkingArticle.id;
            }
        }
    });
    utils.listArticles(data => {
        app.showSpinner = false;
        app.filteredArticles = app.articles = data.data.map(a => new ArticleItem(a));
        app.articlesReady = true;
    })
</script>
</body>

</html>