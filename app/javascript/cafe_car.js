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
  if (event.target === window.mouseDownTarget && event.target.matches(".Modal_Close, .Modal")) {
    event.preventDefault()
    event.stopPropagation()
    event.target.closest(".Modal").classList.add("remove")
  }
}, { capture: true })

addEventListener("keydown", event => {
  switch (event.key) {
    case "Escape":
      let modal = event.target.closest(".Modal") ||
        last(document.querySelectorAll(".Modal-fixed"))
      if (modal) modal.classList.add("remove");
  }
})

addEventListener("animationend", event => {
  if (event.target.matches(".remove")) event.target.remove()
})

addEventListener("transitionend", event => {
  if (event.target.matches(".remove")) event.target.remove()
})

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
