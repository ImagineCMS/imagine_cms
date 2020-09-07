let Handlebars = require("./handlebars");

module.exports = (tpl_str, context) => {
  return Handlebars.compile(tpl_str)(context);
}
