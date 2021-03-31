(function (W) {
    W.ERROR_SUCCESS = 0;
    W.ERROR_INCORRECT_USER = 1;
    W.ERROR_ALREADY_LOGGED = 2;
    W.ERROR_NOT_LOGGED_YET = 3;
    W.ERROR_MISSING_ALBUM = 4;
    W.ERROR_INVALID_INDEX = 5;
    W.ERROR_ALBUM_ALREADY_EXISTS = 6;
    W.ERROR_FILENAME_USED = 7;
    W.ERROR_ACCESS_DENIED = 8;
    W.pages = {
        '/': 0,
        '/login': 0,
        '/album': 1,
        '/album/index.jsp': 1,
        '/album/detail.jsp': 1,
        '/album/upload.jsp': 2,
        '/article': 1,
        '/article/index.jsp': 1,
        '/article/detail.jsp': 1,
        '/article/post.jsp': 2,
        '/admin.jsp': 3
    }
    W.parseQueryString = qs => {
        if (!qs) {
            qs = window.location.search;
            if (!qs) return {};
        }
        if (qs.startsWith('?')) qs = qs.substr(1);
        let parsed = {};
        qs.split('&').map(value => value.split('=')).forEach(value => {
            parsed[value[0]] = window.decodeURIComponent(value[1]);
        })
        return parsed;
    }
    W.getPageLevel = path => {
        if (!path.startsWith('/')) path = '/' + path;
        if (path.endsWith('/')) path = path.substr(0, path.length - 1);
        let level = W.pages[path];
        if (typeof level == 'undefined') level = 0;
        return level;
    }
    W.performLogin = (username, password, callback) => {
        $.ajax("/login/login", {
            method: 'POST',
            data: {
                type: "login",
                username: username,
                password: W.sha256digest(password)
            },
            success: callback
        })
    }
    W.checkLogin = callback => {
        $.ajax("/login/login", {
            method: 'POST',
            data: {
                type: 'check'
            },
            success: callback
        })
    }
    W.performLogout = callback => {
        $.ajax("/login/login", {
            method: 'POST',
            data: {
                type: 'logout'
            },
            success: callback
        })
    }
    W.performGuest = callback => {
        $.ajax("/login/login", {
            method: 'POST',
            data: {
                type: 'guest'
            },
            success: callback
        })
    }
    W.changePassword = (oldPassword, newPassword, callback) => {
        $.ajax("/login/login", {
            method: 'POST',
            data: {
                type: 'change',
                oldPassword: W.sha256digest(oldPassword),
                newPassword: W.sha256digest(newPassword)
            },
            success: callback
        })
    }
    W.sha256digest = msg => CryptoJS.SHA256(msg).toString(CryptoJS.enc.Base64);
    W.listAlbums = callback => {
        $.ajax("/album/album", {
            method: 'GET',
            data: {
                type: 'list'
            },
            success: callback
        })
    }
    W.getAlbum = (albumName, callback) => {
        $.ajax("/album/album", {
            method: 'GET',
            data: {
                type: 'get',
                name: albumName
            },
            success: callback
        })
    }
    W.getTagUsage = (tagName, callback) => {
        $.ajax("/album/album", {
            method: 'GET',
            data: {
                type: 'usage',
                tag: tagName
            },
            success: callback
        })
    }
    W.createAlbum = (albumName, date, tags, callback) => {
        $.ajax("/album/album", {
            method: 'POST',
            data: {
                type: 'create',
                name: albumName,
                date: date,
                tags: tags
            },
            success: callback
        })
    }
    W.deleteAlbum = (albumName, callback) => {
        $.ajax("/album/album", {
            method: 'POST',
            data: {
                type: 'delete',
                name: albumName
            },
            success: callback
        })
    }
    W.putImage = (albumName, fileName, data, callback) => {
        $.ajax("/album/album", {
            method: 'POST',
            data: {
                type: 'put',
                name: albumName,
                filename: fileName,
                data: data
            },
            success: callback
        })
    }
    W.deleteImage = (albumName, index, callback) => {
        $.ajax("/album/album", {
            method: 'POST',
            data: {
                type: 'pop',
                name: albumName,
                index: index
            },
            success: callback
        })
    }
    W.checkLocked = (albumName, callback) => {
        $.ajax("/album/album", {
            method: 'GET',
            data: {
                type: 'locked',
                name: albumName
            },
            success: callback
        })
    }
    W.lock = (albumName, callback) => {
        $.ajax("/album/album", {
            method: 'POST',
            data: {
                type: 'lock',
                name: albumName
            },
            success: callback
        })
    }
    W.unlock = (albumName, callback) => {
        $.ajax("/album/album", {
            method: 'POST',
            data: {
                type: 'unlock',
                name: albumName
            },
            success: callback
        })
    }
    W.deleteAlbumRequest = (albumName, reason, callback) => {
        $.ajax("/misc", {
            method: 'POST',
            data: {
                type: 'create_request',
                category: 1,
                name: albumName,
                reason: reason
            },
            success: callback
        })
    }
    W.deleteArticleRequest = (articleId, reason, callback) => {
        $.ajax("/misc", {
            method: 'POST',
            data: {
                type: 'create_request',
                category: 2,
                id: articleId,
                reason: reason
            },
            success: callback
        })
    }
    W.latestAlbum = callback => {
        $.ajax("/album/album", {
            method: 'GET',
            data: {
                type: 'latest'
            },
            success: callback
        })
    }
    W.latestArticle = callback => {
        $.ajax("/article/article", {
            method: 'GET',
            data: {
                type: 'latest'
            },
            success: callback
        })
    }
    W.listRecords = callback => {
        $.ajax("/misc", {
            method: 'GET',
            data: {
                type: 'list_records'
            },
            success: callback
        })
    }
    W.fulfillRequest = (id, callback) => {
        $.ajax("/misc", {
            method: 'POST',
            data: {
                type: 'fulfill_request',
                id: id
            },
            success: callback
        })
    }
    W.deleteRequest = (id, callback) => {
        $.ajax("/misc", {
            method: 'POST',
            data: {
                type: 'delete_request',
                id: id
            },
            success: callback
        })
    }
    W.listArticles = callback => {
        $.ajax("/article/article", {
            method: 'GET',
            data: {
                type: 'list'
            },
            success: callback
        })
    }
    W.getArticle = (id, callback) => {
        $.ajax("/article/article", {
            method: 'GET',
            data: {
                type: 'get',
                id: id
            },
            success: callback
        })
    }
    W.articleContent = (id, callback) => {
        $.ajax("/article/article", {
            method: 'GET',
            data: {
                type: 'content',
                id: id
            },
            success: callback
        })
    }
    W.createArticle = (title, callback) => {
        $.ajax("/article/article", {
            method: 'POST',
            data: {
                type: 'create',
                title: title
            },
            success: callback
        })
    }
    W.putArticleImage = (id, extension, base64, callback) => {
        $.ajax("/article/article", {
            method: 'POST',
            data: {
                type: 'put',
                data: base64,
                id: id,
                extension: extension
            },
            success: callback
        })
    }
    W.putContent = (id, content, callback) => {
        $.ajax("/article/article", {
            method: 'POST',
            data: {
                type: 'content',
                content: content,
                id: id
            },
            success: callback
        })
    }
    W.deleteArticle = (id, callback) => {
        $.ajax("/article/article", {
            method: 'POST',
            data: {
                type: 'delete',
                id: id
            },
            success: callback
        })
    }
    W.getCarousels = callback => {
        $.ajax("/misc", {
            method: 'GET',
            data: {
                type: 'list_carousels'
            },
            success: callback
        })
    }
    W.getUsers = callback => {
        $.ajax("/misc", {
            method: 'GET',
            data: {
                type: 'list_users'
            },
            success: callback
        })
    }
    W.blacklist = (username, callback) => {
        $.ajax("/misc", {
            method: 'POST',
            data: {
                type: 'blacklist_user',
                username: username
            },
            success: callback
        })
    }
    W.whitelist = (username, callback) => {
        $.ajax("/misc", {
            method: 'POST',
            data: {
                type: 'whitelist_user',
                username: username
            },
            success: callback
        })
    }
    W.listRequests = callback => {
        $.ajax("/misc", {
            method: 'GET',
            data: {
                type: 'list_requests'
            },
            success: callback
        })
    }
    W.putCarousel = (title, desc, fileName, data, callback) => {
        $.ajax("/misc", {
            method: 'POST',
            data: {
                type: 'put_carousel',
                title: title,
                description: desc,
                filename: fileName,
                data: data
            },
            success: callback
        })
    }
    W.deleteCarousel = (id, callback) => {
        $.ajax("/misc", {
            method: 'POST',
            data: {
                type: 'delete_carousel',
                id: id
            },
            success: callback
        })
    }
    W.listDomains = callback => {
        $.ajax("/misc", {
            method: 'GET',
            data: {
                type: 'list_domains'
            },
            success: callback
        })
    }
    W.addDomain = (domainName, path, space, callback) => {
        $.ajax("/misc", {
            method: 'POST',
            data: {
                type: 'put_domain',
                name: domainName,
                path: path,
                space: space.toString()
            },
            success: callback
        })
    }
    W.deleteDomain = (domainName, callback) => {
        $.ajax("/misc", {
            method: 'POST',
            data: {
                type: 'delete_domain',
                name: domainName
            },
            success: callback
        })
    }
    W.listOptions = callback => {
        $.ajax("/misc", {
            method: 'GET',
            data: {
                type: 'list_options'
            },
            success: callback
        })
    }
    W.toggleOption = (optionName, value, callback) => {
        $.ajax("/misc", {
            method: 'POST',
            data: {
                type: 'toggle_option',
                name: optionName,
                value: value.toString()
            },
            success: callback
        })
    }
    W.listResources = callback => {
        $.ajax("/misc", {
            method: 'GET',
            data: {
                type: 'list_resources'
            },
            success: callback
        })
    }
    W.listFiles = callback => {
        $.ajax("/space/space", {
            method: 'GET',
            data: {
                type: 'list'
            },
            success: callback
        })
    }
    W.getFile = (fileName, callback) => {
        $.ajax("/space/space", {
            method: 'GET',
            data: {
                type: 'get',
                name: fileName
            },
            success: callback
        })
    }
    W.verifyPassword = (fileName, password, callback) => {
        $.ajax("/space/space", {
            method: 'POST',
            data: {
                type: 'verify',
                name: fileName,
                password: W.sha256digest(password)
            },
            success: callback
        })
    }
    W.deleteFile = (fileName, callback) => {
        $.ajax("/space/space", {
            method: 'POST',
            data: {
                type: 'delete',
                name: fileName
            },
            success: callback
        })
    }
    W.md5digest = value => {
        return CryptoJS.MD5(value).toString();
    }
    W.buffer2base64 = buffer => {
        return CryptoJS.lib.WordArray.create(buffer).toString(CryptoJS.enc.Base64);
    }
})(this.utils = {});