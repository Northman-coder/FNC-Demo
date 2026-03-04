import { Controller } from "@hotwired/stimulus"

// A lightweight chat widget that posts messages to /ai/chats
export default class extends Controller {
    static targets = ["panel", "input", "messages", "button", "status"]

    connect() {
        // Render once so the launcher button exists immediately.
        this.renderPanel()
        this.panelVisible = false
    }

    toggle(event) {
        event.preventDefault()
        if (!this.panelVisible) {
            this.renderPanel()
        }
        this.panelTarget.classList.toggle("hidden")
        this.panelVisible = !this.panelVisible
        if (this.panelVisible) {
            this.inputTarget.focus()
        }
    }

    async submit(event) {
        event.preventDefault()
        const message = this.inputTarget.value.trim()
        if (!message) return

        await this.sendMessage(message)
    }

    appendMessage(sender, text, role = "assistant") {
        const wrap = document.createElement("div")
        wrap.className = "mb-3 flex" + (role === "user" ? " justify-end" : " justify-start")

        const bubble = document.createElement("div")
        bubble.className = "max-w-[85%] rounded-2xl px-3 py-2 shadow-sm whitespace-pre-wrap " +
            (role === "user" ? "bg-gradient-to-r from-indigo-600 to-indigo-500 text-white" : "bg-white/90 text-gray-900 border border-white/60")
        bubble.textContent = text

        const avatar = document.createElement("div")
        avatar.className = "h-8 w-8 shrink-0 rounded-full flex items-center justify-center text-[11px] font-semibold " +
            (role === "user" ? "bg-indigo-600 text-white ml-2" : "bg-gray-900 text-white mr-2")
        avatar.textContent = role === "user" ? "You" : "FNC"

        if (role === "user") {
            wrap.appendChild(bubble)
            wrap.appendChild(avatar)
        } else {
            wrap.appendChild(avatar)
            wrap.appendChild(bubble)
        }

        this.messagesTarget.appendChild(wrap)
        this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }

    appendProducts(products) {
        if (!products.length) return
        const list = document.createElement("div")
        list.className = "grid grid-cols-1 gap-2 mt-2"
        products.forEach((product) => {
            const card = document.createElement("a")
            card.href = product.path
            card.className = "flex items-center gap-3 rounded-lg border border-white/20 bg-white/90 p-2 hover:border-indigo-400/80 transition shadow-sm"
            if (product.image_path) {
                const img = document.createElement("img")
                img.src = product.image_path
                img.alt = product.name
                img.className = "w-12 h-12 object-cover rounded-md"
                card.appendChild(img)
            }
            const info = document.createElement("div")
            info.className = "flex flex-col"
            const title = document.createElement("p")
            title.className = "text-sm font-semibold text-gray-900"
            title.textContent = product.name
            const meta = document.createElement("p")
            meta.className = "text-xs text-gray-600"
            meta.textContent = [product.brand, this.formatPrice(product.price)].filter(Boolean).join(" · ")
            info.appendChild(title)
            info.appendChild(meta)
            card.appendChild(info)
            list.appendChild(card)
        })
        this.messagesTarget.appendChild(list)
        this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }

    formatPrice(value) {
        if (value === null || value === undefined) return null
        return `$${value}`
    }

    csrfToken() {
        const meta = document.querySelector('meta[name="csrf-token"]')
        return meta && meta.getAttribute("content")
    }

