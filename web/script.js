// 替换为你的Supabase配置
const SUPABASE_URL = 'https://opyeahbzibuupmkmjpkr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9weWVhaGJ6aWJ1dXBta21qcGtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMjk3MDcsImV4cCI6MjA5MzYwNTcwN30.7kCHwI7lKy1jH5BjI4gOKqw2vEUxpsjRJar_94j4Srk';

// 初始化Supabase客户端
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// ========== 新增：认证核心函数 ==========
// 检查登录状态，未登录则跳转到登录页
async function checkAuth() {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) {
        window.location.href = 'login.html?v=20260524-5';
        return false;
    }
    // 将JWT挂载到window，供后续API请求使用（如果需要）
    window.authToken = session.access_token;
    return true;
}

// 登出函数
async function logout() {
    const { error } = await supabase.auth.signOut();
    if (!error) {
        window.location.href = 'login.html?v=20260524-5';
    } else {
        alert('登出失败：' + error.message);
    }
}

// 渲染难度星级
function renderDifficultyStars(difficulty) {
    let stars = '';
    for (let i = 1; i <= 5; i++) {
        if (i <= difficulty) {
            stars += '<i class="fa fa-star" style="color:var(--pixel-dark);"></i>';
        } else {
            stars += '<i class="fa fa-star" style="color:var(--pixel-dim);"></i>';
        }
    }
    return stars;
}

function toNumber(value, fallback = 0) {
    const number = parseFloat(value);
    return Number.isFinite(number) ? number : fallback;
}

// 渲染预算表格
function renderBudgetTable(budget) {
    if (typeof budget === 'string') {
        try { budget = JSON.parse(budget); } catch(e) { budget = []; }
    }
    if (!Array.isArray(budget)) budget = [];
    let html = '';
    let total = 0;
    
    budget.forEach(item => {
        const price = toNumber(item.price);
        const quantity = toNumber(item.quantity, 1);
        const subtotal = price * quantity;
        total += subtotal;
        html += `
            <tr>
                <td class="px-4 py-2">${item.category || ''}</td>
                <td class="px-4 py-2">${item.detail || ''}</td>
                <td class="px-4 py-2 text-right">${price.toFixed(2)}</td>
                <td class="px-4 py-2 text-right">${quantity}</td>
                <td class="px-4 py-2 text-right">${subtotal.toFixed(2)}</td>
                <td class="px-4 py-2">${item.billing || '一次性'}</td>
            </tr>
        `;
    });
    
    html += `
        <tfoot>
            <tr class="font-bold">
                <td class="px-4 py-2" colspan="4">星蟹币合计</td>
                <td class="px-4 py-2 text-right text-lg">${total.toFixed(2)}</td>
                <td class="px-4 py-2" colspan="2"></td>
            </tr>
        </tfoot>
    `;
    
    return html;
}

// 获取状态文本和样式
function getStatusInfo(status) {
    const statusMap = {
        'pending': { text: '等待回应', class: 'status-pending' },
        'approved': { text: '愿望批准', class: 'status-approved' },
        'rejected': { text: '暂不实现', class: 'status-rejected' },
        'completed': { text: '进化完成', class: 'status-completed' }
    };
    return statusMap[status] || statusMap['pending'];
}

// 页面导航旋钮初始化
function initNavigation() {
    var p = location.pathname, k = document.getElementById('mainKnob'), d = 'list', r = -45;
    if (/diary/.test(p)) { d = 'diary'; r = 0; }
    else if (/ledger/.test(p)) { d = 'ledger'; r = 45; }
    else if (/list|approval/.test(p)) { d = 'list'; r = -45; }
    if (k) k.style.transform = 'rotate(' + r + 'deg)';
    var pages = ['list.html', 'diary.html', 'ledger.html'];
    document.querySelectorAll('.case-scale').forEach(function(e, i) {
        e.title = pages[i];
        e.onclick = function() { location.href = pages[i]; };
    });
    if (k) {
        k.title = '点击切换页面';
        k.onclick = function() { var idx = d === 'diary' ? 1 : d === 'ledger' ? 2 : 0; location.href = pages[(idx + 1) % 3]; };
    }
}

document.addEventListener('DOMContentLoaded', function() {
    initNavigation();
});

// 导出供其他页面使用（list.html 用 onclick="logout()" 需要 window.logout）
window.logout = logout;

export { supabase, checkAuth, logout, renderDifficultyStars, renderBudgetTable, getStatusInfo };
