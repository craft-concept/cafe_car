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