    renderPanel() {
        // The panel markup lives inside this controller element to avoid touching the main layout too much.
        this.element.innerHTML = `
            <button data-action="click->ai-assistant#toggle" class="fixed bottom-6 right-6 z-40 bg-gradient-to-br from-black via-neutral-900 to-neutral-800 text-white rounded-full h-14 w-28 shadow-2xl shadow-black/30 flex items-center justify-center hover:scale-[1.03] hover:brightness-110 transition-transform duration-150 focus:outline-none focus-visible:ring-2 focus-visible:ring-white/70">
                <span class="text-sm font-semibold tracking-wide">Ask AI</span>
            </button>
            <div data-ai-assistant-target="panel" class="hidden fixed bottom-24 right-4 z-40 w-[420px] max-w-[calc(100%-1.5rem)] bg-gradient-to-br from-black via-neutral-950 to-neutral-900 border border-white/5 rounded-3xl shadow-2xl shadow-black/30 overflow-hidden backdrop-blur-xl">
                <div class="px-4 py-3 border-b border-white/10 bg-white/5 flex items-center justify-between gap-3">
                    <div class="flex items-center gap-3">
                        <div class="h-10 w-10 rounded-2xl bg-white/10 text-white flex items-center justify-center text-xs font-bold shadow-sm">FNC</div>
                        <div>
                            <p class="text-sm font-semibold text-white">FNC AI</p>
                            <p data-ai-assistant-target="status" class="text-xs text-gray-200/80">Online · Ask for deals, cheapest, or new drops.</p>
                        </div>
                    </div>
                    <button data-action="click->ai-assistant#toggle" aria-label="Close" class="text-gray-200 hover:text-white h-8 w-8 rounded-xl flex items-center justify-center hover:bg-white/10 transition">
                        ×
                    </button>
                </div>
                <div class="px-4 pt-3 pb-2 bg-white/5 border-b border-white/5">
                    <div class="flex flex-wrap gap-2 text-xs">
                        ${this.quickPromptButton("Cheapest under $50", "cheapest items under $50")}
                        ${this.quickPromptButton("New arrivals", "show me new arrivals")}
                        ${this.quickPromptButton("On sale", "best offers and discounts")}
                        ${this.quickPromptButton("Gift ideas", "gift ideas around $100")}
                    </div>
                </div>
                <div data-ai-assistant-target="messages" class="p-4 space-y-3 max-h-96 overflow-y-auto text-sm bg-gradient-to-b from-white/5 via-white/0 to-white/5 text-gray-100">
                    <div class="text-xs text-gray-200/90">I’m here to help you find the right products.</div>
                </div>
                <form data-action="submit->ai-assistant#submit" class="border-t border-white/10 bg-white/8 p-3">
                    <div class="flex items-center gap-2">
                        <input data-ai-assistant-target="input" type="text" placeholder="Try: cheapest headphones under $80" class="flex-1 rounded-2xl border border-white/20 bg-white/10 text-white placeholder:text-white/60 px-3 py-2.5 text-sm focus:border-white/50 focus:ring-2 focus:ring-white/30 shadow-sm" />
                        <button type="submit" class="bg-white text-gray-900 text-sm font-semibold px-3.5 py-2.5 rounded-2xl hover:bg-gray-100 transition shadow-sm">Send</button>
                    </div>
                </form>
            </div>
        `
    }

    quickPromptButton(label, prompt) {
        return `<button type="button" class="px-3 py-1.5 rounded-full bg-white/10 text-white border border-white/15 hover:border-white/40 transition" data-action="click->ai-assistant#prefill" data-prompt="${prompt}">${label}</button>`
    }

    prefill(event) {
        const prompt = event.currentTarget.getAttribute("data-prompt")
        if (prompt) {
            this.inputTarget.value = prompt
            this.inputTarget.focus()
            this.sendMessage(prompt)
        }
    }

    async sendMessage(message) {
        this.appendMessage("You", message, "user")
        this.inputTarget.value = ""
        this.setStatus("Thinking…")

        try {
            const response = await fetch("/ai/chats", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": this.csrfToken()
                },
                body: JSON.stringify({ message })
            })

            if (!response.ok) throw new Error(`HTTP ${response.status}`)
            const payload = await response.json()
            this.appendMessage("Assistant", payload.message, "assistant")
            this.appendProducts(payload.products || [])
        } catch (error) {
            console.error("AI assistant error", error)
            this.appendMessage("Assistant", "I hit a snag. Please try again.", "assistant")
        } finally {
            this.setStatus("")
        }
    }

    setStatus(text) {
        if (this.hasStatusTarget) {
            this.statusTarget.textContent = text
        }
    }
}
