/* ============================================================
   字体按需加载器 — FontFace API v3
   ------------------------------------------------------------
   解决问题：9 个 woff2 合计 ~4.5MB，CDN 慢 / 本地也慢时，
   反复超时→回退→失败→再试形成死循环。

   核心机制：
     1. _failed 集合：某字体本轮确认失败后不再重试（会话级）
     2. _preloadComplete：preload 只执行一次，后续增量检查新字体
     3. CDN 自适应：连续失败后禁用 CDN
     4. 超时回退：单次超时后走 fallback，不无限等

   用法：
     FontLoader.load('FontHei').then(() => { 已就绪 })
     FontLoader.isLoaded('FontHei')  // boolean
     FontLoader.preloadOnce(families)  // 会话级预加载（只执行一次）
     FontLoader.resetFailed()          // 手动清除失败记录重试

   配合：capsule-preview / gallery 页面在切换字体时调用 .load()
   测试页 test_woff2.html 可继续用 fonts.css（全量加载）
   ============================================================ */

(function(global) {
  'use strict';

  // 字体基准路径：默认走本地相对路径（GitHub Pages 同源，用作 CDN 失败回退）
  var FONT_BASE = (document.currentScript && document.currentScript.src)
    ? document.currentScript.src.replace(/[^/]*$/, '')
    : './font/';

  /* ===== jsDelivr 中转 ===== */
  var USE_CDN  = (typeof location !== 'undefined' && location.search.indexOf('nocdn') === -1);
  var FONT_REF = 'main';   // 'main'(分支,缓存~12h) | 'fonts-v1'(tag,即时生效)
  // ⚠️ 已改用版本化目录(v<VERSION>/)破 jsDelivr 分支缓存，无需 tag。
  //    若仍想用 tag 引用：git tag fonts-v1 && git push origin fonts-v1，再把 FONT_REF 改 'fonts-v1'。
  var CDN_BASE = 'https://cdn.jsdelivr.net/gh/BenbenFu/stardust@' + FONT_REF + '/web/font/';

  var VERSION = '20260723f';

  /* 版本化目录：字体落到 v<版本>/ 下。路径变了 = jsDelivr 视为新文件，
     立即向 GitHub 拉取最新内容，绕开分支引用(~main)的 ~12h 缓存。
     （查询参数 ?v= 不能破分支缓存，只能靠换路径。）*/
  var FONT_DIR = 'v' + VERSION + '/';

  /* 单次加载超时（毫秒） */
  var LOAD_TIMEOUT = 60000;

  /* ---- 内部状态 ---- */
  var _loaded  = {};   // family -> FontFace（加载成功）
  var _loading = {};  // family -> Promise（正在加载中，含回退）
  var _failed  = {};  // family -> Error（本轮已确认失败，不重试）

  /* 会话级标记：preloadOnce 已执行过 */
  var _preloadComplete = false;

  /* CDN 自适应：连续失败达到阈值后禁用 */
  var _cdnFailCount = 0;
  var _cdnDisabled = false;
  var CDN_FAIL_THRESHOLD = 2;  // 连续 2 次 CDN 失败即禁用

  /* ---- 字体清单 ---- */
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

  /**
   * 加载单个字体（带三级缓存：_loaded > _loading > _failed > 实际加载）
   * @param {string} family
   * @param {boolean} [forceRetry=false] - 强制忽略 _failed 重试
   * @returns {Promise<FontFace>}
   */
  function loadFont(family, forceRetry) {
    /* L1: 已成功 */
    if (_loaded[family]) {
      return Promise.resolve(_loaded[family]);
    }
    /* L2: 正在加载（含回退中），复用同一 Promise */
    if (_loading[family]) {
      return _loading[family];
    }
    /* L3: 本轮已确认失败，默认不重试（防止死循环）*/
    if (_failed[family] && !forceRetry) {
      return Promise.reject(_failed[family]);
    }

    var file = FONTS[family];
    if (!file) {
      return Promise.reject(new Error('[FontLoader] 未注册字体: ' + family));
    }

    /* 自适应 CDN */
    var useCdn = (USE_CDN && !_cdnDisabled);
    var primary  = useCdn ? (CDN_BASE + FONT_DIR + file + '?v=' + VERSION) : (FONT_BASE + FONT_DIR + file + '?v=' + VERSION);
    var fallback = useCdn ? (FONT_BASE + FONT_DIR + file + '?v=' + VERSION) : null;

    function tryLoad(url, isCdn) {
      return new Promise(function(resolve, reject) {
        var ff = new FontFace(family, 'url("' + url + '")', { display: 'swap' });
        var settled = false;
        var timer = setTimeout(function() {
          if (settled) return;
          settled = true;
          if (isCdn) { _cdnFailCount++; if (_cdnFailCount >= CDN_FAIL_THRESHOLD) _cdnDisabled = true; }
          reject(new Error('timeout'));
        }, LOAD_TIMEOUT);
        ff.load().then(
          function() {
            if (settled) return;
            settled = true;
            clearTimeout(timer);
            if (isCdn) _cdnFailCount = 0;
            document.fonts.add(ff);
            resolve(ff);
          },
          function(err) {
            if (settled) return;
            settled = true;
            clearTimeout(timer);
            if (isCdn) { _cdnFailCount++; if (_cdnFailCount >= CDN_FAIL_THRESHOLD) _cdnDisabled = true; }
            reject(err);
          }
        );
      });
    }

    var promise = tryLoad(primary, useCdn).then(
      function(ff) {
        _loaded[family] = ff;
        delete _loading[family];
        console.log('[FontLoader] OK: ' + family);
        return ff;
      },
      function(err) {
        if (fallback) {
          console.warn('[FontLoader] 主源失败，回退: ' + family, err.message);
          return tryLoad(fallback, false).then(
            function(ff) {
              _loaded[family] = ff;
              delete _loading[family];
              console.log('[FontLoader] OK(local): ' + family);
              return ff;
            },
            function(err2) {
              delete _loading[family];
              _failed[family] = err2;  // 标记失败，不再重试
              console.error('[FontLoader] FAIL(不再重试): ' + family, err2.message);
              throw err2;
            }
          );
        }
        delete _loading[family];
        _failed[family] = err;
        console.error('[FontLoader] FAIL(不再重试): ' + family, err.message);
        throw err;
      }
    );

    _loading[family] = promise;
    return promise;
  }

  /** 批量加载（并发 Promise.all，自动跳过已加载/已失败的） */
  function loadFonts(families) {
    return Promise.all(families.map(function(f) { return loadFont(f); }));
  }

  /** 检查是否就绪 */
  function isLoaded(family) {
    return !!_loaded[family] || document.fonts.check('16px "' + family + '"');
  }

  function getAvailableFonts() { return Object.keys(FONTS); }

  function stats() {
    return {
      registered: Object.keys(FONTS).length,
      loaded: Object.keys(_loaded).length,
      loading: Object.keys(_loading).length,
      failed: Object.keys(_failed).length,
      cdnDisabled: _cdnDisabled,
      preloadDone: _preloadComplete
    };
  }

  /**
   * 会话级预加载（只执行一次）
   * - 首次调用：过滤掉已加载/已失败的，加载剩余的
   * - 后续调用：直接跳过（返回空 resolved Promise）
   * - 用途：gallery 的 renderAll/resize/scroll-load-more 都调这个，不会重复加载
   */
  function preloadOnce(families) {
    if (_preloadComplete) {
      /* 增量模式：只加载之前没见过的新字体 */
      var fresh = families.filter(function(f) { return !_loaded[f] && !_failed[f] && !_loading[f]; });
      if (fresh.length === 0) return Promise.resolve([]);
      return loadFonts(fresh).catch(function() {});
    }
    _preloadComplete = true;
    /* 首次：过滤已加载的，加载剩余 */
    var needed = families.filter(function(f) { return !_loaded[f]; });
    if (needed.length === 0) return Promise.resolve([]);
    return loadFonts(needed).catch(function() {});  // 首批失败不阻塞渲染
  }

  /** 手动清除失败记录（用户主动触发时用，如切换字体下拉框） */
  function resetFailed() {
    _failed = {};
  }

  /** 重置全部状态（测试/调试用） */
  function resetAll() {
    _loaded = {};
    _loading = {};
    _failed = {};
    _preloadComplete = false;
    _cdnDisabled = false;
    _cdnFailCount = 0;
  }

  /* ---- 全局导出 ---- */
  global.FontLoader = {
    load:           loadFont,
    loadAll:        loadFonts,
    isLoaded:       isLoaded,
    getAvailable:   getAvailableFonts,
    stats:          stats,
    FONTS:          FONTS,
    _internal:      { _loaded: _loaded, _failed: _failed },

    /** 会话级预加载（推荐用于 gallery 瀑布流） */
    preloadOnce:    preloadOnce,

    /** 清除失败记录（capsule-preview 切换字体前调用） */
    resetFailed:    resetFailed,

    /** CDN 控制 */
    resetCdn:       function() { _cdnDisabled = false; _cdnFailCount = 0; },
    isCdnDisabled:  function() { return _cdnDisabled; },

    /** 完全重置（仅调试） */
    resetAll:       resetAll
  };

})(window || self);
