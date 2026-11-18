sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension"
], function (ControllerExtension) {
    "use strict";

    /**
     * List Report controller extension.
     *
     * Fiori elements (UI5 1.96) keeps the list table's cached rows when the user
     * navigates back from the Object Page. A bound action executed on the Object
     * Page (e.g. applyDiscount) therefore does not show up in the list until the
     * user presses "Go" again. This extension refreshes the OData model whenever
     * the user returns from the Object Page to the List Report.
     */
    return ControllerExtension.extend("zflights4.flights4.ext.controller.ListReportRefresh", {

        override: {
            onInit: function () {
                var oRouter = this.base.getAppComponent().getRouter();
                this._bReturningFromObjectPage = false;

                oRouter.getRoute("FlightObjectPage").attachPatternMatched(function () {
                    this._bReturningFromObjectPage = true;
                }, this);

                oRouter.getRoute("FlightList").attachPatternMatched(this._onListRouteMatched, this);
            }
        },

        _onListRouteMatched: function () {
            if (!this._bReturningFromObjectPage) {
                return;
            }
            this._bReturningFromObjectPage = false;

            var oModel = this.base.getView().getModel();
            if (oModel && !oModel.hasPendingChanges()) {
                oModel.refresh();
            }
        }
    });
});
