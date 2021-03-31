<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>

<head>
  <title>Public Space</title>
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
      <b>公共空间</b>
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
      <div class='col-md-3 py-1'>
        <form @submit='formSubmit' class='bg-white p-3 border rounded'>
          <span>按名称搜索:</span>
          <input type='text' class='form-control mt-2 mb-1' v-model='byName'>
          <span>按系列搜索:</span>
          <input type='text' class='form-control mt-2 mb-1' v-model='bySeries'>
          <span>按标签搜索:</span>
          <div class='mt-2 d-flex flex-wrap justify-content-around'>
              <span v-for='x in tags' class='badge border' :class='[x.selected ? "badge-secondary" : "badge-light"]'
                    @click='toggleTag(x)' style='cursor: pointer'>
                {{x.name}}
              </span>
          </div>
          <input type='submit' class='btn btn-block btn-outline-primary mt-3' value='提交'>
          <input type='button' class='btn btn-block btn-outline-secondary mt-1' value='清除' @click='clearSearch'>
        </form>
      </div>
      <div class='col-md-9 py-1'>
        <transition name='fly' appear>
          <div v-if='!ready'>
            <span class='spinner-grow text-info'></span>
            <span>请稍候...</span>
          </div>
        </transition>
        <transition name='slide-fade-vertical'>
          <div v-if='ready'>
            <a class='btn btn-light btn-block' href='upload.jsp'
               style='border: 2px dashed; height: 60px; font-size: 1.8rem'>+</a><br>
            <h5>系列:</h5>
            <div class='mb-3'>
              <div v-if='!hasSeries' class='alert alert-warning'>
                没有可用的系列。
              </div>
              <div id='accordion'>
                <div class="card" v-for='x in filterSeries'>
                  <div class="card-header">
                    <a class="card-link" data-toggle="collapse" :href="'#' + x.name">
                      {{x.name}}
                    </a>
                  </div>
                  <div :id="x.name" class="collapse" data-parent="#accordion">
                    <div class='card-body d-flex flex-wrap' v-if='seriesHasFile(x)'>
                      <div class='p-2' v-for='f in x.files'>
                        <div class='card shadow-hover'>
                          <div class='card-body'>
                            <span class='card-title'>文件名: {{f.name}}</span><br>
                            <span>标签: <span class='badge badge-secondary'>{{f.tag}}</span></span>
                            <hr>
                            <a :href='fileUrl(f)'>查看文件</a>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div v-if='!seriesHasFile(x)' class='alert alert-warning m-2'>
                      没有可用的文件。
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <h5>单个文件:</h5>
            <div class='d-flex flex-wrap' v-if='hasFiles'>
              <div class='p-2 flex-fill' v-for='x in filterFiles'>
                <div class='card shadow-hover'>
                  <div class='card-body'>
                    <span class='card-title'>文件名: {{x.name}}</span><br>
                    <span>标签: <span class='badge badge-secondary'>{{x.tag}}</span></span>
                    <hr>
                    <a :href='fileUrl(x)'>查看文件</a>
                  </div>
                </div>
              </div>
            </div>
            <div class='alert alert-warning' v-if='!hasFiles'>
              没有可用的文件。
            </div>
          </div>
        </transition>
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
    function Tag(name){
        this.name = name;
        this.selected = false;
    }
    function Filter(name, series, tags){
        this.name = name;
        this.series = series;
        this.tags = tags;
    }
    Filter.prototype.doSeries = function doSeries(series){
        if (this.series && series.name !== this.series) return {
            name: series.name,
            files: []
        };
        let newSeries = { name: series.name, files: []}
        for (let file of series.files){
            if (file.name.includes(this.name) && (!this.tags.length || this.tags.includes(file.tag))) newSeries.files.push(file);
        }
        return newSeries;
    }
    Filter.prototype.doSingle = function doSingle(file){
        if (this.series) return false;
        return file.name.includes(this.name) && (!this.tags.length || this.tags.includes(file.tag));
    }
    var app = new Vue({
        el: "#app",
        data: {
            tags: [
                "学习", "生活", "样例", "回执", "协议", "记录"
            ].map(t => new Tag(t)),
            currentTag: [],
            filterSeries: [],
            filterFiles: [],
            series: [],
            files: [],
            ready: false,
            byName: "",
            bySeries: ""
        },
        methods: {
            formSubmit(e){
                e.preventDefault();
                var filter = new Filter(this.byName, this.bySeries, this.currentTag);
                this.filterSeries = this.series.map(s => filter.doSeries(s));
                this.filterFiles = this.files.filter(f => filter.doSingle(f));
            },
            clearSearch(){
                this.byName = "";
                this.bySeries = "";
                this.currentTag = [];
                this.tags.forEach(t => t.selected = false);
                this.filterFiles = this.files;
                this.filterSeries = this.series;
            },
            toggleTag(x){
                x.selected = !x.selected;
                if (x.selected){
                    this.currentTag.push(x.name);
                }
                else{
                    this.currentTag.splice(this.currentTag.indexOf(x.name), 1);
                }
            },
            fileUrl(x){
                return "/space/detail.jsp?name=" + x.name
            },
            seriesHasFile(x){
                return x.files.length > 0;
            }
        },
        computed: {
            hasSeries(){
                return this.filterSeries.length > 0;
            },
            hasFiles(){
                return this.filterFiles.length > 0;
            }
        }
    })
    utils.listFiles(data => {
        app.filterFiles = app.files = data.data.files;
        app.filterSeries = app.series = data.data.series;
        app.ready = true;
    })
</script>
</body>

</html>
