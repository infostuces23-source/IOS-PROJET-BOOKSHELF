import Hummingbird
import Foundation

struct HTML: ResponseGenerator {
    let html: String

    func response(from request: Request, context: some RequestContext) throws -> Response {
        let buffer = ByteBuffer(string: html)
        return Response(
            status: .ok,
            headers: [.contentType: "text/html; charset=utf-8"],
            body: .init(byteBuffer: buffer)
        )
    }
}


struct Views {

    // Je fais ici les layout :
    static func layout(title: String, content: String, showToast: String? = nil) -> String {
        let toastJS = showToast != nil ? """
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                var t = document.getElementById('toast-msg');
                if (t) { 
                    t.classList.add('show'); 
                    setTimeout(function(){ t.classList.remove('show'); }, 3000); 
                }
            });
        </script>
        <div id="toast-msg" class="toast">
            <i data-lucide="sparkles" style="width:18px;height:18px;color:var(--gold);"></i>
            \(escapeHTML(showToast!))
        </div>
        """ : ""

        return """
        <!DOCTYPE html>
        <html lang="fr" data-theme="dark">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <title>\(title) - BookShelf</title>
            
            <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@600;800&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
            <script src="https://unpkg.com/lucide@latest"></script>
            
            <style>
                :root {
                    --bg-deep: #050810;
                    --bg-surface: rgba(15, 23, 42, 0.7);
                    --nav-bg: rgba(5, 8, 16, 0.85);
                    --footer-bg: rgba(8, 12, 24, 0.95);
                    --gold: #d4af37;
                    --gold-glow: rgba(212, 175, 55, 0.3);
                    --bordeaux: #800020;
                    --navy: #0a101f;
                    --emerald: #10b981;
                    --ruby: #e11d48;
                    --text-main: #f8fafc;
                    --text-dim: #94a3b8;
                    --border-glass: rgba(255, 255, 255, 0.08);
                    --star-color: #d4af37;
                    --star-opacity: 1;
                    --radius-lg: 20px;
                    --radius-md: 12px;
                    --shadow-xl: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
                }

                [data-theme="light"] {
                    --bg-deep: #f1f5f9;
                    --bg-surface: rgba(255, 255, 255, 0.8);
                    --nav-bg: rgba(255, 255, 255, 0.9);
                    --footer-bg: rgba(235, 240, 248, 0.98);
                    --gold: #b8860b;
                    --gold-glow: rgba(184, 134, 11, 0.15);
                    --bordeaux: #600018;
                    --navy: #1e293b;
                    --text-main: #0f172a;
                    --text-dim: #475569;
                    --border-glass: rgba(0, 0, 0, 0.1);
                    --star-color: #7c8db5;
                    --star-opacity: 0.6;
                    --shadow-xl: 0 20px 40px -10px rgba(0, 0, 0, 0.1);
                }

                * { box-sizing: border-box; transition: background-color 0.4s ease, color 0.4s ease; }

                body {
                    background: var(--bg-deep);
                    color: var(--text-main);
                    font-family: 'Plus Jakarta Sans', sans-serif;
                    margin: 0;
                    overflow-x: hidden;
                    -webkit-font-smoothing: antialiased;
                }

                #starfield {
                    position: fixed; top: 0; left: 0; width: 100%; height: 100%;
                    z-index: -1; pointer-events: none;
                }

                .container { max-width: 1100px; margin: 0 auto; padding: 0 1.5rem; }

                /* Le NAVBAR */
                .navbar {
                    position: sticky; top: 0; z-index: 1000;
                    background: var(--nav-bg);
                    backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
                    border-bottom: 1px solid var(--border-glass);
                    padding: 1rem 0;
                }
                .nav-flex { display: flex; justify-content: space-between; align-items: center; }

                /* Le logo */
                .brand {
                    font-family: 'Cinzel', serif; font-weight: 800; font-size: 1.7rem;
                    color: var(--gold); text-decoration: none; display: flex; align-items: center; gap: 12px;
                    position: relative;
                }
                .brand-icon-wrap {
                    position: relative; display: inline-flex; align-items: center; justify-content: center;
                    filter: drop-shadow(0 0 8px var(--gold-glow));
                }
                .brand-icon-wrap i { animation: book-page-turn 3s ease-in-out infinite; transform-origin: left center; }
                @keyframes book-page-turn {
                    0%, 100% { transform: rotateY(0deg) scale(1); }
                    25% { transform: rotateY(-20deg) scale(1.05); }
                    50% { transform: rotateY(0deg) scale(1); }
                    75% { transform: rotateY(15deg) scale(1.02); }
                }
                .brand-text {
                    position: relative; display: inline-block;
                    background: linear-gradient(90deg, var(--gold) 0%, var(--gold) 40%, #fff5cc 50%, var(--gold) 60%, var(--gold) 100%);
                    background-size: 200% 100%;
                    -webkit-background-clip: text; background-clip: text;
                    -webkit-text-fill-color: transparent;
                    animation: shimmer 4s ease-in-out infinite;
                }
                @keyframes shimmer {
                    0%, 100% { background-position: 100% 0; }
                    50% { background-position: -100% 0; }
                }
                .brand-stars {
                    position: absolute; top: -4px; right: -12px; pointer-events: none;
                }
                .brand-stars span {
                    position: absolute; font-size: 10px; color: var(--gold);
                    animation: brand-star-twinkle 2s ease-in-out infinite;
                }
                .brand-stars span:nth-child(1) { top: -2px; right: 0; animation-delay: 0s; }
                .brand-stars span:nth-child(2) { top: 6px; right: -8px; animation-delay: 0.6s; font-size: 7px; }
                .brand-stars span:nth-child(3) { top: -6px; right: -6px; animation-delay: 1.2s; font-size: 8px; }
                @keyframes brand-star-twinkle {
                    0%, 100% { opacity: 0.2; transform: scale(0.5); }
                    50% { opacity: 1; transform: scale(1.2); }
                }

                .nav-links { display: flex; gap: 1rem; list-style: none; margin: 0; padding: 0; }
                .nav-link {
                    color: var(--text-dim); font-weight: 600; font-size: 0.9rem;
                    text-decoration: none; padding: 8px 16px; border-radius: 12px;
                    display: flex; align-items: center; gap: 8px; transition: all 0.3s;
                }
                .nav-link:hover { background: var(--gold-glow); color: var(--gold); }
                .theme-toggle {
                    cursor: pointer; padding: 10px; border-radius: 50%;
                    background: var(--border-glass); color: var(--gold);
                    display: flex; align-items: center; justify-content: center;
                    border: 1px solid var(--border-glass); transition: all 0.3s;
                }
                .theme-toggle:hover { transform: rotate(15deg) scale(1.1); background: var(--gold-glow); }

                /* Les cartes */
                .glass-card {
                    background: var(--bg-surface);
                    backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);
                    border: 1px solid var(--border-glass);
                    border-radius: var(--radius-lg);
                    box-shadow: var(--shadow-xl);
                    padding: 1.5rem;
                    transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275), border-color 0.4s;
                    position: relative; overflow: hidden;
                }
                .glass-card:hover { transform: translateY(-5px); border-color: var(--gold); }

                .sparkle-container {
                    position: absolute; top: 0; left: 0; width: 100%; height: 100%;
                    pointer-events: none; z-index: 0; opacity: 0; transition: opacity 0.5s;
                }
                .glass-card:hover .sparkle-container { opacity: 1; }
                .sparkle {
                    position: absolute; background: var(--gold); border-radius: 50%;
                    animation: sparkle-anim 2s infinite linear;
                }
                @keyframes sparkle-anim {
                    0% { transform: scale(0) rotate(0deg); opacity: 0; }
                    50% { transform: scale(1.2) rotate(180deg); opacity: 1; }
                    100% { transform: scale(0) rotate(360deg); opacity: 0; }
                }

                /* La barre de recherche */
                .search-bar {
                    display: grid; grid-template-columns: 2fr 1fr 1fr auto; gap: 10px;
                    background: var(--bg-surface); padding: 10px; border-radius: 18px;
                    border: 1px solid var(--border-glass); margin-bottom: 2rem;
                }
                select {
                    background-color: var(--bg-deep) !important;
                    color: var(--text-main) !important;
                    border: 1px solid var(--border-glass);
                    padding: 12px; border-radius: 12px; font-size: 0.9rem;
                    appearance: none; -webkit-appearance: none; text-align-last: center;
                }
                select option { background-color: var(--bg-deep); color: var(--text-main); }
                .search-bar input {
                    background: transparent; border: 1px solid transparent; color: var(--text-main);
                    padding: 12px; font-size: 0.9rem; border-radius: 12px;
                }
                .search-bar input:focus, .search-bar select:focus { border-color: var(--gold-glow); background: rgba(255,255,255,0.05); }

                /* Les boutons */
                .btn-submit {
                    background: var(--gold); color: #fff; border: none; padding: 0 25px;
                    border-radius: 12px; font-weight: 700; cursor: pointer; transition: 0.3s;
                }
                .btn-submit:hover { opacity: 0.9; transform: scale(1.02); box-shadow: 0 0 15px var(--gold-glow); }
                .btn-cancel {
                    background: transparent; color: var(--text-dim); border: 1px solid var(--border-glass);
                    padding: 0 25px; border-radius: 12px; font-weight: 700; cursor: pointer;
                    transition: 0.3s; text-decoration: none; display: inline-flex; align-items: center;
                    justify-content: center; gap: 8px; font-size: 0.9rem;
                }
                .btn-cancel:hover { background: rgba(255,255,255,0.05); color: var(--text-main); border-color: var(--text-dim); }
                .btn-detail {
                    background: var(--gold-glow); color: var(--gold); border: 1px solid var(--gold);
                    padding: 6px 18px; border-radius: 10px; font-weight: 700; font-size: 0.8rem;
                    cursor: pointer; transition: all 0.3s; text-decoration: none;
                    display: inline-flex; align-items: center; gap: 6px;
                }
                .btn-detail:hover { background: var(--gold); color: #fff; transform: translateY(-1px); box-shadow: 0 4px 12px var(--gold-glow); }

                /* Grilles de livres */
                .book-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 1.5rem; }
                .book-card { display: flex; gap: 1.2rem; align-items: center; position: relative; z-index: 1; cursor: pointer; transition: transform 0.2s, box-shadow 0.2s; }
                .book-card:hover { transform: translateY(-3px); box-shadow: 0 8px 25px rgba(0,0,0,0.3); }
                .book-card .actions { position: relative; z-index: 2; }
                .book-card .actions a, .book-card .actions button, .book-card .actions form { position: relative; z-index: 2; }
                .book-cover {
                    width: 100px; height: 140px; border-radius: 12px; flex-shrink: 0;
                    box-shadow: 0 10px 20px rgba(0,0,0,0.3); overflow: hidden;
                    background: var(--navy); display: flex; align-items: center; justify-content: center;
                    border: 1px solid var(--border-glass);
                }
                .book-cover img { width: 100%; height: 100%; object-fit: cover; }
                .book-info { flex: 1; min-width: 0; }
                .book-title { font-family: 'Cinzel', serif; font-size: 1.15rem; font-weight: 800; color: var(--gold); margin-bottom: 4px; }
                .book-author { color: var(--text-dim); font-size: 0.9rem; font-weight: 600; margin-bottom: 8px; }

                .badge {
                    display: inline-flex; align-items: center; gap: 4px;
                    padding: 4px 10px; border-radius: 8px; font-size: 0.65rem; font-weight: 800; text-transform: uppercase;
                }
                .badge-lu { background: rgba(16, 185, 129, 0.15); color: var(--emerald); }
                .badge-encours { background: rgba(245, 158, 11, 0.15); color: #f59e0b; }
                .badge-nonlu { background: rgba(225, 29, 72, 0.15); color: var(--ruby); }

                .stars { display: flex; gap: 2px; margin-top: 8px; }
                .star-icon { width: 15px; height: 15px; animation: star-pulse 2s infinite ease-in-out; }
                @keyframes star-pulse {
                    0%, 100% { transform: scale(1); opacity: 0.8; }
                    50% { transform: scale(1.2); opacity: 1; filter: drop-shadow(0 0 3px var(--gold)); }
                }

                .actions { display: flex; gap: 8px; margin-top: 15px; }
                .action-btn {
                    width: 36px; height: 36px; border-radius: 10px; background: var(--border-glass);
                    color: var(--text-dim); border: 1px solid var(--border-glass);
                    display: flex; align-items: center; justify-content: center; cursor: pointer; transition: 0.2s;
                }
                .action-btn:hover { background: var(--gold); color: white; border-color: var(--gold); transform: translateY(-2px); }
                .action-btn.danger:hover { background: var(--ruby); border-color: var(--ruby); }

                /* LE FOOTER */
                .site-footer {
                    margin-top: 5rem; padding: 0;
                    background: var(--footer-bg);
                    border-top: none;
                    position: relative; overflow: hidden;
                }
                .footer-gold-line {
                    height: 2px; width: 100%;
                    background: linear-gradient(90deg, transparent 0%, var(--gold) 20%, var(--gold) 80%, transparent 100%);
                    opacity: 0.6;
                }
                .footer-inner {
                    padding: 2.5rem 0 2rem;
                    display: flex; flex-direction: column; align-items: center; gap: 1rem;
                    position: relative;
                }
                .footer-brand {
                    font-family: 'Cinzel', serif; font-weight: 800; font-size: 1.3rem;
                    color: var(--gold); display: flex; align-items: center; gap: 10px;
                    letter-spacing: 2px;
                }
                .footer-brand i { filter: drop-shadow(0 0 6px var(--gold-glow)); }
                .footer-divider {
                    width: 60px; height: 1px;
                    background: linear-gradient(90deg, transparent, var(--gold), transparent);
                    opacity: 0.4;
                }
                .footer-credit {
                    font-size: 0.85rem; color: var(--text-dim); font-weight: 500;
                    letter-spacing: 0.5px; text-align: center; line-height: 1.6;
                }
                .footer-year {
                    font-size: 0.7rem; color: var(--text-dim); opacity: 0.5;
                    font-weight: 600; letter-spacing: 1px; text-transform: uppercase;
                }
                .footer-stars {
                    position: absolute; width: 100%; height: 100%; top: 0; left: 0;
                    pointer-events: none; overflow: hidden;
                }
                .footer-star {
                    position: absolute; width: 3px; height: 3px; background: var(--gold);
                    border-radius: 50%; animation: footer-twinkle 3s ease-in-out infinite;
                }
                @keyframes footer-twinkle {
                    0%, 100% { opacity: 0; transform: scale(0.5); }
                    50% { opacity: 0.7; transform: scale(1); }
                }

                /*CATEGORIE TABLE LIVRES*/
                .cat-books-table {
                    width: 100%; border-collapse: separate; border-spacing: 0;
                    border-radius: var(--radius-md); overflow: hidden;
                }
                .cat-books-table thead th {
                    background: var(--gold-glow); color: var(--gold);
                    font-family: 'Cinzel', serif; font-weight: 700; font-size: 0.85rem;
                    padding: 14px 20px; text-align: left; text-transform: uppercase;
                    letter-spacing: 1px; border-bottom: 2px solid var(--gold);
                }
                .cat-books-table thead th:last-child { text-align: center; }
                .cat-books-table tbody tr {
                    transition: all 0.3s;
                }
                .cat-books-table tbody tr:hover {
                    background: var(--gold-glow);
                }
                .cat-books-table tbody td {
                    padding: 14px 20px; font-size: 0.9rem; font-weight: 500;
                    color: var(--text-main); border-bottom: 1px solid var(--border-glass);
                    vertical-align: middle;
                }
                .cat-books-table tbody td:last-child { text-align: center; }
                .cat-books-table tbody tr:last-child td { border-bottom: none; }

                /* MISC */
                .toast {
                    position: fixed; bottom: 30px; left: 50%; transform: translateX(-50%) translateY(100px);
                    background: var(--gold); color: #fff; padding: 12px 25px; border-radius: 50px;
                    font-weight: 700; display: flex; align-items: center; gap: 10px; z-index: 2000;
                    box-shadow: 0 15px 30px var(--gold-glow); transition: 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
                }
                .toast.show { transform: translateX(-50%) translateY(0); }

                .fade-up { animation: fadeUp 0.7s ease-out forwards; opacity: 0; }
                @keyframes fadeUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

                .danger-zone {
                    border: 1px solid rgba(225, 29, 72, 0.2);
                    background: rgba(225, 29, 72, 0.05);
                    border-radius: var(--radius-lg);
                    padding: 1.5rem;
                    margin-top: 2rem;
                }

                /* styles de validation de formulaire */
                input:invalid:not(:placeholder-shown), select:invalid:not([value=""]), textarea:invalid:not(:placeholder-shown) {
                    border-color: var(--ruby) !important;
                    box-shadow: 0 0 0 2px rgba(225, 29, 72, 0.15);
                }
                input:valid:not(:placeholder-shown), select:valid, textarea:valid:not(:placeholder-shown) {
                    border-color: var(--emerald) !important;
                }
                input:required + .field-hint, select:required + .field-hint { display: none; }
                form:invalid .form-error-banner { display: block; }

                @media (max-width: 768px) {
                    .search-bar { grid-template-columns: 1fr; border-radius: 25px; }
                    .nav-link span { display: none; }
                    .book-card { flex-direction: column; text-align: center; }
                    .actions { justify-content: center; }
                    .form-grid-2 { grid-template-columns: 1fr !important; }
                    .detail-flex { flex-direction: column !important; text-align: center; }
                    .cat-layout { grid-template-columns: 1fr !important; }
                    .cat-books-table thead th, .cat-books-table tbody td { padding: 10px 12px; font-size: 0.8rem; }
                }
            </style>
        </head>
        <body>
            <canvas id="starfield"></canvas>

            <nav class="navbar">
                <div class="container nav-flex">
                    <a href="/" class="brand">
                        <span class="brand-icon-wrap"><i data-lucide="book-marked"></i></span>
                        <span class="brand-text">BookShelf</span>
                        <span class="brand-stars"><span>&#10022;</span><span>&#10022;</span><span>&#10022;</span></span>
                    </a>
                    <div style="display:flex; align-items:center; gap:15px;">
                        <ul class="nav-links">
                            <li><a href="/" class="nav-link"><i data-lucide="home"></i> <span>Accueil</span></a></li>
                            <li><a href="/add" class="nav-link"><i data-lucide="plus-square"></i> <span>Ajouter</span></a></li>
                            <li><a href="/categories" class="nav-link"><i data-lucide="layers"></i> <span>Catégories</span></a></li>
                        </ul>
                        <div class="theme-toggle" id="theme-btn"><i data-lucide="sun" id="theme-icon"></i></div>
                    </div>
                </div>
            </nav>

            <main class="container" style="padding-top: 3rem;">
                \(content)
            </main>

            <footer class="site-footer">
                <div class="footer-gold-line"></div>
                <div class="container">
                    <div class="footer-inner">
                        <div class="footer-stars" id="footer-stars"></div>
                        <div class="footer-brand"><i data-lucide="book-marked" style="width:20px; height:20px;"></i> BookShelf</div>
                        <div class="footer-divider"></div>
                        <div class="footer-credit">Projet de développement IOS - Lila MILOUDI - Licence 3 ISEI</div>
                        <div class="footer-year">Université Vincennes Saint Denis Paris 8, 2026</div>
                    </div>
                </div>
            </footer>

            \(toastJS)

            <script>
                lucide.createIcons();

                //Theme persistant (localStorage) :
                (function() {
                    var saved = localStorage.getItem('bookshelf-theme');
                    if (saved) {
                        document.documentElement.setAttribute('data-theme', saved);
                    }
                    var icon = document.getElementById('theme-icon');
                    if (icon) {
                        var current = document.documentElement.getAttribute('data-theme');
                        icon.setAttribute('data-lucide', current === 'dark' ? 'sun' : 'moon');
                        lucide.createIcons();
                    }
                })();

                document.getElementById('theme-btn').addEventListener('click', function() {
                    var html = document.documentElement;
                    var current = html.getAttribute('data-theme');
                    var next = current === 'dark' ? 'light' : 'dark';
                    html.setAttribute('data-theme', next);
                    localStorage.setItem('bookshelf-theme', next);
                    var icon = document.getElementById('theme-icon');
                    icon.setAttribute('data-lucide', next === 'dark' ? 'sun' : 'moon');
                    lucide.createIcons();
                });

                //Starfield (visible dans les deux modes) :
                (function() {
                    var c = document.getElementById('starfield');
                    var ctx = c.getContext('2d');
                    var stars = [];
                    function resize() { c.width = window.innerWidth; c.height = window.innerHeight; }
                    window.addEventListener('resize', resize);
                    resize();
                    for (var i = 0; i < 200; i++) {
                        stars.push({
                            x: Math.random() * c.width,
                            y: Math.random() * c.height,
                            r: Math.random() * 1.8 + 0.3,
                            o: Math.random(),
                            s: Math.random() * 0.005 + 0.002,
                            d: Math.random() > 0.5 ? 1 : -1
                        });
                    }
                    function draw() {
                        ctx.clearRect(0, 0, c.width, c.height);
                        var isDark = document.documentElement.getAttribute('data-theme') === 'dark';
                        for (var i = 0; i < stars.length; i++) {
                            var s = stars[i];
                            s.o += s.s * s.d;
                            if (s.o >= 1 || s.o <= 0.1) s.d *= -1;
                            if (isDark) {
                                ctx.globalAlpha = s.o;
                                ctx.fillStyle = '#d4af37';
                            } else {
                                ctx.globalAlpha = s.o * 0.55;
                                ctx.fillStyle = '#7c8db5';
                            }
                            ctx.beginPath();
                            ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
                            ctx.fill();
                        }
                        requestAnimationFrame(draw);
                    }
                    draw();
                })();

                //les étoiles du footer :
                (function() {
                    var container = document.getElementById('footer-stars');
                    if (!container) return;
                    for (var i = 0; i < 15; i++) {
                        var star = document.createElement('div');
                        star.className = 'footer-star';
                        star.style.left = Math.random() * 100 + '%';
                        star.style.top = Math.random() * 100 + '%';
                        star.style.animationDelay = Math.random() * 3 + 's';
                        star.style.animationDuration = (2 + Math.random() * 2) + 's';
                        container.appendChild(star);
                    }
                })();

                //Validation de formulaire (messages personnalisés) :
                document.querySelectorAll('form[method="post"]').forEach(function(form) {
                    form.addEventListener('submit', function(e) {
                        var fields = form.querySelectorAll('[required]');
                        var firstInvalid = null;
                        fields.forEach(function(f) {
                            var label = f.closest('div').querySelector('label');
                            var name = label ? label.textContent.trim() : f.name;
                            if (!f.value || f.value.trim() === '') {
                                f.setCustomValidity('Le champ "' + name + '" est obligatoire.');
                                if (!firstInvalid) firstInvalid = f;
                            } else { f.setCustomValidity(''); }
                        });
                        if (firstInvalid) {
                            e.preventDefault();
                            firstInvalid.reportValidity();
                        }
                    });
                    form.querySelectorAll('[required]').forEach(function(f) {
                        f.addEventListener('input', function() { f.setCustomValidity(''); });
                    });
                });

                //paillettes :
                document.querySelectorAll('.glass-card').forEach(function(card) {
                    var container = document.createElement('div');
                    container.className = 'sparkle-container';
                    card.appendChild(container);
                    for (var i = 0; i < 8; i++) {
                        var sparkle = document.createElement('div');
                        sparkle.className = 'sparkle';
                        sparkle.style.width = Math.random() * 4 + 2 + 'px';
                        sparkle.style.height = sparkle.style.width;
                        sparkle.style.left = Math.random() * 100 + '%';
                        sparkle.style.top = Math.random() * 100 + '%';
                        sparkle.style.animationDelay = Math.random() * 2 + 's';
                        container.appendChild(sparkle);
                    }
                });
            </script>
        </body>
        </html>
        """
    }


