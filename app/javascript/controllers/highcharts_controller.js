import { Controller } from "@hotwired/stimulus"
import Highcharts from "highcharts"
import exporting from "exporting"
import data from "data"
import accessibility from "accessibility"
import nodata from "nodata"
exporting(Highcharts)
data(Highcharts)
accessibility(Highcharts)
nodata(Highcharts)

export default class extends Controller {
    static get targets() {
        return ['canvasBI','canvasCF', 'canvasTreso', 'canvasMS','canvasEmplois','canvasEmploisBis', 'canvasCharges', 'canvasProduits', 'canvasChargesProduits','canvasDepenses','canvasRecettes','canvasDepensesRecettes', 'canvasTresoBFR', 'canvasTresoRAP'
        ];
    }
    connect() {
        this.showViz();
        const data = JSON.parse(this.data.get("datavalue"))
        if (data && Object.keys(data).length > 0) {
            this.renderChart(data)
        }
    }

    showViz(){
        const budgetsbi = JSON.parse(this.data.get("budgetsbi"));
        const budgetscf = JSON.parse(this.data.get("budgetscf"));
        const abscisses = JSON.parse(this.data.get("abscisses"));
        const grouped_datas = JSON.parse(this.data.get("groupeddatas"));
        const series = JSON.parse(this.data.get("series"));

        if (budgetsbi != null && budgetsbi.length > 0) {
            const options = this.syntheseBudget(budgetsbi, "");
            this.chart = Highcharts.chart(this.canvasBITarget, options);
            this.chart.reflow();
        }
        if (budgetscf != null && budgetscf.length > 0) {
            const options2 = this.syntheseBudget(budgetscf, "");
            this.chart = Highcharts.chart(this.canvasCFTarget, options2);
            this.chart.reflow();
        }
        if (grouped_datas != null ) {

            const colors_ms = ["var(--green-menthe-950-100)","var(--green-menthe-850-200)"];
            const colors_emplois = ["var(--purple-glycine-925-125)", "var(--purple-glycine-main-494)"];
            let stack_type_budget = ["BI","CF"]

            let data_bi = {
                dataTresoBI: [],
                dataTresojoursBI: [],
                dataETPTBI: [],
                dataCPBI_personnel: [],
                dataChargesBI_personnel: [],
                dataChargesBI_fonctionnement: [],
                dataChargesBI_intervention: [],
                dataCPBI_fonctionnement: [],
                dataCPBI_intervention: [],
                dataCPBI_investissement: [],
                dataRecettesBI_non_flechees: [],
                dataRecettesBI_flechees: [],
                dataProduitsBI_etat: [],
                dataProduitsBI_fiscalite: [],
                dataProduitsBI_subvention: [],
                dataProduitsBI_autres: [],

            }
            let data_cf = {
                dataTresoCF: [],
                dataTresojoursCF: [],
                dataETPTCF: [],
                dataCPCF_personnel: [],
                dataChargesCF_personnel: [],
                dataChargesCF_fonctionnement: [],
                dataChargesCF_intervention: [],
                dataCPCF_fonctionnement: [],
                dataCPCF_intervention: [],
                dataCPCF_investissement: [],
                dataRecettesCF_non_flechees: [],
                dataRecettesCF_flechees: [],
                dataProduitsCF_etat: [],
                dataProduitsCF_fiscalite: [],
                dataProduitsCF_subvention: [],
                dataProduitsCF_autres: [],

            }
            abscisses.forEach((exercice) => {
                const chiffres = grouped_datas[exercice];
                let item;
                let item_cf;
                if (chiffres) {
                    item = chiffres.find(([budgetType]) => budgetType === "Budget initial");
                    item_cf = chiffres.find(([budgetType]) => budgetType === "Compte financier");
                }
                Object.keys(data_bi).forEach((key, index) => {
                    data_bi[key].push(item ? item[index + 1] : null);
                })
                Object.keys(data_cf).forEach((key, index) => {
                    data_cf[key].push(item_cf ? item_cf[index + 1] : null);
                });
            })
            let dataChargesBI = [data_bi.dataChargesBI_personnel,data_bi.dataChargesBI_fonctionnement, data_bi.dataChargesBI_intervention]
            let dataChargesCF = [data_cf.dataChargesCF_personnel,data_cf.dataChargesCF_fonctionnement, data_cf.dataChargesCF_intervention]

            let dataProduitsBI = [data_bi.dataProduitsBI_etat,data_bi.dataProduitsBI_fiscalite, data_bi.dataProduitsBI_subvention, data_bi.dataProduitsBI_autres]
            let dataProduitsCF = [data_cf.dataProduitsCF_etat,data_cf.dataProduitsCF_fiscalite, data_cf.dataProduitsCF_subvention, data_cf.dataProduitsCF_autres]

            let dataCPBI = [data_bi.dataCPBI_personnel,data_bi.dataCPBI_fonctionnement, data_bi.dataCPBI_intervention, data_bi.dataCPBI_investissement]
            let dataCPCF = [data_cf.dataCPCF_personnel,data_cf.dataCPCF_fonctionnement, data_cf.dataCPCF_intervention, data_cf.dataCPCF_investissement]

            let dataRecettesBI = [data_bi.dataRecettesBI_non_flechees,data_bi.dataRecettesBI_flechees]
            let dataRecettesCF = [data_cf.dataRecettesCF_non_flechees,data_cf.dataRecettesCF_flechees]

            const colors_treso = ["var(--blue-france-925-125)","var(--blue-france-850-200)"];
            const options_treso = this.syntheseBarSimple("Évolution de la trésorerie finale", abscisses, "Trésorerie finale (€)",'Trésorerie finale BI', data_bi.dataTresoBI, " €",  "Trésorerie finale CF", data_cf.dataTresoCF,  colors_treso);
            this.chart = Highcharts.chart(this.canvasTresoTarget, options_treso);
            this.chart.reflow();

            const options_ms = this.syntheseBarSimple("Évolution de la masse salariale", abscisses, "Masse salariale (€)",'Masse salariale BI', data_bi.dataCPBI_personnel," €", "Masse salariale CF", data_cf.dataCPCF_personnel, colors_ms);
            this.chart = Highcharts.chart(this.canvasMSTarget, options_ms);
            this.chart.reflow();

            const options_emplois = this.syntheseBarSimple("Évolution des emplois", abscisses, "Emplois (ETPT)","Emplois BI", data_bi.dataETPTBI," ETPT", "Emplois CF", data_cf.dataETPTCF, colors_emplois);
            this.chart = Highcharts.chart(this.canvasEmploisTarget, options_emplois);
            this.chart.reflow();

            if (this.data.get("cb") == "Non") {
                const colors_charges = ["var(--brown-caramel-850-200)","var(--green-archipel-850-200)","var(--beige-gris-galet-main-702) " ];
                let serie_name1_charges = ["Charges de personnel BI", "Charges de fonctionnement BI", "Charges d'intervention BI"];
                let serie_name2_charges = ["Charges de personnel CF", "Charges de fonctionnement CF", "Charges d'intervention CF"];
                const options_charges = this.syntheseBarStacked("Évolution des charges", abscisses, "Montant (€)",' €', serie_name1_charges, dataChargesBI,serie_name2_charges, dataChargesCF, colors_charges, stack_type_budget );
                this.chart = Highcharts.chart(this.canvasChargesTarget, options_charges);
                this.chart.reflow();

                const colors_produits = ["var(--beige-gris-galet-sun-407-moon-821-active)","var(--yellow-tournesol-950-100-hover)", "var(--beige-gris-galet-925-125)","var(--green-menthe-850-200)" ];
                let serie_name1_produits = ["Subventions de l’Etat BI", "Fiscalité affectée BI", "Autres subventions BI", "Autres produits BI"];
                let serie_name2_produits = ["Subventions de l’Etat CF", "Fiscalité affectée CF", "Autres subventions CF", "Autres produits CF"];
                const options_produits = this.syntheseBarStacked("Évolution des produits", abscisses, "Montant (€)",' €', serie_name1_produits, dataProduitsBI,serie_name2_produits, dataProduitsCF, colors_produits, stack_type_budget );
                this.chart = Highcharts.chart(this.canvasProduitsTarget, options_produits);
                this.chart.reflow();
            }else {
                const colors_depenses = ["var(--blue-cumulus-925-125)","var(--blue-ecume-sun-247-moon-675)","var(--orange-terre-battue-925-125-active","var(--green-emeraude-sun-425-moon-753-active)" ];
                let serie_name1_depenses = ["Dépenses de personnel BI", "Dépenses de fonctionnement BI", "Dépenses d'intervention BI", "Dépenses d'investissement BI"];
                let serie_name2_depenses = ["Dépenses de personnel CF", "Dépenses de fonctionnement CF", "Dépenses d'intervention CF", "Dépenses d'investissement CF"];
                const options_depenses = this.syntheseBarStacked("Évolution des dépenses", abscisses, "Montant (€)",' €',serie_name1_depenses, dataCPBI,serie_name2_depenses,dataCPCF, colors_depenses, stack_type_budget );
                this.chart = Highcharts.chart(this.canvasDepensesTarget, options_depenses);
                this.chart.reflow();

                const colors_recettes = ["var(--yellow-tournesol-950-100-hover)", "var(--beige-gris-galet-925-125)"];
                let serie_name1_recettes = ["Recettes globalisées BI", "Recettes fléchées BI"];
                let serie_name2_recettes = ["Recettes globalisées CF", "Recettes fléchées CF"];
                const options_recettes = this.syntheseBarStacked("Évolution des recettes", abscisses, "Montant (€)",' €',serie_name1_recettes, dataRecettesBI,serie_name2_recettes,dataRecettesCF, colors_recettes, stack_type_budget );
                this.chart = Highcharts.chart(this.canvasRecettesTarget, options_recettes);
                this.chart.reflow();
            }
        }
        if( series != null){
            const abscisses_series = JSON.parse(this.data.get("abscissesbis"));

            const colors_emplois_cout = ["var(--green-menthe-850-200)","var(--purple-glycine-main-494)","var(--pink-tuile-925-125-active)", "var(--pink-tuile-main-556)","var(--background-disabled-grey)"]
            const emplois_total = Object.values(series).map(values => values[3]);
            const emplois_montant = Object.values(series).map(values => values[4]);
            const options_emplois_bis = this.syntheseColSpline("Comparaison de l'évolution de la masse salariale et des emplois", abscisses_series, "Masse salariale (€)",'Masse salariale', emplois_montant," €", "Emplois (ETPT)", "Emplois", emplois_total, " ETPT" ,colors_emplois_cout);
            this.chart = Highcharts.chart(this.canvasEmploisBisTarget, options_emplois_bis);
            this.chart.reflow();

            const colors_treso_bfr = ["var(--blue-ecume-850-200)", "var(--green-menthe-850-200)"]
            const treso = Object.values(series).map(values => values[1]);
            const bfr = Object.values(series).map(values => values[17]);
            const options_treso_bfr = this.syntheseColSpline( "Comparaison de la trésorerie et du besoin en fonds de roulement", abscisses_series, "Montant (€)",'Trésorerie finale', treso, " €", "", "Besoin fonds de roulement", bfr, " €",colors_treso_bfr );
            this.chart = Highcharts.chart(this.canvasTresoBFRTarget, options_treso_bfr);
            this.chart.reflow();

            if (this.data.get("cb") == "Non") {
                const charges_personnel = Object.values(series).map(values => values[5]);
                const charges_fonctionnement = Object.values(series).map(values => values[6]);
                const charges_intervention = Object.values(series).map(values => values[7]);
                const data_charges = [charges_personnel, charges_fonctionnement, charges_intervention]
                const produits_etat = Object.values(series).map(values => values[13]);
                const produits_fiscalite = Object.values(series).map(values => values[14]);
                const produits_subvention = Object.values(series).map(values => values[15]);
                const produits_autres = Object.values(series).map(values => values[16]);
                const data_produits = [produits_etat, produits_fiscalite,produits_subvention, produits_autres];
                const colors_charges_produits = [ "var(--brown-caramel-850-200)","var(--green-archipel-850-200)","var(--beige-gris-galet-main-702) ","var(--beige-gris-galet-sun-407-moon-821-active)","var(--yellow-tournesol-950-100-hover)", "var(--beige-gris-galet-925-125)","var(--green-menthe-850-200)" ];
                const serie_name1_produits = ["Subventions de l’Etat", "Fiscalité affectée", "Autres subventions", "Autres produits"];
                const serie_name2_charges = ["Charges de personnel", "Charges de fonctionnement", "Charges d'intervention"];
                const stack_produits = ["Charges", "Produits"];
                const options_dr = this.syntheseBarStacked("Comparaison de l’évolution des charges et des produits", abscisses_series, "Montant (€)",' €',serie_name2_charges,data_charges,serie_name1_produits, data_produits, colors_charges_produits, stack_produits );
                this.chart = Highcharts.chart(this.canvasChargesProduitsTarget, options_dr);
                this.chart.reflow();
            }else{
                const colors_treso_rap = ["var(--yellow-tournesol-850-200)", "var(--blue-france-850-200)", "var(--pink-tuile-main-556)"]
                const treso_flechee = Object.values(series).map(values => values[19]);
                const treso_non_flechee = Object.values(series).map(values => values[20]);
                const rap = Object.values(series).map(values => values[18]);
                const stack_treso = ["Trésorerie"]
                const options_treso_bfr = this.syntheseStackSpline( "Comparaison de la trésorerie et des RAP ", abscisses_series, "Montant (€)",'Trésorerie fléchée', treso_flechee, "Trésorerie non fléchée", treso_non_flechee," €", "Restes à payer", rap, " €",colors_treso_rap, stack_treso );
                this.chart = Highcharts.chart(this.canvasTresoRAPTarget, options_treso_bfr);
                this.chart.reflow();

                const recettes_flechees = Object.values(series).map(values => values[12]);
                const recettes_globalisees = Object.values(series).map(values => values[11]);
                const data_recettes = [recettes_globalisees, recettes_flechees]
                const d_personnel = Object.values(series).map(values => values[4]);
                const d_fonctionnel = Object.values(series).map(values => values[8]);
                const d_intervention = Object.values(series).map(values => values[9]);
                const d_investissement = Object.values(series).map(values => values[10]);
                const data_depenses = [d_personnel, d_fonctionnel,d_intervention, d_investissement];
                const colors_depenses = ["var(--blue-cumulus-925-125)","var(--blue-ecume-sun-247-moon-675)","var(--orange-terre-battue-925-125-active","var(--green-emeraude-sun-425-moon-753-active)", "var(--yellow-tournesol-950-100-hover)", "var(--beige-gris-galet-925-125)" ];
                const serie_name1_recettes = ["Recettes fléchées", "Recette globalisées"];
                const serie_name2_depenses = ["Dépenses de personnel", "Dépenses de fonctionnement", "Dépenses d'intervention", "Dépenses d'investissement"];
                const stack_depenses = ["Dépenses", "Recettes"];
                const options_dr = this.syntheseBarStacked("Comparaison de l’évolution des dépenses et des recettes", abscisses_series, "Montant (€)",' €',serie_name2_depenses,data_depenses,serie_name1_recettes, data_recettes, colors_depenses, stack_depenses );
                this.chart = Highcharts.chart(this.canvasDepensesRecettesTarget, options_dr);
                this.chart.reflow();
            }
        }
    }
    syntheseBudget(data, title){
        const colors = ["var(--green-emeraude-850-200)","var(--green-tilleul-verveine-925-125)","var(--pink-tuile-925-125-active)", "var(--pink-tuile-main-556)","var(--background-disabled-grey)"]
        const options = {
            chart: {
                height:'100%',
                style:{
                    fontFamily: "Marianne",
                },
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: false,
                type: 'pie',

            },
            exporting:{enabled: false},
            colors: Highcharts.map(colors, function (color) {
                return {
                    radialGradient: {
                        cx: 0.5,
                        cy: 0.3,
                        r: 0.7
                    },
                    stops: [
                        [0, color],
                        [1, Highcharts.color(color).brighten(-0.3).get('rgb')] // darken
                    ]
                };
            }),

            title: {
                text: title,

                style: {
                    fontSize: '13px',
                    fontWeight: "900",
                    color: 'var(--text-title-grey)',
                },
            },
            legend:{
                itemStyle: {
                    color: 'var(--text-title-grey)',
                },
            },
            tooltip: {
                borderColor: 'transparent',
                borderRadius: 16,
                backgroundColor: "rgba(245, 245, 245, 1)",
                formatter: function () {
                    return '<b>' + this.point.name +': </b>' + this.point.y + ' (' + Math.round(this.percentage*10)/10 + '% )'
                }
                //pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
            },
            accessibility: {
                point: {
                    valueSuffix: '%'
                }
            },
            plotOptions: {
                pie: {
                    size: '100%',
                    innerSize: '80%',
                    allowPointSelect: true,
                    cursor: 'pointer',
                    dataLabels: {
                        enabled: false
                    },
                    showInLegend: true,
                }
            },
            series: [{
                name: 'Catégorie',
                data: [
                    { name: 'Situation saine', y: data[0] },
                    { name: 'Situation saine a priori mais à surveiller', y: data[1] },
                    { name: 'Risque d’insoutenabilité à moyen terme', y: data[2] },
                    { name: 'Risque d’insoutenabilité élevé', y: data[3] },
                    { name: 'Budgets non renseignés', y: data[4] }
                ]
            }]
        }
        return options
    }

