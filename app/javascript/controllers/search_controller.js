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
        this.collapseMenu(query, this.buttonTarget);
    }

    // liste déroulante de check box multi select dans formulaire
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
    updateSearch(e){
        e.preventDefault();
        const searchTerm = this.removeAccents(this.inputTarget.value.toLowerCase());
        this.collapseMenu(searchTerm, this.buttonTarget);
        let displayedElementsCount = 0; // Initialise le compteur d'éléments affichés
        this.listeDeroulanteTargets.forEach((listeDeroulante) => {
            const label = this.removeAccents(listeDeroulante.querySelector(".element").textContent.toLowerCase());
            if (label.includes(searchTerm)) {
                listeDeroulante.style.display = "block";
                displayedElementsCount++;
            } else {
                listeDeroulante.style.display = "none";
            }
        });
        const resultatCount = document.getElementById("nombreResultat")
        if (resultatCount != null){
            resultatCount.innerHTML = displayedElementsCount;
        }
        const resultats = document.getElementById("resultats");
        if (displayedElementsCount == 0){
            resultats.classList.remove("fr-hidden");
        }else{
            resultats.classList.add("fr-hidden");
        }
    }


    submitSearch(e){

        e.preventDefault();
        let submit = true
        // mettre à jour la valeur de organisme
        console.log(event.currentTarget)
        const searchValue = event.currentTarget.dataset.searchValue;
        const organisme_field = document.getElementById("organisme_field");
        organisme_field.value = searchValue;
        this.inputTarget.value = ""
        // fin du collapse
        this.buttonTarget.setAttribute("aria-expanded", "false");
        let formSearch = document.getElementById("formSearch");
        const modalAutocomplete = document.getElementById("modal-autocomplete");
        let labelResultat = document.getElementById("labelResultat");
        // Attendre la fin de l'evenement
        modalAutocomplete.addEventListener("transitionend", () => {
            if (submit){
                formSearch.classList.add("fr-hidden");
                labelResultat.classList.remove("fr-hidden");
            }
            submit = false
        });

        labelResultat.innerHTML = `<button class="fr-tag fr-tag--dismiss" aria-label="Retirer">${event.currentTarget.innerHTML}</button>`;
        this.formTarget.requestSubmit();

    }
    showForm(){
        const formSearch = document.getElementById("formSearch");
        formSearch.classList.remove("fr-hidden");
        const labelResultat = document.getElementById("labelResultat");
        labelResultat.classList.add("fr-hidden");
        const organisme_field = document.getElementById("organisme_field");
        organisme_field.value = null;
        this.formTarget.requestSubmit();
    }
    removeAccents(text) {
        return text.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
    }

    collapseMenu(searchTerm, target){
        if (searchTerm.length >= 1) {
            target.setAttribute("aria-expanded", "true");
        }else{
            target.setAttribute("aria-expanded", "false");
        }
    }

    Dropdown(e){
        e.preventDefault();
    }
}