    static func starsHTML(rating: Int64) -> String {
        return (1...5).map { i in
            let color = i <= Int(rating) ? "var(--gold)" : "rgba(128,128,128,0.2)"
            let delay = Double(i) * 0.2
            return "<i data-lucide=\"star\" class=\"star-icon\" style=\"fill:\(color); color:\(color); animation-delay:\(delay)s;\"></i>"
        }.joined()
    }

    static func statusBadge(for status: String) -> String {
        switch status {
        case "Lu": return "<span class=\"badge badge-lu\"><i data-lucide=\"check-circle-2\" style=\"width:12px;\"></i> Lu</span>"
        case "En cours": return "<span class=\"badge badge-encours\"><i data-lucide=\"clock\" style=\"width:12px;\"></i> En cours</span>"
        default: return "<span class=\"badge badge-nonlu\"><i data-lucide=\"book-open\" style=\"width:12px;\"></i> À lire</span>"
        }
    }


    static func renderIndex(
        books: [Book],
        categories: [Category],
        stats: (total: Int, read: Int, reading: Int, unread: Int),
        search: String = "",
        sortBy: String = "",
        sortOrder: String = "asc"
    ) -> String {
        let categoryMap: [Int64: String] = {
            var m: [Int64: String] = [:]
            categories.forEach { c in if let id = c.id { m[id] = c.name } }
            return m
        }()

        let searchHTML = """
        <div class="fade-up">
            <form method="get" action="/" class="search-bar">
                <input type="search" name="search" placeholder="Rechercher un titre, un auteur..." value="\(escapeHTML(search))">
                <select name="sortBy">
                    <option value="">Trier par...</option>
                    <option value="title" \(sortBy == "title" ? "selected" : "")>Titre</option>
                    <option value="author" \(sortBy == "author" ? "selected" : "")>Auteur</option>
                    <option value="year" \(sortBy == "year" ? "selected" : "")>Année</option>
                    <option value="rating" \(sortBy == "rating" ? "selected" : "")>Note</option>
                </select>
                <select name="sortOrder">
                    <option value="asc" \(sortOrder == "asc" ? "selected" : "")>Croissant</option>
                    <option value="desc" \(sortOrder == "desc" ? "selected" : "")>Décroissant</option>
                </select>
                <button type="submit" class="btn-submit">Filtrer</button>
            </form>
        </div>
        """

        let booksHTML: String
        if books.isEmpty {
            booksHTML = """
            <div class="glass-card fade-up" style="text-align:center; padding: 4rem;">
                <i data-lucide="book-x" style="width:48px; height:48px; color:var(--text-dim); margin-bottom: 1rem; opacity: 0.3;"></i>
                <h3 style="color:var(--text-dim);">Aucun ouvrage trouvé</h3>
                <p>Commencez par enrichir votre collection.</p>
                <a href="/add" class="btn-submit" style="text-decoration:none; display:inline-block; padding: 12px 30px;">Ajouter un livre</a>
            </div>
            """
        } else {
            booksHTML = "<div class=\"book-grid fade-up\">" + books.map { book in
                let catName = categoryMap[book.categoryId] ?? "Général"
                let coverHTML = !book.imageUrl.isEmpty
                    ? "<img src=\"\(escapeHTML(book.imageUrl))\" alt=\"Couverture\">"
                    : "<i data-lucide=\"book-open-check\"></i>"
                return """
                <div class="glass-card book-card" onclick="window.location.href='/book/\(book.id ?? 0)'">
                    <div class="book-cover">\(coverHTML)</div>
                    <div class="book-info">
                        <div class="book-title">\(escapeHTML(book.title))</div>
                        <div class="book-author">\(escapeHTML(book.author))</div>
                        <div style="margin-bottom: 8px;">\(statusBadge(for: book.status))</div>
                        <div style="font-size: 0.75rem; color: var(--text-dim); font-weight: 700; display:flex; align-items:center; gap:5px;">
                            <i data-lucide="tag" style="width:12px;"></i> \(escapeHTML(catName)) • \(book.publicationYear)
                        </div>
                        <div class="stars">\(starsHTML(rating: book.rating))</div>
                        <div class="actions" onclick="event.stopPropagation()">
                            <a href="/edit/\(book.id ?? 0)" class="action-btn" title="Modifier"><i data-lucide="pencil"></i></a>
                            <form method="post" action="/toggle-status/\(book.id ?? 0)" style="margin:0;">
                                <button type="submit" class="action-btn" title="Changer Statut"><i data-lucide="refresh-cw"></i></button>
                            </form>
                            <form method="post" action="/delete/\(book.id ?? 0)" style="margin:0;" onsubmit="return confirm('Supprimer ce livre ?');">
                                <button type="submit" class="action-btn danger" title="Supprimer"><i data-lucide="trash-2"></i></button>
                            </form>
                        </div>
                    </div>
                </div>
                """
            }.joined() + "</div>"
        }

        let content = """
        <div class="fade-up" style="margin-bottom: 2rem; display:flex; justify-content:space-between; align-items:center;">
            <div>
                <h2 style="margin:0; font-family:'Cinzel',serif; color:var(--gold);">Ma Bibliothèque</h2>
                <p style="color:var(--text-dim); font-weight: 500;">Ma liste des livres personnels</p>
            </div>
            <div style="background:var(--gold-glow); color:var(--gold); padding: 8px 18px; border-radius: 12px; font-weight: 800; font-size: 0.9rem; border: 1px solid var(--gold);">
                \(books.count) LIVRE\(books.count > 1 ? "S" : "")
            </div>
        </div>
        
        <div style="display:grid; grid-template-columns: repeat(4, 1fr); gap: 1rem; margin-bottom: 2.5rem;" class="fade-up">
            <div class="glass-card" style="text-align:center; padding: 1rem;">
                <div style="font-size: 1.5rem; font-weight: 800; color: var(--gold);">\(stats.total)</div>
                <div style="font-size: 0.7rem; font-weight: 700; color: var(--text-dim); text-transform: uppercase;">Total</div>
            </div>
            <div class="glass-card" style="text-align:center; padding: 1rem;">
                <div style="font-size: 1.5rem; font-weight: 800; color: var(--emerald);">\(stats.read)</div>
                <div style="font-size: 0.7rem; font-weight: 700; color: var(--text-dim); text-transform: uppercase;">Lus</div>
            </div>
            <div class="glass-card" style="text-align:center; padding: 1rem;">
                <div style="font-size: 1.5rem; font-weight: 800; color: #f59e0b;">\(stats.reading)</div>
                <div style="font-size: 0.7rem; font-weight: 700; color: var(--text-dim); text-transform: uppercase;">En cours</div>
            </div>
            <div class="glass-card" style="text-align:center; padding: 1rem;">
                <div style="font-size: 1.5rem; font-weight: 800; color: var(--ruby);">\(stats.unread)</div>
                <div style="font-size: 0.7rem; font-weight: 700; color: var(--text-dim); text-transform: uppercase;">À lire</div>
            </div>
        </div>

        \(searchHTML)
        \(booksHTML)
        """
        return layout(title: "Accueil", content: content)
    }

