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

        this.appendMessage("You", message)
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
            this.appendMessage("Assistant", payload.message)
            this.appendProducts(payload.products || [])
        } catch (error) {
            console.error("AI assistant error", error)
            this.appendMessage("Assistant", "I hit a snag. Please try again.")
        } finally {
            this.setStatus("")
        }
    }

    appendMessage(sender, text) {
        const div = document.createElement("div")
        div.className = "mb-2"
        const name = document.createElement("p")
        name.className = "text-xs font-semibold text-gray-500"
        name.textContent = sender
        const body = document.createElement("p")
        body.className = "text-sm text-gray-900 whitespace-pre-wrap"
        body.textContent = text
        div.appendChild(name)
        div.appendChild(body)
        this.messagesTarget.appendChild(div)
        this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }

    appendProducts(products) {
        if (!products.length) return
        const list = document.createElement("div")
        list.className = "grid grid-cols-1 gap-2 mt-2"
        products.forEach((product) => {
            const card = document.createElement("a")
            card.href = product.path
            card.className = "flex items-center gap-3 rounded-lg border border-gray-200 p-2 hover:border-primary transition"
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
            title.className = "text-sm font-semibold text-gray-800"
            title.textContent = product.name
            const meta = document.createElement("p")
            meta.className = "text-xs text-gray-500"
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
      <button data-action="click->ai-assistant#toggle" class="fixed bottom-6 right-6 z-40 bg-gray-900 text-white rounded-full h-14 w-14 shadow-xl flex items-center justify-center hover:bg-gray-800 transition">
        <span class="text-sm font-semibold">AI</span>
      </button>
      <div data-ai-assistant-target="panel" class="hidden fixed bottom-24 right-4 z-40 w-80 max-w-[calc(100%-2rem)] bg-white border border-gray-200 rounded-2xl shadow-2xl overflow-hidden">
        <div class="px-4 py-3 border-b border-gray-100 flex items-center justify-between bg-gray-50">
          <div>
            <p class="text-sm font-semibold text-gray-900">Product assistant</p>
            <p data-ai-assistant-target="status" class="text-xs text-gray-500"></p>
          </div>
          <button data-action="click->ai-assistant#toggle" class="text-gray-500 hover:text-gray-800">×</button>
        </div>
        <div data-ai-assistant-target="messages" class="p-4 space-y-2 max-h-72 overflow-y-auto text-sm bg-white"></div>
        <form data-action="submit->ai-assistant#submit" class="border-t border-gray-100 bg-gray-50 p-3">
          <div class="flex items-center gap-2">
            <input data-ai-assistant-target="input" type="text" placeholder="Ask about products" class="flex-1 rounded-lg border border-gray-200 px-3 py-2 text-sm focus:border-primary focus:ring-2 focus:ring-primary/20" />
            <button type="submit" class="bg-primary text-white text-sm font-semibold px-3 py-2 rounded-lg hover:bg-primary-dark transition">Send</button>
          </div>
        </form>
      </div>
    `
    }

    setStatus(text) {
        if (this.hasStatusTarget) {
            this.statusTarget.textContent = text
        }
    }
}
