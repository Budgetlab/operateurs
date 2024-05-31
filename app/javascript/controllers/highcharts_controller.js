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
        const treso = JSON.parse(this.data.get("treso"));
        const fr_final = JSON.parse(this.data.get("frfinal"));
        const emplois = JSON.parse(this.data.get("emplois"));
        const emploiscout = JSON.parse(this.data.get("emploiscout"));
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
        if (treso != null && treso.length > 0) {
            const options_treso = this.syntheseBar("Évolution de la trésorerie finale et du fonds de roulement final", abscisses, "Trésorerie finale (€)",'Trésorerie finale', treso, " €", "Fonds de roulement final (€)", "Fonds de roulement final", fr_final, " €" );
            this.chart = Highcharts.chart(this.canvasTresoTarget, options_treso);
            this.chart.reflow();
        }
        if (emplois != null && emplois.length > 0) {
            const options_emplois = this.syntheseBar("Évolution de la masse salariale et des autorisations d'emplois", abscisses, "Masse salariale (€)",'Masse salariale', emploiscout," €", "Autorisations d'emplois (ETPT)", "Autorisations d'emplois", emplois, " ETPT" );
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

    syntheseBar(title, abscisses, title_y1, serie_name1,data1, value_tooltip1, title_y2, serie_name2, data2, value_tooltip2){
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

            },
            yAxis: [{
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
                opposite: false,
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
                opposite: true,
            }],
            plotOptions: {
                column: {
                    maxPointWidth: 50,
                    borderWidth: 0
                }
            },
            series: [{
                name: serie_name1,
                data: data1,
                type: 'column',
                yAxis: 0,
                tooltip: {
                    valueSuffix: value_tooltip1
                }
            },{
                name: serie_name2,
                data: data2,
                type: 'spline',
                yAxis: 1,
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