    //Formulaire partagé (pas de layout, juste le formulaire) :
    static func renderFormContent(book: Book, categories: [Category], errors: [ValidationError], isEdit: Bool, actionUrl: String, cancelUrl: String = "/", fromContext: String = "") -> String {
        let catOpts = categories.map { c in
            "<option value=\"\(c.id ?? 0)\" \(c.id == book.categoryId ? "selected" : "")>\(escapeHTML(c.name))</option>"
        }.joined()

        return """
        \(renderErrors(errors))
        <div class="glass-card fade-up" style="padding: 2.5rem;">
            <form method="post" action="\(actionUrl)">
                <input type="hidden" name="_from" value="\(fromContext)">
                <div class="form-grid-2" style="display:grid; grid-template-columns: 1fr 1fr; gap: 2rem; margin-bottom: 1.5rem;">
                    <div style="display:flex; flex-direction:column; gap:8px;">
                        <label style="font-weight:700; font-size:0.85rem; color:var(--text-dim);">TITRE DU LIVRE</label>
                        <input type="text" name="title" value="\(escapeHTML(book.title))" placeholder="Ex: Harry Potter" required style="background:rgba(255,255,255,0.05); border:1px solid var(--border-glass); padding:12px; border-radius:10px; color:var(--text-main);">
                    </div>
                    <div style="display:flex; flex-direction:column; gap:8px;">
                        <label style="font-weight:700; font-size:0.85rem; color:var(--text-dim);">AUTEUR</label>
                        <input type="text" name="author" value="\(escapeHTML(book.author))" placeholder="Ex: J.K. Rowling" required style="background:rgba(255,255,255,0.05); border:1px solid var(--border-glass); padding:12px; border-radius:10px; color:var(--text-main);">
                    </div>
                </div>
                <div class="form-grid-2" style="display:grid; grid-template-columns: 1fr 1fr; gap: 2rem; margin-bottom: 1.5rem;">
                    <div style="display:flex; flex-direction:column; gap:8px;">
                        <label style="font-weight:700; font-size:0.85rem; color:var(--text-dim);">CATÉGORIE</label>
                        <select name="categoryId" required><option value="" disabled selected>Choisir...</option>\(catOpts)</select>
                    </div>
                    <div style="display:flex; flex-direction:column; gap:8px;">
                        <label style="font-weight:700; font-size:0.85rem; color:var(--text-dim);">ANNÉE</label>
                        <input type="number" name="publicationYear" value="\(book.publicationYear)" required min="0" max="2100" style="background:rgba(255,255,255,0.05); border:1px solid var(--border-glass); padding:12px; border-radius:10px; color:var(--text-main);">
                    </div>
                </div>
                <div class="form-grid-2" style="display:grid; grid-template-columns: 1fr 1fr; gap: 2rem; margin-bottom: 1.5rem;">
                    <div style="display:flex; flex-direction:column; gap:8px;">
                        <label style="font-weight:700; font-size:0.85rem; color:var(--text-dim);">NOTE</label>
                        <select name="rating">
                            <option value="1" \(book.rating == 1 ? "selected" : "")>★☆☆☆☆ Décevant</option>
                            <option value="2" \(book.rating == 2 ? "selected" : "")>★★☆☆☆ Moyen</option>
                            <option value="3" \(book.rating == 3 ? "selected" : "")>★★★☆☆ Bien</option>
                            <option value="4" \(book.rating == 4 ? "selected" : "")>★★★★☆ Excellent</option>
                            <option value="5" \(book.rating == 5 ? "selected" : "")>★★★★★ Chef-d'oeuvre</option>
                        </select>
                    </div>
                    <div style="display:flex; flex-direction:column; gap:8px;">
                        <label style="font-weight:700; font-size:0.85rem; color:var(--text-dim);">STATUT</label>
                        <select name="status">
                            <option value="Non lu" \(book.status == "Non lu" ? "selected" : "")>À lire</option>
                            <option value="En cours" \(book.status == "En cours" ? "selected" : "")>En cours</option>
                            <option value="Lu" \(book.status == "Lu" ? "selected" : "")>Terminé</option>
                        </select>
                    </div>
                </div>
                <div style="margin-bottom: 1.5rem; display:flex; flex-direction:column; gap:8px;">
                    <label style="font-weight:700; font-size:0.85rem; color:var(--text-dim);">URL DE L'IMAGE</label>
                    <input type="url" name="imageUrl" value="\(escapeHTML(book.imageUrl))" placeholder="https://..." style="background:rgba(255,255,255,0.05); border:1px solid var(--border-glass); padding:12px; border-radius:10px; color:var(--text-main);">
                </div>
                <div style="margin-bottom: 2rem; display:flex; flex-direction:column; gap:8px;">
                    <label style="font-weight:700; font-size:0.85rem; color:var(--text-dim);">NOTES</label>
                    <textarea name="notes" rows="3" style="background:rgba(255,255,255,0.05); border:1px solid var(--border-glass); padding:12px; border-radius:10px; color:var(--text-main);">\(escapeHTML(book.notes))</textarea>
                </div>
                <div style="display:flex; gap:1rem; justify-content:center;">
                    <a href="\(cancelUrl)" class="btn-cancel" style="padding:14px 30px;">Annuler</a>
                    <button type="submit" class="btn-submit" style="padding: 14px 40px; font-size: 1rem;">
                        \(isEdit ? "ENREGISTRER" : "AJOUTER")
                    </button>
                </div>
            </form>
        </div>
        """
    }

