import { Hook, makeHook } from "phoenix_typed_hook";

class CopyToClipboardHook extends Hook {
  mounted() {
    this.handleCopy = () => {
      if ("clipboard" in navigator) {
        const target = document.querySelector(this.el.dataset.to)

        const text = target.value || target.innerText

        const content = this.el.dataset.content || "text"

        navigator.clipboard.writeText(text).then(() => {
          this.pushEvent("clipboard", {content: content})
        })
      } else {
        alert("Sorry, your browser does not support clipboard copy.")
      }
    }

    this.el.addEventListener("click", this.handleCopy)
  }

  destroyed() {
    this.el.removeEventListener("click", this.handleCopy)
  }
}

export default makeHook(CopyToClipboardHook)
