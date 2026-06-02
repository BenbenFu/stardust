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
    let numStars = parseInt(difficulty);
    if (isNaN(numStars)) {
        const starMatch = String(difficulty).match(/(\u2605|\u2B50)/g);
        numStars = starMatch ? starMatch.length : 0;
    }
    let stars = '';
    for (let i = 1; i <= 5; i++) {
        if (i <= numStars) {
            stars += '<svg width="24" height="24" viewBox="0 0 12 12" style="display:inline;vertical-align:middle;"><path d="M6 1L7 5 11 5 8 8 9 12 6 9 3 12 4 8 1 5 5 5Z" fill="#1e2622"/></svg>';
        } else {
            stars += '<svg width="24" height="24" viewBox="0 0 12 12" style="display:inline;vertical-align:middle;"><path d="M6 1L7 5 11 5 8 8 9 12 6 9 3 12 4 8 1 5 5 5Z" fill="none" stroke="#1e2622" stroke-width="1"/></svg>';
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
            <tr class="hover:bg-neonblue/5 transition-colors">
                <td class="border border-neonblue/30 px-4 py-2">${item.category || ''}</td>
                <td class="border border-neonblue/30 px-4 py-2">${item.detail || ''}</td>
                <td class="border border-neonblue/30 px-4 py-2 text-right">${price.toFixed(2)}</td>
                <td class="border border-neonblue/30 px-4 py-2 text-right">${quantity}</td>
                <td class="border border-neonblue/30 px-4 py-2 text-right text-cyanglow">${subtotal.toFixed(2)}</td>
                <td class="border border-neonblue/30 px-4 py-2">${item.billing || '一次性'}</td>
            </tr>
        `;
    });
    
    html += `
        <tfoot>
            <tr class="bg-deepspace/80 font-bold">
                <td class="border border-neonblue/30 px-4 py-2 text-neonpurple font-cyber" colspan="4">星蟹币合计</td>
                <td class="border border-neonblue/30 px-4 py-2 text-right text-goldstardust font-cyber text-lg">${total.toFixed(2)}</td>
                <td class="border border-neonblue/30 px-4 py-2" colspan="2"></td>
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

// 导出供其他页面使用
window.supabase = supabase;
window.renderDifficultyStars = renderDifficultyStars;
window.renderBudgetTable = renderBudgetTable;
window.getStatusInfo = getStatusInfo;
window.checkAuth = checkAuth; // 导出认证检查函数
window.logout = logout; // 导出登出函数

export { supabase, checkAuth, logout, renderDifficultyStars, renderBudgetTable, getStatusInfo };
