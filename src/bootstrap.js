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

  /* Ilova nusxasi tashqariga ochiladi: admin qatlami (admin-boot.js)
     bazadan kelgan ma'lumotni shu orqali holatga yozadi. Bu yagona
     tashqi nuqta — boshqa hech qanday global holat yo'q. */
  window.nzApp = app;

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

  /* ── Sozlamalarni qurilma qatlamiga ulash ────────────────────────────
     Dizayn sozlamalarni state'da ushlaydi ("Ovoz: Yoniq"), lekin ularni
     bajarish qurilma qatlamining ishi. Har setState'dan keyin holat
     qatlamlarga ko'chiriladi — shunda sozlama va haqiqiy xulq bir-biridan
     ajralib qolmaydi (ilgari "Ovoz" tugmasi faqat yozuvni o'zgartirardi). */
  let firstSync = true;

  function syncSettings() {
    if (window.nzFeedback) window.nzFeedback.setEnabled(app.state.soundOn);
    if (window.nzNotify) {
      // Ruxsat rad etilsa sozlama "yoniq" ko'rinib, aslida hech narsa
      // kelmasligi mumkin emas — holat haqiqatga qaytariladi.
      // setEnabled o'zgarish bo'lmasa qayta ishlamaydi, shuning uchun bu
      // setState qaytalanuvchi tsikl yaratmaydi.
      //
      // interactive: birinchi sinxronizatsiya ilova ochilishida bo'ladi —
      // unda ruxsat SO'RALMAYDI va xato ham ko'rsatilmaydi. Foydalanuvchi
      // tugmani o'zi bosgandan keyingina tizim oynasi chiqadi.
      const first = firstSync;
      firstSync = false;
      window.nzNotify.setEnabled(app.state.notifOn, {
        interactive: !first,
        onDenied: function (reason) {
          app.setState({ notifOn: false });
          if (reason === 'denied') {
            toast('Bildirishnomaga ruxsat berilmagan — tizim sozlamalaridan yoqing');
          }
        }
      });
    }
  }

  // Tema o'zgarganda status bar ham ergashsin
  const origSetState = app.setState.bind(app);
  app.setState = function (patch) { origSetState(patch); syncChrome(); syncSettings(); };
  syncChrome();
  syncSettings();

  /* Bildirishnoma sozlamasi faqat u HAQIQATAN mumkin bo'lgan joyda
     ko'rsatiladi: APK ichida plagin bor, brauzerda yo'q. Bosib
     bo'lmaydigan qator ko'rsatgandan ko'ra uni butunlay yashirish
     halolroq. */
  if (window.nzNotify && window.nzNotify.available()) app.setState({ notifAvailable: true });

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

  /* ── Savollar bazasi ────────────────────────────────────────────────
     Ilova APK ichidagi savollar bilan DARHOL ishlay boshlaydi; baza esa
     orqa fonda so'raladi va muvaffaq bo'lsa bankni almashtiradi.
     Shuning uchun sekin yoki yo'q internet ilovani kutdirmaydi.

     canSwap: test davom etayotganda bankni almashtirish MUMKIN EMAS —
     savol indekslari pool'ga bog'langan, bank o'zgarsa foydalanuvchi
     boshqa savolga javob bergan bo'lib qoladi. Bunday holda yangilanish
     saqlanadi va keyingi ochilishda qo'llanadi. */
  if (window.nzData) {
    const canSwap = () => !app.state.quiz;
    const redraw = () => app.setState({});
    window.nzData.sync(app.state.lang, canSwap, redraw);

    /* Til almashganda savol matni ham o'sha tilga o'tishi kerak —
       tarjima bazada saqlanadi (question_translations). */
    const origSetLangSync = syncSettings;
    let lastLang = app.state.lang;
    syncSettings = function () {
      origSetLangSync();
      if (app.state.lang !== lastLang) {
        lastLang = app.state.lang;
        if (!app.state.quiz && window.nzData.applyLang(app.state.lang)) app.setState({});
      }
    };
  }

  /* Splash — ilova chizilgandan keyin yopiladi (oq ekran ko'rinmasin) */
  requestAnimationFrame(() => {
    const sp = window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.SplashScreen;
    if (sp) sp.hide().catch(() => {});
  });
})();
