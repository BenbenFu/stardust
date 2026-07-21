/* ============================================================
   字体按需加载器 — FontFace API
   ------------------------------------------------------------
   解决问题：9 个 woff2 合计 ~10MB，一次性全下需 4-5 分钟，
   后几个超时失败。本模块只加载当前需要的那一个字体。
   
   用法：
     FontLoader.load('FontHei').then(() => { /* 已就绪 */ })
     FontLoader.isLoaded('FontHei')  // boolean
     FontLoader.getAvailable()       // ['FontHei','FontSong',...]
     
   配合：capsule-preview / gallery 页面在切换字体时调用 .load()
   测试页 test_woff2.html 可继续用 fonts.css（全量加载）
   ============================================================ */

(function(global) {
  'use strict';

  var FONT_BASE = (document.currentScript && document.currentScript.src)
    ? document.currentScript.src.replace(/[^/]*$/, '')
    : './font/';
  var VERSION = '20260721e';

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

    var url = FONT_BASE + file + '?v=' + VERSION;

    var promise = new Promise(function(resolve, reject) {
      var ff = new FontFace(family, 'url("' + url + '")', { display: 'swap' });

      ff.load().then(
        function() {
          document.fonts.add(ff);
          _loaded[family] = ff;
          delete _loading[family];
          console.log('[FontLoader] OK: ' + family + ' (' + (ff.status || 'loaded') + ')');
          resolve(ff);
        },
        function(err) {
          delete _loading[family];
          console.error('[FontLoader] FAIL: ' + family, err);
          reject(err);
        }
      );
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
