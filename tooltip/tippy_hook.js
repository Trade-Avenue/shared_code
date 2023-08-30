// NOTE: For some reason this library adds more than 800 kb to the final JS file
// maybe we should consider a alternative or a LiveView only solution?
import tippy from 'tippy.js'

const maybeParseOffset = (dataset) => {
    if (dataset.skidding == undefined && dataset.distance == undefined) {
        return undefined
    } else {
        const skidding = parseInt(dataset.skidding ?? "0")
        const distance = parseInt(dataset.distance ?? "0")

        return [skidding, distance]
    }
}

const parseOpts = (opts, dataset, element) => {
    const type = dataset.type

    const animation = dataset.animation
    const theme = dataset.theme

    const offset = maybeParseOffset(dataset)

    const showArrow = dataset.show_arrow == "true"

    opts = {arrow: showArrow, theme: theme, animation: animation, offset: offset, ...opts}

    if (type == "simple") {
        opts = {content: dataset.content, ...opts}
    }

    if (type == "html_content") {
        const element = element.querySelector(`div#${this.el.id}-html-content`)

        console.log(element)

        opts = {content: element}
    }

    return opts
}

TippyHook = {
    mounted() {
        const opts = parseOpts({}, this.el.dataset, this.el)

        tippy(this.el, opts)
    },
    
    updated() {
        const opts = parseOpts({}, this.el.dataset, this.el)

        tippy(this.el, opts)
    }
}

export default TippyHook