    syntheseBarSimple(title, abscisses, title_y, serie_name1, data1, value_tooltip, serie_name2, data2, colors){
        const options = {
            chart: {
                height: 400,
                style:{
                    fontFamily: "Marianne",
                },
                type: 'column',
            },
            exporting:{enabled: true},
            colors: colors,
            title: {
                text: '',

                style: {
                    fontSize: '13px',
                    fontWeight: "900",
                    color: 'var(--text-title-grey)',
                },
            },
            legend:{
                itemStyle: {
                    color: 'var(--text-title-grey)',
                },
            },
            tooltip: {
                borderColor: 'transparent',
                borderRadius: 16,
                backgroundColor: "rgba(245, 245, 245, 1)",
            },
            xAxis: {
                categories: abscisses,
                labels: {
                    style: {
                        color: 'var(--text-title-grey)',
                    },
                },
            },
            yAxis: [
                {
                    title: {
                        text: title_y,
                        style: {
                            color: 'var(--text-title-grey)',
                        },
                    },
                    labels: {
                        style: {
                            color: 'var(--text-title-grey)',
                        },
                    },
                    opposite: false,
                }],
            plotOptions: {
                column: {
                }
            },
            series: [{
                name: serie_name1,
                type: 'column',
                tooltip: {
                    valueSuffix: value_tooltip
                },
                data: data1,
                dataLabels: {
                    enabled: true,           // Active les dataLabels
                    crop: false,
                    overflow: 'none',
                    formatter: function() {
                        let value = this.y;
                        let formattedNumber = (value >= 1000000) ? (value / 1000000).toFixed(1) + 'M' : (value >= 1000) ? (value / 1000).toFixed(1) + 'K' : value.toFixed(0);
                        return `BI : ${formattedNumber}`;
                    }
                }

            }, {
                name: serie_name2,
                type: 'column',
                tooltip: {
                    valueSuffix: value_tooltip
                },
                data: data2,
                dataLabels: {
                    enabled: true,           // Active les dataLabels
                    crop: false,
                    overflow: 'none',
                    formatter: function() {
                        let value = this.y;
                        let formattedNumber = (value >= 1000000) ? (value / 1000000).toFixed(1) + 'M' : (value >= 1000) ? (value / 1000).toFixed(1) + 'K' : value.toFixed(0);
                        return `CF : ${formattedNumber}`;
                    }
                }
            }]
            ,
            responsive: {
                rules: [{
                    condition: {
                        maxWidth: 500
                    },
                    chartOptions: {
                        legend: {
                            floating: false,
                            layout: 'horizontal',
                            align: 'center',
                            verticalAlign: 'bottom',
                            x: 0,
                            y: 0
                        },
                    }
                }],
            }
        }
        return options
    }

