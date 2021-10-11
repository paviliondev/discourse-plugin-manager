import { htmlSafe } from "@ember/template";
import { registerUnbound } from "discourse-common/lib/helpers";
import I18n from "I18n";

registerUnbound("owner-logo", (owner, opts={}) => {
  let classes = `owner-logo ${opts.label ? 'has-label' : ''}`;
  let html = `<${opts.linked ? `a href=${owner.url}` : 'div'} class="${classes}" ${opts.linked ? 'target="_blank"' : ''}>`;
  
  let imgAlt = I18n.t("server_status.plugin.owner.logo", { ownerName: owner.name });
  html += `<img class="owner-logo-img" src=${owner.avatar_url} alt=${imgAlt}>`;

  if (opts.label) {
    html += `<span>${owner.name}</span>`;
  }

  html += `</${opts.linked ? 'a' : 'div'}>`;

  return htmlSafe(html);
});