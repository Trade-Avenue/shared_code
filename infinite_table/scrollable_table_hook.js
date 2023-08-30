const ScrollableTableHook = {
    mounted() {
        const table = this.el.querySelector("table")
        const header = this.el.querySelector("thead")
        const body = this.el.querySelector("tbody:last-child")

        this.resizeFunction = (height) => {
            table.style.height = height + "px"
            body.style.height = (height - header.clientHeight) + "px"
        }

        const resizeObserver = new ResizeObserver(([{contentRect: rect}]) => {
            this.resizeFunction(rect.height)
        })

        resizeObserver.observe(this.el)
    },
    updated() {
        this.resizeFunction(this.el.clientHeight)
    }
}

export default ScrollableTableHook