    syntheseBarStacked(title, abscisses, title_y, value_tooltip, serie_name1, data1, serie_name2, data2, colors, stack){
        let series = [];

        data1.forEach((data, i) => {
            let serie = { name: serie_name1[i],
                tooltip: {
                valueSuffix: value_tooltip
                },
                stack: stack[0],
                data: data,
            };
            series.push(serie);
        });
        data2.forEach((data, i) => {
            let serie = { name: serie_name2[i],
                tooltip: {
                    valueSuffix: value_tooltip
                },
                stack: stack[1],
                data: data};
            series.push(serie);
        });

        const options = {
            chart: {
                height: 400,
                style:{
                    fontFamily: "Marianne",
                },
                type: 'column',
            },
            exporting:{enabled: true},
            colors: colors,
            title: {
                text: '',

                style: {
                    fontSize: '13px',
                    fontWeight: "900",
                    color: 'var(--text-title-grey)',
                },
            },
            legend:{
                itemStyle: {
                    color: 'var(--text-title-grey)',
                },
            },
            tooltip: {
                borderColor: 'transparent',
                borderRadius: 16,
                backgroundColor: "rgba(245, 245, 245, 1)",
            },
            xAxis: {
                categories: abscisses,
                labels: {
                    style: {
                        color: 'var(--text-title-grey)',
                    },
                },
            },
            yAxis: [
                {
                    title: {
                        text: title_y,
                        style: {
                            color: 'var(--text-title-grey)',
                        },
                    },
                    labels: {
                        style: {
                            color: 'var(--text-title-grey)',
                        },
                    },
                    stackLabels: {
                        enabled: true,
                        crop: false,
                        overflow: 'none',
                        formatter: function() {
                            let value = this.total;
                            let stackName = this.stack;
                            let formattedNumber = (value >= 1000000) ? (value / 1000000).toFixed(1) + 'M' : (value >= 1000) ? (value / 1000).toFixed(1) + 'K' : value.toFixed(0);
                            return `${stackName} : ${formattedNumber}`;
                        }
                    }
                }],
            plotOptions: {
                column: {
                    maxPointWidth: 50,
                    stacking: 'normal',
                }
            },
            series: series
            ,
            responsive: {
                rules: [{
                    condition: {
                        maxWidth: 500
                    },
                    chartOptions: {
                        legend: {
                            floating: false,
                            layout: 'horizontal',
                            align: 'center',
                            verticalAlign: 'bottom',
                            x: 0,
                            y: 0
                        },
                    }
                }],
            }
        }
        return options
    }

