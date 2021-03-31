<%@ page pageEncoding="utf-8" language="java"%>
<!DOCTYPE html>
<html>

<head>
  <title>Public File Details</title>
  <script src='/js/main.js'></script>
  <script src='/js/jquery-3.4.1.js'></script>
  <script src='/js/popper.js'></script>
  <script src='/js/bootstrap.js'></script>
  <script src='/js/vue.js'></script>
  <script src='/js/marked.js'></script>
  <script src='/js/cryptojs-core.js'></script>
  <script src='/js/cryptojs-enc-base64.js'></script>
  <script src='/js/cryptojs-sha256.js'></script>
  <link rel='stylesheet' href='/css/bootstrap.css'>
  <link rel='stylesheet' href='/css/main.css'>
</head>

<body class='bg-light'>
<header>
  <nav class="navbar navbar-expand-md navbar-light fixed-top bg-light py-0 shadow">
    <div class='nav-cover text-center text-dark'>
      <b>文件查看</b>
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
  <transition name='fly' appear>
    <div class='small-box mx-auto text-center' v-if='!ready'>
      <span class='spinner-grow text-info'></span>
      <span>请稍候...</span>
    </div>
  </transition>
  <transition name='slide-fade-vertical'>
    <div class='container alert alert-warning mx-auto' v-if='error'>
      加载文件错误。
    </div>
  </transition>
  <transition name='slide-fade-vertical'>
    <div class='container' v-if='ready && !error'>
      <div class='small-box text-center mx-auto'>
        <h5>文件名: {{file.name}}</h5>
        <span>文件扩展名: {{extensionOf(file.name)}}</span><br>
        <span>是否已加密: {{file.encrypted ? "是" : "否"}}</span><br>
        <span title='MD5 哈希摘要可以检验文件的完整性.'>MD5 哈希摘要: {{file.encrypted ? "保密" : file.digest}}</span><br>
        <button class='btn btn-outline-primary mt-2' @click='decryptAndDownload' type='button' v-if='file.encrypted'>下载文件</button>
        <a :href='downloadHref' class='btn btn-outline-primary mt-2' v-else>下载文件</a>
      </div>
      <hr>
      <div class="bg-white border rounded p-3">
        <div class='row'>
          <div class='col-md-6'>
            <span>验证 MD5:</span><br>
            <div class='alert alert-warning mt-3' v-if='file.encrypted'>
              该文件已加密，无法提供 MD5 摘要。
            </div>
            <div v-else>
              <code>$ CertUtil -hashfile "{{file.name}}" MD5<br>
                MD5 的 {{file.name}} 哈希:<br>
                {{file.digest}}<br>
                CertUtil: -hashfile 命令成功完成。
              </code><br>
              出现以上输出则说明文件完整。
            </div><br>
            <span>在其他页面中链接此文件:</span><br>
            <code>http://www.g2011.team/space/files/{{file.name}}</code><br>
            <span class='text-warning' v-if='file.encrypted'>
                注意: 不要直接下载此文件。<br>
                由于此文件经过 AES 算法加密，您的设备无法解析此文件。
              </span>
          </div>
          <div class='col-md-6'>
            预览:
            <div v-if='file.encrypted' class='alert alert-warning mt-3'>
              该文件已加密，无法提供预览。
            </div>
            <div v-else>
              <div v-if="canPreview">
                <transition name='fly' appear>
                  <div v-if='!previewReady'>
                    <span class='spinner-grow text-info'></span>
                    <span>请稍候...</span>
                  </div>
                </transition>
                <div v-html='renderedPreview' class='border rounded text-center p-3 mt-2' v-if='previewReady'></div>
              </div>
              <div v-else class="alert alert-warning mt-2">
                无可用预览。
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </transition>
  <div class="modal fade" tabindex="-1" id='passwordModal'>
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">输入密码</h5>
          <button type="button" class="close" data-dismiss="modal">
            <span>&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <span>解密密码:</span><br>
          <input type='password' class='form-control my-2' v-model='password'>
          <transition name='fly'>
            <div v-if='verifying'>
              <span class='spinner-border'></span>
              <span>请稍候...</span>
            </div>
          </transition>
          <span class='text-danger' v-if='verifyError'>密码错误。</span>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">取消</button>
          <button type="button" class="btn btn-primary" @click='submitPassword'>提交</button>
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
    $(() => {
        $("#passwordModal").modal({
            show: false
        })
    })
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
        'htm': 'frame',
        'html': 'frame',
        'sh': 'plain',
        'bash': 'plain',
        'zsh': 'plain',
        'md': 'markdown',
        'markdown': 'markdown',
        'mp3': 'audio',
        'wav': 'audio',
        'm4a': 'audio',
        'wma': 'audio',
        'flac': 'audio',
        'aac': 'audio',
        'mp4': 'video',
        'mkv': 'video',
        'rmvb': 'video',
        'avi': 'video',
        'wmv': 'video',
        'flv': 'video'
    }
    var qs = utils.parseQueryString();
    var canPreview = fileName => {
        let parts = fileName.split(".");
        if (parts.length <= 1) return false;
        let ext = parts[parts.length-1].toLowerCase();
        return typeMap[ext] !== undefined;
    }
    var needsFetch = fileName => {
        let parts = fileName.split(".");
        if (parts.length <= 1) return false;
        let ext = parts[parts.length-1].toLowerCase();
        let type = typeMap[ext];
        return type === 'plain' || type === 'markdown';
    }
    var app = new Vue({
        el: '#app',
        data:{
            file: {},
            ready: false,
            error: false,
            previewReady: false,
            renderedPreview: "",
            password: "",
            verifying: false,
            verifyError: false
        },
        methods:{
            submitPassword(){
                this.verifyError = false;
                this.verifying = true;
                utils.verifyPassword(this.file.name, this.password, data => {
                    let _this = app;
                    if (data.result){
                        location.assign("space?type=decrypt&password=" + _this.password + "&name=" + _this.file.name);
                    }
                    else{
                        _this.verifyError = true;
                    }
                    _this.verifying = false;
                })
            },
            extensionOf(name){
                let parts = name.split(".");
                if (parts.length <= 1) return "无"
                let ext = parts[parts.length-1].toLowerCase();
                let desc = extMap[ext];
                if (desc === undefined){
                    return ext;
                }
                else {
                    return ext + " (" + desc + ")";
                }
            },
            renderPreview(data){
                let parts = data.name.split(".");
                let ext;
                if (parts.length <= 1) ext = "";
                else ext = parts[parts.length-1].toLowerCase();
                var type = typeMap[ext];
                let el;
                if (type === undefined){
                    el = $("<div class='alert alert-warning'>没有可用的预览。</div>")[0];
                }
                else if (type === 'plain'){
                    el = document.createElement("pre");
                    el.style.whiteSpace = "pre-wrap";
                    el.style.wordWrap = "break-word";
                    el.innerText = data.content;
                }
                else if (type === 'image'){
                    el = document.createElement("img");
                    el.src = "files/" + data.name;
                    el.alt = "preview";
                    el.style.maxWidth = "100%";
                }
                else if (type === 'markdown'){
                    el = document.createElement("pre");
                    el.innerHTML = marked(data.content);
                    el.classList.add('text-left');
                }
                else if (type === 'audio'){
                    el = document.createElement("audio");
                    el.src = "files/" + data.name;
                    el.controls = true;
                }
                else if (type === 'video'){
                    el = document.createElement("video");
                    el.src = "files/" + data.name;
                }
                else if (type === 'frame'){
                    el = document.createElement("iframe");
                    el.src = "files/" + data.name;
                }
                this.renderedPreview = el.outerHTML;
                this.previewReady = true;
            },
            decryptAndDownload(){
                $("#passwordModal").modal('show');
            }
        },
        computed: {
            downloadHref(){
                return 'files/' + this.file.name;
            },
            canPreview(){
                return canPreview(this.file.name);
            }
        }
    })
    utils.getFile(qs.name, data => {
        if (data.success){
            app.file = data.data;
            app.ready = true;
            if (!data.data.encrypted && canPreview(data.data.name)){
                if (needsFetch(data.data.name)){
                    $.ajax("files/" + data.data.name, {
                        method: 'GET',
                        success(content){
                            app.renderPreview({
                                name: data.data.name,
                                content: content
                            });
                        }
                    })
                }
                else {
                    app.renderPreview(data.data);
                }
            }
        }
        else{
            app.ready = true;
            app.error = true;
        }
    })
</script>
</body>

</html>