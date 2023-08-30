EventsHook = {
    mounted() {
        const events = this.el.dataset.onEvents.split(",")

        events.forEach((event) => {
            event = event.trim()

            this.el.addEventListener(event, (_) => {
                const commands = this.el.dataset[event + "Commands"]

                if (commands) {
                    liveSocket.execJS(this.el, commands)
                }
            })
        })
    }
}

export default EventsHook
