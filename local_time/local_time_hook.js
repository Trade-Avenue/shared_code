const convertToLocal = (element) => {
  const date = new Date(element.dateTime)

  // TODO Add option to format or remove this hook and format in server
  // return `${date.toLocaleString()} ${Intl.DateTimeFormat().resolvedOptions().timeZone}`
  return `${date.toLocaleString()}`
}

LocalTimeHook = {
  mounted() {
    this.el.textContent = convertToLocal(this.el)
  },

  updated() {
    this.el.textContent = convertToLocal(this.el)
  }
}

export default LocalTimeHook