    //Ajout (avec layout) :
    static func renderAddForm(categories: [Category], errors: [ValidationError] = [], book: Book? = nil) -> String {
        let b = book ?? Book(id: nil, title: "", author: "", categoryId: 0, publicationYear: 2024, rating: 3, status: "Non lu", notes: "", imageUrl: "")

        let content = """
        <div class="fade-up" style="max-width: 800px; margin: 0 auto;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 2rem;">
                <h2 style="margin:0; font-family:'Cinzel',serif; color:var(--gold);">Ajouter un livre</h2>
                <a href="/" class="action-btn" style="width:auto; padding: 0 15px; gap: 8px; font-weight: 700; font-size: 0.8rem; text-decoration:none;">
                    <i data-lucide="arrow-left" style="width:16px;"></i> Retour
                </a>
            </div>
            \(renderFormContent(book: b, categories: categories, errors: errors, isEdit: false, actionUrl: "/create"))
        </div>
        """
        return layout(title: "Ajouter", content: content)
    }

    //Détails (lecture seule sans formulaire) :
    static func renderDetail(book: Book, categoryName: String, success: String? = nil, backUrl: String = "/", from: String = "") -> String {
        let coverHTML = !book.imageUrl.isEmpty
            ? "<img src=\"\(escapeHTML(book.imageUrl))\" alt=\"Couverture\" style=\"width:180px; height:260px; border-radius:15px; box-shadow:0 15px 30px rgba(0,0,0,0.5);\">"
            : "<div class=\"book-cover\" style=\"width:180px; height:260px;\"><i data-lucide=\"book-open-check\" style=\"width:48px; height:48px;\"></i></div>"

        let content = """
        <div style="max-width: 800px; margin: 0 auto;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 2rem;">
                <h2 style="margin:0; font-family:'Cinzel',serif; color:var(--gold);">Détails du livre</h2>
                <div style="display:flex; gap:10px;">
                    <a href="/edit/\(book.id ?? 0)\(from.isEmpty ? "" : "?from=\(from)")" class="btn-submit" style="text-decoration:none; display:inline-flex; align-items:center; gap:8px; padding: 10px 20px; font-size:0.85rem;">
                        <i data-lucide="pencil" style="width:16px;"></i> Modifier
                    </a>
                    <a href="\(backUrl)" class="action-btn" style="width:auto; padding: 0 15px; gap: 8px; font-weight: 700; font-size: 0.8rem; text-decoration:none;">
                        <i data-lucide="arrow-left" style="width:16px;"></i> Retour
                    </a>
                </div>
            </div>

            <div class="glass-card fade-up detail-flex" style="display:flex; gap:2.5rem; align-items:flex-start; margin-bottom: 2rem; padding: 2.5rem;">
                <div style="flex-shrink:0;">\(coverHTML)</div>
                <div style="flex:1;">
                    <div style="font-family:'Cinzel'; font-size:2rem; font-weight:800; color:var(--gold); margin-bottom:10px;">\(escapeHTML(book.title))</div>
                    <div style="font-size:1.2rem; font-weight:600; color:var(--text-dim); margin-bottom:15px;">par \(escapeHTML(book.author))</div>
                    <div style="display:flex; gap:15px; align-items:center; margin-bottom:20px; flex-wrap:wrap;">
                        \(statusBadge(for: book.status))
                        <span style="color:var(--text-dim); font-weight:700;"><i data-lucide='tag' style='width:14px; vertical-align:middle;'></i> \(escapeHTML(categoryName))</span>
                        <span style="color:var(--text-dim); font-weight:700;"><i data-lucide='calendar' style='width:14px; vertical-align:middle;'></i> \(book.publicationYear)</span>
                    </div>
                    <div class="stars" style="gap:5px;">\(starsHTML(rating: book.rating))</div>
                    \(book.notes.isEmpty ? "" : "<div style='margin-top:20px; padding:15px; background:rgba(255,255,255,0.03); border-radius:10px; border-left:4px solid var(--gold); font-style:italic; color:var(--text-dim);'>\"\(escapeHTML(book.notes))\"</div>")
                </div>
            </div>
        </div>
        """
        return layout(title: "\(book.title)", content: content,
                      showToast: success != nil ? "Modifications enregistrées" : nil)
    }

