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
        return ['canvasBI','canvasCF'
        ];
    }
    connect() {
        this.showViz();
    }

    showViz(){
        const budgetsbi = JSON.parse(this.data.get("budgetsbi"));
        const budgetscf = JSON.parse(this.data.get("budgetscf"));
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


}
