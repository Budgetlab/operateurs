var i="undefined"!==typeof globalThis?globalThis:"undefined"!==typeof self?self:global;var a={};(function(i){a?a=i:i(Highcharts)})((function(a){(function(a){var e=a.deg2rad,o=a.isNumber,s=a.pick,r=a.relativeLength;a.CenteredSeriesMixin={getCenter:function(){var a=(this||i).options,e=(this||i).chart,o=2*(a.slicedOffset||0),n=e.plotWidth-2*o,e=e.plotHeight-2*o,h=a.center,h=[s(h[0],"50%"),s(h[1],"50%"),a.size||"100%",a.innerSize||0],l=Math.min(n,e),p,c;for(p=0;4>p;++p)c=h[p],a=2>p||2===p&&/%$/.test(c),h[p]=r(c,[n,e,l,h[2]][p])+(a?o:0);h[3]>h[2]&&(h[3]=h[2]);return h},getStartAndEndRadians:function(i,a){i=o(i)?i:0;a=o(a)&&a>i&&360>a-i?a:i+360;return{start:e*(i+-90),end:e*(a+-90)}}}})(a);(function(a){function t(i,a){this.init(i,a)}var e=a.CenteredSeriesMixin,o=a.each,s=a.extend,r=a.merge,n=a.splat;s(t.prototype,{coll:"pane",init:function(a,e){(this||i).chart=e;(this||i).background=[];e.pane.push(this||i);this.setOptions(a)},setOptions:function(a){(this||i).options=r((this||i).defaultOptions,(this||i).chart.angular?{background:{}}:void 0,a)},render:function(){var a=(this||i).options,e=(this||i).options.background,o=(this||i).chart.renderer;(this||i).group||((this||i).group=o.g("pane-group").attr({zIndex:a.zIndex||0}).add());this.updateCenter();if(e)for(e=n(e),a=Math.max(e.length,(this||i).background.length||0),o=0;o<a;o++)e[o]&&(this||i).axis?this.renderBackground(r((this||i).defaultBackgroundOptions,e[o]),o):(this||i).background[o]&&((this||i).background[o]=(this||i).background[o].destroy(),(this||i).background.splice(o,1))},renderBackground:function(a,e){var o="animate";(this||i).background[e]||((this||i).background[e]=(this||i).chart.renderer.path().add((this||i).group),o="attr");(this||i).background[e][o]({d:(this||i).axis.getPlotBandPath(a.from,a.to,a)}).attr({fill:a.backgroundColor,stroke:a.borderColor,"stroke-width":a.borderWidth,class:"highcharts-pane "+(a.className||"")})},defaultOptions:{center:["50%","50%"],size:"85%",startAngle:0},defaultBackgroundOptions:{shape:"circle",borderWidth:1,borderColor:"#cccccc",backgroundColor:{linearGradient:{x1:0,y1:0,x2:0,y2:1},stops:[[0,"#ffffff"],[1,"#e6e6e6"]]},from:-Number.MAX_VALUE,innerRadius:0,to:Number.MAX_VALUE,outerRadius:"105%"},updateCenter:function(a){(this||i).center=(a||(this||i).axis||{}).center=e.getCenter.call(this||i)},update:function(a,e){r(!0,(this||i).options,a);this.setOptions((this||i).options);this.render();o((this||i).chart.axes,(function(a){a.pane===(this||i)&&(a.pane=null,a.update({},e))}),this||i)}});a.Pane=t})(a);(function(a){var e=a.each,o=a.extend,s=a.map,r=a.merge,n=a.noop,h=a.pick,l=a.pInt,p=a.wrap,c,d,u=a.Axis.prototype;a=a.Tick.prototype;c={getOffset:n,redraw:function(){(this||i).isDirty=!1},render:function(){(this||i).isDirty=!1},setScale:n,setCategories:n,setTitle:n};d={defaultRadialGaugeOptions:{labels:{align:"center",x:0,y:null},minorGridLineWidth:0,minorTickInterval:"auto",minorTickLength:10,minorTickPosition:"inside",minorTickWidth:1,tickLength:10,tickPosition:"inside",tickWidth:2,title:{rotation:0},zIndex:2},defaultRadialXOptions:{gridLineWidth:1,labels:{align:null,distance:15,x:0,y:null,style:{textOverflow:"none"}},maxPadding:0,minPadding:0,showLastLabel:!1,tickLength:0},defaultRadialYOptions:{gridLineInterpolation:"circle",labels:{align:"right",x:-3,y:-2},showLastLabel:!1,title:{x:4,text:null,rotation:90}},setOptions:function(a){a=(this||i).options=r((this||i).defaultOptions,(this||i).defaultRadialOptions,a);a.plotBands||(a.plotBands=[])},getOffset:function(){u.getOffset.call(this||i);(this||i).chart.axisOffset[(this||i).side]=0},getLinePath:function(a,e){a=(this||i).center;var o=(this||i).chart,s=h(e,a[2]/2-(this||i).offset);(this||i).isCircular||void 0!==e?(e=(this||i).chart.renderer.symbols.arc((this||i).left+a[0],(this||i).top+a[1],s,s,{start:(this||i).startAngleRad,end:(this||i).endAngleRad,open:!0,innerR:0}),e.xBounds=[(this||i).left+a[0]],e.yBounds=[(this||i).top+a[1]-s]):(e=this.postTranslate((this||i).angleRad,s),e=["M",a[0]+o.plotLeft,a[1]+o.plotTop,"L",e.x,e.y]);return e},setAxisTranslation:function(){u.setAxisTranslation.call(this||i);(this||i).center&&((this||i).transA=(this||i).isCircular?((this||i).endAngleRad-(this||i).startAngleRad)/((this||i).max-(this||i).min||1):(this||i).center[2]/2/((this||i).max-(this||i).min||1),(this||i).minPixelPadding=(this||i).isXAxis?(this||i).transA*(this||i).minPointOffset:0)},beforeSetTickPositions:function(){((this||i).autoConnect=(this||i).isCircular&&void 0===h((this||i).userMax,(this||i).options.max)&&(this||i).endAngleRad-(this||i).startAngleRad===2*Math.PI)&&((this||i).max+=(this||i).categories&&1||(this||i).pointRange||(this||i).closestPointRange||0)},setAxisSize:function(){u.setAxisSize.call(this||i);(this||i).isRadial&&((this||i).pane.updateCenter(this||i),(this||i).isCircular&&((this||i).sector=(this||i).endAngleRad-(this||i).startAngleRad),(this||i).len=(this||i).width=(this||i).height=(this||i).center[2]*h((this||i).sector,1)/2)},getPosition:function(a,e){return this.postTranslate((this||i).isCircular?this.translate(a):(this||i).angleRad,h((this||i).isCircular?e:this.translate(a),(this||i).center[2]/2)-(this||i).offset)},postTranslate:function(a,e){var o=(this||i).chart,s=(this||i).center;a=(this||i).startAngleRad+a;return{x:o.plotLeft+s[0]+Math.cos(a)*e,y:o.plotTop+s[1]+Math.sin(a)*e}},getPlotBandPath:function(a,e,o){var r=(this||i).center,n=(this||i).startAngleRad,p=r[2]/2,c=[h(o.outerRadius,"100%"),o.innerRadius,h(o.thickness,10)],d=Math.min((this||i).offset,0),u=/%$/,g,f=(this||i).isCircular;"polygon"===(this||i).options.gridLineInterpolation?r=this.getPlotLinePath(a).concat(this.getPlotLinePath(e,!0)):(a=Math.max(a,(this||i).min),e=Math.min(e,(this||i).max),f||(c[0]=this.translate(a),c[1]=this.translate(e)),c=s(c,(function(i){u.test(i)&&(i=l(i,10)*p/100);return i})),"circle"!==o.shape&&f?(a=n+this.translate(a),e=n+this.translate(e)):(a=-Math.PI/2,e=1.5*Math.PI,g=!0),c[0]-=d,c[2]-=d,r=(this||i).chart.renderer.symbols.arc((this||i).left+r[0],(this||i).top+r[1],c[0],c[0],{start:Math.min(a,e),end:Math.max(a,e),innerR:h(c[1],c[0]-c[2]),open:g}));return r},getPlotLinePath:function(a,o){var s=this||i,r=s.center,n=s.chart,h=s.getPosition(a),l,p,c;s.isCircular?c=["M",r[0]+n.plotLeft,r[1]+n.plotTop,"L",h.x,h.y]:"circle"===s.options.gridLineInterpolation?(a=s.translate(a))&&(c=s.getLinePath(0,a)):(e(n.xAxis,(function(i){i.pane===s.pane&&(l=i)})),c=[],a=s.translate(a),r=l.tickPositions,l.autoConnect&&(r=r.concat([r[0]])),o&&(r=[].concat(r).reverse()),e(r,(function(i,e){p=l.getPosition(i,a);c.push(e?"L":"M",p.x,p.y)})));return c},getTitlePosition:function(){var a=(this||i).center,e=(this||i).chart,o=(this||i).options.title;return{x:e.plotLeft+a[0]+(o.x||0),y:e.plotTop+a[1]-{high:.5,middle:.25,low:0}[o.align]*a[2]+(o.y||0)}}};p(u,"init",(function(a,e,s){var n=e.angular,l=e.polar,p=s.isX,u=n&&p,g,f=e.options,y=s.pane||0,m=(this||i).pane=e.pane&&e.pane[y],y=m&&m.options;n?(o(this||i,u?c:d),g=!p)&&((this||i).defaultRadialOptions=(this||i).defaultRadialGaugeOptions):l&&(o(this||i,d),(this||i).defaultRadialOptions=(g=p)?(this||i).defaultRadialXOptions:r((this||i).defaultYAxisOptions,(this||i).defaultRadialYOptions));n||l?((this||i).isRadial=!0,e.inverted=!1,f.chart.zoomType=null):(this||i).isRadial=!1;m&&g&&(m.axis=this||i);a.call(this||i,e,s);!u&&m&&(n||l)&&(a=(this||i).options,(this||i).angleRad=(a.angle||0)*Math.PI/180,(this||i).startAngleRad=(y.startAngle-90)*Math.PI/180,(this||i).endAngleRad=(h(y.endAngle,y.startAngle+360)-90)*Math.PI/180,(this||i).offset=a.offset||0,(this||i).isCircular=g)}));p(u,"autoLabelAlign",(function(a){if(!(this||i).isRadial)return a.apply(this||i,[].slice.call(arguments,1))}));p(a,"getPosition",(function(a,e,o,s,r){var n=(this||i).axis;return n.getPosition?n.getPosition(o):a.call(this||i,e,o,s,r)}));p(a,"getLabelPosition",(function(a,e,o,s,r,n,l,p,c){var d=(this||i).axis,u=n.y,g=20,f=n.align,y=(d.translate((this||i).pos)+d.startAngleRad+Math.PI/2)/Math.PI*180%360;d.isRadial?(a=d.getPosition((this||i).pos,d.center[2]/2+h(n.distance,-25)),"auto"===n.rotation?s.attr({rotation:y}):null===u&&(u=d.chart.renderer.fontMetrics(s.styles.fontSize).b-s.getBBox().height/2),null===f&&(d.isCircular?((this||i).label.getBBox().width>d.len*d.tickInterval/(d.max-d.min)&&(g=0),f=y>g&&y<180-g?"left":y>180+g&&y<360-g?"right":"center"):f="center",s.attr({align:f})),a.x+=n.x,a.y+=u):a=a.call(this||i,e,o,s,r,n,l,p,c);return a}));p(a,"getMarkPath",(function(a,e,o,s,r,n,h){var l=(this||i).axis;l.isRadial?(a=l.getPosition((this||i).pos,l.center[2]/2+s),e=["M",e,o,"L",a.x,a.y]):e=a.call(this||i,e,o,s,r,n,h);return e}))})(a);(function(a){var e=a.each,o=a.pick,s=a.defined,r=a.seriesType,n=a.seriesTypes,h=a.Series.prototype,l=a.Point.prototype;r("arearange","area",{lineWidth:1,threshold:null,tooltip:{pointFormat:'<span style="color:{series.color}">●</span> {series.name}: <b>{point.low}</b> - <b>{point.high}</b><br/>'},trackByArea:!0,dataLabels:{align:null,verticalAlign:null,xLow:0,xHigh:0,yLow:0,yHigh:0}},{pointArrayMap:["low","high"],dataLabelCollections:["dataLabel","dataLabelUpper"],toYData:function(i){return[i.low,i.high]},pointValKey:"low",deferTranslatePolar:!0,highToXY:function(a){var e=(this||i).chart,o=(this||i).xAxis.postTranslate(a.rectPlotX,(this||i).yAxis.len-a.plotHigh);a.plotHighX=o.x-e.plotLeft;a.plotHigh=o.y-e.plotTop;a.plotLowX=a.plotX},translate:function(){var a=this||i,o=a.yAxis,s=!!a.modifyValue;n.area.prototype.translate.apply(a);e(a.points,(function(i){var e=i.low,r=i.high,n=i.plotY;null===r||null===e?(i.isNull=!0,i.plotY=null):(i.plotLow=n,i.plotHigh=o.translate(s?a.modifyValue(r,i):r,0,1,0,1),s&&(i.yBottom=i.plotHigh))}));(this||i).chart.polar&&e((this||i).points,(function(i){a.highToXY(i);i.tooltipPos=[(i.plotHighX+i.plotLowX)/2,(i.plotHigh+i.plotLow)/2]}))},getGraphPath:function(a){var e=[],s=[],r,h=n.area.prototype.getGraphPath,l,p,c;c=(this||i).options;var d=(this||i).chart.polar&&!1!==c.connectEnds,u=c.connectNulls,g=c.step;a=a||(this||i).points;for(r=a.length;r--;)l=a[r],l.isNull||d||u||a[r+1]&&!a[r+1].isNull||s.push({plotX:l.plotX,plotY:l.plotY,doCurve:!1}),p={polarPlotY:l.polarPlotY,rectPlotX:l.rectPlotX,yBottom:l.yBottom,plotX:o(l.plotHighX,l.plotX),plotY:l.plotHigh,isNull:l.isNull},s.push(p),e.push(p),l.isNull||d||u||a[r-1]&&!a[r-1].isNull||s.push({plotX:l.plotX,plotY:l.plotY,doCurve:!1});a=h.call(this||i,a);g&&(!0===g&&(g="left"),c.step={left:"right",center:"center",right:"left"}[g]);e=h.call(this||i,e);s=h.call(this||i,s);c.step=g;c=[].concat(a,e);(this||i).chart.polar||"M"!==s[0]||(s[0]="L");(this||i).graphPath=c;(this||i).areaPath=a.concat(s);c.isArea=!0;c.xMap=a.xMap;(this||i).areaPath.xMap=a.xMap;return c},drawDataLabels:function(){var a=(this||i).data,e=a.length,o,s=[],r=(this||i).options.dataLabels,n=r.align,l=r.verticalAlign,p=r.inside,c,d,u=(this||i).chart.inverted;if(r.enabled||(this||i)._hasPointLabels){for(o=e;o--;)(c=a[o])&&(d=p?c.plotHigh<c.plotLow:c.plotHigh>c.plotLow,c.y=c.high,c._plotY=c.plotY,c.plotY=c.plotHigh,s[o]=c.dataLabel,c.dataLabel=c.dataLabelUpper,c.below=d,u?n||(r.align=d?"right":"left"):l||(r.verticalAlign=d?"top":"bottom"),r.x=r.xHigh,r.y=r.yHigh);h.drawDataLabels&&h.drawDataLabels.apply(this||i,arguments);for(o=e;o--;)(c=a[o])&&(d=p?c.plotHigh<c.plotLow:c.plotHigh>c.plotLow,c.dataLabelUpper=c.dataLabel,c.dataLabel=s[o],c.y=c.low,c.plotY=c._plotY,c.below=!d,u?n||(r.align=d?"left":"right"):l||(r.verticalAlign=d?"bottom":"top"),r.x=r.xLow,r.y=r.yLow);h.drawDataLabels&&h.drawDataLabels.apply(this||i,arguments)}r.align=n;r.verticalAlign=l},alignDataLabel:function(){n.column.prototype.alignDataLabel.apply(this||i,arguments)},drawPoints:function(){var a=(this||i).points.length,e,o;h.drawPoints.apply(this||i,arguments);for(o=0;o<a;)e=(this||i).points[o],e.lowerGraphic=e.graphic,e.graphic=e.upperGraphic,e._plotY=e.plotY,e._plotX=e.plotX,e.plotY=e.plotHigh,s(e.plotHighX)&&(e.plotX=e.plotHighX),o++;h.drawPoints.apply(this||i,arguments);for(o=0;o<a;)e=(this||i).points[o],e.upperGraphic=e.graphic,e.graphic=e.lowerGraphic,e.plotY=e._plotY,e.plotX=e._plotX,o++},setStackedPoints:a.noop},{setState:function(){var a=(this||i).state,e=(this||i).series,o=e.chart.polar;s((this||i).plotHigh)||((this||i).plotHigh=e.yAxis.toPixels((this||i).high,!0));s((this||i).plotLow)||((this||i).plotLow=(this||i).plotY=e.yAxis.toPixels((this||i).low,!0));l.setState.apply(this||i,arguments);(this||i).graphic=(this||i).upperGraphic;(this||i).plotY=(this||i).plotHigh;o&&((this||i).plotX=(this||i).plotHighX);(this||i).state=a;e.stateMarkerGraphic&&(e.lowerStateMarkerGraphic=e.stateMarkerGraphic,e.stateMarkerGraphic=e.upperStateMarkerGraphic);l.setState.apply(this||i,arguments);(this||i).plotY=(this||i).plotLow;(this||i).graphic=(this||i).lowerGraphic;o&&((this||i).plotX=(this||i).plotLowX);e.stateMarkerGraphic&&(e.upperStateMarkerGraphic=e.stateMarkerGraphic,e.stateMarkerGraphic=e.lowerStateMarkerGraphic,e.lowerStateMarkerGraphic=void 0)},haloPath:function(){var a=(this||i).series.chart.polar,e;(this||i).plotY=(this||i).plotLow;a&&((this||i).plotX=(this||i).plotLowX);e=l.haloPath.apply(this||i,arguments);(this||i).plotY=(this||i).plotHigh;a&&((this||i).plotX=(this||i).plotHighX);return e=e.concat(l.haloPath.apply(this||i,arguments))},destroy:function(){(this||i).upperGraphic&&((this||i).upperGraphic=(this||i).upperGraphic.destroy());return l.destroy.apply(this||i,arguments)}})})(a);(function(i){var a=i.seriesType;a("areasplinerange","arearange",null,{getPointSpline:i.seriesTypes.spline.prototype.getPointSpline})})(a);(function(a){var e=a.defaultPlotOptions,o=a.each,s=a.merge,r=a.noop,n=a.pick,h=a.seriesType,l=a.seriesTypes.column.prototype;h("columnrange","arearange",s(e.column,e.arearange,{pointRange:null,marker:null,states:{hover:{halo:!1}}}),{translate:function(){var a=this||i,e=a.yAxis,s=a.xAxis,r=s.startAngleRad,h,p=a.chart,c=a.xAxis.isRadial,d=Math.max(p.chartWidth,p.chartHeight)+999,u;l.translate.apply(a);o(a.points,(function(i){var o=i.shapeArgs,l=a.options.minPointLength,g,f;i.plotHigh=u=Math.min(Math.max(-d,e.translate(i.high,0,1,0,1)),d);i.plotLow=Math.min(Math.max(-d,i.plotY),d);f=u;g=n(i.rectPlotY,i.plotY)-u;Math.abs(g)<l?(l-=g,g+=l,f-=l/2):0>g&&(g*=-1,f-=g);c?(h=i.barX+r,i.shapeType="path",i.shapeArgs={d:a.polarArc(f+g,f,h,h+i.pointWidth)}):(o.height=g,o.y=f,i.tooltipPos=p.inverted?[e.len+e.pos-p.plotLeft-f-g/2,s.len+s.pos-p.plotTop-o.x-o.width/2,g]:[s.left-p.plotLeft+o.x+o.width/2,e.pos-p.plotTop+f+g/2,g])}))},directTouch:!0,trackerGroups:["group","dataLabelsGroup"],drawGraph:r,getSymbol:r,crispCol:l.crispCol,drawPoints:l.drawPoints,drawTracker:l.drawTracker,getColumnMetrics:l.getColumnMetrics,pointAttribs:l.pointAttribs,animate:function(){return l.animate.apply(this||i,arguments)},polarArc:function(){return l.polarArc.apply(this||i,arguments)},translate3dPoints:function(){return l.translate3dPoints.apply(this||i,arguments)},translate3dShapes:function(){return l.translate3dShapes.apply(this||i,arguments)}},{setState:l.pointClass.prototype.setState})})(a);(function(a){var e=a.each,o=a.isNumber,s=a.merge,r=a.pick,n=a.pInt,h=a.Series,l=a.seriesType,p=a.TrackerMixin;l("gauge","line",{dataLabels:{enabled:!0,defer:!1,y:15,borderRadius:3,crop:!1,verticalAlign:"top",zIndex:2,borderWidth:1,borderColor:"#cccccc"},dial:{},pivot:{},tooltip:{headerFormat:""},showInLegend:!1},{angular:!0,directTouch:!0,drawGraph:a.noop,fixedBox:!0,forceDL:!0,noSharedTooltip:!0,trackerGroups:["group","dataLabelsGroup"],translate:function(){var a=(this||i).yAxis,h=(this||i).options,l=a.center;this.generatePoints();e((this||i).points,(function(i){var e=s(h.dial,i.dial),p=n(r(e.radius,80))*l[2]/200,c=n(r(e.baseLength,70))*p/100,d=n(r(e.rearLength,10))*p/100,u=e.baseWidth||3,g=e.topWidth||1,f=h.overshoot,y=a.startAngleRad+a.translate(i.y,null,null,null,!0);o(f)?(f=f/180*Math.PI,y=Math.max(a.startAngleRad-f,Math.min(a.endAngleRad+f,y))):!1===h.wrap&&(y=Math.max(a.startAngleRad,Math.min(a.endAngleRad,y)));y=180*y/Math.PI;i.shapeType="path";i.shapeArgs={d:e.path||["M",-d,-u/2,"L",c,-u/2,p,-g/2,p,g/2,c,u/2,-d,u/2,"z"],translateX:l[0],translateY:l[1],rotation:y};i.plotX=l[0];i.plotY=l[1]}))},drawPoints:function(){var a=this||i,o=a.yAxis.center,n=a.pivot,h=a.options,l=h.pivot,p=a.chart.renderer;e(a.points,(function(i){var e=i.graphic,o=i.shapeArgs,r=o.d,n=s(h.dial,i.dial);e?(e.animate(o),o.d=r):(i.graphic=p[i.shapeType](o).attr({rotation:o.rotation,zIndex:1}).addClass("highcharts-dial").add(a.group),i.graphic.attr({stroke:n.borderColor||"none","stroke-width":n.borderWidth||0,fill:n.backgroundColor||"#000000"}))}));n?n.animate({translateX:o[0],translateY:o[1]}):(a.pivot=p.circle(0,0,r(l.radius,5)).attr({zIndex:2}).addClass("highcharts-pivot").translate(o[0],o[1]).add(a.group),a.pivot.attr({"stroke-width":l.borderWidth||0,stroke:l.borderColor||"#cccccc",fill:l.backgroundColor||"#000000"}))},animate:function(a){var o=this||i;a||(e(o.points,(function(i){var a=i.graphic;a&&(a.attr({rotation:180*o.yAxis.startAngleRad/Math.PI}),a.animate({rotation:i.shapeArgs.rotation},o.options.animation))})),o.animate=null)},render:function(){(this||i).group=this.plotGroup("group","series",(this||i).visible?"visible":"hidden",(this||i).options.zIndex,(this||i).chart.seriesGroup);h.prototype.render.call(this||i);(this||i).group.clip((this||i).chart.clipRect)},setData:function(a,e){h.prototype.setData.call(this||i,a,!1);this.processData();this.generatePoints();r(e,!0)&&(this||i).chart.redraw()},drawTracker:p&&p.drawTrackerPoint},{setState:function(a){(this||i).state=a}})})(a);(function(a){var e=a.each,o=a.noop,s=a.pick,r=a.seriesType,n=a.seriesTypes;r("boxplot","column",{threshold:null,tooltip:{pointFormat:'<span style="color:{point.color}">●</span> <b> {series.name}</b><br/>Maximum: {point.high}<br/>Upper quartile: {point.q3}<br/>Median: {point.median}<br/>Lower quartile: {point.q1}<br/>Minimum: {point.low}<br/>'},whiskerLength:"50%",fillColor:"#ffffff",lineWidth:1,medianWidth:2,states:{hover:{brightness:-.3}},whiskerWidth:2},{pointArrayMap:["low","q1","median","q3","high"],toYData:function(i){return[i.low,i.q1,i.median,i.q3,i.high]},pointValKey:"high",pointAttribs:function(a){var e=(this||i).options,o=a&&a.color||(this||i).color;return{fill:a.fillColor||e.fillColor||o,stroke:e.lineColor||o,"stroke-width":e.lineWidth||0}},drawDataLabels:o,translate:function(){var a=(this||i).yAxis,o=(this||i).pointArrayMap;n.column.prototype.translate.apply(this||i);e((this||i).points,(function(i){e(o,(function(e){null!==i[e]&&(i[e+"Plot"]=a.translate(i[e],0,1,0,1))}))}))},drawPoints:function(){var a=this||i,o=a.options,r=a.chart.renderer,n,h,l,p,c,d,u=0,g,f,y,m,x=!1!==a.doQuartiles,b,P=a.options.whiskerLength;e(a.points,(function(i){var e=i.graphic,M=e?"animate":"attr",v=i.shapeArgs,k={},w={},A={},L=i.color||a.color;void 0!==i.plotY&&(g=v.width,f=Math.floor(v.x),y=f+g,m=Math.round(g/2),n=Math.floor(x?i.q1Plot:i.lowPlot),h=Math.floor(x?i.q3Plot:i.lowPlot),l=Math.floor(i.highPlot),p=Math.floor(i.lowPlot),e||(i.graphic=e=r.g("point").add(a.group),i.stem=r.path().addClass("highcharts-boxplot-stem").add(e),P&&(i.whiskers=r.path().addClass("highcharts-boxplot-whisker").add(e)),x&&(i.box=r.path(void 0).addClass("highcharts-boxplot-box").add(e)),i.medianShape=r.path(void 0).addClass("highcharts-boxplot-median").add(e)),k.stroke=i.stemColor||o.stemColor||L,k["stroke-width"]=s(i.stemWidth,o.stemWidth,o.lineWidth),k.dashstyle=i.stemDashStyle||o.stemDashStyle,i.stem.attr(k),P&&(w.stroke=i.whiskerColor||o.whiskerColor||L,w["stroke-width"]=s(i.whiskerWidth,o.whiskerWidth,o.lineWidth),i.whiskers.attr(w)),x&&(e=a.pointAttribs(i),i.box.attr(e)),A.stroke=i.medianColor||o.medianColor||L,A["stroke-width"]=s(i.medianWidth,o.medianWidth,o.lineWidth),i.medianShape.attr(A),d=i.stem.strokeWidth()%2/2,u=f+m+d,i.stem[M]({d:["M",u,h,"L",u,l,"M",u,n,"L",u,p]}),x&&(d=i.box.strokeWidth()%2/2,n=Math.floor(n)+d,h=Math.floor(h)+d,f+=d,y+=d,i.box[M]({d:["M",f,h,"L",f,n,"L",y,n,"L",y,h,"L",f,h,"z"]})),P&&(d=i.whiskers.strokeWidth()%2/2,l+=d,p+=d,b=/%$/.test(P)?m*parseFloat(P)/100:P/2,i.whiskers[M]({d:["M",u-b,l,"L",u+b,l,"M",u-b,p,"L",u+b,p]})),c=Math.round(i.medianPlot),d=i.medianShape.strokeWidth()%2/2,c+=d,i.medianShape[M]({d:["M",f,c,"L",y,c]}))}))},setStackedPoints:o})})(a);(function(a){var e=a.each,o=a.noop,s=a.seriesType,r=a.seriesTypes;s("errorbar","boxplot",{color:"#000000",grouping:!1,linkedTo:":previous",tooltip:{pointFormat:'<span style="color:{point.color}">●</span> {series.name}: <b>{point.low}</b> - <b>{point.high}</b><br/>'},whiskerWidth:null},{type:"errorbar",pointArrayMap:["low","high"],toYData:function(i){return[i.low,i.high]},pointValKey:"high",doQuartiles:!1,drawDataLabels:r.arearange?function(){var a=(this||i).pointValKey;r.arearange.prototype.drawDataLabels.call(this||i);e((this||i).data,(function(i){i.y=i[a]}))}:o,getColumnMetrics:function(){return(this||i).linkedParent&&(this||i).linkedParent.columnMetrics||r.column.prototype.getColumnMetrics.call(this||i)}})})(a);(function(a){var e=a.correctFloat,o=a.isNumber,s=a.pick,r=a.Point,n=a.Series,h=a.seriesType,l=a.seriesTypes;h("waterfall","column",{dataLabels:{inside:!0},lineWidth:1,lineColor:"#333333",dashStyle:"dot",borderColor:"#333333",states:{hover:{lineWidthPlus:0}}},{pointValKey:"y",translate:function(){var a=(this||i).options,o=(this||i).yAxis,r,n,h,p,c,d,u,g,f,y,m=s(a.minPointLength,5),x=m/2,b=a.threshold,P=a.stacking,M;l.column.prototype.translate.apply(this||i);g=f=b;n=(this||i).points;r=0;for(a=n.length;r<a;r++)h=n[r],u=(this||i).processedYData[r],p=h.shapeArgs,c=P&&o.stacks[((this||i).negStacks&&u<b?"-":"")+(this||i).stackKey],M=this.getStackIndicator(M,h.x,(this||i).index),y=c?c[h.x].points[M.key]:[0,u],h.isSum?h.y=e(u):h.isIntermediateSum&&(h.y=e(u-f)),d=Math.max(g,g+h.y)+y[0],p.y=o.translate(d,0,1,0,1),h.isSum?(p.y=o.translate(y[1],0,1,0,1),p.height=Math.min(o.translate(y[0],0,1,0,1),o.len)-p.y):h.isIntermediateSum?(p.y=o.translate(y[1],0,1,0,1),p.height=Math.min(o.translate(f,0,1,0,1),o.len)-p.y,f=y[1]):(p.height=0<u?o.translate(g,0,1,0,1)-p.y:o.translate(g,0,1,0,1)-o.translate(g-u,0,1,0,1),g+=c&&c[h.x]?c[h.x].total:u),0>p.height&&(p.y+=p.height,p.height*=-1),h.plotY=p.y=Math.round(p.y)-(this||i).borderWidth%2/2,p.height=Math.max(Math.round(p.height),.001),h.yBottom=p.y+p.height,p.height<=m&&!h.isNull?(p.height=m,p.y-=x,h.plotY=p.y,h.minPointLengthOffset=0>h.y?-x:x):h.minPointLengthOffset=0,p=h.plotY+(h.negative?p.height:0),(this||i).chart.inverted?h.tooltipPos[0]=o.len-p:h.tooltipPos[1]=p},processData:function(a){var o=(this||i).yData,s=(this||i).options.data,r,h=o.length,l,p,c,d,u,g;p=l=c=d=(this||i).options.threshold||0;for(g=0;g<h;g++)u=o[g],r=s&&s[g]?s[g]:{},"sum"===u||r.isSum?o[g]=e(p):"intermediateSum"===u||r.isIntermediateSum?o[g]=e(l):(p+=u,l+=u),c=Math.min(p,c),d=Math.max(p,d);n.prototype.processData.call(this||i,a);(this||i).options.stacking||((this||i).dataMin=c,(this||i).dataMax=d)},toYData:function(i){return i.isSum?0===i.x?null:"sum":i.isIntermediateSum?0===i.x?null:"intermediateSum":i.y},pointAttribs:function(a,e){var o=(this||i).options.upColor;o&&!a.options.color&&(a.color=0<a.y?o:null);a=l.column.prototype.pointAttribs.call(this||i,a,e);delete a.dashstyle;return a},getGraphPath:function(){return["M",0,0]},getCrispPath:function(){var a=(this||i).data,e=a.length,o=(this||i).graph.strokeWidth()+(this||i).borderWidth,o=Math.round(o)%2/2,s=(this||i).yAxis.reversed,r=[],n,h,l;for(l=1;l<e;l++){h=a[l].shapeArgs;n=a[l-1].shapeArgs;h=["M",n.x+n.width,n.y+a[l-1].minPointLengthOffset+o,"L",h.x,n.y+a[l-1].minPointLengthOffset+o];(0>a[l-1].y&&!s||0<a[l-1].y&&s)&&(h[2]+=n.height,h[5]+=n.height);r=r.concat(h)}return r},drawGraph:function(){n.prototype.drawGraph.call(this||i);(this||i).graph.attr({d:this.getCrispPath()})},setStackedPoints:function(){var a=(this||i).options,e,o;n.prototype.setStackedPoints.apply(this||i,arguments);e=(this||i).stackedYData?(this||i).stackedYData.length:0;for(o=1;o<e;o++)a.data[o].isSum||a.data[o].isIntermediateSum||((this||i).stackedYData[o]+=(this||i).stackedYData[o-1])},getExtremes:function(){if((this||i).options.stacking)return n.prototype.getExtremes.apply(this||i,arguments)}},{getClassName:function(){var a=r.prototype.getClassName.call(this||i);(this||i).isSum?a+=" highcharts-sum":(this||i).isIntermediateSum&&(a+=" highcharts-intermediate-sum");return a},isValid:function(){return o((this||i).y,!0)||(this||i).isSum||(this||i).isIntermediateSum}})})(a);(function(a){var e=a.Series,o=a.seriesType,s=a.seriesTypes;o("polygon","scatter",{marker:{enabled:!1,states:{hover:{enabled:!1}}},stickyTracking:!1,tooltip:{followPointer:!0,pointFormat:""},trackByArea:!0},{type:"polygon",getGraphPath:function(){for(var a=e.prototype.getGraphPath.call(this||i),o=a.length+1;o--;)(o===a.length||"M"===a[o])&&0<o&&a.splice(o,0,"z");return(this||i).areaPath=a},drawGraph:function(){(this||i).options.fillColor=(this||i).color;s.area.prototype.drawGraph.call(this||i)},drawLegendSymbol:a.LegendSymbolMixin.drawRectangle,drawTracker:e.prototype.drawTracker,setStackedPoints:a.noop})})(a);(function(a){var e=a.arrayMax,o=a.arrayMin,s=a.Axis,r=a.color,n=a.each,h=a.isNumber,l=a.noop,p=a.pick,c=a.pInt,d=a.Point,u=a.Series,g=a.seriesType,f=a.seriesTypes;g("bubble","scatter",{dataLabels:{formatter:function(){return(this||i).point.z},inside:!0,verticalAlign:"middle"},marker:{lineColor:null,lineWidth:1,radius:null,states:{hover:{radiusPlus:0}},symbol:"circle"},minSize:8,maxSize:"20%",softThreshold:!1,states:{hover:{halo:{size:5}}},tooltip:{pointFormat:"({point.x}, {point.y}), Size: {point.z}"},turboThreshold:0,zThreshold:0,zoneAxis:"z"},{pointArrayMap:["y","z"],parallelArrays:["x","y","z"],trackerGroups:["group","dataLabelsGroup"],specialGroup:"group",bubblePadding:!0,zoneAxis:"z",directTouch:!0,pointAttribs:function(a,e){var o=p((this||i).options.marker.fillOpacity,.5);a=u.prototype.pointAttribs.call(this||i,a,e);1!==o&&(a.fill=r(a.fill).setOpacity(o).get("rgba"));return a},getRadii:function(a,e,o,s){var r,n,h,l=(this||i).zData,p=[],c=(this||i).options,d="width"!==c.sizeBy,u=c.zThreshold,g=e-a;n=0;for(r=l.length;n<r;n++)h=l[n],c.sizeByAbsoluteValue&&null!==h&&(h=Math.abs(h-u),e=Math.max(e-u,Math.abs(a-u)),a=0),null===h?h=null:h<a?h=o/2-1:(h=0<g?(h-a)/g:.5,d&&0<=h&&(h=Math.sqrt(h)),h=Math.ceil(o+h*(s-o))/2),p.push(h);(this||i).radii=p},animate:function(a){var e=(this||i).options.animation;a||(n((this||i).points,(function(i){var a=i.graphic,o;a&&a.width&&(o={x:a.x,y:a.y,width:a.width,height:a.height},a.attr({x:i.plotX,y:i.plotY,width:1,height:1}),a.animate(o,e))})),(this||i).animate=null)},translate:function(){var e,o=(this||i).data,s,r,n=(this||i).radii;f.scatter.prototype.translate.call(this||i);for(e=o.length;e--;)s=o[e],r=n?n[e]:0,h(r)&&r>=(this||i).minPxSize/2?(s.marker=a.extend(s.marker,{radius:r,width:2*r,height:2*r}),s.dlBox={x:s.plotX-r,y:s.plotY-r,width:2*r,height:2*r}):s.shapeArgs=s.plotY=s.dlBox=void 0},alignDataLabel:f.column.prototype.alignDataLabel,buildKDTree:l,applyZones:l},{haloPath:function(a){return d.prototype.haloPath.call(this||i,0===a?0:((this||i).marker&&(this||i).marker.radius||0)+a)},ttBelow:!1});s.prototype.beforePadding=function(){var a=this||i,s=(this||i).len,r=(this||i).chart,l=0,d=s,u=(this||i).isXAxis,g=u?"xData":"yData",f=(this||i).min,y={},m=Math.min(r.plotWidth,r.plotHeight),x=Number.MAX_VALUE,b=-Number.MAX_VALUE,P=(this||i).max-f,M=s/P,v=[];n((this||i).series,(function(i){var s=i.options;!i.bubblePadding||!i.visible&&r.options.chart.ignoreHiddenSeries||(a.allowZoomOutside=!0,v.push(i),u&&(n(["minSize","maxSize"],(function(i){var a=s[i],e=/%$/.test(a),a=c(a);y[i]=e?m*a/100:a})),i.minPxSize=y.minSize,i.maxPxSize=Math.max(y.maxSize,y.minSize),i=i.zData,i.length&&(x=p(s.zMin,Math.min(x,Math.max(o(i),!1===s.displayNegative?s.zThreshold:-Number.MAX_VALUE))),b=p(s.zMax,Math.max(b,e(i))))))}));n(v,(function(i){var e=i[g],o=e.length,s;u&&i.getRadii(x,b,i.minPxSize,i.maxPxSize);if(0<P)for(;o--;)h(e[o])&&a.dataMin<=e[o]&&e[o]<=a.dataMax&&(s=i.radii[o],l=Math.min((e[o]-f)*M-s,l),d=Math.max((e[o]-f)*M+s,d))}));v.length&&0<P&&!(this||i).isLog&&(d-=s,M*=(s+l-d)/s,n([["min","userMin",l],["max","userMax",d]],(function(i){void 0===p(a.options[i[0]],a[i[1]])&&(a[i[0]]+=i[2]/M)})))}})(a);(function(a){function t(a,e){var o=(this||i).chart,s=(this||i).options.animation,r=(this||i).group,n=(this||i).markerGroup,h=(this||i).xAxis.center,l=o.plotLeft,p=o.plotTop;o.polar?o.renderer.isSVG&&(!0===s&&(s={}),e?(a={translateX:h[0]+l,translateY:h[1]+p,scaleX:.001,scaleY:.001},r.attr(a),n&&n.attr(a)):(a={translateX:l,translateY:p,scaleX:1,scaleY:1},r.animate(a,s),n&&n.animate(a,s),(this||i).animate=null)):a.call(this||i,e)}var e=a.each,o=a.pick,s=a.seriesTypes,r=a.wrap,n=a.Series.prototype,h=a.Pointer.prototype;n.searchPointByAngle=function(a){var e=(this||i).chart,o=(this||i).xAxis.pane.center;return this.searchKDTree({clientX:180+-180/Math.PI*Math.atan2(a.chartX-o[0]-e.plotLeft,a.chartY-o[1]-e.plotTop)})};n.getConnectors=function(i,a,e,o){var s,r,n,h,l,p,c,d;r=o?1:0;s=0<=a&&a<=i.length-1?a:0>a?i.length-1+a:0;a=0>s-1?i.length-(1+r):s-1;r=s+1>i.length-1?r:s+1;n=i[a];r=i[r];h=n.plotX;n=n.plotY;l=r.plotX;p=r.plotY;r=i[s].plotX;s=i[s].plotY;h=(1.5*r+h)/2.5;n=(1.5*s+n)/2.5;l=(1.5*r+l)/2.5;c=(1.5*s+p)/2.5;p=Math.sqrt(Math.pow(h-r,2)+Math.pow(n-s,2));d=Math.sqrt(Math.pow(l-r,2)+Math.pow(c-s,2));h=Math.atan2(n-s,h-r);c=Math.PI/2+(h+Math.atan2(c-s,l-r))/2;Math.abs(h-c)>Math.PI/2&&(c-=Math.PI);h=r+Math.cos(c)*p;n=s+Math.sin(c)*p;l=r+Math.cos(Math.PI+c)*d;c=s+Math.sin(Math.PI+c)*d;r={rightContX:l,rightContY:c,leftContX:h,leftContY:n,plotX:r,plotY:s};e&&(r.prevPointCont=this.getConnectors(i,a,!1,o));return r};r(n,"buildKDTree",(function(a){(this||i).chart.polar&&((this||i).kdByAngle?(this||i).searchPoint=(this||i).searchPointByAngle:(this||i).options.findNearestPointBy="xy");a.apply(this||i)}));n.toXY=function(a){var e,o=(this||i).chart,s=a.plotX;e=a.plotY;a.rectPlotX=s;a.rectPlotY=e;e=(this||i).xAxis.postTranslate(a.plotX,(this||i).yAxis.len-e);a.plotX=a.polarPlotX=e.x-o.plotLeft;a.plotY=a.polarPlotY=e.y-o.plotTop;(this||i).kdByAngle?(o=(s/Math.PI*180+(this||i).xAxis.pane.options.startAngle)%360,0>o&&(o+=360),a.clientX=o):a.clientX=a.plotX};s.spline&&(r(s.spline.prototype,"getPointSpline",(function(a,e,o,s){(this||i).chart.polar?s?(a=this.getConnectors(e,s,!0,(this||i).connectEnds),a=["C",a.prevPointCont.rightContX,a.prevPointCont.rightContY,a.leftContX,a.leftContY,a.plotX,a.plotY]):a=["M",o.plotX,o.plotY]:a=a.call(this||i,e,o,s);return a})),s.areasplinerange&&(s.areasplinerange.prototype.getPointSpline=s.spline.prototype.getPointSpline));r(n,"translate",(function(a){var e=(this||i).chart;a.call(this||i);if(e.polar&&((this||i).kdByAngle=e.tooltip&&e.tooltip.shared,!(this||i).preventPostTranslate))for(a=(this||i).points,e=a.length;e--;)this.toXY(a[e])}));r(n,"getGraphPath",(function(a,o){var s=this||i,r,n,h;if((this||i).chart.polar){o=o||(this||i).points;for(r=0;r<o.length;r++)if(!o[r].isNull){n=r;break}!1!==(this||i).options.connectEnds&&void 0!==n&&((this||i).connectEnds=!0,o.splice(o.length,0,o[n]),h=!0);e(o,(function(i){void 0===i.polarPlotY&&s.toXY(i)}))}r=a.apply(this||i,[].slice.call(arguments,1));h&&o.pop();return r}));r(n,"animate",t);s.column&&(s=s.column.prototype,s.polarArc=function(a,e,s,r){var n=(this||i).xAxis.center,h=(this||i).yAxis.len;return(this||i).chart.renderer.symbols.arc(n[0],n[1],h-e,null,{start:s,end:r,innerR:h-o(a,h)})},r(s,"animate",t),r(s,"translate",(function(a){var e=(this||i).xAxis,o=e.startAngleRad,s,r,n;(this||i).preventPostTranslate=!0;a.call(this||i);if(e.isRadial)for(s=(this||i).points,n=s.length;n--;)r=s[n],a=r.barX+o,r.shapeType="path",r.shapeArgs={d:this.polarArc(r.yBottom,r.plotY,a,a+r.pointWidth)},this.toXY(r),r.tooltipPos=[r.plotX,r.plotY],r.ttBelow=r.plotY>e.center[1]})),r(s,"alignDataLabel",(function(a,e,o,s,r,h){(this||i).chart.polar?(a=e.rectPlotX/Math.PI*180,null===s.align&&(s.align=20<a&&160>a?"left":200<a&&340>a?"right":"center"),null===s.verticalAlign&&(s.verticalAlign=45>a||315<a?"bottom":135<a&&225>a?"top":"middle"),n.alignDataLabel.call(this||i,e,o,s,r,h)):a.call(this||i,e,o,s,r,h)})));r(h,"getCoordinates",(function(a,o){var s=(this||i).chart,r={xAxis:[],yAxis:[]};s.polar?e(s.axes,(function(i){var a=i.isXAxis,e=i.center,n=o.chartX-e[0]-s.plotLeft,e=o.chartY-e[1]-s.plotTop;r[a?"xAxis":"yAxis"].push({axis:i,value:i.translate(a?Math.PI-Math.atan2(n,e):Math.sqrt(Math.pow(n,2)+Math.pow(e,2)),!0)})})):r=a.call(this||i,o);return r}));r(a.Chart.prototype,"getAxes",(function(o){(this||i).pane||((this||i).pane=[]);e(a.splat((this||i).options.pane),(function(e){new a.Pane(e,this||i)}),this||i);o.call(this||i)}));r(a.Chart.prototype,"drawChartBox",(function(a){a.call(this||i);e((this||i).pane,(function(i){i.render()}))}));r(a.Chart.prototype,"get",(function(e,o){return a.find((this||i).pane,(function(i){return i.options.id===o}))||e.call(this||i,o)}))})(a)}));var e=a;export default e;