    //Modification (formulaire seul + zone de danger)
    static func renderEditForm(book: Book, categories: [Category], categoryName: String, errors: [ValidationError] = [], success: String? = nil, from: String = "") -> String {
        let detailUrl = "/book/\(book.id ?? 0)\(from.isEmpty ? "" : "?from=\(from)")"
        let content = """
        <div style="max-width: 800px; margin: 0 auto;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 2rem;">
                <h2 style="margin:0; font-family:'Cinzel',serif; color:var(--gold);">Modifier l'ouvrage</h2>
                <a href="\(detailUrl)" class="action-btn" style="width:auto; padding: 0 15px; gap: 8px; font-weight: 700; font-size: 0.8rem; text-decoration:none;">
                    <i data-lucide="arrow-left" style="width:16px;"></i> Retour aux détails
                </a>
            </div>

            \(renderFormContent(book: book, categories: categories, errors: errors, isEdit: true, actionUrl: "/update/\(book.id ?? 0)", cancelUrl: "\(detailUrl)", fromContext: from))

            <div class="danger-zone fade-up">
                <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem;">
                    <div>
                        <div style="font-family:'Cinzel',serif; font-weight:800; color:var(--ruby); margin-bottom:4px;">Zone de danger</div>
                        <div style="font-size:0.85rem; color:var(--text-dim);">Cette action est irréversible.</div>
                    </div>
                    <div style="display:flex; gap:8px;">
                        <a href="\(detailUrl)" class="btn-cancel" style="padding:10px 20px;">Annuler</a>
                        <form method="post" action="/delete/\(book.id ?? 0)" style="margin:0;" onsubmit="return confirm('Supprimer définitivement ?');">
                            <button type="submit" class="btn-submit" style="background:var(--ruby); padding:10px 20px;">Supprimer</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        """
        return layout(title: "Modifier — \(book.title)", content: content,
                      showToast: success != nil ? "Modifications enregistrées" : nil)
    }

