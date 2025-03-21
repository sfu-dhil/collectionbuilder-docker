const getPreferredTheme = () => window.matchMedia("(prefers-color-scheme: dark)").matches ? 'dark' : 'light'
const updateThemeUI = () => {
  const theme = localStorage.getItem('theme') || 'auto'
  document.querySelector("html").setAttribute("data-bs-theme", theme === 'auto' ? getPreferredTheme() : theme)

  const activeThemeIcon = document.querySelector('.theme-icon-active use')
  const btnToActive = document.querySelector(`[data-bs-theme-value="${theme}"]`)
  const svgOfActiveBtn = btnToActive.querySelector('svg use').getAttribute('href')

  document.querySelectorAll('[data-bs-theme-value]').forEach(element => element.classList.remove('active'))

  btnToActive.classList.add('active')
  activeThemeIcon.setAttribute('href', svgOfActiveBtn)
}
window.addEventListener('DOMContentLoaded', () => {
  updateThemeUI()

  document.querySelectorAll('[data-bs-theme-value]').forEach(toggle => {
    toggle.addEventListener('click', () => {
      localStorage.setItem('theme', toggle.getAttribute('data-bs-theme-value'))
      updateThemeUI()
    })
  })
})