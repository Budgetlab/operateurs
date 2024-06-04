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
        return ['canvasBI','canvasCF', 'canvasTreso', 'canvasEmplois'
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
            let dataTreso = [];
            let dataFR = [];
            let dataCP = [];
            let dataETPT = [];
            Object.keys(grouped_datas).forEach((exercice, i) => {
                const chiffres = grouped_datas[exercice];
                chiffres.forEach((chiffre, j) => {
                    let adjustment;
                    if (chiffres.length === 1) {
                        adjustment = 0;
                    } else if (chiffres.length === 2) {
                        adjustment = (j === 0 ? -0.12 : 0.12);
                    } else {
                        adjustment = 0.22 * (j - Math.floor(chiffres.length / 2));
                    }
                    let x_placement = chiffres.length === 1 ? i : i + (j === 0 ? -0.12 : 0.12);
                    const point = {
                        x: i + adjustment,  // Adjust point placement for scatter
                        y: chiffre[1],
                        name: chiffre[0]
                    };
                    const point2 = {
                        x: i + adjustment,  // Adjust point placement for scatter
                        y: chiffre[2],
                        name: chiffre[0]
                    };
                    const point3 = {
                        x: i + adjustment, // Adjust point placement for scatter
                        y: chiffre[3],
                        name: chiffre[0]
                    };
                    const point4 = {
                        x: i + adjustment, // Adjust point placement for scatter
                        y: chiffre[4],
                        name: chiffre[0]
                    };
                    dataTreso.push(point);
                    dataFR.push(point2);
                    dataETPT.push(point3);
                    dataCP.push(point4)
                });
            });

            const colors_treso = ["var(--green-menthe-850-200)","var(--purple-glycine-main-494)","var(--pink-tuile-925-125-active)", "var(--pink-tuile-main-556)","var(--background-disabled-grey)"];
            const colors_emplois = ["var(--blue-ecume-850-200)","var(--pink-macaron-main-689)","var(--pink-tuile-925-125-active)", "var(--pink-tuile-main-556)","var(--background-disabled-grey)"];

            const options_treso = this.syntheseBar("Évolution de la trésorerie finale et du fonds de roulement final", abscisses, "Trésorerie finale (€)",'Trésorerie finale', dataTreso, " €", "Fonds de roulement final (€)", "Fonds de roulement final", dataFR, " €", colors_treso );
            this.chart = Highcharts.chart(this.canvasTresoTarget, options_treso);
            this.chart.reflow();

            const options_emplois = this.syntheseBar("Évolution de la masse salariale et des autorisations d'emplois", abscisses, "Masse salariale (€)",'Masse salariale', dataCP," €", "Autorisations d'emplois (ETPT)", "Autorisations d'emplois", dataETPT, " ETPT", colors_emplois );
            this.chart = Highcharts.chart(this.canvasEmploisTarget, options_emplois);
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

    syntheseBar(title, abscisses, title_y1, serie_name1,data1, value_tooltip1, title_y2, serie_name2, data2, value_tooltip2, colors){
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
                            color: colors[0],
                        },
                    },
                    labels: {
                        style: {
                            color: colors[0],
                        },
                    },
                    opposite: false,
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
                    grouping: false,
                    shadow: false,
                    borderWidth: 0,
                    maxPointWidth: 40,
                }
            },
            series: [{
                name: serie_name1,
                type: 'column',
                tooltip: {
                    valueSuffix: value_tooltip1
                },
                pointPadding: 0.2,
                data: data1,

            }, {
                name: serie_name2,
                type: 'spline',
                data: data2,
                pointPadding: 0.2,
                tooltip: {
                    valueSuffix: value_tooltip2
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


}
