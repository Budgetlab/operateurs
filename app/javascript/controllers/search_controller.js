import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static get targets() {
        return ["form","input","button"];
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
    Dropdown(e){
        e.preventDefault();
    }
}
