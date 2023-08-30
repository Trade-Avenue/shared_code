const isFullyWithinViewport = (element, containerElement) => {
    const lhsRect = element.getBoundingClientRect()
    const rhsRect = containerElement.getBoundingClientRect()

    return lhsRect.top >= rhsRect.top && lhsRect.bottom <= rhsRect.bottom
}

const isFirstElementPresent = (firstChild, id) => firstChild.id == id

const findScrollContainer = (element) => {
    if (["scroll", "auto"].indexOf(getComputedStyle(element).overflowY) >= 0) {
        return element
    }

    if (document.body === element) {
        throw Error("Could not find a scrollable container")
    }

    return findScrollContainer(element.parentElement)
}

const innerHeight = (element) => element.scrollHeight - element.clientHeight

const hasReachedBottom = (element) => element.scrollTop >= innerHeight(element)
const hasReachedTop = (element) => element.scrollTop <= 0

const hideOrShowGoToTopButton = (goToTopButton, scrollContainer) => {
    if (hasReachedTop(scrollContainer)) {
        goToTopButton.classList.add("hidden")
    } else {
        goToTopButton.classList.remove("hidden")
    }
}

const getBottomEvent = (element, socket) => element.getAttribute(socket.binding("viewport-bottom-event"))
const getTopEvent = (element, socket) => element.getAttribute(socket.binding("viewport-top-event"))

const showLoading = (element, liveSocket) => liveSocket.execJS(element, element.getAttribute("data-show"))
const hideLoading = (element, liveSocket) => liveSocket.execJS(element, element.getAttribute("data-hide"))

const throttle = (interval, callback) => {
    let lastCallAt = 0
    let timer

    return (...args) => {
        const now = Date.now()
        const remainingTime = interval - (now - lastCallAt)

        if (remainingTime <= 0 || remainingTime > interval) {
            if (timer) {
                clearTimeout(timer)

                timer = null
            }

            lastCallAt = now

            callback(...args)
        } else if (!timer) {
            timer = setTimeout(() => {
                lastCallAt = Date.now()
                timer = null

                callback(...args)
            }, remainingTime)
        }
    }
}

