import { Controller } from "@hotwired/stimulus"
import { jsPDF } from 'jspdf';
import html2canvas from 'html2canvas';

export default class extends Controller {
    static targets = ["button"]
    connect() {
        console.log('jj')
    }
    export(){
        this._toggleButtonState(true);
        // Attendre un court instant pour laisser le DOM se stabiliser
        setTimeout(() => {
            this._prepareForExport();
        }, 50);
    }
    _prepareForExport() {
        const printElements = document.querySelectorAll('.print');
        this._toggleVisibility(printElements, false);

        const element = document.getElementById('containPDF');
        element.classList.add('fr-container');

        this._captureAndExport(element, printElements);
    }

    _captureAndExport(element, printElements) {
        html2canvas(element).then((canvas) => {
            this.generatePDF(canvas);
            this._resetExportState(printElements, element);
        });
    }

    // Méthode privée pour désactiver le bouton et modifier le texte
    _toggleButtonState(disable) {
        this.buttonTarget.disabled = disable;
        this.buttonTarget.textContent = disable
            ? "Génération du PDF en cours (cela peut prendre quelques secondes)..."
            : "Exporter les résultats au format PDF";
    }

    // Méthode privée pour afficher ou cacher les éléments
    _toggleVisibility(elements, hidden) {
        elements.forEach(el => el.classList.toggle('fr-hidden', hidden));
    }
    // Méthode privée pour réinitialiser l'état après l'export
    _resetExportState(printElements, element) {
        this._toggleButtonState(false);
        this._toggleVisibility(printElements, true);
        element.classList.remove('fr-container');
    }
    generatePDF(canvas) {
        const imgData = canvas.toDataURL('image/png');
        // Crée un nouveau document PDF au format A4 en mode portrait ('p')
        const pdf = new jsPDF('p', 'mm', 'a4');
        const imgProps = pdf.getImageProperties(imgData);
        const pdfWidth = pdf.internal.pageSize.getWidth();
        const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;

        let heightLeft = pdfHeight;
        let position = 0;
        let pageHeight = pdf.internal.pageSize.getHeight();

        while (heightLeft >= 0) {
            pdf.addImage(imgData, 'PNG', 0, position, pdfWidth, pdfHeight);
            heightLeft -= pageHeight;
            if (heightLeft > 0) {
                pdf.addPage();
                position -= pageHeight;
            }
        }
        pdf.save('enquete.pdf');
    }


}