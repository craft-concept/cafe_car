function last(arr) {
    return arr[arr.length - 1];
}

document.addEventListener("click", event => {
    if (event.target.matches(".Modal_Close")) {
        event.preventDefault()
        event.target.closest(".Modal").remove()
    } else if (event.target.matches(".Modal")) {
        event.preventDefault()
        event.target.remove()
    }
})

document.addEventListener("keydown", event => {
    switch (event.key) {
        case "Escape":
            let modal = event.target.closest(".Modal") ||
                last(document.querySelectorAll(".Modal-fixed"))
            modal?.remove()
    }
})