    syntheseColSpline(title, abscisses, title_y, serie_name,data, value_tooltip1, title_y2, serie_name2, data2, value_tooltip2, colors){
        let y_Axis = []
        let y_Axis_value = 0
        if (title_y2 == ''){
            y_Axis = [{
                title: {
                    text: title_y,
                    style: {
                        color: 'var(--text-title-grey)',
                    },
                },
                labels: {
                    style: {
                        color: 'var(--text-title-grey)',
                    },
                },
            }]
        }else{
            y_Axis_value = 1;
            y_Axis = [{
                title: {
                    text: title_y,
                    style: {
                        color: colors[0],
                    },
                },
                labels: {
                    style: {
                        color: colors[0],
                    },
                },
            }, {
                title: {
                    text: title_y2,
                    style: {
                        color: colors[1],
                    },
                },
                labels: {
                    style: {
                        color: colors[1],
                    },
                },
                opposite: true,
            }]
        }
        const options = {
            chart: {
                height: 400,
                style:{
                    fontFamily: "Marianne",
                },
                type: 'column',
            },
            exporting:{enabled: true},
            colors: colors,

            title: {
                text: '',

                style: {
                    fontSize: '13px',
                    fontWeight: "900",
                    color: 'var(--text-title-grey)',
                },
            },
            legend:{
                itemStyle: {
                    color: 'var(--text-title-grey)',
                },
            },
            tooltip: {
                borderColor: 'transparent',
                borderRadius: 16,
                backgroundColor: "rgba(245, 245, 245, 1)",
            },
            xAxis: {
                categories: abscisses,

            },
            yAxis: y_Axis,
            plotOptions: {
                column: {
                    maxPointWidth: 50,
                    borderWidth: 0
                }
            },
            series: [{
                name: serie_name,
                data: data,
                type: 'column',
                tooltip: {
                    valueSuffix: value_tooltip1
                },
                dataLabels: {
                    enabled: true,           // Active les dataLabels
                    crop: false,
                    overflow: 'none',
                    formatter: function() {
                        let value = this.y;
                        let formattedNumber = (value >= 1000000) ? (value / 1000000).toFixed(1) + 'M' : (value >= 1000) ? (value / 1000).toFixed(1) + 'K' : value.toFixed(0);
                        return `${formattedNumber}`;
                    }
                }
            },{
                name: serie_name2,
                data: data2,
                type: 'spline',
                yAxis: y_Axis_value,
                tooltip: {
                    valueSuffix: value_tooltip2
                }
            }],
            responsive: {
                rules: [{
                    condition: {
                        maxWidth: 500
                    },
                    chartOptions: {
                        legend: {
                            floating: false,
                            layout: 'horizontal',
                            align: 'center',
                            verticalAlign: 'bottom',
                            x: 0,
                            y: 0
                        },
                    }
                }],
            }
        }
        return options
    }

