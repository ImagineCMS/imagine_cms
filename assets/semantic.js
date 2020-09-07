document.addEventListener("DOMContentLoaded", () => {
  $(".ui.checkbox").checkbox();
  $("select.dropdown").dropdown({ placeholder: false, fullTextSearch: true });
  $("div.dropdown").dropdown({ fullTextSearch: true });

  $(".negative.basic.button").mouseover(function () { $(this).removeClass("basic"); })
    .mouseout(function () { $(this).addClass("basic"); });
});
