import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static get targets() {
        return ["form", "list", "filterField"];
    }

    connect() {
    }

    checkTag(event){
        event.preventDefault();
        let button = event.currentTarget;
        let checkbox = button.querySelector('input[type="checkbox"]');
        checkbox.checked = !checkbox.checked;
        this.formTarget.requestSubmit();
    }
    addTagSelected(event){
        event.preventDefault();
        const selectedValue = event.currentTarget.value;
        const selectedName = event.currentTarget.options[event.currentTarget.selectedIndex].text;
        // Ajouter les tags si n'existe pas déjà
        const tag = `<li data-action="click->request#removeTagSelected" data-value="${selectedValue}"><button class="fr-tag fr-tag--dismiss" aria-label="Retirer">${selectedName}</button></li>`;
        const nomTag = event.currentTarget.getAttribute("data-tag");
        const fieldTag = document.getElementById(nomTag);
        let checkbox = fieldTag.querySelector('input[type="checkbox"][value="' + selectedValue + '"]');
        if (checkbox.checked == false){
            checkbox.checked = !checkbox.checked;
            fieldTag.insertAdjacentHTML("beforeend", tag);
        }
        // Réinitialiser le champ select
        const selectElement = event.currentTarget.closest(".fr-select-group").querySelector(".fr-select");
        selectElement.selectedIndex = 0;
        // submit form
        this.formTarget.requestSubmit();
    }
    removeTagSelected(event){
        event.preventDefault();
        const selectedValue = event.currentTarget.getAttribute("data-value");
        let checkbox = event.currentTarget.parentNode.querySelector('input[type="checkbox"][value="' + selectedValue + '"]');
        if (checkbox.checked){
            checkbox.checked = !checkbox.checked;
        }
        this.formTarget.requestSubmit()
    }

    addTagSelected2(event){
        event.preventDefault();
        const elementType = event.currentTarget.tagName.toLowerCase();
        const fieldName = event.currentTarget.getAttribute("data-field");
        let fieldValue = document.getElementById(fieldName);
        if (elementType === "select") {
            let selectedValue = event.currentTarget.value;
            this.updateArrayfield(fieldValue, selectedValue);
            const selectedName = event.currentTarget.options[event.currentTarget.selectedIndex].text;
            // Ajouter les tags
            const tag = `<li data-action="click->request#removeTagSelected" data-field="${fieldName}" data-value="${selectedValue}"><button class="fr-tag fr-tag--dismiss" aria-label="Retirer">${selectedName}</button></li>`;
            const nomTag = event.currentTarget.getAttribute("data-tag");
            const fieldTag = document.getElementById(nomTag);
            fieldTag.insertAdjacentHTML("beforeend", tag);
            // Réinitialiser le champ select
            const selectElement = event.currentTarget.closest(".fr-select-group").querySelector(".fr-select");
            selectElement.selectedIndex = 0;
        }else{
            let selectedValue = event.currentTarget.textContent.trim();
            this.updateArrayfield(fieldValue, selectedValue);
        }

        this.formTarget.requestSubmit();
    }

    updateArrayfield(fieldValue, selectedValue){
        // Convertir la valeur du champ caché en un tableau JavaScript
        let selectedValues = fieldValue.value ? JSON.parse(fieldValue.value) : [];
        // Ajouter la valeur sélectionnée au tableau
        selectedValues.push(selectedValue);
        // Mettre à jour la valeur du champ caché avec le tableau
        fieldValue.value = JSON.stringify(selectedValues);
    }

    removeTagSelected2(event){
        event.preventDefault();
        const selectedValue = event.currentTarget.getAttribute("data-value")
        const fieldName = event.currentTarget.getAttribute("data-field");
        const fieldValue = document.getElementById(fieldName);
        let selectedValues = fieldValue.value ? JSON.parse(fieldValue.value) : [];
        selectedValues = selectedValues.filter(value => value !== selectedValue);
        fieldValue.value = JSON.stringify(selectedValues);
        // this.formTarget.requestSubmit()
    }

    submitFilter(event){

        event.preventDefault();
        // ADD THIS: Reset the 'p' parameter in the URL
        let params = new URLSearchParams(location.search);
        params.set('p', 1);
        history.replaceState(null, '', `${location.pathname}?${params}`);

        let url = this.formTarget.action + "?" + new URLSearchParams(new FormData(this.formTarget)).toString();

        fetch(url, {
            headers: {
                "X-Requested-With": "XMLHttpRequest"
            }
        })
            .then(response => response.text())
            .then(html => {
                this.listTarget.innerHTML = html;
            });
    }

    paginate(event){

        let filterActivated = this.filterFieldTargets.some(field => field.value !== '')
        if (filterActivated){
            event.preventDefault()
            const url = new URL(event.target.href) // The href contains the page number
            // Retrieve active page parameter
            let params = new URLSearchParams(url.search)
            let page = params.get('p')
            fetch(url, {
                method: 'GET',
                headers: {
                    "Accept": "text/html"
                },
            })
                .then(response => response.text())
                .then(html => this.listTarget.innerHTML = html)

            // Modify the current URL
            let currentParams = new URLSearchParams(location.search);
            currentParams.set('p', page)
            history.replaceState(null, '', `${location.pathname}?${currentParams}`);

        }
    }


}