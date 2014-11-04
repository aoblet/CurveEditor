import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {
    width: 500
    height: 500

    ListModel{
        id:pointsCurve

        ListElement{
            x:50
            y:100
            xBezier1:50
            yBezier1:400
            xBezier2:50
            yBezier2:400
        }

        ListElement{
            x:550
            y:800
            xBezier1:400
            yBezier1:100
            xBezier2:400
            yBezier2:100
        }
    }

    Canvas{
        id:canvas
        contextType:"2d"
        anchors.fill: parent
        property int xRangeGrid: 10
        property int yRangeGrid: 10
        property int scale: 1;


        function convertEffectToCoord(effect){
            var firstX = pointsCurve.get(0).x; var lastX = pointsCurve.get(pointsCurve.count-1).x;
            var firstY = pointsCurve.get(0).y; var lastY = pointsCurve.get(pointsCurve.count-1).y;
            var distanceYminMax = Math.abs(lastY-firstY)

            var point ={};
            point.x = ( (effect.x - firstX)/(lastX-firstX) ) * canvas.width;
            point.y = Math.abs(((effect.y - Math.min(firstY,lastY))/distanceYminMax * canvas.height) - canvas.height);
            point.xBezier1 = point.x;
            point.yBezier1 = point.y;
            point.xBezier2 = point.x;
            point.yBezier2 = point.y;

            if(effect.xBezier1 && effect.yBezier2 && effect.xBezier2 && effect.yBezier2){

            }

            return point;
        }

        function convertCoordToEffect(point){
            var firstX = pointsCurve.get(0).x; var lastX = pointsCurve.get(pointsCurve.count-1).x;
            var firstY = pointsCurve.get(0).y; var lastY = pointsCurve.get(pointsCurve.count-1).y;
            var distanceYminMax = Math.abs(lastY-firstY)

            var effect = {}
            effect.x = ((lastX - firstX) * point.x/canvas.width) + firstX;
            effect.y = (Math.abs(point.y - canvas.height) * distanceYminMax / canvas.height) + Math.min(firstY,lastY);
            return effect;
        }

        function drawGrid(ctx){
            var xFootStep = canvas.width / canvas.xRangeGrid;
            var yFootStep = canvas.height / canvas.yRangeGrid;

            ctx.strokeStyle = "#ccc";
            ctx.lineWidth=1;
            ctx.beginPath();

            for(var i=0; i< canvas.width; i+=xFootStep){
                ctx.moveTo(i,0);
                ctx.lineTo(i,canvas.height);
            }

            for(var j=0; j< canvas.height; j+=yFootStep){
                ctx.moveTo(0,j);
                ctx.lineTo(canvas.width,j);
            }
            ctx.stroke();
        }

        function drawLine(ctx){
            if(pointsCurve.count > 1 ){
                ctx.lineWidth=1;
                ctx.beginPath();
                ctx.strokeStyle = "#000";

                var startPoint = canvas.convertEffectToCoord({x:pointsCurve.get(0).x, y:pointsCurve.get(0).y});
                ctx.moveTo(startPoint.x,startPoint.y);
                for(var i=1; i<pointsCurve.count ; ++i){

                    var coordPoint = canvas.convertEffectToCoord({x: pointsCurve.get(i).x, y:pointsCurve.get(i).y});
                    ctx.bezierCurveTo(coordPoint.xBezier1, coordPoint.yBezier1, coordPoint.xBezier2,coordPoint.yBezier2,coordPoint.x,coordPoint.y);
                    //ctx.lineTo(coordPoint.x,coordPoint.y);
                }
                ctx.stroke();
            }
        }


        function drawKeys(ctx){
            if(pointsCurve.count > 1 ){
                ctx.fillStyle = "#aac";

                ctx.beginPath();
                ctx.moveTo(pointsCurve.get(0).x,pointsCurve.get(0).y);
                for(var i=0; i<pointsCurve.count ; ++i){
                    ctx.beginPath();
                    var coordPoint = canvas.convertEffectToCoord({x:pointsCurve.get(i).x, y:pointsCurve.get(i).y});
                    ctx.rect(coordPoint.x-10/2,coordPoint.y-10/2,10,10);
                    ctx.stroke();
                }
            }
        }

        function writeLegendFrame(ctx){
            ctx.beginPath();
            ctx.fillStyle="#188";
            ctx.fillText("Frames",canvas.width-40,canvas.height-40);

            var frameRange = ((pointsCurve.get(pointsCurve.count -1 ).x-pointsCurve.get(0).x)/canvas.xRangeGrid);
            for(var i=1; i<canvas.xRangeGrid ; ++i){
                var xFrame = canvas.width * i /canvas.xRangeGrid ;
                ctx.fillText(Math.ceil(frameRange*i )+ pointsCurve.get(0).x,xFrame,canvas.height);
              }
        }

        function writeLegendUnits(ctx){
            ctx.beginPath();
            ctx.fillStyle="#115"
            ctx.fillText("Units",20,10);

            var firstX = pointsCurve.get(0).x; var lastX = pointsCurve.get(pointsCurve.count-1).x;
            var firstY = pointsCurve.get(0).y; var lastY = pointsCurve.get(pointsCurve.count-1).y;
            var distanceYminMax = Math.abs(lastY-firstY);

            var unitFrame = distanceYminMax/canvas.yRangeGrid;
            for(var i=1; i<canvas.yRangeGrid ; ++i){
                var yUnit = Math.abs(((canvas.height)/(canvas.yRangeGrid)*i)-canvas.height);
                ctx.fillText(Math.ceil(unitFrame*i )+ Math.min(pointsCurve.get(0).y,pointsCurve.get(pointsCurve.count-1).y),20,yUnit);
            }
        }

        MouseArea{
            id:canvasMouseArea
            anchors.fill:parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            property bool dragging: false
            property bool pressed: false
            property int pointDraggingIndex: -1


            Text {
                id: toolTipPoint
                text: qsTr("")
                font.pixelSize: 12

                function display(txt,x,y){
                    toolTipPoint.x= x;
                    toolTipPoint.y= y;
                    toolTipPoint.text = txt;
                }

                function keepBox(){
                    var outWidthText = toolTipPoint.x + toolTipPoint.width - canvas.width;
                    var outHeightText = toolTipPoint.y - toolTipPoint.height;

                    if(outWidthText > 0)
                        toolTipPoint.x -= outWidthText;
                    if(outHeightText < 0)
                        toolTipPoint.y += outHeightText*-1;
                }
            }



            function logPoints(){
                console.log("Nb points: " + pointsCurve.count);
                for(var i=0; i< pointsCurve.count ; ++i){
                    console.log(pointsCurve.get(i).x +", "+pointsCurve.get(i).y);
                }
            }

            function isPointInRadius(mouse,pointToTest,radius){
                if( (mouse.x >= pointToTest.x -radius) && (mouse.x <= pointToTest.x +radius) &&
                    (mouse.y >= pointToTest.y -radius) && (mouse.y <= pointToTest.y +radius))
                        return true;

                return false;
            }

            function pointInSelection(mouse,radius){
                var i=0;
                var radiusSelect = 15; //px
                do{
                    ++i;
                    var pointToTest = canvas.convertEffectToCoord({x:pointsCurve.get(i).x, y:pointsCurve.get(i).y});
                }
                while(i != pointsCurve.count-1 && !isPointInRadius(mouse,pointToTest,radiusSelect))
                return i;
            }

            onClicked: {
                if(mouse.button == Qt.LeftButton){
                    if(!dragging){
                        if(pointsCurve.count > 1){
                            //verif si compris entre min et max frame
                            var lastPoint = pointsCurve.count-1;
                            var coordPointFirst = canvas.convertEffectToCoord({x:pointsCurve.get(0).x, y:pointsCurve.get(0).y});
                            var coordPointLast = canvas.convertEffectToCoord({x:pointsCurve.get(lastPoint).x, y:pointsCurve.get(lastPoint).y});

                            if(mouse.x > coordPointFirst.x && mouse.x < coordPointLast.x){
                                var indexToInsert = 0;
                                while(canvas.convertEffectToCoord({x:pointsCurve.get(indexToInsert).x}).x < mouse.x){
                                    indexToInsert++;
                                }

                                var pointToEffect = canvas.convertCoordToEffect({x:mouse.x, y:mouse.y})
                                pointsCurve.insert(indexToInsert, {
                                                       x:pointToEffect.x, y:pointToEffect.y,
                                                       xBezier1:pointToEffect.x, yBezier1:pointToEffect.y,
                                                       xBezier2:pointToEffect.x, yBezier2:pointToEffect.y});
                                canvas.requestPaint();
                           }
                        }
                    }

                    dragging = false;
                }
                else{
                    var i=pointInSelection(mouse,15);

                    if(i<pointsCurve.count -1 ){
                        pointsCurve.remove(i,1);
                        canvas.requestPaint();
                    }
                }
            }

            onPressed: {
                pressed=true;
            }
            onReleased: {
                pressed=false;
                pointDraggingIndex = -1;
            }

            onPositionChanged:  {
                var effectHover = canvas.convertCoordToEffect({x:mouse.x,y:mouse.y});
                toolTipPoint.display("Frame: "+ Math.ceil(effectHover.x)+", Value: "+Math.ceil(effectHover.y), mouse.x,mouse.y-15);
                toolTipPoint.keepBox();

                if(!pressed)
                    return;

                dragging = true;

                //first and last supposed fixed
                var i=pointInSelection(mouse,15);

                if(pointDraggingIndex != -1 && pointDraggingIndex != i){
                    return;
                }

                if(i<pointsCurve.count-1){
                        var pointNext = canvas.convertEffectToCoord({x:pointsCurve.get(i+1).x ,y:pointsCurve.get(i+1).y});
                        var pointPrevious = canvas.convertEffectToCoord({x:pointsCurve.get(i-1).x ,y:pointsCurve.get(i-1).y});

                        if(mouse.x >= pointNext.x)
                            pointsCurve.get(i).x = canvas.convertCoordToEffect({x:pointNext.x -1}).x;
                        else if(mouse.x <= pointPrevious.x)
                            pointsCurve.get(i).x = canvas.convertCoordToEffect({x:pointPrevious.x +1}).x;
                        else
                            pointsCurve.get(i).x = canvas.convertCoordToEffect({x:mouse.x}).x;

                        pointsCurve.get(i).y = canvas.convertCoordToEffect({y:mouse.y}).y;

                        canvas.requestPaint();
                        pointDraggingIndex=i;
                }
                else{
                    pressed = false;
                    toolTipPoint.text="";
                }
            }
        }

        Button{
            id: upXR
            text:"Size up Xrange";
            onClicked: {
                canvas.xRangeGrid += 1
                canvas.requestPaint()
            }
        }

        Button{
            id:dnXR
            anchors.left: upXR.right
            text:"Size down Xrange";
            onClicked: {
                canvas.xRangeGrid -= 1
                canvas.requestPaint()
            }
        }

        Button{
            id:upYR
            anchors.left: dnXR.right
            text:"Size up yrange";
            onClicked: {
                canvas.yRangeGrid += 1
                canvas.requestPaint()
            }
        }

        Button{
            id:dnYR
            anchors.left: upYR.right
            text:"Size down yrange";
            onClicked: {
                canvas.yRangeGrid -= 1
                canvas.requestPaint()
            }

        }

        onPaint:{
            var ctx = getContext('2d');
            ctx.reset();
            drawGrid(ctx);
            drawLine(ctx);
            drawKeys(ctx);
            writeLegendUnits(ctx)
            writeLegendFrame(ctx);
        }
    }

}
