import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static get targets() {
        return ['form','submitBouton','fieldRequire', 'checkRequire'];
    }
    connect() {

    }
    validateBtn(isValid){
        if (isValid == true) {
            this.submitBoutonTarget.disabled = false;
        } else {
            this.submitBoutonTarget.disabled = true;
        }
    }
    validateForm(event){
        let isValid = true;
        this.fieldRequireTargets.forEach((field) => {
            if (field.value == "" && field.disabled == false){
                isValid = false;
            }
        })
        if (this.data.get("nomsorganismes")!= null){
            const nom_orga = document.getElementById("nom").value;
            const noms_organismes = JSON.parse(this.data.get("nomsorganismes"));
            noms_organismes.forEach((nom) => {
                if (nom_orga == nom){
                    isValid = false;
                }
            })
        }
        this.validateBtn(isValid);
        if (!isValid) {
            event.preventDefault();
        }
    }
    ChangeNom(event){
        document.getElementById("nom").classList.remove('fr-input--error');
        document.getElementById("nom").parentNode.classList.remove('fr-input-group--error');
        document.getElementById("ErreurNom").classList.add("fr-hidden");
        const result = event.target.value;
        const noms_organismes = JSON.parse(this.data.get("nomsorganismes"));
        noms_organismes.forEach((nom) => {
            if (result == nom){
                document.getElementById("nom").classList.add('fr-input--error');
                document.getElementById("nom").parentNode.classList.add('fr-input-group--error');
                document.getElementById("ErreurNom").classList.remove("fr-hidden");
            }
        })
    }
    ChangeSiren(event){
        document.getElementById("alertSiren").classList.add("fr-hidden");
        const result = event.target.value;
        const siren_organismes = JSON.parse(this.data.get("sirenorganismes"));
        siren_organismes.forEach((siren) => {
            if (result == siren){
                document.getElementById("alertSiren").classList.remove("fr-hidden");
            }
        })
    }
    changeNature(event){
        const result = getSelectedValues(event);
        const date_previsionnelle= document.getElementById("date_previsionnelle_dissolution")
        if (result == "GIP"){
            date_previsionnelle.disabled = false;
            date_previsionnelle.parentNode.classList.remove('fr-select-group--disabled');
        }else{
            date_previsionnelle.disabled = true;
            date_previsionnelle.parentNode.classList.add('fr-select-group--disabled');
            date_previsionnelle.value = null;
        }
    }
    changeEtat(event){
        const result = getSelectedValues(event);
        const date_dissolution= document.getElementById("date_dissolution");
        const effet_dissolution= document.getElementById("effet_dissolution");
        const btn_rattachement= document.getElementById("BtnRattachement")
        if (result == "Inactif"){
            [date_dissolution,effet_dissolution].forEach((field) =>{
                field.disabled = false;
                field.parentNode.classList.remove('fr-select-group--disabled');
            })
        }else{
            [date_dissolution,effet_dissolution, btn_rattachement].forEach((field) =>{
                field.disabled = true;
                field.parentNode.classList.add('fr-select-group--disabled');
            })
            date_dissolution.value = null;
            effet_dissolution.selectedIndex = 0;
            btn_rattachement.setAttribute("aria-expanded", "false");
        }
    }
    changeEffetDissolution(event){
        const result = getSelectedValues(event);
        const btn_rattachement= document.getElementById("BtnRattachement")
        if (result == "Rattachement" || result == "création"){
            btn_rattachement.disabled = false;
            btn_rattachement.parentNode.classList.remove('fr-select-group--disabled');

        }else{
            btn_rattachement.disabled = true;
            btn_rattachement.parentNode.classList.add('fr-select-group--disabled');
            btn_rattachement.setAttribute("aria-expanded", "false");
        }
    }
    ChangeGBCP1(event){
        const agent_comptable_no= document.getElementById("radio-agent");
        const agent_comptable_oui= document.getElementById("radio-agent-1");
        const gbcp_3_oui= document.getElementById("radio-gbcp-3");
        const gbcp_3_no= document.getElementById("radio-gbcp-3N");
        const comptabilite_non= document.getElementById("radio-compta");
        const comptabilite_oui= document.getElementById("radio-compta-1");
        const comptabilite_adapte= document.getElementById("radio-compta-b");
        const degre= document.getElementById("degre_gbcp");
        const value = JSON.parse(event.target.value);
        if (value == true){
            agent_comptable_no.disabled = true;
            agent_comptable_oui.checked = true;
            gbcp_3_oui.disabled = false;
        }else{
            agent_comptable_no.disabled = false;
            gbcp_3_no.checked = true;
            gbcp_3_oui.disabled = true;
            comptabilite_non.checked = true;
            comptabilite_oui.disabled = true;
            comptabilite_adapte.disabled = true;
            degre.selectedIndex = 5;
        }
    }
    ChangeGBCP3(event){
        const value = JSON.parse(event.target.value);
        const comptabilite_non= document.getElementById("radio-compta");
        const comptabilite_oui= document.getElementById("radio-compta-1");
        const comptabilite_adapte= document.getElementById("radio-compta-b");
        if (value == false){
            comptabilite_non.checked = true;
            comptabilite_oui.disabled = true;
            comptabilite_adapte.disabled = true;
        }else{
            comptabilite_oui.disabled = false;
            comptabilite_adapte.disabled = false;
        }
    }
    validateFormStep2(event){
        let isValid = true;
        const checkRequireTargets = this.checkRequireTargets.filter(target => target.checked);
        if (checkRequireTargets.length != 3) {
            isValid = false;
        }
        this.validateBtn(isValid);
        if (!isValid) {
            event.preventDefault();
        }
    }
    ChangeControle(event){
        const value = JSON.parse(event.target.value);
        const inputFields = this.formTarget.querySelectorAll('input:not([type="hidden"]), select');
        inputFields.forEach((field) => {
            if (value == false){
                if (field.name != "organisme[presence_controle]"&& field.id != "controleur" &&
                    field.id != "submitBouton" && field.name != "organisme[document_controle_present]"){
                    field.disabled = true;
                    console.log(field);
                    console.log(field.parentNode)
                    if (field.nodeName === 'INPUT') {
                        field.value = null;
                        field.parentNode.classList.add('fr-input-group--disabled');
                    }else if (field.nodeName === 'SELECT') {
                        field.selectedIndex = 0;
                        field.parentNode.classList.add('fr-select-group--disabled');
                    }
                }else if (field.name == "organisme[document_controle_present]"){
                    field.closest('fieldset').disabled = true;
                    if (field.id == "radio-document"){
                        field.checked = true;
                    }

                }
            }else{
                if (field.nodeName === 'INPUT') {
                    if (field.name == "organisme[document_controle_present]"){
                        field.closest('fieldset').disabled = false;
                    }else if (field.id != "date_signature" && field.id != "document_controle_lien"){
                        field.disabled = false;
                        field.parentNode.classList.remove('fr-input-group--disabled');
                    }
                }else if (field.nodeName === 'SELECT') {
                    field.disabled = false;
                    field.parentNode.classList.remove('fr-select-group--disabled');
                }
            }

        })
    }
    ChangePresenceDocument(event){
        const date = document.getElementById("date_signature");
        const lien = document.getElementById("document_controle_lien");
        if (event.target.value == 'true'){
            date.disabled = false;
            date.parentNode.classList.remove('fr-input-group--disabled');
            lien.disabled = false;
            lien.parentNode.classList.remove('fr-input-group--disabled');
        }else{
            date.disabled = true;
            date.parentNode.classList.add('fr-input-group--disabled');
            lien.disabled = true;
            lien.parentNode.classList.add('fr-input-group--disabled');
        }
    }
    validateFormStep3(event){
        let isValid = true;
        this.fieldRequireTargets.forEach((field) => {
            if (field.value == "" && field.disabled == false){
                isValid = false;
            }
        })
        const checkRequireTargets = this.checkRequireTargets.filter(target => target.checked);
        if (checkRequireTargets.length != 1) {
            isValid = false;
        }
        this.validateBtn(isValid);
        if (!isValid) {
            event.preventDefault();
        }
    }
    ChangeTutelle(event){
        const value = JSON.parse(event.target.value);
        if (value == true){
            document.getElementById("radio-approbation-1").closest('fieldset').disabled = false;
        }else{
            document.getElementById("radio-approbation-1").closest('fieldset').disabled = true;
            document.getElementById("radio-approbation-1").checked = false;
            document.getElementById("radio-approbation").checked = false;
            document.getElementById("autorite").selectedIndex = 0;
            document.getElementById("autorite").disabled = true;
            document.getElementById("autorite").parentNode.classList.add('fr-select-group--disabled');
        }
    }
    ChangeApprobation(event){
        const autorite = document.getElementById("autorite");
        const value = JSON.parse(event.target.value);
        if (value == true){
            autorite.disabled = false;
            autorite.parentNode.classList.remove('fr-select-group--disabled');
        }else{
            autorite.selectedIndex = 0;
            autorite.disabled = true;
            autorite.parentNode.classList.add('fr-select-group--disabled');
        }
    }
    ChangeAdmin(event){
        const admin_db_fonction = document.getElementById("admin_db_fonction");
        if (event.target.value == 'true'){
            admin_db_fonction.disabled = false;
            admin_db_fonction.parentNode.classList.remove('fr-input-group--disabled');
        }else{
            admin_db_fonction.value = null;
            admin_db_fonction.disabled = true;
            admin_db_fonction.parentNode.classList.add('fr-input-group--disabled');
        }
    }
    submitForm(event){
        let isValid = this.validateForm(this.formTarget);
        if (!isValid) {
            event.preventDefault();
        }
    }
    Dropdown(e){
        e.preventDefault();
    }
}
function getSelectedValues(event) {
    return [...event.target.selectedOptions].map(option => option.value)
}