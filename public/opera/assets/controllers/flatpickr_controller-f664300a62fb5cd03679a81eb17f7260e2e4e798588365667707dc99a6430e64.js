import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"
import "flatpickr/dist/l10n/fr.js"

export default class extends Controller {
    static targets = []

    connect() {
        const modal = document.getElementById('picker-container')

        if (modal != null){
            flatpickr(this.element, {
                locale: 'fr',
                dateFormat: "d/m/Y",
                appendTo: document.getElementById('picker-container')
            })
        }else {
            flatpickr(this.element, {
                locale: 'fr',
                dateFormat: "d/m/Y",
            })
        }
    }

};