    syntheseStackSpline(title, abscisses, title_y, serie_name,data,serie_name_bis, data_bis, value_tooltip1, serie_name2, data2, value_tooltip2, colors, stack){

        const options = {
            chart: {
                height: 400,
                style:{
                    fontFamily: "Marianne",
                },
                type: 'column',
            },
            exporting:{enabled: true},
            colors: colors,

            title: {
                text: '',

                style: {
                    fontSize: '13px',
                    fontWeight: "900",
                    color: 'var(--text-title-grey)',
                },
            },
            legend:{
                itemStyle: {
                    color: 'var(--text-title-grey)',
                },
            },
            tooltip: {
                borderColor: 'transparent',
                borderRadius: 16,
                backgroundColor: "rgba(245, 245, 245, 1)",
            },
            xAxis: {
                categories: abscisses,

            },
            yAxis: [{
                title: {
                    text: title_y,
                    style: {
                        color: 'var(--text-title-grey)',
                    },
                },
                labels: {
                    style: {
                        color: 'var(--text-title-grey)',
                    },
                },
                stackLabels: {
                    enabled: true,
                    crop: false,
                    overflow: 'none',
                    formatter: function() {
                        let value = this.total;
                        let stackName = this.stack;
                        let formattedNumber = (value >= 1000000) ? (value / 1000000).toFixed(1) + 'M' : (value >= 1000) ? (value / 1000).toFixed(1) + 'K' : value.toFixed(0);
                        return `${stackName} : ${formattedNumber}`;
                    }
                }
            }],
            plotOptions: {
                column: {
                    maxPointWidth: 50,
                    stacking: 'normal',
                }
            },
            series: [{
                name: serie_name,
                data: data,
                type: 'column',
                stack: stack[0],
                tooltip: {
                    valueSuffix: value_tooltip1
                },
            },{ name: serie_name_bis,
                tooltip: {
                    valueSuffix: value_tooltip1
                },
                type: 'column',
                stack: stack[0],
                data: data_bis,
            },{
                name: serie_name2,
                data: data2,
                type: 'spline',
                tooltip: {
                    valueSuffix: value_tooltip2
                }
            }],
            responsive: {
                rules: [{
                    condition: {
                        maxWidth: 500
                    },
                    chartOptions: {
                        legend: {
                            floating: false,
                            layout: 'horizontal',
                            align: 'center',
                            verticalAlign: 'bottom',
                            x: 0,
                            y: 0
                        },
                    }
                }],
            }
        }
        return options
    }

