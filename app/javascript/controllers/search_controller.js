import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static get targets() {
        return ["form","input","button","listeDeroulante"];
    }
    connect() {
    }
    autocomplete() {
        const query = this.inputTarget.value.trim();
        this.formTarget.requestSubmit();
        if (query.length >= 1) {
            this.buttonTarget.setAttribute("aria-expanded", "true");
        }else{
            this.buttonTarget.setAttribute("aria-expanded", "false");
        }
    }

    updateList(){
        const searchTerm = this.removeAccents(this.inputTarget.value.toLowerCase());
        this.listeDeroulanteTargets.forEach((listeDeroulante) => {
            listeDeroulante.querySelectorAll(".form-check").forEach((item) => {
                const label = this.removeAccents(item.querySelector("label").textContent.toLowerCase());
                if (label.includes(searchTerm)) {
                    listeDeroulante.style.display = "block";
                } else {
                    listeDeroulante.style.display = "none";
                }
            });
        });
    }
    removeAccents(text) {
        return text.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
    }

    Dropdown(e){
        e.preventDefault();
    }
}
