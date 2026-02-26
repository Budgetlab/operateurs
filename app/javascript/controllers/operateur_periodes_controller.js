import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["block", "list", "periodeItem", "deInput", "aInput", "aGroup", "avecFin", "addBtn", "addBtnWrapper", "deHidden", "aHidden", "details"]

  connect() {
    this.periodeIndex = this.periodeItemTargets.length
    // If De is pre-filled (existing open period), ensure hidden is active
    const de = parseInt(this.deInputTarget.value)
    if (!isNaN(de) && de >= 2000) {
      this.deHiddenTarget.name = `periodes[${this.periodeIndex}][de]`
      this.deHiddenTarget.value = de
    }
  }

  syncDeHidden() {
    const de = parseInt(this.deInputTarget.value)
    if (!isNaN(de) && de >= 2000) {
      this.deHiddenTarget.name = `periodes[${this.periodeIndex}][de]`
      this.deHiddenTarget.value = de
    } else {
      this.deHiddenTarget.name = ''
      this.deHiddenTarget.value = ''
    }
  }

  toggleOperateur() {
    const isOui = this.element.querySelector('#radio-operateur-actif-1')?.checked
    this.blockTarget.style.display = isOui ? '' : 'none'
    this.detailsTarget.style.display = isOui ? '' : 'none'
  }

  toggleFin() {
    const avecFin = this.avecFinTarget.checked
    this.aGroupTarget.style.display = avecFin ? '' : 'none'
    this.addBtnWrapperTarget.style.display = avecFin ? '' : 'none'
    if (!avecFin) {
      this.aInputTarget.value = ''
      this.aHiddenTarget.name = ''
      this.aHiddenTarget.value = ''
    }
    this.updateAddButton()
  }

  updateAddButton() {
    const de = parseInt(this.deInputTarget.value)
    const avecFin = this.avecFinTarget.checked
    const a = avecFin ? parseInt(this.aInputTarget.value) : null

    const deValide = !isNaN(de) && de >= 2000
    const aValide  = !avecFin || (!isNaN(a) && a >= de)

    this.addBtnTarget.disabled = !(deValide && aValide)

    // Sync aHidden quand la valeur est valide
    if (avecFin && deValide && !isNaN(a) && a >= de) {
      this.aHiddenTarget.name = `periodes[${this.periodeIndex}][a]`
      this.aHiddenTarget.value = a
    } else {
      this.aHiddenTarget.name = ''
      this.aHiddenTarget.value = ''
    }

    // Feedback visuel si année fin < année début
    if (avecFin && !isNaN(a) && a < de) {
      this.aInputTarget.classList.add('fr-input--error')
    } else {
      this.aInputTarget.classList.remove('fr-input--error')
    }
  }

  addPeriode() {
    const de = parseInt(this.deInputTarget.value)
    const avecFin = this.avecFinTarget.checked
    const a = avecFin ? parseInt(this.aInputTarget.value) : null

    if (isNaN(de)) return

    const idx = this.periodeIndex++
    const item = document.createElement('div')
    item.className = 'fr-grid-row fr-grid-row--gutters fr-grid-row--middle fr-mb-1w periode-item'
    item.dataset.operateurPeriodesTarget = 'periodeItem'

    const label = a != null ? `De <strong>${de}</strong> à <strong>${a}</strong>` : `De <strong>${de}</strong> → présent`

    item.innerHTML = `
      <input type="hidden" name="periodes[${idx}][de]" value="${de}" />
      ${a != null ? `<input type="hidden" name="periodes[${idx}][a]" value="${a}" />` : ''}
      <div class="fr-col-auto">
        <span class="fr-text--sm">${label}</span>
      </div>
      <div class="fr-col-auto">
        <button type="button" class="fr-btn fr-btn--tertiary-no-outline fr-btn--sm fr-icon-delete-line"
                aria-label="Supprimer cette période"
                data-action="click->operateur-periodes#removePeriode">
        </button>
      </div>
    `

    this.listTarget.appendChild(item)

    // Reset form
    this.deInputTarget.value = ''
    this.aInputTarget.value = ''
    this.avecFinTarget.checked = false
    this.aGroupTarget.style.display = 'none'
    this.addBtnWrapperTarget.style.display = 'none'
    this.addBtnTarget.disabled = true
    // Clear hidden inputs — period is now in the list
    this.deHiddenTarget.name = ''
    this.deHiddenTarget.value = ''
    this.aHiddenTarget.name = ''
    this.aHiddenTarget.value = ''
  }

  removePeriode(event) {
    event.currentTarget.closest('.periode-item').remove()
  }
}
