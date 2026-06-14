// === GALLERY CARD RENDERING MODULE ===
// 使用 style-engine.js 的 data-属性驱动渲染
// 迁移说明：原 18 种 card-type 已映射为 STYLE_PRESETS（style_json 格式）
// 旧 cardType → preset 兼容层保留，新日记应直接使用 style_json 字段

import { renderStyleJson, STYLE_PRESETS, injectCardEngineCss } from './style-engine.js';

injectCardEngineCss();  // 副作用：自动注入引擎 CSS

/**
 * 渲染单张卡片
 * @param {Object} diary - { id, title, date, dateRaw, highlights, capsuleName, cardType, style_json }
 * @returns {string} HTML 字符串
 */
export function renderCard(diary) {
    // 优先使用 style_json（新格式）
    if (diary.style_json) {
        return renderStyleJson(diary.style_json, diary);
    }
    // 兼容旧格式：cardType → preset
    const presetName = diary.cardType || 'default';
    const preset = STYLE_PRESETS[presetName];
    if (!preset) {
        console.warn(`Unknown cardType: ${presetName}, falling back to 'default'`);
        return renderStyleJson(STYLE_PRESETS['default'], diary);
    }
    return renderStyleJson(preset, diary);
}
