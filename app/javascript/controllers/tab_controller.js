import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static get targets() {
        return ['section', 'nav'];
    }
    connect() {
        if (document.getElementById("budget-initial-tab") != null ){
            const activeTab = document.getElementById("budget-initial-tab");

            const activeTabSections = activeTab.querySelectorAll("[data-tab-target]");
            // Afficher les sections correspondantes
            activeTabSections.forEach((section) => {
                section.id = section.getAttribute("data-tab-value");
            });
        }
        if (document.getElementById("nav_credits") != null){
            this.afficherCredits();
        }
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
        this.afficherCredits();

    }
    afficherCredits(){
        const nav_credits = document.getElementById("nav_credits");
        if (document.getElementById("credits") != null){
            nav_credits.classList.remove('fr-hidden');
        }else{
            nav_credits.classList.add('fr-hidden');
        }
    }

    changeNav(event){
        this.navTargets.forEach((nav) => {
            nav.removeAttribute("aria-current");
        });
        event.currentTarget.setAttribute("aria-current", "page")
    }
}
