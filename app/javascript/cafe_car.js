function last(arr) {
    return arr[arr.length - 1];
}

addEventListener("click", event => {
    if (event.target.matches(".Modal_Close")) {
        event.preventDefault()
        event.target.closest(".Modal").classList.add("remove")
    } else if (event.target.matches(".Modal")) {
        event.preventDefault()
        event.target.classList.add("remove")
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

document.addEventListener("animationend", event => {
    if (event.target.matches(".remove")) event.target.remove()
})
