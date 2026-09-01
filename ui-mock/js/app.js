(function () {
  const $ = (sel, root) => (root || document).querySelector(sel);
  const $$ = (sel, root) => Array.from((root || document).querySelectorAll(sel));

  const state = {
    role: sessionStorage.getItem("kh_role") || null,
    screen: null,
  };

  const views = {
    login: $("#view-login"),
    mobile: $("#view-mobile"),
    admin: $("#view-admin"),
  };

  function setHash(role, screenId) {
    location.hash = `#/${role}/${screenId}`;
  }

  function parseHash() {
    const m = location.hash.match(/^#\/(login|customer|vendor|admin)(?:\/([A-Z]{3}-S\d{2}))?$/i);
    if (!m) return null;
    const role = m[1].toLowerCase();
    if (role === "login") return { role: "login", screen: null };
    return { role, screen: (m[2] || "").toUpperCase() || null };
  }

  function showView(name) {
    views.login.classList.toggle("hidden", name !== "login");
    views.mobile.classList.toggle("hidden", name !== "mobile");
    views.admin.classList.toggle("hidden", name !== "admin");
    document.body.classList.toggle("has-mobile-shell", name === "mobile");
  }

  function loginAs(role) {
    sessionStorage.setItem("kh_role", role);
    state.role = role;
    const def = KH_NAV[role].default;
    setHash(role, def);
  }

  function logout() {
    sessionStorage.removeItem("kh_role");
    state.role = null;
    state.screen = null;
    location.hash = "#/login";
    route();
  }

  function wireLogin() {
    $$("[data-role]").forEach((btn) => {
      btn.addEventListener("click", () => loginAs(btn.dataset.role));
    });
  }

  function renderBottomNav(role, activeId) {
    const nav = $("#bottom-nav");
    const tabs = KH_NAV[role].tabs || [];
    nav.innerHTML = tabs
      .map((t) => {
        const active = t.screen === activeId || isTabActive(role, t, activeId);
        return `<a href="#/${role}/${t.screen}" class="${active ? "is-active" : ""}" data-tab="${t.id}">
          <span class="nav-icon" aria-hidden="true">${t.icon}</span>
          <span>${t.label}</span>
        </a>`;
      })
      .join("");
  }

  function isTabActive(role, tab, screenId) {
    // Light heuristic: child screens light parent tab
    const map = {
      customer: {
        home: ["CUS-S02", "CUS-S03", "CUS-S04", "CUS-S05", "CUS-S06", "CUS-S07", "CUS-S08", "CUS-S09"],
        requests: ["CUS-S10", "CUS-S11", "CUS-S12", "CUS-S13", "CUS-S14", "CUS-S17"],
        connections: ["CUS-S15", "CUS-S16", "CUS-S18", "CUS-S22"],
        notifications: ["CUS-S19"],
        profile: ["CUS-S20", "CUS-S21", "CUS-S01"],
      },
      vendor: {
        dashboard: ["VEN-S05"],
        requests: ["VEN-S06", "VEN-S07", "VEN-S08", "VEN-S09"],
        offers: ["VEN-S10", "VEN-S11", "VEN-S14"],
        connections: ["VEN-S12", "VEN-S13", "VEN-S19", "VEN-S21"],
        more: ["VEN-S15", "VEN-S16", "VEN-S17", "VEN-S18", "VEN-S20", "VEN-S22", "VEN-S01", "VEN-S02", "VEN-S03", "VEN-S04"],
      },
    };
    const pack = map[role];
    if (!pack) return false;
    return (pack[tab.id] || []).includes(screenId);
  }

  function renderAdminNav(activeId) {
    const nav = $("#admin-nav");
    const items = KH_NAV.admin.screens.filter((s) => s.id !== "ADM-S01");
    nav.innerHTML = items
      .map(
        (s) =>
          `<a href="#/admin/${s.id}" class="${s.id === activeId ? "is-active" : ""}">${s.title}</a>`
      )
      .join("");
  }

  function openScreenMap() {
    const role = state.role;
    if (!role || role === "login") return;
    const list = $("#screen-map-list");
    list.innerHTML = KH_NAV[role].screens
      .map(
        (s) =>
          `<a href="#/${role}/${s.id}" data-close-map><span>${s.title}</span><span class="sid">${s.id}</span></a>`
      )
      .join("");
    $("#screen-map").classList.add("is-open");
  }

  function closeScreenMap() {
    $("#screen-map").classList.remove("is-open");
  }

  async function loadScreen(role, screenId) {
    const meta = KH_NAV.find(role, screenId);
    if (!meta) {
      const fallback = KH_NAV[role].default;
      setHash(role, fallback);
      return;
    }
    state.screen = screenId;
    const path = `screens/${role}/${meta.file}`;
    const root = role === "admin" ? $("#admin-screen-root") : $("#screen-root");

    root.innerHTML = `<p class="field-hint">Loading ${screenId}…</p>`;

    try {
      const res = await fetch(path);
      if (!res.ok) throw new Error(res.status + " " + path);
      const html = await res.text();
      root.innerHTML = html;
    } catch (err) {
      root.innerHTML = `
        <div class="notice notice-error">
          <strong>Could not load ${screenId}</strong><br/>
          ${String(err.message)}<br/><br/>
          Open this mock via a local server, e.g.<br/>
          <code>npx serve ui-mock</code>
        </div>`;
      console.error(err);
    }

    // Chrome
    if (role === "admin") {
      showView("admin");
      $("#admin-title").textContent = meta.title;
      $("#admin-screen-id").textContent = screenId;
      renderAdminNav(screenId);
      views.admin.classList.remove("sidebar-open");
    } else {
      showView("mobile");
      $("#top-title").textContent = meta.title;
      $("#screen-id-pill").textContent = screenId;
      views.mobile.classList.toggle("is-restricted", !!meta.restricted);
      renderBottomNav(role, screenId);
      const back = $("#btn-back");
      if (meta.parent) {
        back.style.visibility = "visible";
        back.onclick = () => setHash(role, meta.parent);
      } else {
        back.style.visibility = "hidden";
        back.onclick = null;
      }
    }

    // Intercept in-screen links that use data-nav
    $$("[data-nav]", root).forEach((el) => {
      el.addEventListener("click", (e) => {
        e.preventDefault();
        const target = el.getAttribute("data-nav");
        if (target) setHash(role, target);
      });
    });

    if (window.KHGoldLight) KHGoldLight.init(root);
  }

  function route() {
    const parsed = parseHash();
    if (!parsed || parsed.role === "login") {
      showView("login");
      if (window.KHGoldLight) KHGoldLight.init(views.login);
      return;
    }
    const role = parsed.role;
    if (!sessionStorage.getItem("kh_role")) {
      sessionStorage.setItem("kh_role", role);
    }
    state.role = role;
    const screen = parsed.screen || KH_NAV[role].default;
    if (!parsed.screen) {
      setHash(role, screen);
      return;
    }
    loadScreen(role, screen);
  }

  function setExplainOpen(open) {
    const panel = $("#explain-panel");
    const fab = $("#btn-explain-open");
    if (!panel) return;
    panel.classList.toggle("is-open", open);
    document.body.classList.toggle("explain-open", open);
    if (fab) fab.setAttribute("aria-expanded", open ? "true" : "false");
    try {
      sessionStorage.setItem("kh_explain_open", open ? "1" : "0");
    } catch (_) {}
  }

  async function loadExplanationPanel() {
    const body = $("#explain-panel-body");
    if (!body) return;
    try {
      const res = await fetch("docs/explanation-side.html");
      if (!res.ok) throw new Error(String(res.status));
      body.innerHTML = await res.text();
    } catch (err) {
      body.innerHTML = `
        <div class="explain-inner">
          <h2 class="explain-title">UI Mock guide</h2>
          <p class="explain-lead">Could not load side panel content. Open the full export instead.</p>
          <a class="explain-export" href="docs/EXPLANATION.md" target="_blank" rel="noopener">Open EXPLANATION.md ↗</a>
          <p class="field-hint" style="margin-top:1rem">${String(err.message)}</p>
        </div>`;
    }
  }

  function wireExplainPanel() {
    const openBtn = $("#btn-explain-open");
    const closeBtn = $("#btn-explain-close");
    openBtn?.addEventListener("click", () => setExplainOpen(true));
    closeBtn?.addEventListener("click", () => setExplainOpen(false));
    // Backdrop click (mobile pseudo-element): click outside panel
    document.addEventListener("click", (e) => {
      if (!document.body.classList.contains("explain-open")) return;
      if (window.matchMedia("(min-width: 1100px)").matches) return;
      const panel = $("#explain-panel");
      if (!panel?.classList.contains("is-open")) return;
      if (panel.contains(e.target) || openBtn?.contains(e.target)) return;
      // Only if click is on body overlay area — ignore if target is interactive app
      if (e.target === document.body || e.target === document.documentElement) {
        setExplainOpen(false);
      }
    });
    // Escape closes
    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape" && document.body.classList.contains("explain-open")) {
        if (window.matchMedia("(max-width: 1099px)").matches) setExplainOpen(false);
      }
    });

    // Default: open on wide screens first visit
    let preferOpen = true;
    try {
      const saved = sessionStorage.getItem("kh_explain_open");
      if (saved === "0") preferOpen = false;
      if (saved === "1") preferOpen = true;
      if (saved == null && window.matchMedia("(max-width: 1099px)").matches) preferOpen = false;
    } catch (_) {
      preferOpen = window.matchMedia("(min-width: 1100px)").matches;
    }
    setExplainOpen(preferOpen);
    loadExplanationPanel();
  }

  function wireChrome() {
    $("#btn-logout")?.addEventListener("click", logout);
    $("#btn-admin-logout")?.addEventListener("click", logout);
    $("#btn-screen-map")?.addEventListener("click", openScreenMap);
    $("#btn-admin-map")?.addEventListener("click", openScreenMap);
    $("#btn-map-close")?.addEventListener("click", closeScreenMap);
    $("#screen-map")?.addEventListener("click", (e) => {
      if (e.target.id === "screen-map" || e.target.closest("[data-close-map]")) {
        closeScreenMap();
      }
    });
    $("#btn-admin-menu")?.addEventListener("click", () => {
      views.admin.classList.toggle("sidebar-open");
    });
    $("#admin-backdrop")?.addEventListener("click", () => {
      views.admin.classList.remove("sidebar-open");
    });
  }

  wireLogin();
  wireChrome();
  wireExplainPanel();
  window.addEventListener("hashchange", route);
  if (!location.hash) location.hash = "#/login";
  route();
})();
