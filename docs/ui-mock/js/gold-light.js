/* Signature gold light sweep — design context §6–8 */
window.KHGoldLight = (function () {
  const reduced =
    typeof matchMedia === "function" &&
    matchMedia("(prefers-reduced-motion: reduce)").matches;

  const timers = new WeakMap();

  function randomDelay(minS, maxS) {
    return (minS + Math.floor(Math.random() * (maxS - minS + 1))) * 1000;
  }

  function schedule(el) {
    if (reduced || !el) return;
    clearTimeout(timers.get(el));
    const isHero = el.classList.contains("hero-block") || el.dataset.sweep === "hero";
    const delay = isHero ? randomDelay(12, 30) : randomDelay(8, 22);
    const t = setTimeout(() => {
      el.classList.add("is-sweeping");
      const done = () => {
        el.classList.remove("is-sweeping");
        el.removeEventListener("animationend", done);
        schedule(el);
      };
      el.addEventListener("animationend", done);
      // Fallback if animationend missed
      setTimeout(() => {
        if (el.classList.contains("is-sweeping")) {
          el.classList.remove("is-sweeping");
          schedule(el);
        }
      }, 1600);
    }, delay);
    timers.set(el, t);
  }

  function init(root) {
    if (reduced) return;
    const scope = root || document;
    scope.querySelectorAll(".gold-light").forEach((el) => {
      clearTimeout(timers.get(el));
      schedule(el);
    });
  }

  return { init };
})();
