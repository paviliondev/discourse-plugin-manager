import { htmlSafe } from "@ember/template";
import { registerUnbound } from "discourse-common/lib/helpers";

registerUnbound("branch-label", (obj) => {
  let html = `<span class="branch-label">`;
  if (obj.branchUrl) {
    html += `<a href=${obj.branchUrl} class="branch-link" target="_blank">`;
  }
  html += obj.git_branch;
  if (obj.branchUrl) {
    html += `</a>`;
  }
  html += '</span>'
  return htmlSafe(html);
});