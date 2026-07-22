/* ============================================================
   字体按需加载器 — FontFace API
   ------------------------------------------------------------
   解决问题：9 个 woff2 合计 ~10MB，一次性全下需 4-5 分钟，
   后几个超时失败。本模块只加载当前需要的那一个字体。
   
   用法：
     FontLoader.load('FontHei').then(() => { 已就绪 })
     FontLoader.isLoaded('FontHei')  // boolean
     FontLoader.getAvailable()       // ['FontHei','FontSong',...]
     
   配合：capsule-preview / gallery 页面在切换字体时调用 .load()
   测试页 test_woff2.html 可继续用 fonts.css（全量加载）
   ============================================================ */

(function(global) {
  'use strict';

  // 字体基准路径：默认走本地相对路径（GitHub Pages 同源，用作 CDN 失败回退）
  var FONT_BASE = (document.currentScript && document.currentScript.src)
    ? document.currentScript.src.replace(/[^/]*$/, '')
    : './font/';

  /* ===== jsDelivr 中转（加速国内从 GitHub Pages 拉字体）=====
     - 站点与字体都放在 GitHub 仓库、由 GitHub Pages 托管时，国内拉取常被
       限速到 ~30KB/s（9 个字体全下要 2~3 分钟）。
     - 改为从 jsDelivr CDN 拉取（cdn.jsdelivr.net/gh/<repo>@<ref>/...），
       利用其在国内的边缘节点，通常能快一个数量级。
     - 前置条件：仓库须为【公开】；且仓库体积须 < jsDelivr 的 50MB 上限
       （故 .fontwork 原始 TTF 已移出 git，见 _deprecated）。
     - 切换：USE_CDN 默认 true；在 URL 后加 ?nocdn 可强制走本地做 A/B 对比。
     - 缓存：jsDelivr 按 @ref 缓存，字体更新后请把 FONT_REF 从 'main' 改成
       发布 tag（如 'fonts-v1'），否则按分支缓存最多延迟 ~12h 生效。
     - 回退：CDN 加载失败时自动回退到本地 FONT_BASE，不会白屏。            */
  var USE_CDN  = (typeof location !== 'undefined' && location.search.indexOf('nocdn') === -1);
  var FONT_REF = 'main';   // 'main' | 'v1.2.3'(tag) | 完整 commit SHA
  var CDN_BASE = 'https://cdn.jsdelivr.net/gh/BenbenFu/stardust@' + FONT_REF + '/web/font/';

  var VERSION = '20260722b';

  /* ---- 字体清单（family 名 -> 相对路径）---- */
  var FONTS = {
    'FontHei':      'hei.woff2',
    'FontSong':     'song.woff2',
    'FontYuan':     'yuan.woff2',
    'FontKai':      'kai.woff2',
    'FontMono':     'mono.woff2',
    'FontCreative': 'creative.woff2',
    'FontHand':     'hand.woff2',
    'FontCalli':    'calli.woff2',
    'FontCartoon':  'cartoon.woff2'
  };

  /* ---- 内部状态 ---- */
  var _loaded = {};   // family -> FontFace (已加载)
  var _loading = {};  // family -> Promise (正在加载)

  /**
   * 加载单个字体（带去重缓存）
   * @param {string} family - FontFace family 名称
   * @returns {Promise<FontFace>}
   */
  function loadFont(family) {
    /* 缓存命中 */
    if (_loaded[family]) {
      return Promise.resolve(_loaded[family]);
    }
    /* 正在加载中（防止重复请求）*/
    if (_loading[family]) {
      return _loading[family];
    }

    var file = FONTS[family];
    if (!file) {
      return Promise.reject(new Error('[FontLoader] 未注册字体: ' + family));
    }

    var primary  = (USE_CDN ? CDN_BASE : FONT_BASE) + file + '?v=' + VERSION;
    var fallback = (USE_CDN ? FONT_BASE : CDN_BASE) + file + '?v=' + VERSION;

    var promise = new Promise(function(resolve, reject) {
      function attempt(url, isFallback) {
        var ff = new FontFace(family, 'url("' + url + '")', { display: 'swap' });
        ff.load().then(
          function() {
            document.fonts.add(ff);
            _loaded[family] = ff;
            delete _loading[family];
            console.log('[FontLoader] OK: ' + family + ' <- ' + url);
            resolve(ff);
          },
          function(err) {
            if (!isFallback && fallback !== primary) {
              console.warn('[FontLoader] 主源失败，回退本地: ' + family, err);
              attempt(fallback, true);
            } else {
              delete _loading[family];
              console.error('[FontLoader] FAIL: ' + family, err);
              reject(err);
            }
          }
        );
      }
      attempt(primary, false);
    });

    _loading[family] = promise;
    return promise;
  }

  /** 批量加载（并发 Promise.all） */
  function loadFonts(families) {
    return Promise.all(families.map(loadFont));
  }

  /** 检查某字体是否就绪 */
  function isLoaded(family) {
    return !!_loaded[family] ||
           document.fonts.check('16px "' + family + '"');
  }

  /** 获取全部可用字体 family 名 */
  function getAvailableFonts() {
    return Object.keys(FONTS);
  }

  /** 获取加载统计 */
  function stats() {
    return {
      registered: Object.keys(FONTS).length,
      loaded: Object.keys(_loaded).length,
      loading: Object.keys(_loading).length
    };
  }

  /* ---- 全局导出 ---- */
  global.FontLoader = {
    load:       loadFont,
    loadAll:    loadFonts,
    isLoaded:   isLoaded,
    getAvailable: getAvailableFonts,
    stats:      stats,
    FONTS:      FONTS,
    _internal:  { _loaded: _loaded }  // 仅用于调试
  };

})(window || self);
