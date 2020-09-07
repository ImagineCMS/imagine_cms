// @see https://docs.headwayapp.co/widget for more configuration options.
var config = {
  account: "x8dEnx",
  selector: ".hw_changelog", // CSS selector where to inject the badge
  trigger: ".hw_changelog"
}
document.addEventListener("DOMContentLoaded", () => {
  Headway.init(config);
});
