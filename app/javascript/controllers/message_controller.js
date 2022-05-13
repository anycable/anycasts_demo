import { Controller } from "@hotwired/stimulus";

const fetchMeta = (key) => {
  let element = document.head.querySelector(`meta[name='${key}']`)

  if (element) {
    return element.getAttribute('content')
  }
}

let currentUserID = fetchMeta('current-user-id')

export default class extends Controller {
  connect() {
    if (this.data.get('user-id') === currentUserID) {
      this.element.classList.add('mine')
    } else {
      this.element.classList.add('theirs')
    }
  }
}
