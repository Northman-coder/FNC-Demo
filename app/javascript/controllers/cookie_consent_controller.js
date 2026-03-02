import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["banner", "modal", "analytics", "marketing"]

  connect() {
    if (this.preferences) {
      this.hide()
    }
  }

  acceptAll() {
    this.#savePreferences({ necessary: true, analytics: true, marketing: true })
  }

  rejectAll() {
    this.#savePreferences({ necessary: true, analytics: false, marketing: false })
  }

  manage() {
    const prefs = this.preferences || { necessary: true, analytics: false, marketing: false }

    if (this.hasAnalyticsTarget) this.analyticsTarget.checked = !!prefs.analytics
    if (this.hasMarketingTarget) this.marketingTarget.checked = !!prefs.marketing

    this.showModal()
  }

  save() {
    const prefs = {
      necessary: true,
      analytics: this.hasAnalyticsTarget ? !!this.analyticsTarget.checked : false,
      marketing: this.hasMarketingTarget ? !!this.marketingTarget.checked : false
    }

    this.#savePreferences(prefs)
  }

  close() {
    this.hideModal()
  }

  hide() {
    if (this.hasBannerTarget) this.bannerTarget.classList.add("hidden")
    else this.element.classList.add("hidden")
  }

  showModal() {
    if (this.hasModalTarget) this.modalTarget.classList.remove("hidden")
  }

  hideModal() {
    if (this.hasModalTarget) this.modalTarget.classList.add("hidden")
  }

  get preferences() {
    const raw = this.#getCookie("cookie_preferences")
    if (!raw) return null

    try {
      const json = decodeURIComponent(raw.split("=")[1] || "")
      const prefs = JSON.parse(json)
      if (!prefs || typeof prefs !== "object") return null
      return {
        necessary: true,
        analytics: !!prefs.analytics,
        marketing: !!prefs.marketing
      }
    } catch (_) {
      return null
    }
  }

  #savePreferences(prefs) {
    const payload = JSON.stringify({
      v: 1,
      analytics: !!prefs.analytics,
      marketing: !!prefs.marketing,
      updated_at: new Date().toISOString()
    })

    this.#setCookie("cookie_preferences", payload, 365)

    window.dispatchEvent(new CustomEvent("cookie:preferences", { detail: prefs }))

    this.hideModal()
    this.hide()
  }

  #setCookie(name, value, days) {
    const maxAge = days * 24 * 60 * 60
    const secure = window.location.protocol === "https:" ? "; Secure" : ""
    document.cookie = `${encodeURIComponent(name)}=${encodeURIComponent(value)}; Path=/; Max-Age=${maxAge}; SameSite=Lax${secure}`
  }

  #getCookie(name) {
    const target = `${encodeURIComponent(name)}=`
    return document.cookie
      .split(";")
      .map((c) => c.trim())
      .find((c) => c.startsWith(target))
  }
}
