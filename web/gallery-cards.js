// === GALLERY CARD RENDERING MODULE v2.0 ===
// DB驱动架构：renderCard 传递 allOptions 给 style-engine
// 旧 cardType/STYLE_PRESETS 兼容层已移除

import { renderStyleJson, injectBaseCss, DEFAULT_STYLE_JSON } from './style-engine.js?v=20260715c';

injectBaseCss();  // 副作用：注入 BASE_CSS

/**
 * 渲染单张卡片
 * @param {Object} diary — { id, title, date, dateRaw, highlights, capsuleName, style_json }
 * @param {Object} allOptions — 九张维度表的全量数据
 * @returns {string} HTML 字符串
 */
export function renderCard(diary, allOptions) {
    if (diary && diary.style_json) {
        return renderStyleJson(diary.style_json, diary, allOptions);
    }
    return renderStyleJson(DEFAULT_STYLE_JSON, diary, allOptions);
}
