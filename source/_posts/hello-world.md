---
title: Hello World
abbrlink: 4a17b156

tags:
  - program
  - diary
  - web


---

  <%-
    popular_posts_json({ maxCount: 5 , ulClass: 'popular-posts' , PPMixingRate: 0.0 , isImage: true} , post )
  %>

Welcome to [Hexo](https://hexo.io/)! This is your very first post. Check [documentation](https://hexo.io/docs/) for more info. If you get any problems when using Hexo, you can find the answer in [troubleshooting](https://hexo.io/docs/troubleshooting.html) or you can ask me on [GitHub](https://github.com/hexojs/hexo/issues).

## Quick Start

### Create a new post

``` bash
$ hexo new "My New Post"
```




{% dplayer “url=https://www.bilibili.com/video/BV1ck4y1i7Bd/?share_source=copy_web.mp4” “https://i0.hdslb.com/bfs/archive/08954fbadc03c7b119a2454137b6a6dfd74a1b80.jpg@518w_290h_!web-video-share-cover.webp.jpg” “api=https://api.prprpr.me/dplayer/” “id=” “loop=false” %}

{% pdf “http://gisersqdai.top/mycv/201702.pdf” %}

![qwe](https://i.loli.net/2018/02/09/5a7d6a402e15e.jpg)

![测试4](/picture/1.jpg)

More info: [Writing](https://hexo.io/docs/writing.html)

{% pdf https://www.alldatasheetcn.com/datasheet-pdf/pdf/56260/ATMEL/ATMEGA128.html %}

### Run server

``` bash
$ hexo server
```

More info: [Server](https://hexo.io/docs/server.html)

### Generate static files

``` bash
$ hexo generate
```

More info: [Generating](https://hexo.io/docs/generating.html)

### Deploy to remote sites

``` bash
$ hexo deploy
```

More info: [Deployment](https://hexo.io/docs/one-command-deployment.html)
