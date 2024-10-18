import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static get targets() {
        return ['section'];
    }
    connect() {
        this.initialiserSection();
    }
    initialiserSection(){
        // Récupérer tous les onglets
        const tabs = document.querySelectorAll(".fr-tabs__tab");

        // Trouver l'onglet sélectionné
        const selectedTab = Array.from(tabs).find((tab) => tab.getAttribute("aria-selected") === "true");
        const ariaControlsValue = selectedTab.getAttribute("aria-controls");
        if (document.getElementById(ariaControlsValue) != null ){
            const activeTab = document.getElementById(ariaControlsValue);

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
        // reset tab check false
        const elements = document.querySelectorAll(".fr-toggle__input");
        elements.forEach(element =>{
            element.checked = false;
        })
        const blocs = document.querySelectorAll(".options");
        blocs.forEach(element => {
            element.classList.add("fr-hidden");
        })
    }
    afficherCredits(){
        const nav_credits = document.getElementById("nav_credits");
        if (document.getElementById("credits") != null){
            nav_credits.classList.remove('fr-hidden');
        }else{
            nav_credits.classList.add('fr-hidden');
        }
    }

    openModal(event){
        const chiffreId = event.target.getAttribute("data-tab-value");
        const modalId = `modal-${chiffreId}`;
        const bouton = document.querySelector(`[aria-controls="${modalId}"]`);
        bouton.click()
    }

};
