/* ============================================================
   CRAVING HOSPITALITY — interactions
   ============================================================ */
(function () {
  "use strict";
  var WHATSAPP = "96171590222";
  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var $ = function (s, c) { return (c || document).querySelector(s); };
  var $$ = function (s, c) { return Array.prototype.slice.call((c || document).querySelectorAll(s)); };

  /* ---------- analytics helper (no-op until GA present) ---------- */
  function track(name, params) {
    try { if (typeof window.gtag === "function") window.gtag("event", name, params || {}); } catch (e) {}
    // also dataLayer push for GTM compatibility
    try { (window.dataLayer = window.dataLayer || []).push(Object.assign({ event: name }, params || {})); } catch (e) {}
  }
  // auto-track tagged clicks
  document.addEventListener("click", function (e) {
    var el = e.target.closest("[data-track]");
    if (el) track(el.getAttribute("data-track"), { label: el.getAttribute("data-track-label") || el.textContent.trim().slice(0, 40) });
  });

  /* ---------- preloader ---------- */
  window.addEventListener("load", function () {
    var l = $("#loader");
    if (l) { setTimeout(function () { l.classList.add("hide"); }, 300); }
  });
  // safety: hide loader even if load is slow
  setTimeout(function () { var l = $("#loader"); if (l) l.classList.add("hide"); }, 2600);

  /* ---------- nav scroll state ---------- */
  var nav = $("#nav");
  function onScroll() {
    if (!nav) return;
    if (window.scrollY > 40) nav.classList.add("nav--scrolled");
    else nav.classList.remove("nav--scrolled");
  }
  window.addEventListener("scroll", onScroll, { passive: true });
  onScroll();

  /* ---------- mobile menu ---------- */
  var burger = $("#burger"), mobile = $("#mobile"), mClose = $("#mobileClose");
  function setMenu(open) {
    if (!mobile) return;
    mobile.classList.toggle("open", open);
    if (burger) burger.setAttribute("aria-expanded", open ? "true" : "false");
    document.body.style.overflow = open ? "hidden" : "";
  }
  if (burger) burger.addEventListener("click", function () { setMenu(!mobile.classList.contains("open")); });
  if (mClose) mClose.addEventListener("click", function () { setMenu(false); });
  $$(".mobile__links a").forEach(function (a) { a.addEventListener("click", function () { setMenu(false); }); });
  document.addEventListener("keydown", function (e) { if (e.key === "Escape") setMenu(false); });

  /* ---------- reveal on scroll ---------- */
  var reveals = $$(".reveal");
  if (reduceMotion || !("IntersectionObserver" in window)) {
    reveals.forEach(function (el) { el.classList.add("in"); });
  } else {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (en.isIntersecting) { en.target.classList.add("in"); io.unobserve(en.target); }
      });
    }, { threshold: 0.12, rootMargin: "0px 0px -8% 0px" });
    reveals.forEach(function (el) { io.observe(el); });
  }

  /* ---------- subtle hero parallax ---------- */
  var pfx = $$("[data-parallax]");
  if (!reduceMotion && pfx.length && window.matchMedia("(pointer:fine)").matches) {
    var ticking = false;
    window.addEventListener("scroll", function () {
      if (ticking) return; ticking = true;
      requestAnimationFrame(function () {
        var y = window.scrollY;
        pfx.forEach(function (el) {
          var sp = parseFloat(el.getAttribute("data-parallax")) || 0.08;
          el.style.transform = "translate3d(0," + (y * sp) + "px,0)";
        });
        ticking = false;
      });
    }, { passive: true });
  }

  /* ---------- footer year ---------- */
  var yr = $("#year"); if (yr) yr.textContent = new Date().getFullYear();

  /* ============================================================
     INQUIRY (bookmark) — soft flagging of menu items
     ============================================================ */
  var STORE = "craving_inquiry";
  function getFlags() { try { return JSON.parse(localStorage.getItem(STORE) || "[]"); } catch (e) { return []; } }
  function setFlags(a) { try { localStorage.setItem(STORE, JSON.stringify(a)); } catch (e) {} updateFlagUI(); }
  function updateFlagUI() {
    var flags = getFlags();
    $$(".bookmark").forEach(function (b) {
      var on = flags.indexOf(b.getAttribute("data-item")) > -1;
      b.classList.toggle("is-on", on);
      b.setAttribute("aria-pressed", on ? "true" : "false");
    });
    $$("[data-flag-count]").forEach(function (c) {
      c.textContent = flags.length;
      c.parentElement && c.parentElement.classList.toggle("hidden", flags.length === 0);
    });
    // prefill any inquiry textarea marker
    $$("[data-flag-list]").forEach(function (t) { t.value = flags.join(", "); });
  }
  $$(".bookmark").forEach(function (b) {
    b.addEventListener("click", function () {
      var id = b.getAttribute("data-item"); var flags = getFlags(); var i = flags.indexOf(id);
      if (i > -1) flags.splice(i, 1); else { flags.push(id); track("add_to_inquiry", { item: id }); }
      setFlags(flags);
    });
  });
  updateFlagUI();

  /* ============================================================
     MENU — category toggle + protein filters
     ============================================================ */
  var catBtns = $$("[data-cat]");
  catBtns.forEach(function (btn) {
    btn.addEventListener("click", function () {
      var cat = btn.getAttribute("data-cat");
      catBtns.forEach(function (b) { b.classList.toggle("is-active", b === btn); b.setAttribute("aria-pressed", b === btn ? "true" : "false"); });
      var target = $("#sec-" + cat);
      if (target) {
        var top = target.getBoundingClientRect().top + window.scrollY - 120;
        window.scrollTo({ top: top, behavior: reduceMotion ? "auto" : "smooth" });
      }
    });
  });
  var chips = $$("[data-filter]");
  chips.forEach(function (chip) {
    chip.addEventListener("click", function () {
      var f = chip.getAttribute("data-filter");
      var active = chip.classList.contains("is-active");
      chips.forEach(function (c) { c.classList.remove("is-active"); c.setAttribute("aria-pressed", "false"); });
      if (!active) { chip.classList.add("is-active"); chip.setAttribute("aria-pressed", "true"); }
      var filter = active ? "all" : f;
      $$("[data-tags]").forEach(function (card) {
        var show = filter === "all" || card.getAttribute("data-tags").indexOf(filter) > -1;
        card.style.display = show ? "" : "none";
      });
      track("menu_filter", { filter: filter });
    });
  });

  /* ============================================================
     GALLERY — filter tabs + lightbox
     ============================================================ */
  var gtabs = $$("[data-gfilter]");
  gtabs.forEach(function (t) {
    t.addEventListener("click", function () {
      var f = t.getAttribute("data-gfilter");
      gtabs.forEach(function (x) { x.classList.toggle("is-active", x === t); x.setAttribute("aria-pressed", x === t ? "true" : "false"); });
      $$(".gitem").forEach(function (it) {
        it.classList.toggle("hide", !(f === "all" || it.getAttribute("data-gcat") === f));
      });
    });
  });

  var lb = $("#lightbox");
  if (lb) {
    var lbImg = $("#lbImg"), items = [], idx = 0;
    function refreshItems() { items = $$(".gitem:not(.hide)"); }
    function openLb(i) {
      refreshItems(); idx = i;
      var node = items[idx]; if (!node) return;
      lbImg.src = node.getAttribute("data-full") || node.querySelector("img").src;
      lbImg.alt = node.querySelector("img").alt || "Craving Hospitality";
      lb.classList.add("open"); document.body.style.overflow = "hidden";
      track("gallery_open", {});
    }
    function closeLb() { lb.classList.remove("open"); document.body.style.overflow = ""; }
    function step(d) { refreshItems(); idx = (idx + d + items.length) % items.length; var n = items[idx]; if (n) { lbImg.src = n.getAttribute("data-full") || n.querySelector("img").src; lbImg.alt = n.querySelector("img").alt; } }
    $$(".gitem").forEach(function (it, i) {
      it.addEventListener("click", function () { refreshItems(); openLb(items.indexOf(it)); });
    });
    $("#lbClose").addEventListener("click", closeLb);
    $("#lbPrev").addEventListener("click", function () { step(-1); });
    $("#lbNext").addEventListener("click", function () { step(1); });
    lb.addEventListener("click", function (e) { if (e.target === lb) closeLb(); });
    document.addEventListener("keydown", function (e) {
      if (!lb.classList.contains("open")) return;
      if (e.key === "Escape") closeLb();
      if (e.key === "ArrowLeft") step(-1);
      if (e.key === "ArrowRight") step(1);
    });
    // swipe
    var sx = 0;
    lb.addEventListener("touchstart", function (e) { sx = e.touches[0].clientX; }, { passive: true });
    lb.addEventListener("touchend", function (e) { var dx = e.changedTouches[0].clientX - sx; if (Math.abs(dx) > 50) step(dx < 0 ? 1 : -1); });
  }

  /* ============================================================
     MULTI-STEP FORM  ->  WhatsApp
     ============================================================ */
  $$("[data-multistep]").forEach(function (form) {
    var steps = $$(".fstep", form);
    var pSteps = $$(".progress__step", form);
    var cur = 0;
    function show(n) {
      cur = Math.max(0, Math.min(steps.length - 1, n));
      steps.forEach(function (s, i) { s.classList.toggle("active", i === cur); });
      pSteps.forEach(function (p, i) {
        p.classList.toggle("active", i === cur);
        p.classList.toggle("done", i < cur);
      });
      var back = $(".js-back", form), next = $(".js-next", form), submit = $(".js-submit", form);
      if (back) back.classList.toggle("hidden", cur === 0);
      if (next) next.classList.toggle("hidden", cur === steps.length - 1);
      if (submit) submit.classList.toggle("hidden", cur !== steps.length - 1);
      var top = form.getBoundingClientRect().top + window.scrollY - 110;
      if (window.scrollY > top + 60) window.scrollTo({ top: top, behavior: reduceMotion ? "auto" : "smooth" });
    }
    function validate(n) {
      var ok = true;
      $$(".fstep", form)[n].querySelectorAll("[required]").forEach(function (f) {
        if (!f.value || (f.type === "checkbox" && !f.checked)) { ok = false; f.classList.add("err"); f.style.borderColor = "var(--coral-deep)"; }
        else { f.classList.remove("err"); f.style.borderColor = ""; }
      });
      // require at least one checkbox in a [data-require-group]
      $$("[data-require-group]", $$(".fstep", form)[n]).forEach(function (g) {
        if (!g.querySelector("input:checked")) ok = false;
      });
      if (!ok) { var e = $$(".fstep", form)[n].querySelector(".err"); if (e) e.focus(); }
      return ok;
    }
    var nextBtn = $(".js-next", form), backBtn = $(".js-back", form);
    if (nextBtn) nextBtn.addEventListener("click", function () { if (validate(cur)) { show(cur + 1); track("form_step", { step: cur + 1 }); } });
    if (backBtn) backBtn.addEventListener("click", function () { show(cur - 1); });

    form.addEventListener("submit", function (e) {
      e.preventDefault();
      if (!validate(cur)) return;
      var fd = new FormData(form);
      var lines = ["Hi Craving Hospitality! I'd like to plan an event. *"];
      var labels = {
        eventType: "Event type", eventDate: "Date", guests: "Guests",
        categories: "Food", dietary: "Dietary notes", budget: "Budget",
        name: "Name", phone: "Phone", email: "Email", contactPref: "Preferred contact", message: "Message"
      };
      // gather multi-checkbox categories
      var cats = fd.getAll("categories"); if (cats.length) fd.set("categories", cats.join(", "));
      var msg = ["Hi Craving Hospitality! 👋 I'd like to plan an event:\n"];
      Object.keys(labels).forEach(function (k) {
        var v = fd.get(k);
        if (v && String(v).trim()) msg.push("• " + labels[k] + ": " + v);
      });
      // include flagged menu items
      var flags = getFlags();
      if (flags.length) msg.push("• Loved on the menu: " + flags.join(", "));
      var url = "https://wa.me/" + WHATSAPP + "?text=" + encodeURIComponent(msg.join("\n"));
      track("form_submit", { form: form.getAttribute("data-multistep") });
      // show success + open WhatsApp
      var succ = $(".success", form.parentElement) || $(".success", form);
      var card = form;
      if (succ) { form.style.display = "none"; succ.classList.add("show"); var link = $(".js-wa-final", succ); if (link) link.href = url; }
      window.open(url, "_blank");
    });

    show(0);
  });

  /* range live value */
  $$("input[type=range][data-out]").forEach(function (r) {
    var out = $("#" + r.getAttribute("data-out"));
    function upd() { if (out) out.textContent = (+r.value >= +r.max ? r.value + "+" : r.value) + " guests"; }
    r.addEventListener("input", upd); upd();
  });

  /* ---------- smooth in-page anchors ---------- */
  $$('a[href^="#"]:not([href="#"])').forEach(function (a) {
    a.addEventListener("click", function (e) {
      var t = document.getElementById(a.getAttribute("href").slice(1));
      if (t) { e.preventDefault(); var top = t.getBoundingClientRect().top + window.scrollY - 100; window.scrollTo({ top: top, behavior: reduceMotion ? "auto" : "smooth" }); }
    });
  });
})();
