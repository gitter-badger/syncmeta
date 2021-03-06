define([
    'jqueryui',
    'lodash',
    'iwcw',
    'activity_widget/Activity'
],/** @lends EdgeDeleteActivity */function($,_,IWCW,Activity) {

    EdgeDeleteActivity.TYPE = "EdgeDeleteActivity";

    EdgeDeleteActivity.prototype = new Activity();
	EdgeDeleteActivity.prototype.constructor = EdgeDeleteActivity;
    /**
     * Activity representing the deletion of an edge
     * @class activity_widget.EdgeDeleteActivity
     * @memberof activity_widget
     * @extends activity_widget.Activity
     * @param {string} entityId Entity id of the entity this activity works on
     * @param {string} sender JabberId of the user who issued this activity
     * @param {string} text Text of this activity which is displayed in the activity widget
     * @constructor
     */
    function EdgeDeleteActivity(entityId,sender,text){
        Activity.call(this,entityId,sender,text);
    }

    return EdgeDeleteActivity;

});
