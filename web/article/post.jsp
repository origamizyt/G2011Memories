<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>

<head>
  <title>Post</title>
  <script src='/js/main.js'></script>
  <script src='/js/jquery-3.4.1.js'></script>
  <script src='/js/popper.js'></script>
  <script src='/js/bootstrap.js'></script>
  <script src='/js/vue.js'></script>
  <link rel='stylesheet' href='/css/bootstrap.css'>
  <link rel='stylesheet' href='/css/main.css'>
  <style>
    #viewer h3,
    #editor h3 {
      margin-bottom: 20px;
      margin-top: 10px;
    }

    #viewer p,
    #editor p {
      text-indent: 2em;
    }

    @media screen and (max-width: 767px) {

      #viewer img,
      #editor img {
        max-width: 100%;
        margin-top: 10px;
        margin-bottom: 10px;
      }
    }

    @media screen and (min-width: 768px) {

      #viewer img,
      #editor img {
        max-width: 600px;
        margin: 10px;
      }
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
      <b>发布文章</b>
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
  <nav>
    <ul class="pagination justify-content-center">
      <li class="page-item"><span class="page-link" style='cursor: pointer;' @click='previousPage'>&lsaquo;</span>
      </li>
      <li class="page-item" :class='{ active: pageIndex==0 }'><span class="page-link">创建文章</span></li>
      <li class="page-item" :class='{ active: pageIndex==1 }'><span class="page-link">编写页面</span></li>
      <li class="page-item" :class='{ active: pageIndex==2 }'><span class="page-link">上传文章</span></li>
      <li class="page-item"><span class="page-link" style='cursor: pointer;' @click='nextPage'>&rsaquo;</span></li>
    </ul>
  </nav>
  <transition-group name='fly'>
    <div v-if='pageIndex==0' :key='0'>
      <form class='small-box mx-auto text-center'>
        <h5>创建文章</h5>
        <input type='text' v-model='title' class='form-control input-list-head' placeholder="文章标题" required>
        <div class='input-group'>
          <div class='input-group-prepend'>
            <span class='input-group-text input-list-foot'>作者:</span>
          </div>
          <input type='text' class='form-control input-list-foot' v-model='author' readonly>
        </div>
        <hr>
      </form>
      <div class='mt-3 small-box mx-auto text-center'>
        <h5>上传图片</h5>
        <ul class='list-group mt-2'>
          <li class='list-group-item p-0'>
            <button type='button' class='btn btn-light btn-block' style='border: 2px dashed; font-size: 2rem'
                    @click='selectImage'>+</button>
          </li>
          <li class='list-group-item' v-for='(x, index) in images'>
            <span>{{x.file.name}} (将被重命名为 {{index+'.'+x.extension()}})</span>
            <span style='cursor: pointer;' class='text-danger' @click='deleteImage(x)'>&times;</span><br>
            <div class='progress my-2'>
              <div class='progress-bar progress-bar-animated progress-bar-striped' :style='{width: x.percent+"%"}'>
              </div>
            </div>
            <span v-if='x.finished' class='text-success'>加载完成。</span>
            <span v-if='x.error' class='text-danger'>加载失败。</span>
            <span v-if='!x.error && !x.finished'>正在加载...</span>
          </li>
        </ul>
      </div>
    </div>
    <div v-if='pageIndex==1' :key='1' class='container'>
      <ul class="nav nav-tabs text-center">
        <li class="nav-item flex-fill">
          <a class="nav-link active" data-toggle="tab" href="#edit" title='文本'>
            <img src='/images/create-outline.png' alt='edit' height='25'>
          </a>
        </li>
        <li class="nav-item flex-fill">
          <a class="nav-link" data-toggle="tab" href="#text" title='文本'>
            <img src='/images/text-outline.png' alt='text' height='25'>
          </a>
        </li>
        <li class="nav-item flex-fill">
          <a class="nav-link" data-toggle="tab" href="#code" title='XML' @click='updateRawDocument'>
            <img src='/images/code-slash-outline.png' alt='code' height='25'>
          </a>
        </li>
      </ul>
      <div class="tab-content bg-white border border-top-0 p-3 rounded-bottom">
        <div class='tab-pane fade show active' id='edit'>
          <div class='container mt-3 rounded-top border bg-white p-2 text-center'>
            <button type='button' class='btn btn-light border dropdown-toggle' data-toggle='dropdown'>
              <img src='/images/add.png' alt='add' height="20">
            </button>
            <div class="dropdown-menu">
              <span class="dropdown-item" style='cursor: pointer' @click='newHeadline'>标题</span>
              <span class="dropdown-item" style='cursor: pointer' @click='newParagraph'>段落</span>
              <span class="dropdown-item" style='cursor: pointer' @click='newLink'>链接</span>
              <span class="dropdown-item" :class="hasImage ? [] : ['disabled']" style='cursor: pointer;' @click='newImage'>图片</span>
            </div>
            <button type='button' class='btn btn-light border' @click='clearDocument'>
              <img src='/images/close-outline.png' alt='clear' height='20'>
            </button>
          </div>
          <div class='container rounded-bottom border' style='margin-top: -1px;' id='editor' v-html='renderedEditDocument'>
          </div>
        </div>
        <div class="tab-pane fade" id="text">
          <div v-html='renderedDocument' id='viewer'></div>
        </div>
        <div class="tab-pane fade" id="code">
          <pre style='white-space: pre-wrap; word-wrap: break-word;' class='line-num' v-html='rawDocument'></pre>
        </div>
      </div>
    </div>
    <div v-if='pageIndex==2' :key='2' class='container text-center'>
      <div v-if='uploading' class='small-box mx-auto mb-3'>
        <span>文章创建进度</span>
        <div class='progress my-2'>
          <div class='progress-bar progress-bar-animated progress-bar-striped' :style='{ width: createProgress * 100 + "%"}'></div>
        </div>
        <span>图片上传进度</span>
        <div class='progress my-2'>
          <div class='progress-bar progress-bar-animated progress-bar-striped' :style='{ width: imageProgress * 100 + "%"}'></div>
        </div>
        <span>文章上传进度</span>
        <div class='progress my-2'>
          <div class='progress-bar progress-bar-animated progress-bar-striped' :style='{ width: uploadProgress * 100 + "%"}'></div>
        </div>
      </div>
      <button type='button' class='btn btn-outline-primary' v-else @click='startUpload'>上传文章</button>
      <span v-if='uploaded'>
          上传文章完成! <a :href='articleDetailHref'>预览文章</a>
        </span>
    </div>
  </transition-group>
  <input type='file' style='display: none' id='file' @change='imageSelected' multiple>
  <div class="modal fade" id="linkModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">添加链接</h5>
          <button type="button" class="close" data-dismiss="modal">
            <span>&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <span>链接信息:</span>
          <input type='text' class='form-control input-list-head mt-3' v-model='linkText' placeholder="链接文本">
          <input type='text' class='form-control input-list-foot mb-3' v-model='linkTarget' placeholder="链接目标">
          <span>注: 网址前请加 http:// 或 https:// 前缀</span><br>
          <span>链接将会添加至最下方的 paragraph 元素中</span>
        </div>
        <div class="modal-footer">
          <input type="button" class="btn btn-secondary" data-dismiss="modal" value='取消'>
          <input type="button" class="btn btn-primary" data-dismiss="modal" value='添加' @click='doNewLink'
                 :disabled='!canAddLink'>
        </div>
      </div>
    </div>
  </div>
  <div class="modal fade" id="imageModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">选择图片</h5>
          <button type="button" class="close" data-dismiss="modal">
            <span>&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <div class='d-flex flex-wrap border rounded' id='selector'>
            <img :src='x.dataURL' :width='imageWidth' v-for='x in images' alt='thumbnail' style='cursor: pointer'
                 :class='{ "album-thumbnail-border": x.selected }' class='border-dark m-1' @click='toggleSelect(x)'>
          </div>
          <input type='text' v-model='imageDesc' class='form-control mt-3' placeholder="图片描述">
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">取消</button>
          <button type="button" class="btn btn-primary" data-dismiss="modal" @click='doNewImage' :disabled='!canSelect'>确定</button>
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
    function WaitingFile(file) {
        this.file = file;
        this.reader = new FileReader();
        this.percent = 0;
        this.finished = false;
        this.error = false;
        this.dataURL = "";
        let _this = this;
        this.reader.onprogress = e => {
            _this.percent = e.loaded / e.total * 100;
        }
        this.reader.onload = () => {
            _this.finished = true;
            _this.dataURL = this.reader.result;
        }
        this.reader.onerror = () => {
            _this.error = true;
        }
        this.selected = false;
    }
    WaitingFile.prototype.load = function load() {
        this.reader.readAsDataURL(this.file);
    }
    WaitingFile.prototype.extension = function extension() {
        let parts = this.file.name.split('.');
        return parts[parts.length - 1]
    }
    var nodes = [];
    var updateElement = elm => {
        nodes[elm.dataset.id].innerText = elm.textContent;
        app.renderDocument();
    }
    var deleteElement = (span, id) => {
        app.document.documentElement.removeChild(nodes[id]);
        nodes.splice(id, 1);
        $("[data-id=" + id + "]").remove();
        $(span).remove();
        app.renderDocument();
    }
    var escapeXml = text => {
        while (text.includes("<")) text = text.replace("<", "&lt;");
        while (text.includes(">")) text = text.replace(">", "&gt;");
        return text;
    }
    $(() => {
        $("#linkModal").modal({
            show: false
        })
        $("#imageModal").modal({
            show: false
        }).on("shown.bs.modal", () => {
            app.imageWidth = $("#selector").width() / 5 - 8;
        })
    })
    var app = new Vue({
        el: "#app",
        data: {
            title: "",
            author: "",
            pageIndex: 0,
            images: [],
            document: new Document(),
            renderedDocument: "",
            renderedEditDocument: "",
            linkText: "",
            linkTarget: "",
            rawDocument: "",
            imageWidth: 84,
            imageDesc: "",
            uploading: false,
            uploaded: false,
            createProgress: 0,
            imageProgress: 0,
            uploadProgress: 0,
            id: ""
        },
        methods: {
            previousPage() {
                if (this.uploading) return;
                if (this.pageIndex === 0) return;
                this.pageIndex--;
            },
            nextPage() {
                if (this.uploading) return;
                if (this.pageIndex === 2) return;
                if (this.pageIndex === 0 &&
                    ((this.title = this.title.trim()) === "" || this.images.some(f => !f.finished))) return;
                this.pageIndex++;
            },
            selectImage() {
                $("#file").click();
            },
            imageSelected() {
                let el = $("#file");
                let files = el[0].files;
                let created = [];
                for (let file of files) {
                    if (file.type.startsWith("image/")) {
                        created.push(new WaitingFile(file));
                    }
                }
                created.forEach(f => f.load());
                this.images = [...this.images, ...created];
                el.val("");
            },
            deleteImage(x) {
                this.images.splice(this.images.indexOf(x), 1);
            },
            renderDocument() {
                this.renderedDocument = this.renderedEditDocument = "";
                nodes = [];
                for (let node of this.document.documentElement.children) {
                    let div = document.createElement("div");
                    let span = document.createElement("span");
                    let el = this.renderEdit(node);
                    span.style.cursor = "pointer";
                    span.textContent = "×";
                    span.classList.add("text-danger", "mr-3");
                    span.setAttribute("onclick", "deleteElement(this, " + el.dataset.id + ")");
                    div.appendChild(span);
                    div.appendChild(el);
                    this.renderedEditDocument += div.outerHTML;
                    el.contentEditable = false;
                    this.renderedDocument += el.outerHTML;
                }
            },
            renderEdit(node) {
                let id = nodes.push(node) - 1;
                let el = null;
                if (node.tagName === 'headline') {
                    el = document.createElement('h3');
                    el.innerHTML = node.innerHTML.trim();
                    el.classList.add("mx-auto");
                    el.contentEditable = true;
                }
                else if (node.tagName === 'paragraph') {
                    el = document.createElement('p');
                    el.innerHTML = node.innerHTML.trim();
                    el.contentEditable = true;
                }
                else if (node.tagName === 'image') {
                    el = document.createElement('div');
                    let img = document.createElement('img');
                    img.src = this.images[node.getAttribute("index")].dataURL;
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
                    el.contentEditable = true;
                }
                el.dataset.id = id.toString();
                el.setAttribute('onblur', 'updateElement(this)');
                return el;
            },
            newParagraph() {
                let para = this.document.createElement("paragraph");
                para.innerHTML = "在此输入段落";
                this.document.documentElement.appendChild(para);
                this.renderDocument();
            },
            newHeadline() {
                let headline = this.document.createElement("headline");
                headline.innerHTML = "在此输入标题";
                this.document.documentElement.appendChild(headline);
                this.renderDocument();
            },
            newLink() {
                $("#linkModal").modal('show');
            },
            newImage(){
                $("#imageModal").modal('show');
            },
            doNewImage(){
                let index = this.images.findIndex(i => i.selected);
                this.images.forEach(i => i.selected = false);
                let image = this.document.createElement("image");
                image.setAttribute("index", index.toString());
                image.setAttribute("desc", this.imageDesc);
                this.document.documentElement.appendChild(image);
                this.renderDocument();
                $("#imageModal").modal('hide');
            },
            doNewLink() {
                let link = this.document.createElement("a");
                link.textContent = this.linkText.trim();
                link.setAttribute('href', this.linkTarget.trim());
                let paragraphs = this.document.getElementsByTagName("paragraph");
                let lastPara;
                if (paragraphs.length <= 0) {
                    lastPara = this.document.createElement('paragraph');
                    this.document.documentElement.appendChild(lastPara);
                }
                else lastPara = paragraphs[paragraphs.length - 1];
                lastPara.appendChild(link);
                this.renderDocument();
            },
            updateRawDocument() {
                let doc = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<article>\n";
                for (let node of this.document.documentElement.children) {
                    if (node.tagName === 'paragraph') {
                        doc += "    <paragraph>\n        ";
                        doc += node.innerHTML.trim();
                        doc += "\n    </paragraph>\n"
                    }
                    else if (node.tagName === 'image') {
                        doc += "    <image index=\"";
                        doc += node.getAttribute('index');
                        doc += "\" desc=\""
                        doc += node.getAttribute('desc');
                        doc += "\"/>\n";
                    }
                    else if (node.tagName === 'headline') {
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
                for (let line of doc.split("\n")) {
                    html += "<div class='line'><div>" + escapeXml(line) + "</div></div>"
                }
                this.rawDocument = html;
            },
            clearDocument(){
                if (!confirm("确定要清除文档吗?")) return;
                this.document = new Document();
                this.initDocument();
            },
            initDocument(){
                this.document.appendChild(this.document.createElement("article"));
                let title = this.document.createElement("headline");
                title.innerHTML = "在此输入标题";
                this.document.documentElement.appendChild(title);
                let para = this.document.createElement("paragraph");
                para.innerHTML = "在此输入段落";
                this.document.documentElement.appendChild(para);
                this.renderDocument();
            },
            toggleSelect(x){
                this.images.forEach(i => i.selected = false);
                x.selected = true;
            },
            startUpload(){
                this.uploading = true;
                utils.createArticle(this.title, data => {
                    let _this = app;
                    _this.id = data.id;
                    _this.createProgress = 1;
                    _this.createFinished();
                })
            },
            createFinished(){
                if (this.images.length <= 0) {
                    this.imageProgress = 1;
                    this.imageFinished();
                    return;
                }
                let index = 0;
                let callback = data => {
                    index++;
                    let _this = app;
                    _this.imageProgress += 1/_this.images.length;
                    if (index >= _this.images.length) {
                        _this.imageFinished();
                        return;
                    }
                    let next = _this.images[index];
                    utils.putArticleImage(_this.id, next.extension(), next.dataURL.split(",", 2)[1], callback);
                }
                utils.putArticleImage(this.id, this.images[0].dataURL.split(",", 2)[1], callback);
            },
            imageFinished(){
                let doc = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<article>\n";
                for (let node of this.document.documentElement.children) {
                    if (node.tagName === 'paragraph') {
                        doc += "    <paragraph>\n        ";
                        doc += node.innerHTML.trim();
                        doc += "\n    </paragraph>\n"
                    }
                    else if (node.tagName === 'image') {
                        doc += "    <image index=\"";
                        doc += node.getAttribute('index');
                        doc += "\" desc=\""
                        doc += node.getAttribute('desc');
                        doc += "\"/>\n";
                    }
                    else if (node.tagName === 'headline') {
                        doc += "    <headline>";
                        doc += node.innerHTML.trim();
                        doc += "</headline>\n"
                    }
                    else {
                        doc += "    " + node.outerHTML + "\n";
                    }
                }
                doc += "</article>";
                utils.putContent(this.id, doc, data => {
                    this.uploadProgress = 1;
                    this.uploadFinished();
                });
            },
            uploadFinished(){
                this.uploaded = true;
            }
        },
        computed: {
            canAddLink() {
                return this.linkText.trim() !== "" && this.linkTarget.trim() !== "";
            },
            hasImage(){
                return this.images.length > 0;
            },
            canSelect(){
                return this.images.some(i => i.selected) && this.imageDesc.trim() !== "";
            },
            articleDetailHref(){
                return "/article/detail.jsp?id=" + this.id;
            }
        },
        mounted() {
            this.initDocument();
        }
    })
    utils.checkLogin(data => {
      app.author = data.username;
    })
</script>
</body>

</html>
