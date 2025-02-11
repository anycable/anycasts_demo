// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo"

import { start } from "@anycable/turbo-stream"
import cable from "cable"
start(cable, { requestSocketIDHeader: true, presence: true })

import "controllers"
