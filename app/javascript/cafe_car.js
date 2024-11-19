Object.assign(Turbo.StreamActions, {
    dialog() {
        this.removeDuplicateTargetChildren();
        this.targetElements.forEach(e => e.remove())

        let content = this.templateContent
        let dialog = content.querySelector('dialog')
        dialog.onclose = dialog.oncancel = () => dialog.remove()
        this.ownerDocument.body.append(dialog)
        dialog.showModal()
    }
})

document.addEventListener("click", event => {
    if (!event.target.matches(".Modal_Close")) return
    event.preventDefault()
    event.target.closest(".Modal").remove()
})