    //Catégories (avec liens vers livres)
    static func renderCategories(categories: [Category], errors: [ValidationError] = [], success: String? = nil) -> String {
        let listHTML = categories.map { c in
            """
            <div class="glass-card fade-up" style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 1rem; padding: 1.2rem;">
                <a href="/categories/\(c.id ?? 0)" style="text-decoration:none; flex:1;">
                    <div style="font-family:'Cinzel'; font-weight:800; color:var(--gold); display:flex; align-items:center; gap:8px;">
                        \(escapeHTML(c.name))
                        <i data-lucide="chevron-right" style="width:16px; height:16px; color:var(--text-dim);"></i>
                    </div>
                    <div style="font-size:0.8rem; color:var(--text-dim);">\(escapeHTML(c.description))</div>
                </a>
                <form method="post" action="/categories/delete/\(c.id ?? 0)" style="margin:0;" onsubmit="return confirm('Supprimer ?');">
                    <button type="submit" class="action-btn danger"><i data-lucide="trash-2"></i></button>
                </form>
            </div>
            """
        }.joined()

        let content = """
        <div class="fade-up">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 2.5rem;">
                <h2 style="margin:0; font-family:'Cinzel',serif; color:var(--gold);">Gestion des Catégories</h2>
                <a href="/" class="action-btn" style="width:auto; padding: 0 15px; gap: 8px; font-weight: 700; font-size: 0.8rem; text-decoration:none;">
                    <i data-lucide="arrow-left" style="width:16px;"></i> Retour
                </a>
            </div>

            \(renderErrors(errors))

            <div class="cat-layout" style="display:grid; grid-template-columns: 1fr 1.5fr; gap: 3rem; align-items: start;">
                <div>
                    <h3 style="font-size: 1.2rem; margin-bottom: 1.5rem; color: var(--text-dim); font-family:'Cinzel',serif;">Nouvelle Catégorie</h3>
                    <div class="glass-card">
                        <form method="post" action="/categories/create">
                            <div style="margin-bottom: 1rem;">
                                <label style="font-weight:700; font-size:0.85rem; color:var(--text-dim);">NOM</label>
                                <input type="text" name="name" required minlength="2" placeholder="Ex: Manga" style="background:rgba(255,255,255,0.05); border:1px solid var(--border-glass); padding:12px; border-radius:10px; color:var(--text-main); width:100%;">
                            </div>
                            <div style="margin-bottom: 1.5rem;">
                                <label style="font-weight:700; font-size:0.85rem; color:var(--text-dim);">DESCRIPTION</label>
                                <textarea name="description" rows="3" placeholder="Description..." style="background:rgba(255,255,255,0.05); border:1px solid var(--border-glass); padding:12px; border-radius:10px; color:var(--text-main); width:100%;"></textarea>
                            </div>
                            <div style="display:flex; gap:0.8rem;">
                                <a href="/" class="btn-cancel" style="padding:10px 20px; flex:1; text-align:center;">Annuler</a>
                                <button type="submit" class="btn-submit" style="flex:1; padding: 10px;">CRÉER</button>
                            </div>
                        </form>
                    </div>
                </div>
                <div>
                    <h3 style="font-size: 1.2rem; margin-bottom: 1.5rem; color: var(--text-dim); font-family:'Cinzel',serif;">Liste (\(categories.count))</h3>
                    <p style="font-size:0.8rem; color:var(--text-dim); margin-bottom:1rem; font-style:italic;">Cliquez sur une catégorie pour voir ses livres.</p>
                    \(listHTML)
                </div>
            </div>
        </div>
        """
        return layout(title: "Catégories", content: content, showToast: success != nil ? "Mise à jour réussie" : nil)
    }


