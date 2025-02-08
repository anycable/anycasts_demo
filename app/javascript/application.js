// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo"

import { start } from "@anycable/turbo-stream"
import cable from "cable"
start(cable, { requestSocketIDHeader: true })

import "controllers"
import { PresenceSourceElement } from "presence_source_element";

PresenceSourceElement.cable = cable;
if (customElements.get('turbo-presence-source') === undefined) {
  customElements.define('turbo-presence-source', PresenceSourceElement)
}
