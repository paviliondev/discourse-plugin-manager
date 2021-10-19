import { htmlSafe } from "@ember/template";
import { registerUnbound } from "discourse-common/lib/helpers";
import I18n from "I18n";

registerUnbound("owner-logo", (owner, opts={}) => {
  let classes = `owner-logo ${opts.label ? 'has-label' : ''} ${opts.class ? opts.class : ''}`;
  let href = owner.website ? owner.website : owner.url;
  let target = opts.linked ? "_blank" : "";
  let html = `<${opts.linked ? `a href=${href}` : 'div'} class="${classes}" target="${target}">`;

  let imgAlt = I18n.t("server_status.plugin.owner.logo", { ownerName: owner.name });
  html += `<img class="owner-logo-img" src=${owner.avatar_url} alt=${imgAlt}>`;

  if (opts.label) {
    html += `<span class="owner-logo-label">${owner.name}</span>`;
  }

  html += `</${opts.linked ? 'a' : 'div'}>`;
  return htmlSafe(html);
});