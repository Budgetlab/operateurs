import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets() {
    return ['commentaireLong','commentaireCourt'];
  }
  connect() {
  }
  toggle(event) {
    const isChecked = event.target.checked;
    const sectionId = event.target.getAttribute("data-section");
    const section = this.findSection(sectionId);
    section.classList.toggle("fr-hidden");
  }
  findSection(sectionId) {
    return document.getElementById(sectionId);
  }
  afficherPlus() {
    this.commentaireLongTarget.style.display = 'inline';
    this.commentaireCourtTarget.style.display = 'none';
  }
  afficherMoins() {
    this.commentaireCourtTarget.style.display = 'inline';
    this.commentaireLongTarget.style.display = 'none';
  }
}
