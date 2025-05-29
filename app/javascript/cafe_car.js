function last(arr) {
    return arr[arr.length - 1];
}

addEventListener("mousedown", event => {
    window.mouseDownTarget = event.target
})

addEventListener("mouseup", event => {
    if (event.target === window.mouseDownTarget && event.target.matches(".Modal_Close, .Modal")) {
        event.preventDefault()
        event.target.closest(".Modal").classList.add("remove")
    }
})

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