    //Livres par catégorie (NOUVELLE PAGE) :
    static func renderCategoryBooks(category: Category, books: [Book]) -> String {
        let tableHTML: String
        if books.isEmpty {
            tableHTML = """
            <div class="glass-card fade-up" style="text-align:center; padding: 3rem;">
                <i data-lucide="book-x" style="width:40px; height:40px; color:var(--text-dim); margin-bottom: 1rem; opacity: 0.3;"></i>
                <h3 style="color:var(--text-dim); margin-bottom: 0.5rem;">Aucun livre dans cette catégorie</h3>
                <p style="color:var(--text-dim); font-size:0.9rem;">Ajoutez un livre et assignez-le à cette catégorie.</p>
                <a href="/add" class="btn-submit" style="text-decoration:none; display:inline-block; padding: 10px 25px; margin-top: 1rem;">Ajouter un livre</a>
            </div>
            """
        } else {
            let rows = books.map { book in
                """
                <tr>
                    <td>
                        <div style="display:flex; align-items:center; gap:12px;">
                            <div style="font-family:'Cinzel',serif; font-weight:700; color:var(--gold);">\(escapeHTML(book.title))</div>
                        </div>
                    </td>
                    <td style="color:var(--text-dim); font-weight:500;">\(escapeHTML(book.author))</td>
                    <td>\(starsHTML(rating: book.rating))</td>
                    <td>\(statusBadge(for: book.status))</td>
                    <td>
                        <a href="/book/\(book.id ?? 0)?from=cat\(category.id ?? 0)" class="btn-detail">
                            <i data-lucide="eye" style="width:14px; height:14px;"></i> Détails
                        </a>
                    </td>
                </tr>
                """
            }.joined()

            tableHTML = """
            <div class="glass-card fade-up" style="padding: 0; overflow: hidden;">
                <table class="cat-books-table">
                    <thead>
                        <tr>
                            <th>Titre</th>
                            <th>Auteur</th>
                            <th>Note</th>
                            <th>Statut</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        \(rows)
                    </tbody>
                </table>
            </div>
            """
        }

        let content = """
        <div class="fade-up">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 2rem;">
                <div>
                    <h2 style="margin:0; font-family:'Cinzel',serif; color:var(--gold);">\(escapeHTML(category.name))</h2>
                    <p style="color:var(--text-dim); font-weight: 500; margin-top:4px;">\(escapeHTML(category.description))</p>
                </div>
                <div style="display:flex; gap:10px; align-items:center;">
                    <div style="background:var(--gold-glow); color:var(--gold); padding: 6px 14px; border-radius: 10px; font-weight: 800; font-size: 0.85rem; border: 1px solid var(--gold);">
                        \(books.count) LIVRE\(books.count > 1 ? "S" : "")
                    </div>
                    <a href="/categories" class="action-btn" style="width:auto; padding: 0 15px; gap: 8px; font-weight: 700; font-size: 0.8rem; text-decoration:none;">
                        <i data-lucide="arrow-left" style="width:16px;"></i> Retour
                    </a>
                </div>
            </div>

            \(tableHTML)
        </div>
        """
        return layout(title: "\(category.name)", content: content)
    }

   // Gestion des erreurs de validation (affichage dans les formulaires) :
    static func renderErrors(_ errors: [ValidationError]) -> String {
        if errors.isEmpty { return "" }
        let items = errors.map { "<li>\(escapeHTML($0.message))</li>" }.joined()
        return """
        <div class="glass-card fade-up" style="border-color: var(--ruby); background: rgba(225, 29, 72, 0.1); margin-bottom: 2rem; padding: 1.2rem;">
            <div style="color:var(--ruby); font-weight:800; margin-bottom: 0.5rem; display:flex; align-items:center; gap:8px;">
                <i data-lucide="alert-circle" style="width:18px;"></i> Erreur de validation
            </div>
            <ul style="margin:0; padding-left: 1.5rem; font-size: 0.85rem; color: var(--ruby); font-weight: 600;">\(items)</ul>
        </div>
        """
    }

    static func escapeHTML(_ str: String) -> String {
        return str.replacingOccurrences(of: "&", with: "&amp;")
                  .replacingOccurrences(of: "<", with: "&lt;")
                  .replacingOccurrences(of: ">", with: "&gt;")
                  .replacingOccurrences(of: "\"", with: "&quot;")
                  .replacingOccurrences(of: "'", with: "&#39;")
    }
}