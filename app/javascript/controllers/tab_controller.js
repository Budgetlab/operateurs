import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static get targets() {
        return ['section', 'nav'];
    }
    connect() {
    }
    showSection(event) {
        event.preventDefault();
        this.sectionTargets.forEach((section) => {
            section.removeAttribute("id");
        });

        // Récupérer le groupe de sections de l'onglet actif
        const activeTabId = event.currentTarget.getAttribute("aria-controls");
        const activeTab = document.getElementById(activeTabId);

        const activeTabSections = activeTab.querySelectorAll("[data-tab-target]");
        // Afficher les sections correspondantes
        activeTabSections.forEach((section) => {
            section.id = section.getAttribute("data-tab-value");
        });

    }

    changeNav(event){
        this.navTargets.forEach((nav) => {
            nav.removeAttribute("aria-current");
        });
        event.currentTarget.setAttribute("aria-current", "page")
    }
}
