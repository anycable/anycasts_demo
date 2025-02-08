# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@anycable/web", to: "@anycable--web.js" # @1.0.0
pin "@anycable/core", to: "@anycable--core.js" # @1.0.0
pin "nanoevents" # @9.1.0
pin "@hotwired/turbo", to: "@hotwired--turbo.js" # @8.0.12
pin "@anycable/turbo-stream", to: "@anycable--turbo-stream.js" # @0.7.0

pin "cable", to: "cable.js", preload: true
pin "presence_source_element", to: "presence_source_element.js"
pin_all_from "app/javascript/controllers", under: "controllers"
