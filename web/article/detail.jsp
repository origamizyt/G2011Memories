<%@ page contentType="text/html;charset=UTF-8" language="java" import="memo.misc.Utils, java.util.UUID" %>
<%
  String idString = request.getParameter("id");
  if (idString != null){
      UUID id = UUID.fromString(idString);
      Utils.increaseAmount(id);
  }
%>
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
  <style>
    #viewer h3 {
      margin-bottom: 20px;
      margin-top: 10px;
    }
    @media screen and (max-width: 767px) {
      #viewer img {
        max-width: 100%;
        margin-top: 10px;
        margin-bottom: 10px;
      }
    }
    @media screen and (min-width: 768px){
      #viewer img {
        max-width: 600px;
        margin: 10px;
      }
    }
    #viewer p {
      text-indent: 2em;
    }
    pre.line-num {
      counter-set: line;
    }
    pre.line-num .line {
      line-height: 1.5rem;
      display: flex;
    }
    pre.line-num .line:before {
      counter-increment: line;
      content: counter(line);
      display: inline-block;
      border-right: 1px solid #ddd;
      padding: 0 .5em;
      margin-right: 20px;
      color: #888;
      min-width: 50px;
    }
  </style>
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>

<body class='bg-light'>
<header>
  <nav class="navbar navbar-expand-md navbar-light fixed-top bg-light py-0 shadow">
    <div class='nav-cover text-center text-dark'>
      <b>文章预览</b>
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
    <div v-if='articleError' class='alert alert-danger container text-center'>
      获取文章错误。
    </div>
  </transition>
  <transition name='slide-fade-vertical'>
    <div v-if='articleReady'>
      <div class='small-box mx-auto text-center'>
        <h4>{{article.title}}</h4>
        <span>上传时间: {{timestampToDateString(article.date)}}</span><br>
        <span>创作者: {{article.author}}</span><br>
        <span>阅读量: {{article.amount}}</span>
        <div class='d-flex flex-wrap mt-2'>
          <div class="dropdown flex-fill mx-1">
            <button class="btn btn-outline-primary dropdown-toggle btn-block" type="button" data-toggle="dropdown">下载</button>
            <ul class="dropdown-menu" style='width: 100%'>
              <li><a class="dropdown-item" :href="pdfDownloadHref">下载 PDF</a></li>
              <li><a class="dropdown-item" :href="xmlDownloadHref">下载 XML</a></li>
            </ul>
          </div>
          <button type='button' class='btn btn-outline-danger flex-fill mx-1' @click='deleteArticle' :disabled='!canDelete'>删除</button>
        </div>
        <hr>
      </div>
      <div class='container'>
        <transition name='slide-fade-vertical'>
          <div v-if='contentLoading' class='text-center mx-auto' style='max-width: 300px;'>
            <span>正在解析文章内容...</span>
            <div class="progress mt-2">
              <div class="progress-bar progress-bar-striped progress-bar-animated" style="width: 100%"></div>
            </div>
          </div>
          <div v-else>
            <ul class="nav nav-tabs text-center">
              <li class="nav-item flex-fill">
                <a class="nav-link active" data-toggle="tab" href="#text" title='文本'>
                  <img src='/images/text-outline.png' alt='text' height='25'>
                </a>
              </li>
              <li class="nav-item flex-fill">
                <a class="nav-link" data-toggle="tab" href="#code" title='XML'>
                  <img src='/images/code-slash-outline.png' alt='code' height='25'>
                </a>
              </li>
            </ul>
            <div class="tab-content bg-white border border-top-0 p-3 rounded-bottom">
              <div class="tab-pane fade show active" id="text">
                <div v-html='renderedDocument' id='viewer'></div>
              </div>
              <div class="tab-pane fade" id="code">
                <pre style='white-space: pre-wrap; word-wrap: break-word;' class='line-num' v-html='rawDocument'></pre>
              </div>
            </div>
          </div>
        </transition>
      </div>
    </div>
  </transition>
  <div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">删除文章请求</h5>
          <button type="button" class="close" data-dismiss="modal">
            <span>&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <span>删除文章请求: {{article.id}}</span><br>
          <textarea v-model='reason' placeholder='删除文章的原因 (少于30个字)' class='form-control my-2' style='resize: none' maxlength='30'></textarea>
          <span>确定要提交请求吗?</span>
        </div>
        <div class="modal-footer">
          <input type="button" class="btn btn-secondary" data-dismiss="modal" value='取消'>
          <input type="button" class="btn btn-primary" value='提交' @click='confirmDelete' :disabled='!reasonValid'>
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
    var render = (article, node) => {
        let el = null;
        if (node.tagName === 'headline'){
            el = document.createElement('h3');
            el.innerHTML = node.innerHTML.trim();
            el.classList.add("mx-auto");
        }
        else if (node.tagName === 'paragraph'){
            el = document.createElement('p');
            el.innerHTML = node.innerHTML.trim();
        }
        else if (node.tagName === 'image'){
            el = document.createElement('div');
            let img = document.createElement('img');
            img.src = "/article/article?type=index&id=" + article.id + "&index=" + node.getAttribute('index');
            img.alt = "article image " + node.getAttribute('index');
            el.classList.add("text-center", "m-2");
            el.append(img);
            el.append(document.createElement("br"));
            let desc = document.createElement("span");
            let descString = node.getAttribute("desc");
            if (descString === null) descString = "图片" + node.getAttribute('index');
            desc.innerHTML = descString;
            desc.classList.add("text-muted");
            el.append(desc);
        }
        else {
            el = document.createElement('span');
            el.innerHTML = node.innerHTML.trim();
        }
        return el;
    }
    var qs = utils.parseQueryString();
    var app = new Vue({
        el: "#app",
        data: {
            showSpinner: true,
            article: {},
            articleReady: false,
            articleError: false,
            articleContentReady: false,
            contentLoading: false,
            contentDocument: null,
            renderedDocument: "",
            reason: "",
            canDelete: false
        },
        methods: {
            timestampToDateString(ts){
                return new Date(ts).toLocaleDateString();
            },
            doLoadDocument(){
                for (let node of this.contentDocument.documentElement.children){
                    this.renderedDocument += render(this.article, node).outerHTML;
                }
                app.contentLoading = false;
            },
            confirmDelete(){
                utils.deleteArticleRequest(this.article.id, this.reason, data => {
                    if (data.success) {
                        alert('提交请求成功! 您可以在"登录"页面中管理请求。');
                    }
                    else {
                        alert('提交请求失败: 功能已被管理员禁用。');
                    }
                    $("#deleteModal").modal('hide');
                });
            },
            deleteArticle() {
                if (this.level === 3){
                    if (!confirm("确定要删除文章吗?")) return;
                    this.showSpinner = true;
                    utils.deleteArticle(this.article.id, () => {
                        location.assign("/article");
                    });
                }
                else {
                    $("#deleteModal").modal('show');
                }
            }
        },
        computed: {
            pdfDownloadHref(){
                return "/article/article?type=download&id=" + this.article.id + "&format=pdf";
            },
            xmlDownloadHref(){
                return "/article/article?type=download&id=" + this.article.id + "&format=xml"
            },
            rawDocument(){
                let doc = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<article>\n";
                for (let node of this.contentDocument.documentElement.children){
                    if (node.tagName === 'paragraph'){
                        doc += "    <paragraph>\n        ";
                        doc += node.innerHTML.trim();
                        doc += "\n    </paragraph>\n"
                    }
                    else if (node.tagName === 'image'){
                        doc += "    <image index=\"";
                        doc += node.getAttribute('index');
                        doc += "\" desc=\""
                        doc += node.getAttribute('desc');
                        doc += "\"/>\n";
                    }
                    else if (node.tagName === 'headline'){
                        doc += "    <headline>";
                        doc += node.innerHTML.trim();
                        doc += "</headline>\n"
                    }
                    else {
                        doc += "    " + node.outerHTML + "\n";
                    }
                }
                doc += "</article>";
                let html = "";
                for (let line of doc.split("\n")){
                    html += "<div class='line'><div>" + line.replace("<", "&lt;").replace(">", "&gt;") + "</div></div>"
                }
                return html;
            },
            reasonValid(){
                return this.reason.trim().length > 0;
            }
        }
    })
    if (!qs.id){
        app.showSpinner = false;
        app.articleError = true;
    }
    else
        utils.getArticle(qs.id, data => {
            app.showSpinner = false;
            console.log(data);
            if (data.success) {
                app.article = data.article;
                app.articleReady = true;
                app.contentLoading = true;
                utils.articleContent(qs.id, data => {
                    app.contentDocument = data;
                    app.doLoadDocument();
                })
            }
            else {
                app.articleError = true;
            }
        })
    utils.checkLogin(data => {
        if (data.result) {
            app.canDelete = data.level >= 2;
            app.level = data.level;
        }
        else app.canDelete = false;
    });
</script>
</body>

</html>
