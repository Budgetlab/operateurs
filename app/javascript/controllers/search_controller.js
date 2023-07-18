import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static get targets() {
        return ["form","input","button"];
    }
    connect() {
    }
    autocomplete() {
        const query = this.inputTarget.value.trim();
        if (query.length >= 1) {
            this.formTarget.requestSubmit();
            this.buttonTarget.setAttribute("aria-expanded", "true");
        }else{
            this.buttonTarget.setAttribute("aria-expanded", "false");
        }
    }
}
