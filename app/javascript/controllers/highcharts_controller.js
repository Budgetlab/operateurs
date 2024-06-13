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
        return ['canvasBI','canvasCF', 'canvasTreso', 'canvasEmplois', 'canvasCharges'
        ];
    }
    connect() {
        this.showViz();
        this.transformValue()
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
            const colors_emplois = ["var(--blue-ecume-850-200)","var(--blue-ecume-main-400)", "var(--pink-macaron-main-689)","var(--pink-macaron-sun-406-moon-833)","var(--background-disabled-grey)"];
            const colors_charges = ["var(--blue-cumulus-925-125)","var(--blue-ecume-sun-247-moon-675)","var(--orange-terre-battue-925-125-active","var(--blue-cumulus-925-125)","var(--blue-ecume-sun-247-moon-675)","var(--orange-terre-battue-925-125-active" ];

            let data_bi = {
                dataTresoBI: [],
                dataTresojoursBI: [],
                dataETPTBI: [],
                dataCPBI: [],
                dataChargesBI_perso: [],
                dataChargesBI_fonctionnement: [],
                dataChargesBI_intervention: [],
            }
            let data_cf = {
                dataTresoCF: [],
                dataTresojoursCF: [],
                dataETPTCF: [],
                dataCPCF: [],
                dataChargesCF_perso: [],
                dataChargesCF_fonctionnement: [],
                dataChargesCF_intervention: [],
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
            let dataChargesBI = [data_bi.dataChargesBI_perso,data_bi.dataChargesBI_fonctionnement, data_bi.dataChargesBI_intervention]
            let dataChargesCF = [data_cf.dataChargesCF_perso,data_cf.dataChargesCF_fonctionnement, data_cf.dataChargesCF_intervention]

            // const options_treso = this.syntheseBarSimple("Évolution de la trésorerie finale", abscisses, "Trésorerie finale (€)",'Trésorerie finale BI', dataTresoBI, " €", "Trésorerie en jours de fonctionnement (Jours)", "Trésorerie finale CF", dataTresoCF, " Jours", colors_treso, "Trésorerie en jours de fonctionnement BI", dataTresojoursBI, "Trésorerie en jours de fonctionnement CF", dataTresojoursCF );
            const options_treso = this.syntheseBarSimple("Évolution de la trésorerie finale", abscisses, "Trésorerie finale (€)",'Trésorerie finale BI', data_bi.dataTresoBI, " €",  "Trésorerie finale CF", data_cf.dataTresoCF,  colors_treso);
            this.chart = Highcharts.chart(this.canvasTresoTarget, options_treso);
            this.chart.reflow();

            // const options_emplois = this.syntheseBar("Évolution de la masse salariale et des autorisations d'emplois", abscisses, "Masse salariale (€)",'Masse salariale', dataCP," €", "Autorisations d'emplois (ETPT)", "Autorisations d'emplois", dataETPT, " ETPT", colors_emplois );
            const options_emplois = this.syntheseBar1("Évolution de la masse salariale et des autorisations d'emplois", abscisses, "Masse salariale (€)",'Masse salariale BI', data_bi.dataCPBI," €", "Autorisations d'emplois (ETPT)", "Masse salariale CF", data_cf.dataCPCF, " ETPT", colors_emplois, "Autorisations d'emplois BI", data_bi.dataETPTBI,"Autorisations d'emplois CF",data_cf.dataETPTCF );
            this.chart = Highcharts.chart(this.canvasEmploisTarget, options_emplois);
            this.chart.reflow();

            const options_charges = this.syntheseBarStacked("Évolution des charges", abscisses, "Montant (€)",' €', dataChargesBI,dataChargesCF, colors_charges );
            this.chart = Highcharts.chart(this.canvasChargesTarget, options_charges);
            this.chart.reflow();
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

    syntheseBar1(title, abscisses, title_y1, serie_name1,data1, value_tooltip1, title_y2, serie_name2, data2, value_tooltip2, colors, serie_name3, data3, serie_name4, data4){
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
                        text: title_y1,
                        style: {
                            color: 'var(--text-title-grey)',
                        },
                    },
                    labels: {
                        style: {
                            color: 'var(--text-title-grey)',
                        },
                    },
                    top: '40%',
                    height: '60%',
                }, {
                    title: {
                        text: title_y2,
                        style: {
                            color: 'var(--text-title-grey)',
                        },
                    },
                    labels: {
                        style: {
                            color: 'var(--text-title-grey)',
                        },
                    },
                    opposite:true,
                    height: '40%',
                }],
            plotOptions: {
                column: {
                }
            },
            series: [{
                name: serie_name1,
                type: 'column',
                tooltip: {
                    valueSuffix: value_tooltip1
                },
                data: data1,
                dataLabels: {
                    enabled: true,           // Active les dataLabels
                    format: 'BI',            // Met le format des labels à 'BI'
                    inside: false,
                    align: 'center',
                    verticalAlign: 'bottom',
                    crop: false,
                    overflow: 'none',
                },

            }, {
                name: serie_name2,
                type: 'column',
                tooltip: {
                    valueSuffix: value_tooltip1
                },
                data: data2,
                dataLabels: {
                    enabled: true,           // Active les dataLabels
                    format: 'CF',            // Met le format des labels à 'BI'
                    inside: false,
                    align: 'center',
                    verticalAlign: 'bottom',
                    crop: false,
                    overflow: 'none',
                },

            },{
                name: serie_name3,
                type: 'column',
                data: data3,
                tooltip: {
                    valueSuffix: value_tooltip2
                },
                dataLabels: {
                    enabled: true,           // Active les dataLabels
                    format: 'BI',            // Met le format des labels à 'BI'
                    inside: false,
                    align: 'center',
                    verticalAlign: 'bottom',
                    crop: false,
                    overflow: 'none',
                },
                yAxis: 1 // Placer sur le deuxième axe Y
            },{
                name: serie_name4,
                type: 'column',
                data: data4,
                tooltip: {
                    valueSuffix: value_tooltip2
                },
                dataLabels: {
                    enabled: true,           // Active les dataLabels
                    format: 'CF',            // Met le format des labels à 'BI'
                    inside: false,
                    align: 'center',
                    verticalAlign: 'bottom',
                    crop: false,
                    overflow: 'none',
                },
                yAxis: 1 // Placer sur le deuxième axe Y
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

    syntheseBarStacked(title, abscisses, title_y, value_tooltip, data1, data2, colors){
        let serie_name1 = ["Charges de personnel BI", "Charges de fonctionnement BI", "Charges d'intervention BI"];
        let serie_name2 = ["Charges de personnel CF", "Charges de fonctionnement CF", "Charges d'intervention CF"];
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



}
