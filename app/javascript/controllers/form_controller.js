import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static get targets() {
        return ['form','submitBouton','fieldRequire', 'checkRequire','checklist'];
    }
    connect() {

        if (document.getElementById("etat") != null){
            this.changeEtat();
            this.changeEffetDissolution();
            this.checkBox();
        }
        if (this.element.querySelector('#radio-gbcp-1') != null){
            this.ChangeGBCP1();
            this.ChangeGBCP3();
        }
        if (this.element.querySelector('#radio-controle-1') != null) {
            this.ChangeControle();
        }
        if (this.element.querySelector('#radio-document-1') != null){
            this.ChangePresenceDocument();
        }
        if (this.element.querySelector('#radio-tutelle-1') != null){
            this.ChangeTutelle();
        }
        if (document.getElementById("ministere") != null ){
            this.checkBox();
        }
        if (this.element.querySelector('#radio-admin-1') != null){
            this.ChangeAdmin();
        }
        if (this.element.querySelector('#radio-presence-1') != null){
            this.ChangeCategorie();
            this.ChangeOperateur();
            this.changeProgramme();
        }
        if (document.getElementById("chiffres") != null ){
            const fields = document.querySelectorAll("input[type='text']");
            fields.forEach(field => {
                this.changeFloatToText(field);
            });

        }
        if (document.getElementById("emplois_total") != null ) {
            this.changeEmplois();
        }
        if (document.getElementById("credits_ae_total") != null ) {
            this.changeCredits();
        }
        if (document.getElementById("tresorerie") != null ) {
            this.changeTresorerie();
        }
        if (document.getElementById("capacite_autofinancement") != null ) {
            this.changeAnalyse();
        }
        this.validateForm(this.formTarget);

    }
    validateBtn(isValid){
        this.submitBoutonTarget.disabled = !isValid;
    }
    validateBtnAffichePlus(isValid){
        const bouton = document.getElementById("btn-plus");
        bouton.disabled = !isValid;
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
        if (document.getElementById("btn-plus") != null){
            this.validateBtnAffichePlus(isValid);
        }
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
    resetChamp(target){
        target.innerHTML = "";
        const option = document.createElement("option");
        option.value = "";
        option.innerHTML = "- sélectionner -";
        target.appendChild(option);
    }
    changeDropdown(input, button, checkedFields){
        if (input === true){
            this.enableInput(button);

        }else{
            this.disableInput(button);
            checkedFields.forEach((field) =>{
                field.checked = false;
            })
            button.setAttribute("aria-expanded", "false");
        }
    }
    changeField(input, field){
        if (input === true){
            this.enableInput(field);
        }else{
            this.disableInput(field);
        }
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
        const maxLength = 9;
        const text_siren_alert = document.getElementById("alertSiren")
        const result = event.target.value.toString();
        const siren_organismes = JSON.parse(this.data.get("sirenorganismes"));
        this.hideField(text_siren_alert);
        if (siren_organismes.includes(result)) {
            this.showField(text_siren_alert);
        }

        if (event.target.value.length > maxLength) {
            event.target.value = event.target.value.slice(0, maxLength);
        }
    }
    changeEtat(){
        const etat= document.getElementById("etat");
        const date_dissolution= document.getElementById("date_dissolution");
        const effet_dissolution= document.getElementById("effet_dissolution");
        const isTrue = etat.value === "Inactif"
        this.changeField(isTrue,date_dissolution);
        this.changeField(isTrue,effet_dissolution);
        this.changeEffetDissolution();
    }
    changeEffetDissolution(){
        const effet= document.getElementById("effet_dissolution");
        if (effet != null){
            const btn_rattachement= document.getElementById("BtnRattachement");
            const checkedFields = Array.from(this.formTarget.querySelectorAll("input[type=\'checkbox\']"));
            const isTrue = effet.value === "Rattachement" || effet.value === "Création"
            this.changeDropdown(isTrue, btn_rattachement, checkedFields)
            this.checkBox();
        }
    }
    checkBox(){
        const btn_rattachement= document.getElementById("BtnRattachement");
        if (btn_rattachement != null){
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
    }

    ChangeGBCP1(){
        const agent_comptable_no= document.getElementById("radio-agent");
        const agent_comptable_oui= document.getElementById("radio-agent-1");
        const gbcp_3_oui= document.getElementById("radio-gbcp-3");
        const gbcp_3_no= document.getElementById("radio-gbcp-3N");
        const degre= document.getElementById("degre_gbcp");

        const gbcp= this.element.querySelector('#radio-gbcp-1').checked;
        const gbcp_no= this.element.querySelector('#radio-gbcp').checked;
        if (gbcp === true){
            agent_comptable_no.disabled = true;
            agent_comptable_oui.checked = true;
            gbcp_3_oui.disabled = false;
            console.log(degre.value)
            if (degre.value == "Exclusion"){
                this.resetChamp(degre);
                ['3° Etablissements publics de santé / GCS','4° Autres personnes morales de droit public (cf. arrêté)','5° Personnes morales de droit privé','6° Personnes morales de droit public hors APU'].forEach((deg)=>{
                    const option = document.createElement("option");
                    option.value = deg;
                    option.innerHTML = deg;
                    degre.appendChild(option);
                })
            }
        }else if (gbcp_no == true) {
            agent_comptable_no.disabled = false;
            gbcp_3_no.checked = true;
            gbcp_3_oui.disabled = true;
            degre.innerHTML = "";
            const option = document.createElement("option");
            option.value = "Exclusion";
            option.innerHTML = "Exclusion";
            degre.appendChild(option);
        }
        this.ChangeGBCP3();
    }
    ChangeGBCP3(){
        const gbcp3_no= this.element.querySelector('#radio-gbcp-3N').checked;
        const comptabilite_non= document.getElementById("radio-compta");
        const comptabilite_oui= document.getElementById("radio-compta-1");
        const comptabilite_adapte= document.getElementById("radio-compta-b");
        if (gbcp3_no == true){
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
                    field.name != "organisme[document_controle_present]" && field.name != "organisme[arrete_nomination]"){
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
        this.changeField(doc,date);
        this.changeField(doc,lien);
    }

    ChangeTutelle(){
        const tutelle = this.element.querySelector('#radio-tutelle-1').checked;
        if (tutelle === true){
            document.getElementById("radio-approbation-1").closest('fieldset').disabled = false;
        }else{
            document.getElementById("radio-approbation-1").closest('fieldset').disabled = true;
            document.getElementById("radio-approbation-1").checked = false;
            document.getElementById("radio-approbation").checked = false;
        }
    }
    ChangeAdmin(){
        const admin = this.element.querySelector('#radio-admin-1').checked;
        const admin_db_fonction = document.getElementById("admin_db_fonction");
        this.changeField(admin,admin_db_fonction);
    }

    ChangeOperateur(){
        const operateurRadios = Array.from(this.element.querySelectorAll('[id^="radio-operateurn"]'));
        const mission = document.getElementById("mission");
        const programme = document.getElementById("programme");
        const btn_rattachement= document.getElementById("BtnRattachement");
        const presenceRadios = Array.from(this.element.querySelectorAll('[id^="radio-presence"]'));
        const checkedFields = Array.from(this.formTarget.querySelectorAll("input[type=\'checkbox\']"));
        const is_checked = operateurRadios.some(radio => radio.checked);

        this.changeCheckDisable(!is_checked,...presenceRadios);
        this.ChangeCategorie();
        this.changeField(is_checked,programme);
        this.changeProgramme();
        this.changeField(is_checked,mission);
        this.changeDropdown(is_checked, btn_rattachement, checkedFields)
        this.checkBox();

    }
    ChangeCategorie(){
        const presence_categorie = this.element.querySelector('#radio-presence-1').checked;
        const nom_categorie = document.getElementById("nom_categorie");
        this.changeField(presence_categorie,nom_categorie);
    }
    changeCheckDisable(isdisabled, field, field_to_check){
        if (isdisabled){
            field.checked = false;
            field.disabled = true;
            field_to_check.checked = true
        }else{
            field.disabled = false;
        }
    }
    changeProgramme(){
        const mission = document.getElementById("mission");
        const programme = document.getElementById("programme").value;
        if (programme != ""){
            const token = document.querySelector('meta[name="csrf-token"]').content;
            const url = "/opera/select_mission"
            const body = { programme }
            fetch(url, {
                method: 'POST',
                body: JSON.stringify(body),
                credentials: "include",
                dataType: 'script',
                headers: {
                    "X-CSRF-Token": token,
                    "Content-Type": "application/json"
                },
            })
                .then(response => response.json()/*response.text()*/)
                .then(data => {
                    mission.innerHTML = "";
                    const opt = document.createElement("option");
                    opt.value = data.mission.id;
                    opt.innerHTML = data.mission.nom;
                    mission.appendChild(opt);
                    mission.selectedIndex = 0;
                    this.validateForm();
                });
        }else{
            this.resetChamp(mission);
        }
    }

    changeNomChiffres(){
        const comptabilite = document.getElementById("comptabilite");
        const organisme = document.getElementById("organisme").value;
        const exercice = document.getElementById("exercice").value;
        const operateur = document.getElementById("operateur");
        this.changeComptabiliteChiffres(organisme, comptabilite);
        this.changeOperateurChiffres(organisme, exercice, operateur);
    }

    changeComptabiliteChiffres(organisme, comptabilite) {
        if (organisme != ""){
            const token = document.querySelector('meta[name="csrf-token"]').content;
            const url = "/opera/select_comptabilite"
            const body = { organisme }
            fetch(url, {
                method: 'POST',
                body: JSON.stringify(body),
                credentials: "include",
                dataType: 'script',
                headers: {
                    "X-CSRF-Token": token,
                    "Content-Type": "application/json"
                },
            })
                .then(response => response.json()/*response.text()*/)
                .then(data => {
                    comptabilite.value = data.comptabilite;
                    this.validateForm();
                });
        }else{
            comptabilite.selectedIndex = 0;
        }
    }

    changeExerciceChiffres(){
        const organisme = document.getElementById("organisme").value;
        const exercice = document.getElementById("exercice").value;
        const operateur = document.getElementById("operateur");
        this.changeOperateurChiffres(organisme, exercice, operateur);
    }

    changeOperateurChiffres(organisme, exercice, operateur){
        if (organisme != "" && exercice != ""){
            const token = document.querySelector('meta[name="csrf-token"]').content;
            const url = "/opera/select_exercice"
            const body = { organisme, exercice }
            fetch(url, {
                method: 'POST',
                body: JSON.stringify(body),
                credentials: "include",
                dataType: 'script',
                headers: {
                    "X-CSRF-Token": token,
                    "Content-Type": "application/json"
                },
            })
                .then(response => response.json()/*response.text()*/)
                .then(data => {
                    operateur.value = data.operateur;
                    this.validateForm();
                });
        }else{
            operateur.selectedIndex = 0;
        }
    }
    changeNumber(event){
        const inputElement = event.target;
        const element = inputElement.value.replace(/[^0-9,]/g, "");
        const lastLetter = inputElement.value[inputElement.value.length - 1];
        const parsedValue = this.numberFormat(element);
        if (!isNaN(parsedValue)) {
            // Formatage du nombre avec séparateur de milliers
            const formattedValue = parsedValue.toLocaleString("fr-FR");
            // Mettez à jour la valeur du champ de formulaire avec le format souhaité
            if (lastLetter == ","){
                inputElement.value = formattedValue + lastLetter;
            }else {
                inputElement.value = formattedValue;
            }
        } else {
            inputElement.value = null;
        }
    }
    changeFloatToText(field){
        const parsedValue = this.numberFormat(field.value);
        if (!isNaN(parsedValue)) {
            // Formatage du nombre avec séparateur de milliers
            const formattedValue = parsedValue.toLocaleString("fr-FR");
            field.value = formattedValue;

        } else {
            field.value = null;
        }
    }
    numberFormat(number){
        const sanitizedValue = number.replace(/\u202F/g, "");
        // Remplacez la virgule par un point pour permettre les décimaux
        const sanitizedValueWithDot = sanitizedValue.replace(',', '.');
        // Analysez la valeur en tant que nombre à virgule flottante
        const parsedValue = parseFloat(sanitizedValueWithDot);
        return parsedValue;
    }
    changeEmplois(){
        if (document.getElementById("emplois_plafond") != null && document.getElementById("emplois_hors_plafond") != null){
            // Mettre à jour indicateur total emplois
            this.changeIndicateurTotalEmplois()
            // Mettre à jour indicateur hors plafond uniquement si emplois hors plafond est non null
            this.changeIndicateurHorsPlafond()
        }
        // Mettre à jour indicateur cout moyen par ETP
        this.changeIndicateurPersonnel();

        if (document.getElementById("emplois_titulaires") != null && document.getElementById("emplois_contractuels") != null){
            // Mettre à jour indicateur cout moyen titulaires
            this.changeIndicateurCoutTitulaires();
            // Mettre à jour indicateur part des contractuels
            this.changeIndicateurPartContractuels();
            // Mettre à jour indicateur cout moyen contractuels
            this.changeIndicateurCoutContractuels();
        }
        if (document.getElementById("emplois_autre_entite") != null){
            // Mettre à jour indicateur part des personnels
            this.changeIndicateurEmploisAutre();
        }
        this.validateForm();
    }
    changeIndicateurTotalEmplois(){
        const emplois_plafond = this.numberFormat(document.getElementById("emplois_plafond").value) || 0;
        const emplois_hors_plafond = this.numberFormat(document.getElementById("emplois_hors_plafond").value) || 0;
        // Mettre à jour total des emplois
        const emplois_total = emplois_plafond + emplois_hors_plafond;
        const total_field = document.getElementById("emplois_total");
        const total_text = document.getElementById("emplois_total_text");
        total_field.value = emplois_total;
        total_text.innerHTML = emplois_total.toLocaleString("fr-FR");
    }
    changeIndicateurHorsPlafond(){
        const emplois_hors_plafond_field = document.getElementById("emplois_hors_plafond");
        const emplois_hors_plafond = this.numberFormat(emplois_hors_plafond_field.value) || 0;
        const emplois_total = this.numberFormat(document.getElementById("emplois_total").value) || 0;
        const indicateur_emploi = document.getElementById("indicateur_emploi");
        this.indicateurRatio(emplois_hors_plafond_field,indicateur_emploi, emplois_hors_plafond, emplois_total,100)
    }
    changeIndicateurPersonnel(){
        const emplois_total = this.numberFormat(document.getElementById("emplois_total").value) || 0;
        const emplois_personnel_field = document.getElementById("emplois_personnel")
        const emplois_personnel = this.numberFormat(emplois_personnel_field.value) || 0;
        const indicateur_cout = document.getElementById("indicateur_cout");
        this.indicateurRatio(emplois_personnel_field, indicateur_cout, emplois_personnel,emplois_total,1)
    }
    changeIndicateurCoutTitulaires(){
        const emplois_titulaires = this.numberFormat(document.getElementById("emplois_titulaires").value) || 0;
        const emplois_titulaires_montant_field = document.getElementById("emplois_titulaires_montant")
        const emplois_titulaires_montant = this.numberFormat(emplois_titulaires_montant_field.value) || 0;
        const indicateur_cout_titulaires = document.getElementById("indicateur_cout_titulaires");
        this.indicateurRatio(emplois_titulaires_montant_field, indicateur_cout_titulaires, emplois_titulaires_montant,emplois_titulaires,1)
    }
    changeIndicateurPartContractuels(){
        const emplois_total = this.numberFormat(document.getElementById("emplois_total").value) || 0;
        const emplois_contractuels_field = document.getElementById("emplois_contractuels")
        const emplois_contractuels = this.numberFormat(emplois_contractuels_field.value) || 0;
        const indicateur_contractuels = document.getElementById("indicateur_contractuels");
        this.indicateurRatio(emplois_contractuels_field,indicateur_contractuels, emplois_contractuels, emplois_total,100)
    }
    changeIndicateurCoutContractuels(){
        const emplois_contractuels = this.numberFormat(document.getElementById("emplois_contractuels").value) || 0;
        const emplois_contractuels_montant_field = document.getElementById("emplois_contractuels_montant")
        const emplois_contractuels_montant = this.numberFormat(emplois_contractuels_montant_field.value) || 0;
        const indicateur_cout_contractuels = document.getElementById("indicateur_cout_contractuels");
        this.indicateurRatio(emplois_contractuels_montant_field, indicateur_cout_contractuels, emplois_contractuels_montant,emplois_contractuels, 1);
    }

    changeIndicateurEmploisAutre(){
        const emplois_total = this.numberFormat(document.getElementById("emplois_total").value) || 0;
        const emplois_non_remuneres = this.numberFormat(document.getElementById("emplois_non_remuneres").value) || 0;
        const emplois_autre_entite = this.numberFormat(document.getElementById("emplois_autre_entite").value) || 0;
        const indicateur_cout_autre = document.getElementById("indicateur_cout_autre");
        const num = emplois_total - emplois_non_remuneres + emplois_autre_entite;
        let field = document.getElementById("emplois_total");
        if (document.getElementById("emplois_non_remuneres").value == "" ){
            field = document.getElementById("emplois_non_remuneres");
        }else if (document.getElementById("emplois_autre_entite").value == ""){
            field = document.getElementById("emplois_autre_entite");
        }
        this.indicateurRatio(field,indicateur_cout_autre,num,emplois_total,100);
    }
    changeCredits(){
        this.changeIndicateurPoidsPersonnel();
        this.changeIndicateurPoidsFonctionnement();
        this.changeIndicateurPoidsIntervention();
        this.changeIndicateurPoidsInvestissement();
        if (document.getElementById("credits_cp_operations") != null){
            this.changeIndicateurOperations();
        }
        if (document.getElementById("credits_subvention_sp") != null) {
            this.changeIndicateurTauxSP();
        }
        this.changeIndicateursRecettes();
        this.changeIndicateurVariationRaP();
        this.changeIndicateurPoidsRaP();
        this.validateForm();
    }
    changeIndicateurPoidsPersonnel(){
        const indicateur_poids_personnel = document.getElementById("indicateur_poids_personnel");
        const credits_cp_personnel_field = document.getElementById("credits_cp_personnel")
        const credits_cp_personnel = this.numberFormat(credits_cp_personnel_field.value) || 0;
        const credits_cp_total = this.numberFormat(document.getElementById("credits_cp_total").value) || 0;
        const credits_cp_investissement = this.numberFormat(document.getElementById("credits_cp_investissement").value) || 0;
        const total = credits_cp_total - credits_cp_investissement
        this.indicateurRatio(credits_cp_personnel_field,indicateur_poids_personnel,credits_cp_personnel,total,100);
    }
    changeIndicateurPoidsFonctionnement(){
        const indicateur_poids_fonctionnement = document.getElementById("indicateur_poids_fonctionnement");
        const credits_cp_fonctionnement_field = document.getElementById("credits_cp_fonctionnement")
        const credits_cp_fonctionnement = this.numberFormat(credits_cp_fonctionnement_field.value) || 0;
        const credits_cp_total = this.numberFormat(document.getElementById("credits_cp_total").value) || 0;
        this.indicateurRatio(credits_cp_fonctionnement_field,indicateur_poids_fonctionnement,credits_cp_fonctionnement,credits_cp_total,100);
    }
    changeIndicateurPoidsIntervention(){
        const indicateur_poids_intervention = document.getElementById("indicateur_poids_intervention");
        const credits_cp_intervention_field = document.getElementById("credits_cp_intervention")
        const credits_cp_intervention = this.numberFormat(credits_cp_intervention_field.value) || 0;
        const credits_cp_total = this.numberFormat(document.getElementById("credits_cp_total").value) || 0;
        this.indicateurRatio(credits_cp_intervention_field,indicateur_poids_intervention,credits_cp_intervention,credits_cp_total,100);
    }
    changeIndicateurPoidsInvestissement(){
        const indicateur_poids_investissement = document.getElementById("indicateur_poids_investissement");
        const credits_cp_investissement_field = document.getElementById("credits_cp_investissement")
        const credits_cp_investissement = this.numberFormat(credits_cp_investissement_field.value) || 0;
        const credits_cp_total = this.numberFormat(document.getElementById("credits_cp_total").value) || 0;
        this.indicateurRatio(credits_cp_investissement_field,indicateur_poids_investissement,credits_cp_investissement,credits_cp_total,100);
    }
    changeIndicateurOperations() {
        const indicateur_operations = document.getElementById("indicateur_operations");
        const credits_cp_operations_field = document.getElementById("credits_cp_operations");
        const credits_cp_operations = this.numberFormat(credits_cp_operations_field.value) || 0;
        const credits_cp_total = this.numberFormat(document.getElementById("credits_cp_total").value) || 0;
        this.indicateurRatio(credits_cp_operations_field,indicateur_operations,credits_cp_operations,credits_cp_total,100);
    }
    changeIndicateurTauxSP() {
        const indicateur_taux_sp = document.getElementById("indicateur_taux_sp");
        const credits_subvention_sp_field = document.getElementById("credits_subvention_sp")
        const credits_subvention_sp = this.numberFormat(credits_subvention_sp_field.value) || 0;
        const credits_cp_fonctionnement = this.numberFormat(document.getElementById("credits_cp_fonctionnement").value) || 0;
        const credits_cp_personnel = this.numberFormat(document.getElementById("credits_cp_personnel").value) || 0;
        const total = credits_cp_fonctionnement + credits_cp_personnel
        this.indicateurRatio(credits_subvention_sp_field,indicateur_taux_sp,credits_subvention_sp,total,100);
    }
    changeIndicateursRecettes(){
        const indicateur_subv_etat = document.getElementById("indicateur_subv_etat");
        const indicateur_total_recettes_propres = document.getElementById("indicateur_total_recettes_propres");
        const indicateur_total_recettes_globalisees = document.getElementById("indicateur_total_recettes_globalisees");
        const indicateur_total_recettes_flechees = document.getElementById("indicateur_total_recettes_flechees");
        const indicateur_total_recettes = document.getElementById("indicateur_total_recettes");
        const indicateur_taux_recettes_propres = document.getElementById("indicateur_taux_recettes_propres");
        const indicateur_poids_recettes_globalisees = document.getElementById("indicateur_poids_recettes_globalisees");
        const indicateur_poids_financements_etat = document.getElementById("indicateur_poids_financements_etat");
        const indicateur_solde_budgetaire = document.getElementById("indicateur_solde_budgetaire");
        const indicateur_solde_budgetaire_fleche = document.getElementById("indicateur_solde_budgetaire_fleche");

        const credits_financements_etat_fleches = this.numberFormat(document.getElementById("credits_financements_etat_fleches").value) || 0;
        const credits_recettes_propres_flechees = this.numberFormat(document.getElementById("credits_recettes_propres_flechees").value) || 0;
        const credits_financements_publics_fleches = this.numberFormat(document.getElementById("credits_financements_publics_fleches").value) || 0;
        const credits_financements_etat_autres = this.numberFormat(document.getElementById("credits_financements_etat_autres").value) || 0;
        const credits_recettes_propres_globalisees = this.numberFormat(document.getElementById("credits_recettes_propres_globalisees").value) || 0;
        const credits_fiscalite_affectee = this.numberFormat(document.getElementById("credits_fiscalite_affectee").value) || 0;
        const credits_financements_publics_autres = this.numberFormat(document.getElementById("credits_financements_publics_autres").value) || 0;
        const credits_cp_total = this.numberFormat(document.getElementById("credits_cp_total").value) || 0;
        const credits_cp_recettes_flechees = this.numberFormat(document.getElementById("credits_cp_recettes_flechees").value) || 0;

        let somme_total_subv_etat = credits_financements_etat_autres + credits_financements_etat_fleches;
        const somme_total_recettes_propres = credits_recettes_propres_globalisees + credits_recettes_propres_flechees;
        let somme_total_recettes_globalisees = credits_recettes_propres_globalisees + credits_financements_etat_autres + credits_fiscalite_affectee + credits_financements_publics_autres;
        let somme_total_recettes_flechees = credits_recettes_propres_flechees + credits_financements_etat_fleches + credits_financements_publics_fleches;
        let somme_total_recettes = credits_recettes_propres_flechees + credits_financements_etat_fleches + credits_financements_publics_fleches + credits_recettes_propres_globalisees + credits_financements_etat_autres + credits_fiscalite_affectee + credits_financements_publics_autres;

        if (document.getElementById("credits_subvention_sp") != null){
            const credits_subvention_sp = this.numberFormat(document.getElementById("credits_subvention_sp").value) || 0;
            const credits_subvention_investissement_globalisee = this.numberFormat(document.getElementById("credits_subvention_investissement_globalisee").value) || 0;
            const credits_subvention_investissement_flechee = this.numberFormat(document.getElementById("credits_subvention_investissement_flechee").value) || 0;
            somme_total_subv_etat = somme_total_subv_etat + credits_subvention_sp + credits_subvention_investissement_globalisee + credits_subvention_investissement_flechee;
            somme_total_recettes_globalisees = somme_total_recettes_globalisees + credits_subvention_sp + credits_subvention_investissement_globalisee ;
            somme_total_recettes_flechees = somme_total_recettes_flechees + credits_subvention_investissement_flechee;
            somme_total_recettes = somme_total_recettes + credits_subvention_sp + credits_subvention_investissement_globalisee + credits_subvention_investissement_flechee;

            const indicateur_poids_scsp = document.getElementById("indicateur_poids_scsp");
            this.indicateurRatio(document.getElementById("credits_subvention_sp"),indicateur_poids_scsp,credits_subvention_sp,somme_total_recettes,100);
        }
        const solde = somme_total_recettes - credits_cp_total;
        const solde_fleche = somme_total_recettes_flechees - credits_cp_recettes_flechees;
        indicateur_solde_budgetaire.innerHTML = solde.toLocaleString("fr-FR");
        indicateur_solde_budgetaire_fleche.innerHTML = solde_fleche.toLocaleString("fr-FR");
        indicateur_subv_etat.innerHTML = somme_total_subv_etat.toLocaleString("fr-FR");
        indicateur_total_recettes_propres.innerHTML = somme_total_recettes_propres.toLocaleString("fr-FR");
        indicateur_total_recettes_globalisees.innerHTML = somme_total_recettes_globalisees.toLocaleString("fr-FR");
        indicateur_total_recettes_flechees.innerHTML = somme_total_recettes_flechees.toLocaleString("fr-FR");
        indicateur_total_recettes.innerHTML = somme_total_recettes.toLocaleString("fr-FR");
        this.indicateurRatio(document.getElementById("credits_recettes_propres_globalisees"),indicateur_taux_recettes_propres,somme_total_recettes_propres,somme_total_recettes,100);
        this.indicateurRatio(document.getElementById("credits_recettes_propres_globalisees"),indicateur_poids_recettes_globalisees,somme_total_recettes_globalisees,somme_total_recettes,100);
        this.indicateurRatio(document.getElementById("credits_financements_etat_autres"),indicateur_poids_financements_etat,somme_total_subv_etat,somme_total_recettes,100);
    }

    changeIndicateurVariationRaP() {
        const indicateur_variation_rap = document.getElementById("indicateur_variation_rap");
        const credits_ae_total = this.numberFormat(document.getElementById("credits_ae_total").value) || 0;
        const credits_cp_total = this.numberFormat(document.getElementById("credits_cp_total").value) || 0;
        const variation = credits_ae_total - credits_cp_total;
        indicateur_variation_rap.innerHTML = variation.toLocaleString("fr-FR");
    }
    changeIndicateurPoidsRaP() {
        const indicateur_poids_rap = document.getElementById("indicateur_poids_rap");
        const credits_restes_a_payer_field = document.getElementById("credits_restes_a_payer")
        const credits_restes_a_payer = this.numberFormat(document.getElementById("credits_restes_a_payer").value) || 0;
        const credits_cp_total = this.numberFormat(document.getElementById("credits_cp_total").value) || 0;
        const credits_cp_personnel = this.numberFormat(document.getElementById("credits_cp_personnel").value) || 0;
        const total = credits_cp_total - credits_cp_personnel
        this.indicateurRatio(credits_restes_a_payer_field,indicateur_poids_rap,credits_restes_a_payer,total,100);
    }
    changeComptabilite(){
        this.validateForm();
    }
    changeTresorerie(){
        this.changeIndicateurTresoJours();
        this.changeIndicateurInit();
        if (document.getElementById("indicateur_treso_non_flechee") != null){
            this.changeIndicateurTresoNonFlechee();
        }
        this.changeIndicateurTresoRAP();
        this.changeIndicateurTresoExtremesJours();
        this.validateForm();
    }
    changeIndicateurTresoNonFlechee(){
        const indicateur_treso_non_flechee = document.getElementById("indicateur_treso_non_flechee");
        const indicateur_treso_non_flechee_jours = document.getElementById("indicateur_treso_non_flechee_jours");
        const tresorerie_finale_text = document.getElementById("tresorerie_finale_text");
        const tresorerie_finale = document.getElementById("tresorerie_finale");
        const tresorerie_finale_non_flechee_field = document.getElementById("tresorerie_finale_non_flechee");
        const tresorerie_finale_non_flechee = this.numberFormat(tresorerie_finale_non_flechee_field.value) || 0;
        const tresorerie_finale_flechee = this.numberFormat(document.getElementById("tresorerie_finale_flechee").value) || 0;
        const total = tresorerie_finale_flechee + tresorerie_finale_non_flechee;
        tresorerie_finale.value = total;
        tresorerie_finale_text.innerHTML = total.toLocaleString("fr-FR");
        this.indicateurRatio(tresorerie_finale_non_flechee_field,indicateur_treso_non_flechee,tresorerie_finale_non_flechee,total,100);
        const den = this.calculateTresoDen();
        this.indicateurRatio(tresorerie_finale_non_flechee_field,indicateur_treso_non_flechee_jours,tresorerie_finale_non_flechee,den,1);
    }
    changeIndicateurInit(){
        const tresorerie_indicateur_initial = document.getElementById("tresorerie_indicateur_initial");
        const tresorerie_finale = this.numberFormat(document.getElementById("tresorerie_finale").value) || 0;
        const tresorerie_variation = this.numberFormat(document.getElementById("tresorerie_variation").value) || 0;
        const tresorie_initiale = tresorerie_finale - tresorerie_variation;
        tresorerie_indicateur_initial.innerHTML = tresorie_initiale.toLocaleString("fr-FR");
    }
    changeIndicateurTresoJours(){
        const indicateur_treso_jours = document.getElementById("indicateur_treso_jours");
        const tresorerie_finale_field = document.getElementById("tresorerie_finale");
        const tresorerie_finale = this.numberFormat(tresorerie_finale_field.value) || 0;
        const den = this.calculateTresoDen();
        this.indicateurRatio(tresorerie_finale_field,indicateur_treso_jours,tresorerie_finale,den,1);
    }
    changeIndicateurTresoRAP(){
        const indicateur_treso_rap = document.getElementById("indicateur_treso_rap");
        const tresorerie_finale_field = document.getElementById("tresorerie_finale")
        const tresorerie_finale = this.numberFormat(tresorerie_finale_field.value) || 0;
        const credits_restes_a_payer = this.numberFormat(document.getElementById("credits_restes_a_payer").value) || 0;
        this.indicateurRatio(tresorerie_finale_field,indicateur_treso_rap,tresorerie_finale,credits_restes_a_payer,100);
    }
    calculateTresoDen(){
        const credits_cp_total = this.numberFormat(document.getElementById("credits_cp_total").value) || 0;
        const credits_cp_investissement = this.numberFormat(document.getElementById("credits_cp_investissement").value) || 0;
        return (credits_cp_total - credits_cp_investissement)/360;
    }
    changeIndicateurTresoExtremesJours(){
        const indicateur_treso_max = document.getElementById("indicateur_treso_max");
        const indicateur_treso_min = document.getElementById("indicateur_treso_min");
        const tresorerie_max_field = document.getElementById("tresorerie_max")
        const tresorerie_max = this.numberFormat(tresorerie_max_field.value) || 0;
        const tresorerie_min_field = document.getElementById("tresorerie_min")
        const tresorerie_min = this.numberFormat(tresorerie_min_field.value) || 0;
        const den = this.calculateTresoDen(); // a modifier cas ocb
        this.indicateurRatio(tresorerie_max_field,indicateur_treso_max,tresorerie_max,den,1);
        this.indicateurRatio(tresorerie_min_field,indicateur_treso_min,tresorerie_min,den,1);
    }
    changeAnalyse(){
        this.changeIndicateurFR();
        this.validateForm();
    }
    changeIndicateurFR(){
        //Variation fonds de roulement
        const indicateur_variation_fr = document.getElementById("indicateur_variation_fr");
        const indicateur_besoin_fr = document.getElementById("indicateur_besoin_fr");
        const fonds_roulement_variation_field = document.getElementById("fonds_roulement_variation")
        const fonds_roulement_variation = this.numberFormat(fonds_roulement_variation_field.value) || 0;
        this.indicateurRatio(fonds_roulement_variation_field,indicateur_variation_fr,fonds_roulement_variation,1,1);
        //Variation du besoin en fonds de roulement
        const fonds_roulement_final_field =document.getElementById("fonds_roulement_final")
        const fonds_roulement_final = this.numberFormat(fonds_roulement_final_field.value) || 0;
        const tresorerie_finale = this.numberFormat(document.getElementById("tresorerie_finale").value) || 0;
        const variation_besoin_fr = fonds_roulement_final - tresorerie_finale;
        this.indicateurRatio(fonds_roulement_final_field,indicateur_besoin_fr,variation_besoin_fr,1,1);

        //risque insolvalibilite
        const tresorerie_variation = this.numberFormat(document.getElementById("tresorerie_variation").value) || 0;
        const solde_budgetaire = 10;
        this.calculRisque(solde_budgetaire, tresorerie_variation, fonds_roulement_variation, variation_besoin_fr)
    }
    updateRisque(value){
        const risque_insolvabilite = document.getElementById("risque_insolvabilite");
        const indicateur_examen = document.getElementById("indicateur_examen");
        risque_insolvabilite.value = value;
        indicateur_examen.innerHTML = value
    }
    calculRisque(solde_budgetaire, tresorerie_variation, fonds_roulement_variation, variation_besoin_fr){
        const commentaire = document.getElementById("commentaire");
        if (solde_budgetaire > 0 && tresorerie_variation > 0 && fonds_roulement_variation > 0){
            this.updateRisque("Situation saine")
            commentaire.innerHTML = "la soutenabilité est atteinte à court et moyen termes, que la variation du besoin en fonds de roulement soit positive ou négative."
        }else if (solde_budgetaire > 0 && tresorerie_variation < 0 && fonds_roulement_variation > 0 && variation_besoin_fr > 0 ){
            this.updateRisque("Situation saine")
            commentaire.innerHTML = "la soutenabilité est atteinte à court et moyen termes, dès lors que la variation du besoin en fonds de roulement est positive. \n" +
                "Il convient de vérifier si des décaissements liés à des opérations de trésorerie non budgétaires peuvent expliquer cette situation (opérations au nom et pour le compte de tiers par exemple)."
        }
        else if (solde_budgetaire > 0 && tresorerie_variation > 0 && fonds_roulement_variation < 0 && variation_besoin_fr < 0 ){
            this.updateRisque("Situation saine a priori mais à surveiller");
            commentaire.innerHTML = "la situation est viable à court terme notamment si le besoin en fonds est structurellement négatif.\n" +
                "Il conviendra de vérifier si la variation à la baisse du fonds de roulement est ponctuelle ou répétée.";
        }
        else if (solde_budgetaire > 0 && tresorerie_variation < 0 && fonds_roulement_variation < 0 && variation_besoin_fr < 0 ){
            this.updateRisque("Situation saine a priori mais à surveiller");
            commentaire.innerHTML = "la situation est viable si la variation du besoin en fonds de roulement est négative, en particulier si le niveau de besoin en fonds de roulement est structurellement négatif.\n" +
                "Il convient de vérifier si des décaissements liés à des opérations non budgétaires peuvent expliquer cette situation. ";
        }
        else if (solde_budgetaire < 0 && tresorerie_variation > 0 && fonds_roulement_variation > 0 && variation_besoin_fr > 0 ){
            this.updateRisque("Situation saine a priori mais à surveiller");
            commentaire.innerHTML = "a situation est viable si la variation du besoin en fonds de roulement est positive. \n" +
                "Des décalages de flux d’encaissement peuvent expliquer que ponctuellement le solde budgétaire soit négatif. Il convient de vérifier si cela est dû à des opérations pluriannuelles.";
        }
        else if (solde_budgetaire < 0 && tresorerie_variation < 0 && fonds_roulement_variation > 0 && variation_besoin_fr > 0 ){
            this.updateRisque("Situation saine a priori mais à surveiller");
            commentaire.innerHTML = "la situation est viable si la variation du besoin en fonds de roulement est positive. \n" +
                "Des décalages de flux d’encaissement peuvent expliquer que ponctuellement le solde budgétaire est négatif. Si le niveau du besoin est structurellement élevé, l’organisme doit disposer d’un niveau de trésorerie important.";
        }
        else if (solde_budgetaire > 0 && tresorerie_variation < 0 && fonds_roulement_variation < 0 && variation_besoin_fr > 0 ){
            this.updateRisque("Risque d’insoutenabilité à moyen terme");
            commentaire.innerHTML = "un risque d’insoutenabilité existe à moyen terme si la variation du besoin en fonds de roulement est positive. En effet, il existe un risque que le fonds de roulement ne se redresse pas pour couvrir le besoin en fonds de roulement. \n" +
                "Dans ce cas, il convient de vérifier si le solde budgétaire positif est dû à des opérations non budgétaires qui généreraient des décalage de flux de trésorerie important (exemple : remboursements d’emprunts). ";
        }
        else if (solde_budgetaire < 0 && tresorerie_variation > 0 && fonds_roulement_variation > 0 && variation_besoin_fr < 0 ){
            this.updateRisque("Risque d’insoutenabilité à moyen terme");
            commentaire.innerHTML = "il y a un risque d’insoutenabilité à moyen terme si la variation du besoin en fonds de roulement est négative. \n" +
                "Une variation du besoin en fonds de roulement devrait, a priori, permettre de dégager un solde budgétaire positif. Il convient donc de vérifier si le solde budgétaire négatif est dû à des opérations pluriannuelles (fléchées ou non) qui généreraient des décalages de flux de trésorerie importants. ";
        }
        else if (solde_budgetaire < 0 && tresorerie_variation > 0 && fonds_roulement_variation < 0 && variation_besoin_fr < 0 ){
            this.updateRisque("Risque d’insoutenabilité élevé");
            commentaire.innerHTML = "Il peut arriver que des opérations pluriannuelles génèrent des impacts négatifs sur le solde budgétaire sur un ou plusieurs exercices. Il convient d'évaluer si cette situation est temporaire ou non et si la trésorerie s'était accrue au cours des exercices antérieurs ou si des encaissements sont prévus sur des exercices ultérieurs. Il convient de vérifier si des opérations de trésorerie non budgétaires peuvent expliquer la variation de trésorerie.";
        }
        else if (solde_budgetaire < 0 && tresorerie_variation < 0 && fonds_roulement_variation < 0 && variation_besoin_fr > 0 ){
            this.updateRisque("Risque d’insoutenabilité élevé");
            commentaire.innerHTML = "le risque d'insoutenabilité est élevé car le fonds de roulement ne finance pas le besoin en fonds de roulement et seule la trésorerie est mise à contribution.\n" +
                "Il peut arriver que des opérations pluriannuelles génèrent des impacts négatifs sur le solde budgétaire sur un ou plusieurs exercices. Il convient d'évaluer si cette situation est temporaire ou non et si la trésorerie s'était accrue au cours des exercices antérieurs ou si des encaissements sont prévus sur des exercices ultérieurs.";
        }
        else if (solde_budgetaire < 0 && tresorerie_variation < 0 && fonds_roulement_variation < 0 && variation_besoin_fr < 0 ){
            this.updateRisque("Risque d’insoutenabilité élevé");
            commentaire.innerHTML = "le risque d'insoutenabilité est élevé car malgré la capacité d'encaisser avant de décaisser, le solde budgétaire est négatif. Il peut arriver que des opérations pluriannuelles génèrent des impacts négatifs sur le solde budgétaire sur un ou plusieurs exercices. Il convient d'évaluer si cette situation est temporaire ou non et si la trésorerie s'était accrue au cours des exercices antérieurs ou si des encaissements sont prévus sur des exercices ultérieurs. ll convient de vérifier si des opérations de trésorerie non budgétaires peuvent expliquer la variation de trésorerie.";
        }
    }

    changePhase(){
        const phase =  document.getElementById("phase").value;
        const error_message = document.getElementById("phase_error");
        if (phase == "Budget non approuvé"){
            this.showField(error_message);
        }else{
            this.hideField(error_message);
        }
        this.validateForm();
    }

    indicateurRatio(field, indicateur_text, value1,value2,value3){
        if (field.value != null && field.value != "" && value2 != 0){
            const ratio = Math.round((value1/value2)*value3);
            indicateur_text.innerHTML = ratio.toLocaleString("fr-FR");
        }else{
            indicateur_text.innerHTML = "-"
        }
    }
    afficherInfos(e){
        e.preventDefault();
        const blocs = document.querySelectorAll(".options");
        blocs.forEach(element => {
            element.classList.remove("fr-hidden");
        })
        const section = document.getElementById("chiffres");
        this.scrollToSection(section);
    }
    changeTextToFloat(event){
        event.preventDefault();
        const fields = document.querySelectorAll("input[type='text']");
        fields.forEach(field => {
            const parsedValue = this.numberFormat(field.value);
            if (!isNaN(parsedValue)) {
                field.value = parsedValue;
                console.log(field.value)
            }
        })
        this.formTarget.submit();
    }
    scrollToTop() {
        window.scrollTo({
            top: 0,
            behavior: "smooth" // Pour un défilement fluide
        });
    }
    scrollToSection(section) {
        if (section) {
            section.scrollIntoView({
                behavior: "smooth",
                block: "start"
            });
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