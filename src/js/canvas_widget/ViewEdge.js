define(function () {

    function makeViewEdge(type, arrowType,shapeType,color,overlay,overlayPosition,overlayRotate,attributes, edgeType, conditions, conj){

        function ViewEdge(id, source, target){
            var viewEdge = new edgeType(id, source, target);
            viewEdge.restyle(arrowType, color, shapeType, overlay, overlayPosition, overlayRotate, attributes);
            viewEdge.setCurrentViewType(type);
            return viewEdge;
        }

        ViewEdge.getConditions = function(){
            return conditions;
        };

        ViewEdge.getConditionConj = function(){
            return conj;
        };

        ViewEdge.getArrowType = function(){
            return arrowType;
        };
        ViewEdge.getShapeType = function(){
            return shapeType;
        };
        ViewEdge.getColor = function(){
            return color;
        };
        ViewEdge.getOverlay = function(){
            return overlay;
        };
        ViewEdge.getOverlayPosition = function(){
            return overlayPosition;
        };
        ViewEdge.getOverlayRotate = function(){
            return overlayRotate;
        };
        ViewEdge.getAttributes = function(){
            return attributes;
        };
        ViewEdge.getTargetEdgeType = function(){
          return edgeType;
        };

        return ViewEdge;
    }
    return makeViewEdge;
});