const InfinityScrollHook = {
    mounted() {
        // Time before another data request can be made
        const throttleInterval = 500

        let pendingOperationFn = null

        let status = "idle"

        let firstChildId = null

        let currentChild = null

        const topLoadingElement = document.querySelector("#" + this.el.dataset.generalId + "-top-loading-table")
        const bottomLoadingElement = document.querySelector("#" + this.el.dataset.generalId + "-bottom-loading-table")

        const goToTopButton = document.querySelector("#" + this.el.dataset.generalId + "-go-to-top-button")

        this.scrollContainer = findScrollContainer(this.el)

        console.log("scrollContainer id:", this.scrollContainer.id)

        // Event when the scroll reached the top of the table
        const onTopReached = throttle(throttleInterval, (topEvent) => {
            const firstChild = this.el.firstElementChild

            // Set pending operation to block scroll to first child until loading is done
            pendingOperationFn = () => firstChild.scrollIntoView({block: "start"})

            currentChild = firstChild

            status = "top_loading"

            showLoading(topLoadingElement, this.liveSocket)

            const cursor = firstChild.dataset.cursor

            this.liveSocket.execJSHookPush(this.el, topEvent, {cursor: cursor})
        })

        // Event when the scroll reached the bottom of the table
        const onBottomReached = throttle(throttleInterval, (bottomEvent) => {
            const lastChild = this.el.lastElementChild

            // Set pending operation to block scroll to last child until loading is done
            pendingOperationFn = () => lastChild.scrollIntoView({block: "end"})

            currentChild = lastChild

            console.log("onBottomReached currentChild:", currentChild)

            status = "bottom_loading"

            showLoading(bottomLoadingElement, this.liveSocket)

            const cursor = lastChild.dataset.cursor

            this.liveSocket.execJSHookPush(this.el, bottomEvent, {cursor: cursor})
        })

        // The event to check if new data needs to be fetched
        this.onScroll = (e) => {
            if (pendingOperationFn) {
                return pendingOperationFn()
            }

            const topEvent = getTopEvent(this.el, this.liveSocket)
            const bottomEvent = getBottomEvent(this.el, this.liveSocket)

            hideOrShowGoToTopButton(goToTopButton, this.scrollContainer)

            if (bottomEvent && hasReachedBottom(this.scrollContainer)) {
                onBottomReached(bottomEvent)
            } else if (topEvent && hasReachedTop(this.scrollContainer)) {
                onTopReached(topEvent)
            }
        }

        const onScrollToTop = (firstChild) => {
            this.el.firstElementChild.scrollIntoView({behavior: "smooth", block: "start"})
        }

        const onLoadAndScrollToTop = () => {
            // Set pending operation to a noop function
            pendingOperationFn = () => null

            status = "go_to_top"

            showLoading(topLoadingElement, this.liveSocket)

            this.liveSocket.execJSHookPush(this.el, "go_to_top")
        }

        // The event to move table to the top
        this.onGoToTop = (event) => {
            if (pendingOperationFn) {
                return pendingOperationFn()
            }

            const firstChild = this.el.firstElementChild

            if (isFirstElementPresent(firstChild, firstChildId)) {
                onScrollToTop(firstChild)
            } else {
                onLoadAndScrollToTop()
            }
        }

        // Checks if there is need to load more data when the table is not scrollable yet
        const maybeLoadMoreDataIfNeeded = () => {
            // This function checks if the scroll is at the bottom, if it is
            // it will fetch more data if there is any to fetch
            // This scenario can happen if the user resizes the browser

            const bottomEvent = getBottomEvent(this.el, this.liveSocket)

            if (bottomEvent && hasReachedBottom(this.scrollContainer)) {
                if (pendingOperationFn) {
                    pendingOperationFn()

                    return false
                }

                onBottomReached(bottomEvent)

                return true
            } else {
                return false
            }
        }

        // The event to handle the after of a initial data load
        const handleInitialLoading = () => {
            const finishLoading = () => {
                // If we finished the initial load, we start the post setup

                status = "idle"

                hideLoading(topLoadingElement, this.liveSocket)

                this.scrollContainer.addEventListener("scroll", this.onScroll)

                this.el.addEventListener("go_to_top", this.onGoToTop)

                // Checks if there is new data needed to be loaded every time there is
                // a resize in the scroll element
                const resizeObserver = new ResizeObserver((_) => maybeLoadMoreDataIfNeeded())
                resizeObserver.observe(this.scrollContainer)
            }
            
            if (this.el.children.length == 0) {
                finishLoading()
            } else {
                // Set the first child id to the current one after the first load
                firstChildId = this.el.firstElementChild.id

                const bottomEvent = getBottomEvent(this.el, this.liveSocket)

                if (bottomEvent && hasReachedBottom(this.scrollContainer)) {
                    // If we reached the bottom of the scroll and we have the `bottomEvent`
                    // available it means that the number of items are not sufficient to fill
                    // the whole scroll area but we still have more data to fetch, so we do that.
                    const cursor = this.el.lastElementChild.dataset.cursor

                    this.liveSocket.execJSHookPush(this.el, bottomEvent, {cursor: cursor})
                } else {
                    finishLoading()
                }
            }
        }

        // The event to handle the after of a top data load
        const handleTopLoading = () => {
            // Reset the first child id to the current one after top load
            firstChildId = this.el.firstElementChild.id

            status = "idle"

            hideLoading(topLoadingElement, this.liveSocket)

            if (!isFullyWithinViewport(currentChild, this.scrollContainer)) {
                currentChild.scrollIntoView({block: "start"})
            }

            pendingOperationFn = null

            // We always check this after a loading because the user can resize
            // the browser during the loading
            maybeLoadMoreDataIfNeeded()
        }

        // The event to handle the after of a bottom data load
        const handleBottomLoading = () => {
            status = "idle"

            console.log("isWithinViewport:", isFullyWithinViewport(currentChild, this.scrollContainer))

            console.log("handleBottomLoading currentChild:", currentChild)


            if (!isFullyWithinViewport(currentChild, this.scrollContainer)) {
                currentChild.scrollIntoView({block: "end"})
            }

            pendingOperationFn = null

            console.log("handleBottomLoading maybeLoadMoreDataIfNeeded:", maybeLoadMoreDataIfNeeded())

            if (maybeLoadMoreDataIfNeeded()) {
                console.log(">>>>>>>>>>>> BUG TRIGGERED <<<<<<<<<<")
            }
            
            // We always check this after a loading because the user can resize
            // the browser during the loading
            if (!maybeLoadMoreDataIfNeeded()) {
                hideLoading(bottomLoadingElement, this.liveSocket)
            }
        }

        // The event to handle the after of a go to top data load
        const handleGoToTop = () => {
            hideLoading(topLoadingElement, this.liveSocket)

            const firstChild = this.el.firstElementChild

            // Set the first child id to the current one
            firstChildId = firstChild.id

            // Just run the scroll to the second last child when there are at least 3 rows in
            // the table.
            if (this.el.children.length >= 3) {
                const secondLastChild = this.el.children[this.el.children.length - 2]

                // We scroll to the second last child first to not trigger the end of the table event
                // This is a workaround until scrollIntoView returns promise so we can know when the
                // smooth animation finishes and we can reset the pending operation.
                secondLastChild.scrollIntoView({block: "end"})
            }

            // Now we smoothly scroll to the first child
            onScrollToTop(firstChild)

            status = "idle"

            pendingOperationFn = null

            // We always check this after a loading because the user can resize
            // the browser during the loading
            maybeLoadMoreDataIfNeeded()
        }

        // This will be triggered when any kind of data load is done by the table
        this.handleEvent("finished_loading", ({id}) => {
            hideOrShowGoToTopButton(goToTopButton, this.scrollContainer)

            // Checks if the message is for this specific element
            if (this.el.id == id + "-tbody") {
                switch (status) {
                case "initial_loading":
                    handleInitialLoading()
                    break
                case "top_loading":
                    handleTopLoading()
                    break
                case "bottom_loading":
                    handleBottomLoading()
                    break
                case "go_to_top":
                    handleGoToTop()
                    break
                }
            }
        })

        // This will be triggered when we do some query change, for example,
        // adding new filters, changing sorting, etc.
        this.handleEvent("start_loading", ({id}) => {
            hideOrShowGoToTopButton(goToTopButton, this.scrollContainer)

            // Checks if the message is for this specific element
            if (this.el.id == id + "-tbody") {
                // Since we are reloading data from the start, we change
                // the status to initial_loading
                status = "initial_loading"

                showLoading(topLoadingElement, this.liveSocket)
            }
        })
    },

    destroyed() {
        this.scrollContainer.removeEventListener("scroll", this.onScroll)

        this.el.removeEventListener("go_to_top", this.onGoToTop)
    }
}

export default InfinityScrollHook
