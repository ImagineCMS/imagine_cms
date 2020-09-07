import Slideout from "slideout";

document.addEventListener("DOMContentLoaded", () => {
  // if (window.slideout) {
  //   window.slideout.destroy();
  //   window.slideout = null;
  // }
  window.slideout = new Slideout({
    "panel": document.getElementById("panel"),
    "menu": document.getElementById("mobile-menu"),
    "padding": 210,
    "tolerance": 70
  });
  window.slideout.enableTouch();

  var close = (e) => {
    e.preventDefault();
    window.slideout.close();
  };

  // Toggle button
  $("a.mobile-menu-toggle").on("click", (e) => {
    window.slideout.toggle();
    e.preventDefault();
  });
  $("#mobile-menu a.item").on("click", () => {
    window.slideout.close();
    // do not prevent default, we do want to go to the thing
  });

  window.slideout.on("beforeopen", () => window.slideout.panel.classList.add("panel-open"));
  window.slideout.on("open", () => window.slideout.panel.addEventListener("click", close));
  window.slideout.on("beforeclose", () => {
    window.slideout.panel.classList.remove("panel-open");
    window.slideout.panel.removeEventListener("click", close);
  });
});
