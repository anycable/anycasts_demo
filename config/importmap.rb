# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@anycable/web", to: "https://ga.jspm.io/npm:@anycable/web@0.7.0/index.js", preload: true
pin "@anycable/core", to: "https://ga.jspm.io/npm:@anycable/core@0.7.0/index.js", preload: true
pin "nanoevents", to: "https://ga.jspm.io/npm:nanoevents@6.0.2/index.js", preload: true
pin "@hotwired/turbo", to: "https://ga.jspm.io/npm:@hotwired/turbo@7.1.0/dist/turbo.es2017-esm.js", preload: true
pin "@anycable/turbo-stream", to: "https://ga.jspm.io/npm:@anycable/turbo-stream@0.3.2/index.js", preload: true

pin "cable", to: "cable.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
