/* ─────────────────────────────────────────────────────────────────────────
   Ilovani ishga tushirish: tema, Android "orqaga" tugmasi, status bar.
   Bularning hech biri dizaynga tegmaydi — qurilma bilan muloqot qatlami.
   ───────────────────────────────────────────────────────────────────── */

(function () {
  const root = document.getElementById('nz-root');
  const tpl = document.getElementById('nz-tpl');

  /* ── Tema: qurilma sozlamasidan (Android tungi rejimi) ── */
  const mq = window.matchMedia('(prefers-color-scheme: dark)');
  const themeOf = () => (mq.matches ? 'dark' : 'light');

  const app = mount(Component, { defaultTheme: themeOf() }, root, tpl);

  function syncChrome() {
    const dark = app.state.theme === 'dark';
    const bg = dark ? '#14121F' : '#F5F3FF';
    const meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.setAttribute('content', bg);
    const sb = window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.StatusBar;
    if (sb) {
      sb.setStyle({ style: dark ? 'DARK' : 'LIGHT' }).catch(() => {});
      sb.setBackgroundColor({ color: bg }).catch(() => {});
    }
  }

  mq.addEventListener('change', () => { app.setState({ theme: themeOf() }); });

  // Tema o'zgarganda status bar ham ergashsin
  const origSetState = app.setState.bind(app);
  app.setState = function (patch) { origSetState(patch); syncChrome(); };
  syncChrome();

  /* ── Android "orqaga" tugmasi ──────────────────────────────────────────
     Standart xulq: WebView'da orqaga bosilsa ilova darhol yopiladi.
     Bu yerda orqaga tugmasi ilovaning O'Z ierarxiyasi bo'yicha yuradi:
     ochiq oyna → test → tab → bosh ekran → chiqish (ikki marta bosish).  */
  let lastBack = 0;

  function toast(text) {
    const t = window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Toast;
    if (t) t.show({ text: text, duration: 'short' }).catch(() => {});
  }

  function handleBack() {
    const s = app.state;
    const CapApp = window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.App;

    if (s.bulk) return app.setState({ bulk: null });
    if (s.confirm) return app.setState({ confirm: null });
    if (s.drawer) return app.setState({ drawer: null, piiShown: false });
    if (s.pay) return app.setState({ pay: null });
    if (s.proView) return app.setState({ proView: false });
    if (s.quiz) return app.setState({ quiz: null });
    if (s.tab !== 'home') return app.setState({ tab: 'home' });

    if (Date.now() - lastBack < 2000) { if (CapApp) CapApp.exitApp(); return; }
    lastBack = Date.now();
    toast('Chiqish uchun yana bir marta bosing');
  }

  function wireBack() {
    const CapApp = window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.App;
    if (CapApp && CapApp.addListener) CapApp.addListener('backButton', handleBack);
  }

  if (window.Capacitor) wireBack();
  else document.addEventListener('deviceready', wireBack, { once: true });

  /* Splash — ilova chizilgandan keyin yopiladi (oq ekran ko'rinmasin) */
  requestAnimationFrame(() => {
    const sp = window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.SplashScreen;
    if (sp) sp.hide().catch(() => {});
  });
})();
