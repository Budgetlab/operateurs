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
        return ['canvasBI','canvasCF', 'canvasTreso', 'canvasMS','canvasEmplois', 'canvasCharges', 'canvasEmploisBis', 'canvasDepenses'
        ];
    }
    connect() {
        this.showViz();
    }

    showViz(){
        const budgetsbi = JSON.parse(this.data.get("budgetsbi"));
        const budgetscf = JSON.parse(this.data.get("budgetscf"));
        const abscisses = JSON.parse(this.data.get("abscisses"));
        const grouped_datas = JSON.parse(this.data.get("groupeddatas"));
        if (budgetsbi != null && budgetsbi.length > 0) {
            const options = this.syntheseBudget(budgetsbi, "Répartition des budgets initiaux 2024");
            this.chart = Highcharts.chart(this.canvasBITarget, options);
            this.chart.reflow();
        }
        if (budgetscf != null && budgetscf.length > 0) {
            const options2 = this.syntheseBudget(budgetscf, "Répartition des comptes financiers 2023");
            this.chart = Highcharts.chart(this.canvasCFTarget, options2);
            this.chart.reflow();
        }
        if (grouped_datas != null ) {
            const colors_treso = ["var(--green-menthe-850-200)","var(--purple-glycine-main-494)","var(--green-menthe-main-548)", "var(--purple-glycine-sun-319-moon-630)","var(--background-disabled-grey)"];
            const colors_ms = ["var(--green-menthe-950-100)","var(--green-menthe-850-200)"];
            const colors_emplois = ["var(--purple-glycine-925-125)", "var(--purple-glycine-main-494)"];
            const colors_charges = ["var(--blue-cumulus-925-125)","var(--blue-ecume-sun-247-moon-675)","var(--orange-terre-battue-925-125-active","var(--blue-cumulus-925-125)","var(--blue-ecume-sun-247-moon-675)","var(--orange-terre-battue-925-125-active" ];
            const colors_depenses = ["var(--blue-cumulus-925-125)","var(--blue-ecume-sun-247-moon-675)","var(--orange-terre-battue-925-125-active","var(--green-emeraude-sun-425-moon-753-active)" ];

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

            let dataCPBI = [data_bi.dataCPBI_personnel,data_bi.dataCPBI_fonctionnement, data_bi.dataCPBI_intervention, data_bi.dataCPBI_investissement]
            let dataCPCF = [data_cf.dataCPCF_personnel,data_cf.dataCPCF_fonctionnement, data_cf.dataCPCF_intervention, data_cf.dataCPCF_investissement]

            // const options_treso = this.syntheseBarSimple("Évolution de la trésorerie finale", abscisses, "Trésorerie finale (€)",'Trésorerie finale BI', dataTresoBI, " €", "Trésorerie en jours de fonctionnement (Jours)", "Trésorerie finale CF", dataTresoCF, " Jours", colors_treso, "Trésorerie en jours de fonctionnement BI", dataTresojoursBI, "Trésorerie en jours de fonctionnement CF", dataTresojoursCF );
            const options_treso = this.syntheseBarSimple("Évolution de la trésorerie finale", abscisses, "Trésorerie finale (€)",'Trésorerie finale BI', data_bi.dataTresoBI, " €",  "Trésorerie finale CF", data_cf.dataTresoCF,  colors_treso);
            this.chart = Highcharts.chart(this.canvasTresoTarget, options_treso);
            this.chart.reflow();

            // const options_emplois = this.syntheseBar("Évolution de la masse salariale et des autorisations d'emplois", abscisses, "Masse salariale (€)",'Masse salariale', dataCP," €", "Autorisations d'emplois (ETPT)", "Autorisations d'emplois", dataETPT, " ETPT", colors_emplois );
            const options_ms = this.syntheseBarSimple("Évolution de la masse salariale", abscisses, "Masse salariale (€)",'Masse salariale BI', data_bi.dataCPBI_personnel," €", "Masse salariale CF", data_cf.dataCPCF_personnel, colors_ms);
            this.chart = Highcharts.chart(this.canvasMSTarget, options_ms);
            this.chart.reflow();

            const options_emplois = this.syntheseBarSimple("Évolution des autorisations d'emplois", abscisses, "Masse salariale (€)","Autorisations d'emplois BI", data_bi.dataETPTBI," ETPT", "Autorisations d'emplois CF", data_cf.dataETPTCF, colors_emplois);
            this.chart = Highcharts.chart(this.canvasEmploisTarget, options_emplois);
            this.chart.reflow();

            let serie_name1_charges = ["Charges de personnel BI", "Charges de fonctionnement BI", "Charges d'intervention BI"];
            let serie_name2_charges = ["Charges de personnel CF", "Charges de fonctionnement CF", "Charges d'intervention CF"];
            const options_charges = this.syntheseBarStacked("Évolution des charges", abscisses, "Montant (€)",' €', serie_name1_charges, dataChargesBI,serie_name2_charges, dataChargesCF, colors_charges );
            this.chart = Highcharts.chart(this.canvasChargesTarget, options_charges);
            this.chart.reflow();

            const abscisses_bis = JSON.parse(this.data.get("abscissesbis"));
            const emplois = JSON.parse(this.data.get("emplois"));
            const emploiscout = JSON.parse(this.data.get("emploiscout"));
            const options_emplois_bis = this.syntheseColSpline(emploiscout, "Évolution de la masse salariale et des emplois", abscisses_bis, "Masse salariale (€)",'Masse salariale', " €", "Emplois totaux (ETPT)", "Emplois totaux", emplois, "" );
            this.chart = Highcharts.chart(this.canvasEmploisBisTarget, options_emplois_bis);
            this.chart.reflow();

            if (this.data.get("cb") != "Non"){
                let serie_name1_depenses = ["Dépenses de personnel BI", "Dépenses de fonctionnement BI", "Dépenses d'intervention BI", "Dépenses d'investissement BI"];
                let serie_name2_depenses = ["Dépenses de personnel CF", "Dépenses de fonctionnement CF", "Dépenses d'intervention CF", "Dépenses d'investissement CF"];
                const options_depenses = this.syntheseBarStacked("Évolution des dépenses", abscisses, "Montant (€)",' €',serie_name1_depenses, dataCPBI,serie_name2_depenses,dataCPCF, colors_depenses );
                this.chart = Highcharts.chart(this.canvasDepensesTarget, options_depenses);
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
                        let formattedNumber = (value >= 1000000) ? (value / 1000000).toFixed(1) + 'M' : (value >= 1000) ? (value / 1000).toFixed(1) + 'K' : value;
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
                        let formattedNumber = (value >= 1000000) ? (value / 1000000).toFixed(1) + 'M' : (value >= 1000) ? (value / 1000).toFixed(1) + 'K' : value;
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

    syntheseBarStacked(title, abscisses, title_y, value_tooltip, serie_name1, data1, serie_name2, data2, colors){
        let series = [];

        data1.forEach((data, i) => {

            let serie = { name: serie_name1[i],
                tooltip: {
                valueSuffix: value_tooltip
                },
                stack: "BI",
                data: data,
            };
            series.push(serie);
        });
        data2.forEach((data, i) => {
            let serie = { name: serie_name2[i],
                tooltip: {
                    valueSuffix: value_tooltip
                },
                stack: "CF",
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
                            let formattedNumber = (value >= 1000000) ? (value / 1000000).toFixed(1) + 'M' : (value >= 1000) ? (value / 1000).toFixed(1) + 'K' : value;
                            return `${formattedNumber}`;
                        }
                    }
                }],
            plotOptions: {
                column: {
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

    syntheseColSpline(data, title, abscisses, title_y, serie_name,value_tooltip1, title_y2, serie_name2, data2, value_tooltip2){
        const colors = ["var(--green-menthe-850-200)","var(--purple-glycine-main-494)","var(--pink-tuile-925-125-active)", "var(--pink-tuile-main-556)","var(--background-disabled-grey)"]
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
            }],
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
                yAxis: 1,
                tooltip: {
                    valueSuffix: value_tooltip1
                },
                dataLabels: {
                    enabled: true,           // Active les dataLabels
                    crop: false,
                    overflow: 'none',
                    formatter: function() {
                        let value = this.y;
                        let formattedNumber = (value >= 1000000) ? (value / 1000000).toFixed(1) + 'M' : (value >= 1000) ? (value / 1000).toFixed(1) + 'K' : value;
                        return `${formattedNumber}`;
                    }
                }
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



}
