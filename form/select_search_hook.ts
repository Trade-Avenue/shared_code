import { Hook, makeHook } from "phoenix_typed_hook";

class SelectSearchHook extends Hook {
  mounted() {
    const getElementText = (element) => {
      const dataset = this.el.dataset

      if (dataset.searchElementQuery) {
        return element.querySelector(dataset.searchElementQuery).innerText.trim().toLowerCase()
      } else {
        return element.innerText.trim().toLowerCase()
      }
    }

    const getElementsList = (element) => {
      return Array.from(element.parentElement.querySelector("ul").children)
    }

    const resetElements = (elements) => {
      Array.from(elements).forEach((element) => {
        element.classList.remove("hidden")
      })
    }

    const maybeHideElements = (elements, inputValue) => {
      Array.from(elements).forEach((element) => {
        const value = getElementText(element)

        if (value.startsWith(inputValue)) {
          element.classList.remove("hidden")
        } else {
          element.classList.add("hidden")
        }
      })
    }

    this.el.addEventListener("input", (event) => {
      const inputValue = this.el.value.toLowerCase()

      const elements = getElementsList(this.el)

      maybeHideElements(elements, inputValue)
    });

    this.handleEvent("clear_input", ({id}) => {
      if (this.el.id == id + "-filter") {
        this.el.value = ""

        const elements = getElementsList(this.el)

        resetElements(elements)
      }
    })
  }
}

export default makeHook(SelectSearchHook)
