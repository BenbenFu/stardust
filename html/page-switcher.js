// 页面切换旋钮控制
(function(){
    var p = location.pathname,
        k = document.getElementById('mainKnob'),
        d = 'list',
        r = -45;
    
    if (/diary/.test(p)) {
        d = 'diary';
        r = 0;
    } else if (/ledger/.test(p)) {
        d = 'ledger';
        r = 45;
    } else if (/approval/.test(p)) {
        d = 'list';
        r = -45;
    } else if (/login/.test(p)) {
        d = 'login';
        r = -45;
    }
    
    k.style.transform = 'rotate(' + r + 'deg)';
    
    var pages = ['list.html', 'diary.html', 'ledger.html'];
    
    document.querySelectorAll('.case-scale').forEach(function(e, i){
        e.title = pages[i];
        e.onclick = function() {
            location.href = pages[i];
        };
    });
    
    k.title = '点击切换页面';
    k.onclick = function() {
        var idx = d === 'diary' ? 1 : (d === 'ledger' ? 2 : 0);
        location.href = pages[(idx + 1) % 3];
    };
})();