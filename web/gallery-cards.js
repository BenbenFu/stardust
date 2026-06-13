// === GBA LCD 卡片渲染模块 ===
// 基础卡片池（capsule 为 "/" 时使用）
    const baseTypes = ['default', 'repair', 'print', 'overheat', 'tamagotchi', 'api-debt', 'panic'];

    // 扭蛋机卡片池（capsule 有值时使用）
    const gashaponTypes = ['code-forge','tech-archive','work-bench','life-logbook','social-broadcast','creative-engine','media-stream','role-engine','fiction-realm','format-deck','misc-mystery'];

    // 风格中文标签
    const styleLabels = {
        'default':'标准工业屏','repair':'维修便签','print':'针式打印','overheat':'过热终端',
        'tamagotchi':'电子宠物','api-debt':'欠费警告','panic':'故障日志',
        'code-forge':'代码编程','tech-archive':'技术文档','work-bench':'工作办公',
        'life-logbook':'生活记录','social-broadcast':'社交网络','creative-engine':'创意写作',
        'media-stream':'媒体通稿','role-engine':'角色扮演','fiction-realm':'小说叙事',
        'format-deck':'格式规范','misc-mystery':'未知分类'
    };

    // 句间分隔符（7 基础 + 11 扭蛋）
    const sepChars = {
        'default':'*  *  *','repair':'- - - - -','print':'· · · · ·','overheat':'',
        'tamagotchi':'+ + + + +','api-debt':'! ! ! ! !','panic':'0x0 0x0',
        'code-forge':'/* ---- */','tech-archive':'','work-bench':'',
        'life-logbook':'~ ~ ~ ~ ~','social-broadcast':'·  ·  ·','creative-engine':'',
        'media-stream':'','role-engine':'','fiction-realm':'* * *',
        'format-deck':'','misc-mystery':'? ? ? ? ?'
    };

    // category → slug 映射（兼容中英文）
    function categoryToSlug(cat) {
        if (!cat) return null;
        const lower = cat.toLowerCase().trim();
        const map = {
            'code-forge':'code-forge','代码编程':'code-forge',
            'tech-archive':'tech-archive','技术文档':'tech-archive',
            'work-bench':'work-bench','工作办公':'work-bench',
            'life-logbook':'life-logbook','生活记录':'life-logbook',
            'social-broadcast':'social-broadcast','社交网络':'social-broadcast',
            'creative-engine':'creative-engine','创意写作':'creative-engine',
            'media-stream':'media-stream','媒体通稿':'media-stream',
            'role-engine':'role-engine','角色扮演':'role-engine',
            'fiction-realm':'fiction-realm','小说叙事':'fiction-realm',
            'format-deck':'format-deck','格式规范':'format-deck',
            'misc-mystery':'misc-mystery','未知分类':'misc-mystery',
        };
        return map[lower] || map[cat] || null;
    }

    // ASCII 宠物池
    const asciiPets = [
        ' /\\_/\\\n( o.o )\n > ^ <\n',
        '  ___\n (>.<)\n (___)\n',
        ' /\\_/\\\n( -.- )\n(\")(\")\n',
        '  __\n (--)\n/(  )\\\n'
    ];

    function formatDateForUI(isoDate) {
        if (!isoDate) return '----/--/--';
        const parts = isoDate.split('-');
        if (parts.length === 3) return `${parts[0]}/${parts[1]}/${parts[2]}`;
        return isoDate;
    }

    // 渲染精华句列表（含句间分隔符）
    function renderHighlights(highlights, sepChar) {
        if (!highlights || highlights.length === 0) return '';
        let html = '';
        highlights.forEach((h, i) => {
            if (i > 0) html += `<div class="hl-sep">${sepChar}</div>`;
            html += `<p class="card-highlight-item">${escapeHtml(h)}</p>`;
        });
        return html;
    }

    // 渲染单张卡片（18 种类型）
    export function renderCard(diary) {
        const cardType = diary.cardType || 'default';
        const highlights = diary.highlights || [];
        const dateRaw = diary.dateRaw || diary.date;
        const styleName = diary.capsuleName || styleLabels[cardType] || cardType;
        const sep = isCustom ? '' : (sepChars[cardType] || '');
        const isCustom = !!diary.capsuleCSS;
        const csAttr = isCustom ? ` data-cs="${escapeHtml(styleName)}"` : '';
        const typeClass = isCustom ? '' : ` card-type-${cardType}`;

        let html = `<a class="gallery-card${typeClass}"${csAttr} href="diary.html?date=${dateRaw}" target="_blank" title="${escapeHtml(diary.title)}" data-id="${diary.id}" data-title="${escapeHtml(diary.title)}" data-date="${diary.date}" data-date-raw="${dateRaw}" data-highlights="${escapeHtml(JSON.stringify(highlights))}">`;

        const nid = numericId(diary.id);

        // custom 类型：最简骨架，无类型特有装饰
        if (isCustom) {
            html += `<div class="card-title">${escapeHtml(diary.title)}</div>`;
            html += `<div class="card-date">${diary.date}</div>`;
            if (highlights.length > 0) {
                html += renderHighlights(highlights, sep);
            } else {
                html += '<p class="card-no-highlight">[ NO_HIGHLIGHTS ]</p>';
            }
            html += `<div class="card-style">${escapeHtml(styleName)}</div>`;
            html += '</a>';
            return html;
        }

        // --- 类型特有头部 ---
        switch (cardType) {
            case 'overheat':
                html += `<div class="card-status-bar"><span>WARNING: OVERHEAT</span><span>${styleName}</span></div>`;
                break;
            case 'api-debt':
                html += '<div class="warning-bar"><span>API DEBT</span><span>'+styleName+'</span></div>';
                break;
            case 'tech-archive':
                html += `<div class="doc-header"><span>RFC-${diary.id}</span><span>STARDUST-SPEC</span></div>`;
                html += '<div class="tech-seal">APPROVED</div>';
                break;
            case 'work-bench':
                html += `<div class="email-header"><span class="email-from">stardust@unit01.internal</span><span class="email-date">${diary.date} · ${styleName}</span></div>`;
                break;
            case 'social-broadcast':
                html += `<div class="user-bar"><div class="social-avatar"></div><div class="user-info"><div class="social-username">星尘单元01</div><div class="social-handle">@stardust_unit01 · ${styleName}</div></div></div>`;
                break;
            case 'role-engine':
                html += '<div class="role-header"><div class="role-avatar"></div><div class="role-info">';
                break;
            case 'print':
                html += '<div class="left-holes"></div><div class="right-holes"></div>';
                break;
        }

        // --- 标题、日期 ---
        // role-engine: 作家人格模拟器布局
        if (cardType === 'role-engine') {
            const injectLabels = ['人格注入', '相似度', '文风匹配', '灵魂复现', '意识同步'];
            const label = injectLabels[nid % injectLabels.length];
            const pct = 30 + (nid % 71); // 30~100%
            html += `<div class="role-name">${escapeHtml(styleName)}</div>`;
            html += `<div class="role-date">${diary.date}</div>`;
            html += `<div class="role-stat">${label}<div class="role-bar"><div class="role-bar-fill" style="width:${pct}%"></div></div></div>`;
            html += `<div class="role-inject">${pct}% · #${nid % 10000}号实验体</div></div></div>`;
            // 日记标题作为卡片标题
            html += `<div class="card-title">${escapeHtml(diary.title)}</div>`;
        } else if (cardType === 'work-bench') {
            html += `<div class="card-title">${escapeHtml(diary.title)}</div>`;
            // date is in email-header
        } else if (cardType === 'life-logbook') {
            html += `<div class="card-title">${escapeHtml(diary.title)}</div>`;
            html += `<div class="card-date">${diary.date}</div>`;
        } else if (cardType === 'creative-engine') {
            html += `<div class="card-title">${escapeHtml(diary.title)}</div>`;
            html += `<div class="card-date">${diary.date}</div>`;
        } else if (cardType === 'fiction-realm') {
            html += `<div class="card-title">${escapeHtml(diary.title)}</div>`;
            html += `<div class="card-date">${diary.date}</div>`;
        } else if (cardType === 'media-stream') {
            html += `<div class="card-title">${escapeHtml(diary.title)}</div>`;
            html += `<div class="media-dateline">【星尘通讯社 ${diary.date}电】</div>`;
        } else {
            // 通用布局：标题 + 日期
            html += `<div class="card-title">${escapeHtml(diary.title)}</div>`;
            if (cardType !== 'tamagotchi' || true) {
                html += `<div class="card-date">${diary.date}</div>`;
            }
        }

        // --- 特有装饰（高亮前） ---
        if (cardType === 'tamagotchi') {
            const pet = asciiPets[nid % asciiPets.length];
            html += `<div class="ascii-art">${pet}</div>`;
        }
        if (cardType === 'api-debt') {
            html += '<div class="api-seal">[!] API_DEBT</div>';
        }

        // --- 精华句 ---
        if (highlights.length > 0) {
            html += renderHighlights(highlights, sep);
        } else {
            html += '<p class="card-no-highlight">[ NO_HIGHLIGHTS ]</p>';
        }

        // --- 特有装饰（高亮后） ---
        if (cardType === 'panic') {
            html += `<div class="panic-dump">EIP: 0x${nid.toString(16).toUpperCase().padStart(8,'0')}<br>EBX: 0xDEADBEEF<br>KERNEL_PANIC: DUMPING...</div>`;
        }

        // --- 风格标签 ---
        // 某些类型已将 style 嵌入头部/底部，其余用通用 .card-style
        const styleInHeader = ['api-debt','tech-archive','work-bench','social-broadcast','role-engine','overheat'].includes(cardType);
        const styleInFooter = ['print','media-stream','fiction-realm','format-deck','tech-archive'].includes(cardType);

        if (cardType === 'print') {
            html += `<div class="card-footer-h"><span>${diary.date}</span><span>${styleName}</span></div>`;
        } else if (cardType === 'media-stream') {
            html += `<div class="card-footer-h"><span>${diary.date}</span><span>${styleName}</span></div>`;
        } else if (cardType === 'fiction-realm') {
            html += `<div class="card-footer-h"><span>${styleName}</span><span>- ${nid % 99 + 1} -</span></div>`;
        } else if (cardType === 'format-deck') {
            html += `<div class="card-footer-h"><span>${diary.date}</span><span>${styleName}</span></div>`;
        } else if (cardType === 'tech-archive') {
            html += `<div class="card-footer-h"><span>${diary.date}</span><span>${styleName}</span></div>`;
        } else if (['repair','life-logbook','creative-engine','misc-mystery'].includes(cardType)) {
            html += `<div class="card-style">${styleName}</div>`;
        } else if (!styleInHeader) {
            html += `<div class="card-style">${styleName}</div>`;
        }

        html += '</a>';
        return html;
    }

    function escapeHtml(str) {
        const div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    // 将 id（可能是 UUID 或数字）转为数值，用于哈希分配
    function numericId(id) {
        if (typeof id === 'number') return id;
        if (typeof id === 'string') {
            let hash = 0;
            for (let i = 0; i < id.length; i++) {
                hash = ((hash << 5) - hash) + id.charCodeAt(i);
                hash |= 0;
            }
            return Math.abs(hash);
        }
        return 0;
    }
