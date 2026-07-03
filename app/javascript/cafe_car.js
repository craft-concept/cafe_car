import "@hotwired/turbo-rails"

Object.assign(Turbo.StreamActions, {
  // <turbo-stream action="navigate" target="Hello, world"></turbo-stream>
  navigate() {
    history.pushState({ action: "navigate" }, "", this.getAttribute("target"))
  }
})

function last(arr) {
  return arr[arr.length - 1];
}

addEventListener("mousedown", event => {
  window.mouseDownTarget = event.target
})

addEventListener("mouseup", event => {
  let isClose = event.target.closest(".Close") || event.target.matches(".Modal")
  if (isClose && event.target === window.mouseDownTarget) {
    event.preventDefault()
    event.stopPropagation()
    event.target.closest(".popup").classList.add("remove")
  }
}, { capture: true })

addEventListener("keydown", event => {
  switch (event.key) {
    case "Escape":
      let popup = event.target.closest(".popup") ||
        last(document.querySelectorAll(".popup"))
      if (popup) popup.classList.add("remove");
  }
})

// Nested-attributes forms: add/remove repeatable `fields_for` rows. The add
// button clones the <template> (swapping the placeholder index for a unique
// one); the remove button drops unsaved rows from the DOM, or marks persisted
// rows for destruction by flipping their `_destroy` hidden field to "1".
addEventListener("click", event => {
  let add = event.target.closest("[data-nested-add]")
  if (add) {
    let wrapper   = add.closest("[data-nested-wrapper]")
    let template  = wrapper.querySelector("template[data-nested-template]")
    let container = wrapper.querySelector("[data-nested-container]")
    let html      = template.innerHTML.replaceAll("CAFE_CAR_NEW_RECORD", Date.now())
    container.insertAdjacentHTML("beforeend", html)
    return
  }

  let remove = event.target.closest("[data-nested-remove]")
  if (remove) {
    let item    = remove.closest("[data-nested-item]")
    let destroy = item.querySelector("input[name*='[_destroy]']")
    if (destroy) {
      destroy.value = "1"
      item.hidden = true
    } else {
      item.remove()
    }
  }
})

// Bulk-select: the header checkbox toggles every row checkbox in its form.
addEventListener("change", event => {
  let all = event.target.closest("[data-bulk-select-all]")
  if (!all) return
  let form = all.closest("form")
  form.querySelectorAll("input[name='ids[]']").forEach(box => box.checked = all.checked)
})

function animationEnd({ target }) {
  if (target.matches(".remove")) target.remove()
  else if (target.matches(".popup")) {
    let input = target.querySelector("input:not([type=hidden]), textarea")
    input?.focus()
    input?.setSelectionRange(-1, -1)
  }
}

addEventListener("animationend", animationEnd)
addEventListener("transitionend", animationEnd)

// NOTE: field-sizing property is used instead
// function adjustHeight(textarea) {
//   textarea.style.height = "1px"
//   textarea.style.height = (textarea.scrollHeight) + "px"
// }

// addEventListener("input", ({ target }) => {
//   if (target.matches("textarea")) adjustHeight(target)
// })

export class Selection extends Array {
  constructor(obj, ...rest) {
    switch (typeof obj) {
      case "string": {
        super(...document.querySelectorAll(obj))
        this.selector = obj
        break
      }
      default: super(obj, ...rest); break
    }
  }

  get clone() { return structuredClone(this) }

  with(...objs) {
    return this.clone.assign(...objs)
  }

  assign(...objs) {
    for (let obj of objs) {
      switch (typeof obj) {
        case "function": obj(this)
        default: Object.assign(this, obj)
      }
    }

    return this
  }

  tap(fn) {
    fn(this)
    return this
  }

  static on(...x) { return this(window).on(...x) }
  static off(...x) { return this(window).off(...x) }

  select(v, ...rest) {
    if (!v) return this

    switch (typeof v) {
      case "function": return super.filter(v).select(...rest)
      case "string": return super.filter(e => e.matches(v)).select(...rest)
    }
  }

  reject(v, ...rest) {
    if (!v) return this
    switch (typeof v) {
      case "function": return super.filter(e => !v(e)).reject(...rest)
      case "string": return super.filter(e => !e.matches(v)).reject(...rest)
    }
  }

  each(...xs) { return this.forEach(...xs) }

  forEach(...xs) {
    super.forEach(...xs)
    return this
  }

  add(name, ...names) {
    if (!name) return this
    if (name[0] == '.') name = name.slice(1)
    return this.each(el => { el.classList.add(name) }).add(...names)
  }

  remove(name, ...names) {
    if (!name) return this
    if (name[0] == '.') name = name.slice(1)
    return this.each(el => el.classList.remove(name)).remove(...names)
  }

  on(eventName, fn) {
    return this.each(el => el.addEventListener(eventName, fn))
  }

  off(eventName, fn) {
    return this.each(el => el.removeEventListener(eventName, fn))
  }

  set onhashchange(fn) { this.on("hashchange", fn) }
  set onload(fn) { this.on("load", fn) }
  set onclick(fn) { this.on("click", fn) }

  get isLoaded() { return document.readyState == "complete" }

  loaded(fn) {
    return this.isLoaded
      ? this.each(fn)
      : this.on('load', fn)
  }

  onIntersection() {}

  intersection(...options) {
    return this.clone.tap(clone => {
      clone.observer = new IntersectionObserver(clone.onIntersection.bind(clone), ...options)
    })
  }

  observe(...options) {
    return this.each(el => this.observer.observe(el, ...options))
  }

  unobserve(...options) {
    this.each(el => this.observer.unobserve(el, ...options))
  }
}

window.Selection = Selection
window.$ = function $(x, ...xs) {
  switch (typeof x) {
    case "function": return $(document).loaded(x)
    default: return new Selection(x, ...xs)
  }
}
