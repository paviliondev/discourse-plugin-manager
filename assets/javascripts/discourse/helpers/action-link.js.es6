import { htmlSafe } from "@ember/template";
import { registerUnbound } from "discourse-common/lib/helpers";
import { iconHTML } from "discourse-common/lib/icon-library";
import I18n from "I18n";

registerUnbound("action-link", (attrs) => {
  let html = `<a href=${attrs.url} class="log-url" target="_blank">`;
  html += iconHTML(attrs.icon);
  html += `<span>${I18n.t(attrs.labelKey)}</span>`;
  html += `</a>`;
  return htmlSafe(html);
});