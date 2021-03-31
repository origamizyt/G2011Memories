<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>

<head>
  <title>Public File Upload</title>
  <script src='/js/main.js'></script>
  <script src='/js/jquery-3.4.1.js'></script>
  <script src='/js/popper.js'></script>
  <script src='/js/bootstrap.js'></script>
  <script src='/js/vue.js'></script>
  <script src='/js/marked.js'></script>
  <script src='/js/cryptojs-core.js'></script>
  <script src='/js/cryptojs-md5.js'></script>
  <script src='/js/cryptojs-typedarrays.js'></script>
  <script src='/js/cryptojs-enc-base64.js'></script>
  <link rel='stylesheet' href='/css/bootstrap.css'>
  <link rel='stylesheet' href='/css/main.css'>
</head>

<body class='bg-light'>
<header>
  <nav class="navbar navbar-expand-md navbar-light fixed-top bg-light py-0 shadow">
    <div class='nav-cover text-center text-dark'>
      <b>文件上传</b>
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
  <div class='container'>
    <div class='row'>
      <div class='col-md-4'>
        <form @submit='formSubmit' class='border rounded m-1 p-3'>
          <input type='file' style='display: none;' id='file' @change='fileSelected'>
          <input type='button' class='btn btn-outline-secondary btn-block mb-3' value='选择文件' @click='selectFile'>
          <ul class='list-group' style='word-wrap: break-word;'>
            <li class='list-group-item'>文件名: {{file.name}}</li>
            <li class='list-group-item'>扩展名: {{extensionOf(file.name)}}</li>
            <li class='list-group-item'>文件大小: {{formatSize(file.size)}}</li>
            <li class='list-group-item'>修改日期: {{file.lastModifiedDate.toLocaleString()}}</li>
            <li class='list-group-item'>MD5 哈希摘要: {{digest}}</li>
          </ul>
          <div class='d-flex flex-wrap justify-content-around mt-2'>
              <span class='badge border' :class='[x.selected ? "badge-secondary": "badge-light"]'
                    v-for='x in tags' style='cursor: pointer;' @click='toggleTag(x)'>{{x.name}}</span>
          </div>
          <div class="form-check mt-2 form-check-inline">
            <input class="form-check-input" type="checkbox" id="encrypt" v-model='encrypt'>
            <label class="form-check-label" for="encrypt" title="加密后，其他人必须输入密码以下载。">加密文件</label>
          </div>
          <div class="form-check mt-2 form-check-inline">
            <input class="form-check-input" type="checkbox" id="hasSeries" v-model='hasSeries'>
            <label class="form-check-label" for="hasSeries">加入系列</label>
          </div>
          <input type='password' placeholder="密码" v-if='encrypt' v-model='password' class='form-control mt-1'>
          <input type='text' placeholder="系列" v-if='hasSeries' v-model='series' class='form-control mt-1'>
          <input type="submit" value='提交文件' class='btn btn-outline-primary btn-block mt-3' :disabled='!isFileSelected || !tagValid || encrypt && !passwordValid || hasSeries && !seriesValid || uploading'>
          <div class='d-flex mt-2'>
            <div class='progress mt-2 flex-grow-1'>
              <div class='progress-bar progress-bar-striped progress-bar-animated bg-success' :style='{ width: progress + "%"}'></div>
            </div>
            <div v-if='uploading' class='ml-2'>
              <span class='spinner-border'></span>
            </div>
          </div>
          <div class='mt-2' v-if='uploadError'>
            <span class='text-danger'>{{uploadErrorMessage}}</span>
          </div>
        </form>
      </div>
      <div class='col-md-8'>
        <div class='m-1 p-3 border rounded'>
          <span>文件预览:</span>
          <div v-if='!isFileSelected' class='alert alert-warning mt-2'>请选择文件。</div>
          <transition name='fly'>
            <div v-if='isFileSelected & !previewReady' class='mt-2'>
              <span class='spinner-grow text-info'></span>
              <span>请稍等...</span>
            </div>
          </transition>
          <div v-if='isFileSelected && previewReady' class='mt-2' v-html='renderedPreview'></div>
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
    var extMap = {
        'txt': '文本文件',
        'doc': 'Microsoft Word 文档',
        'docx': 'Microsoft Word 文档',
        'xls': 'Microsoft Excel 表格',
        'xlsx': 'Microsoft Excel 表格',
        'ppt': 'Microsoft PowerPoint 演示文稿',
        'pptx': 'Microsoft PowerPoint 演示文稿',
        'pdf': 'PDF 文档',
        'json': 'JSON 文档',
        'xml': 'XML 文档',
        'jpg': 'JPEG 图片',
        'jpeg': 'JPEG 图片',
        'png': 'PNG 图片',
        'gif': 'GIF 图片',
        'bmp': 'Bitmap 位图',
        'htm': 'HTML 页面',
        'html': 'HTML 页面',
        'url': 'URL 链接',
        'exe': 'Windows 应用程序',
        'app': 'MacOS 应用程序',
        'bat': 'Windows 批处理文件',
        'cmd': 'Windows 命令文件',
        'com': 'Windows 旧版应用程序',
        'pif': 'Windows 应用程序快捷方式',
        'sh': 'UNIX Shell 命令',
        'bash': 'UNIX Bash 命令',
        'zsh': 'UNIX Zsh 命令',
        'md': 'Markdown 标注',
        'markdown': 'Markdown 标注',
        'zip': 'ZIP 压缩文件',
        'bz2': 'BZIP 压缩文件',
        'gz': 'GZIP 压缩文件',
        'tar': 'TAR 归档文件',
        'rar': 'WinRAR 压缩文件',
        'svg': 'SVG 矢量图',
        'mp3': 'MP3 音频',
        'wav': 'WAV 音频',
        'm4a': 'M4A 音频',
        'mp4': 'MP4 视频',
        'mkv': 'MKV 视频',
        'rmvb': 'RMVB 视频',
        'wma': 'Windows Media 音频',
        'flac': 'FLAC 音频',
        'aac': 'AAC 音频',
        'avi': 'AVI 视频',
        'wmv': 'Windows Media 视频',
        'flv': 'FLV 视频'
    }
    var typeMap = {
        'txt': 'plain',
        'json': 'plain',
        'xml': 'plain',
        'jpg': 'image',
        'jpeg': 'image',
        'png': 'image',
        'gif': 'image',
        'svg': 'image',
        'bmp': 'image',
        'sh': 'plain',
        'bash': 'plain',
        'zsh': 'plain',
        'md': 'markdown',
        'markdown': 'markdown'
    }
    var canPreview = fileName => {
        let parts = fileName.split(".");
        if (parts.length <= 1) return false;
        let ext = parts[parts.length - 1].toLowerCase();
        return typeMap[ext] !== undefined;
    }
    var formatSize = size => {
        if (size <= 0) return "请选择文件";
        if (size <= 1024) return size.toString() + " B";
        else if (size <= 1024*1024) return (size/1000).toFixed(1) + "KB";
        else return (size /1000 /1000).toFixed(1) + " MB";
    }
    var buffer2wordArray = buffer => {
        return CryptoJS.lib.WordArray.create(buffer);
    }
    function Tag(name){
        this.name = name;
        this.selected = false;
    }
    var app = new Vue({
        el: '#app',
        data: {
            file: {
                name: "请选择文件",
                size: -1,
                lastModifiedDate: "请选择文件"
            },
            isFileSelected: false,
            renderedPreview: "",
            previewReady: false,
            progress: 0,
            password: "",
            encrypt: false,
            hasSeries: false,
            series: "",
            binaryContent: "",
            digest: "请选择文件",
            uploading: false,
            uploadError: false,
            uploadErrorMessage: "",
            tags: [
                "学习", "生活", "样例", "回执", "协议", "记录"
            ].map(t => new Tag(t)),
            currentTag: ""
        },
        methods: {
            formatSize(size){
                if (size < 0) return "请选择文件";
                else if (size <= 1024) return size.toString() + " B";
                else if (size <= 1024*1024) return (size/1000).toFixed(1) + "KB";
                else return (size /1000 /1000).toFixed(1) + " MB";
            },
            formSubmit(e){
                e.preventDefault();
                this.startUploading();
            },
            selectFile(){
                $("#file").click();
            },
            fileSelected(){
                this.uploadError = false;
                let file = $("#file")[0].files[0];
                if (file === undefined) return;
                if (file.size >= 1024*1024*50){
                    this.uploadError = true;
                    this.uploadErrorMessage = "文件过大。请上传 50MB 以内的文件。";
                    return;
                }
                this.file = file;
                this.isFileSelected = true;
                this.loadContent();
            },
            extensionOf(name) {
                let parts = name.split(".");
                if (parts.length <= 1) return "无"
                let ext = parts[parts.length - 1].toLowerCase();
                let desc = extMap[ext];
                if (desc === undefined) {
                    return ext;
                }
                else {
                    return ext + " (" + desc + ")";
                }
            },
            renderPreview(data) {
                let parts = data.name.split(".");
                let ext;
                if (parts.length <= 1) ext = "";
                else ext = parts[parts.length - 1].toLowerCase();
                var type = typeMap[ext];
                let el;
                if (type === undefined) {
                    el = $("<div class='alert alert-warning'>没有可用的预览。</div>")[0];
                }
                else if (type === 'plain') {
                    el = document.createElement("pre");
                    el.style.whiteSpace = "pre-wrap";
                    el.style.wordWrap = "break-word";
                    el.innerText = data.content;
                }
                else if (type === 'image') {
                    el = document.createElement("img");
                    el.src = data.content;
                    el.alt = "preview";
                    el.style.maxWidth = "100%";
                }
                else if (type === 'markdown') {
                    el = document.createElement("pre");
                    el.innerHTML = marked(data.content);
                    el.classList.add('text-left');
                }
                this.renderedPreview = el.outerHTML;
                this.previewReady = true;
            },
            loadContent(){
                let binary = new FileReader();
                binary.onloadend = () => {
                    app.binaryContent = binary.result;
                    app.digest = utils.md5digest(buffer2wordArray(binary.result));
                }
                binary.readAsArrayBuffer(this.file);
                let parts = this.file.name.split(".");
                if (parts.length <= 1) return;
                let ext = parts[parts.length - 1].toLowerCase();
                ext = typeMap[ext];
                let reader = new FileReader();
                reader.onload = () => {
                    var e = { name: app.file.name, content: reader.result };
                    app.renderPreview(e);
                };
                if (ext === 'image'){
                    reader.readAsDataURL(this.file);
                }
                else if (ext === 'plain' || ext === 'markdown'){
                    reader.readAsText(this.file);
                }
                else this.renderPreview({ name: this.file.name });
            },
            startUploading(){
                this.progress = 0;
                this.uploading = true;
                this.uploadError = false;
                this.uploadErrorMessage = "";
                let socket = new WebSocket("ws://" + location.host + "/space/put");
                let chunkcount = Math.ceil(this.file.size / 4096);
                socket.onopen = () => {
                    socket.send(JSON.stringify({
                        name: app.file.name,
                        digest: app.digest,
                        encrypted: app.encrypt,
                        password: app.password,
                        series: app.hasSeries ? app.series: null,
                        tag: app.currentTag,
                        count: chunkcount
                    }))
                }
                socket.onmessage = e => {
                    let data = JSON.parse(e.data);
                    if (!data.success) {
                        app.uploading = false;
                        app.uploadError = true;
                        if (data.error === 15) // ERROR_FILE_INTEGRITY_FAIL
                            app.uploadErrorMessage = "文件完整性受损。";
                        else if (data.error === 16) // ERROR_FILE_ALREADY_EXISTS
                            app.uploadErrorMessage = "文件已经存在。";
                        else
                            app.uploadErrorMessage = "上传错误。";
                        return;
                    }
                    app.progress += 100/(chunkcount+1);
                    if (!app.binaryContent.byteLength){
                        app.uploading = false;
                        return;
                    }
                    let bdata = app.binaryContent.slice(0, 4096);
                    app.binaryContent = app.binaryContent.slice(4096);
                    socket.send(utils.buffer2base64(bdata));
                }
                socket.onclose = e => {
                    app.uploading = false;
                    if (e.code === 1000) {
                        location.assign("/space/detail.jsp?name=" + app.file.name);
                    }
                }
            },
            toggleTag(x){
                this.tags.forEach(t => t.selected = false);
                x.selected = true;
                this.currentTag = x.name;
            }
        },
        computed: {
            passwordValid(){
                return this.password.trim() !== "";
            },
            seriesValid(){
                return this.series.trim() !== "";
            },
            tagValid(){
                return this.currentTag !== "";
            }
        }
    })
</script>
</body>

</html>