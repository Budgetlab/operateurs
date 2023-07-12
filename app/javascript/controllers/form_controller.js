import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static get targets() {
        return ['form','submitBouton','fieldRequire', 'checkRequire','checklist'];
    }
    connect() {
        this.validateForm(this.formTarget);
        if (this.data.get("nomsorganismes")!= null) {
            this.changeEtat();
            this.changeNature();
            this.changeEffetDissolution();
            this.checkBox();
        }
        if (this.element.querySelector('#radio-gbcp-1') != null){
            this.ChangeGBCP1();
            this.ChangeGBCP3();
        }
        if (this.element.querySelector('#radio-controle-1') != null){
            this.ChangeControle();
            this.ChangePresenceDocument();
        }
        if (this.element.querySelector('#radio-tutelle-1') != null){
            this.ChangeTutelle();
            this.ChangeApprobation();
            this.checkBox();
        }
        if (this.element.querySelector('#radio-admin-1') != null){
            this.ChangeAdmin();
        }
    }
    validateBtn(isValid){
        this.submitBoutonTarget.disabled = !isValid;
    }
    validateForm(){
        let isValid = true;
        const inputFields = Array.from(this.formTarget.querySelectorAll('input:not([type="hidden"]):not([type="radio"]), select'));
        inputFields.forEach((field) => {
            if (field.value != "") {
                this.enableInput(field);
            }
        })
        this.fieldRequireTargets.forEach((field) => {
            if (field.value == "" && field.disabled == false){
                isValid = false;
            }
        })
        if (this.checkRequireTargets != []){
            const checkRequireTargetschecked = this.checkRequireTargets.filter(target => target.checked);
            if (this.checkRequireTargets.length > 0 && checkRequireTargetschecked.length < Math.floor(this.checkRequireTargets.length/2)) {
                isValid = false;
            }
        }
        this.validateBtn(isValid);
        return isValid;
    }
    addErreurInput(input){
        input.classList.add('fr-select--error');
        input.parentNode.classList.add('fr-select-group--error');
    }
    removeErreurInput(input){
        input.classList.remove('fr-select--error');
        input.parentNode.classList.remove('fr-select-group--error');
    }
    hideField(field){
        field.classList.add("fr-hidden");
    }
    showField(field){
        field.classList.remove("fr-hidden");
    }
    disableInput(input){
        input.disabled = true;
        input.parentNode.classList.add('fr-select-group--disabled');
        if (input.nodeName === 'INPUT') {
            input.value = null;
        }else if (input.nodeName === 'SELECT') {
            input.selectedIndex = 0;
        }
    }
    enableInput(input){
        input.disabled = false;
        input.parentNode.classList.remove('fr-select-group--disabled');
    }

    ChangeNom(event){
        const nom_input = document.getElementById("nom");
        const text_erreur = document.getElementById("ErreurNom")
        const result = event.target.value;
        const noms_organismes = JSON.parse(this.data.get("nomsorganismes"));
        this.removeErreurInput(nom_input);
        this.hideField(text_erreur);
        if (noms_organismes.includes(result)) {
            this.addErreurInput(nom_input);
            this.showField(text_erreur);
            this.validateBtn(false);
        }
    }
    ChangeSiren(event){
        const text_siren_alert = document.getElementById("alertSiren")
        const result = parseInt(event.target.value);
        const siren_organismes = JSON.parse(this.data.get("sirenorganismes"));
        this.hideField(text_siren_alert);
        if (siren_organismes.includes(result)) {
            this.showField(text_siren_alert);
        }
    }
    changeNature(){
        const nature= document.getElementById("nature")
        const date_previsionnelle= document.getElementById("date_previsionnelle_dissolution")
        if (nature.value === "GIP"){
            this.enableInput(date_previsionnelle);
        }else{
            this.disableInput(date_previsionnelle);
        }
    }
    changeEtat(){
        const etat= document.getElementById("etat");
        const date_dissolution= document.getElementById("date_dissolution");
        const effet_dissolution= document.getElementById("effet_dissolution");
        const btn_rattachement= document.getElementById("BtnRattachement");
        const checkedFields = Array.from(this.formTarget.querySelectorAll("input[type=\'checkbox\']"));
        if (etat.value === "Inactif"){
            [date_dissolution,effet_dissolution].forEach((field) =>{
                this.enableInput(field);
            })
        }else{
            [date_dissolution,effet_dissolution, btn_rattachement].forEach((field) =>{
                this.disableInput(field);
            })
            checkedFields.forEach((field) =>{
                field.checked = false;
            })
            btn_rattachement.setAttribute("aria-expanded", "false");
        }
    }
    changeEffetDissolution(){
        const effet= document.getElementById("effet_dissolution");
        const btn_rattachement= document.getElementById("BtnRattachement");
        const checkedFields = Array.from(this.formTarget.querySelectorAll("input[type=\'checkbox\']"));
        if (effet.value === "Rattachement" || effet.value === "Création"){
            this.enableInput(btn_rattachement);

        }else{
            this.disableInput(btn_rattachement);
            checkedFields.forEach((field) =>{
                field.checked = false;
            })
            btn_rattachement.setAttribute("aria-expanded", "false");
        }
    }
    checkBox(){
        const btn_rattachement= document.getElementById("BtnRattachement");
        const checkTargetschecked = this.checklistTargets.filter(target => target.checked);
        if (checkTargetschecked.length > 0) {
            btn_rattachement.textContent = "";
            this.checklistTargets.forEach((field) =>{
                if (field.checked){
                    const label = this.element.querySelector(`label[for="${field.id}"]`);
                    btn_rattachement.textContent = btn_rattachement.textContent + label.textContent + " | " ;
                }
            })
        }else{
            btn_rattachement.textContent = "- sélectionner -"
        }
    }

    ChangeGBCP1(){
        const agent_comptable_no= document.getElementById("radio-agent");
        const agent_comptable_oui= document.getElementById("radio-agent-1");
        const gbcp_3_oui= document.getElementById("radio-gbcp-3");
        const gbcp_3_no= document.getElementById("radio-gbcp-3N");
        const comptabilite_non= document.getElementById("radio-compta");
        const comptabilite_oui= document.getElementById("radio-compta-1");
        const comptabilite_adapte= document.getElementById("radio-compta-b");
        const degre= document.getElementById("degre_gbcp");

        const gbcp= this.element.querySelector('#radio-gbcp-1').checked;
        const gbcp_no= this.element.querySelector('#radio-gbcp').checked;
        if (gbcp === true){
            agent_comptable_no.disabled = true;
            agent_comptable_oui.checked = true;
            gbcp_3_oui.disabled = false;
            this.resetChamp(degre);
            ['3°','4°','5°','6°'].forEach((deg)=>{
                const option = document.createElement("option");
                option.value = deg;
                option.innerHTML = deg;
                degre.appendChild(option);
            })

        }else if (gbcp_no == true) {
            agent_comptable_no.disabled = false;
            gbcp_3_no.checked = true;
            gbcp_3_oui.disabled = true;
            comptabilite_non.checked = true;
            comptabilite_oui.disabled = true;
            comptabilite_adapte.disabled = true;
            degre.innerHTML = "";
            const option = document.createElement("option");
            option.value = "Exclusion";
            option.innerHTML = "Exclusion";
            degre.appendChild(option);
        }
    }
    resetChamp(target){
        target.innerHTML = "";
        const option = document.createElement("option");
        option.value = "";
        option.innerHTML = "- sélectionner -";
        target.appendChild(option);
    }
    ChangeGBCP3(){
        const gbcp3= this.element.querySelector('#radio-gbcp-3').checked;
        const comptabilite_non= document.getElementById("radio-compta");
        const comptabilite_oui= document.getElementById("radio-compta-1");
        const comptabilite_adapte= document.getElementById("radio-compta-b");
        if (gbcp3 == false){
            comptabilite_non.checked = true;
            comptabilite_oui.disabled = true;
            comptabilite_adapte.disabled = true;
        }else{
            comptabilite_oui.disabled = false;
            comptabilite_adapte.disabled = false;
        }
    }

    ChangeControle(){
        const controle= this.element.querySelector('#radio-controle-1').checked;
        const inputFields = this.formTarget.querySelectorAll('input:not([type="hidden"]):not([type="submit"]), select');
        inputFields.forEach((field) => {
            if (controle == false){
                if (field.name != "organisme[presence_controle]"&& field.id != "controleur" &&
                    field.name != "organisme[document_controle_present]"){
                    this.disableInput(field)

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
                        this.enableInput(field);
                    }
                }else if (field.nodeName === 'SELECT') {
                    this.enableInput(field);
                }
            }

        })
    }
    ChangePresenceDocument(){
        const doc = this.element.querySelector('#radio-document-1').checked;
        const date = document.getElementById("date_signature");
        const lien = document.getElementById("document_controle_lien");
        if (doc === true){
            this.enableInput(date);
            this.enableInput(lien);
        }else{
            this.disableInput(date);
            this.disableInput(lien);
        }
    }

    ChangeTutelle(){
        const tutelle = this.element.querySelector('#radio-tutelle-1').checked;
        if (tutelle === true){
            document.getElementById("radio-approbation-1").closest('fieldset').disabled = false;
        }else{
            document.getElementById("radio-approbation-1").closest('fieldset').disabled = true;
            document.getElementById("radio-approbation-1").checked = false;
            document.getElementById("radio-approbation").checked = false;
            this.disableInput(document.getElementById("autorite"));
        }
    }
    ChangeApprobation(){
        const autorite = document.getElementById("autorite");
        const approbation = this.element.querySelector('#radio-approbation-1').checked;
        if (approbation === true){
            this.enableInput(autorite);
        }else{
            this.disableInput(autorite);
        }
    }
    ChangeAdmin(){
        const admin = this.element.querySelector('#radio-admin-1').checked;
        const admin_db_fonction = document.getElementById("admin_db_fonction");
        if (admin === true){
            this.enableInput(admin_db_fonction);
        }else{
            this.disableInput(admin_db_fonction);
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