    renderChart() {
        const data = JSON.parse(this.data.get("datavalue"));

        Highcharts.chart(this.element, {
            chart: {
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: false,
                type: 'pie',
                height:200,
                width: 660,
                spacing: [0, 0, 0, 0], // Supprime tout l'espace autour
                marginLeft: 0
            },
            colors: ["var(--beige-gris-galet-925-125)", "var( --blue-ecume-850-200)", "var(--yellow-moutarde-850-200)", "var(--orange-terre-battue-925-125)", "var(--green-menthe-925-125)", "var(--purple-glycine-950-100)"],
            title: {
                text: null
            },
            tooltip: {
                pointFormat: '{series.name}: <b>{point.y} ({point.percentage:.1f}%)</b>'
            },
            plotOptions: {
                pie: {
                    allowPointSelect: true,
                    cursor: 'pointer',
                    dataLabels: {
                        enabled: false,
                        format: '<b>{point.name}</b>:<br>{point.y} ({point.percentage:.1f}%)',
                        style: {
                            fontSize: '11px'
                        }
                    },
                    showInLegend: true,
                    size: 200,      // Taille relative du pie dans son conteneur
                    center: ['30%', '50%'],
                }
            },
            legend: {
                enabled: true,
                layout: 'horizontal',
                align: 'right',
                verticalAlign: 'middle',
                width: 450,
                itemStyle: {
                    fontSize: '12px',
                    fontFamily: "Marianne",
                },
                x: -10, // Rapproche la légende de la pie
            },
            exporting: {
                enabled: false  // Désactive les options d'export
            },
            series: [{
                name: 'Réponses',
                colorByPoint: true,
                data: Object.entries(data).map(([name, value]) => ({
                    name,
                    y: value,
                }))
            }]
        })
    }
}
