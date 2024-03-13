import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static get targets() {
        return ["form"];
    }

    connect() {
    }

    addTagSelected(event){
        event.preventDefault();
        const elementType = event.currentTarget.tagName.toLowerCase();
        const fieldName = event.currentTarget.getAttribute("data-field");
        let fieldValue = document.getElementById(fieldName);
        if (elementType === "button") {
            let selectedValue = event.currentTarget.textContent.trim();
            event.currentTarget.setAttribute("aria-pressed", "true");
            // Mettre à jour champ_field uniquement si c'est un bouton
            this.updateArrayfield(fieldValue, selectedValue);
            this.formTarget.requestSubmit();

        }else{
            let selectedValue = event.currentTarget.value;
            if (selectedValue) {
                // Récupérer l'élément caché contenant les valeurs sélectionnées
                this.updateArrayfield(fieldValue, selectedValue);
                // Ajouter les tags
                const tag = `<li data-action="click->request#removeTagSelected" data-field="${fieldName}"><button class="fr-tag fr-tag--sm fr-tag--dismiss" aria-label="Retirer">${selectedValue}</button></li>`;
                const nomTag = event.currentTarget.getAttribute("data-tag");
                const fieldTag = document.getElementById(nomTag);
                fieldTag.insertAdjacentHTML("beforeend", tag);
                // Réinitialiser le champ select
                const selectElement = event.currentTarget.closest(".fr-select-group").querySelector(".fr-select");
                selectElement.selectedIndex = 0;

                this.formTarget.requestSubmit();
            }
        }

    }

    updateArrayfield(fieldValue, selectedValue){
        // Convertir la valeur du champ caché en un tableau JavaScript
        let selectedValues = fieldValue.value ? JSON.parse(fieldValue.value) : [];
        // Ajouter la valeur sélectionnée au tableau
        selectedValues.push(selectedValue);
        // Mettre à jour la valeur du champ caché avec le tableau
        fieldValue.value = JSON.stringify(selectedValues);
    }

    removeTagSelected(event){
        event.preventDefault();

        const selectedValue = event.target.textContent;
        const fieldName = event.currentTarget.getAttribute("data-field");
        const fieldValue = document.getElementById(fieldName);
        let selectedValues = fieldValue.value ? JSON.parse(fieldValue.value) : [];
        selectedValues = selectedValues.filter(value => value !== selectedValue);
        fieldValue.value = JSON.stringify(selectedValues);

        // Supprimer le bouton cliqué
        // event.target.parentNode.removeChild(e.target);
        this.formTarget.requestSubmit()
    }

}