import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {}

// Dark mode hook
Hooks.DarkMode = {
  mounted() {
    this.applyTheme()
    this.el.addEventListener("click", () => {
      const isDark = document.documentElement.classList.contains("dark")
      localStorage.setItem("darkMode", isDark ? "light" : "dark")
      this.applyTheme()
    })
  },
  applyTheme() {
    const saved = localStorage.getItem("darkMode")
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
    const shouldDark = saved === "dark" || (saved === null && prefersDark)

    if (shouldDark) {
      document.documentElement.classList.add("dark")
    } else {
      document.documentElement.classList.remove("dark")
    }
  }
}

// Impersonation banner hook
Hooks.ImpersonationBanner = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      if (e.target.classList.contains("banner-exit")) {
        e.preventDefault()
        this.pushEvent("end_impersonation", {})
      }
    })
  }
}

// Toast hook with auto-dismiss
Hooks.Toast = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      if (e.target.closest("[data-dismiss]")) {
        this.el.remove()
      }
    })

    // Auto dismiss after 5 seconds
    this.timeout = setTimeout(() => {
      this.el.style.animation = "fadeOut 0.3s ease-in forwards"
      setTimeout(() => this.el.remove(), 300)
    }, 5000)
  },
  destroyed() {
    if (this.timeout) clearTimeout(this.timeout)
  }
}

// Loading button hook
Hooks.LoadingButton = {
  mounted() {
    this.el.addEventListener("click", () => {
      if (this.el.disabled) return
      this.el.disabled = true
      this.el.setAttribute("aria-busy", "true")
      this.originalText = this.el.innerHTML
      this.el.innerHTML = `
        <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-current" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        Loading...
      `
    })
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollerTimeout: 30000,
  params: {_csrf_token: csrfToken},
  hooks: Hooks,
  dom: {
    // Focus management on route change
    onBeforeElUpdated(from, to) {
      if (from._phxTracking) return
      from._phxTracking = true

      // If this is the main content area, focus it for screen readers
      if (from.id === "main-content") {
        to.setAttribute("tabindex", "-1")
        to.focus()
      }
    }
  }
})

// Topbar configuration
topbar.config({
  barColors: {
    '0': '#3b82f6',
    '0.5': '#60a5fa',
    '1.0': '#93c5fd'
  },
  shadowColor: 'rgba(59, 130, 246, 0.5)',
  barThickness: 3
})

window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// Initialize dark mode from localStorage on page load
if (!document.documentElement.classList.contains("dark") && !localStorage.getItem("darkMode")) {
  const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
  if (prefersDark) {
    document.documentElement.classList.add("dark")
  }
}

liveSocket.connect()

// Expose liveSocket for debugging in development
if (window.location.hostname === "localhost") {
  window.liveSocket = liveSocket
}
