import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets() {
    return ['commentaireLong','commentaireCourt'];
  }
  connect() {
  }
  toggle(event) {
    const isChecked = event.target.checked;
    const blocs = document.querySelectorAll(".options");
    blocs.forEach(element => {
      element.classList.toggle("fr-hidden");
    })
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
