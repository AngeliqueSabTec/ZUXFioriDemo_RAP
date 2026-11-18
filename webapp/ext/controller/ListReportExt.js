sap.ui.define([
    "sap/ui/core/Fragment",
    "sap/ui/model/json/JSONModel",
    "sap/ui/model/Filter",
    "sap/ui/model/FilterOperator",
    "sap/m/MessageBox",
    "sap/m/MessageToast"
], function (Fragment, JSONModel, Filter, FilterOperator, MessageBox, MessageToast) {
    "use strict";

    // Module-level state: there is only ever one "Open Bookings" dialog open at a time.
    var oAnchor = null;        // the ListReport view, used to reach models
    var oRoutingApi = null;    // extensionAPI.routing, used to navigate to a Flight context
    var oDialog = null;
    var oDialogModel = null;
    var oNavContainer = null;
    var oFlightsPage = null;
    var oCreatePage = null;

    function toIsoDate(oDate) {
        var iYear = oDate.getFullYear();
        var iMonth = oDate.getMonth() + 1;
        var iDay = oDate.getDate();
        return iYear + "-" + (iMonth < 10 ? "0" : "") + iMonth + "-" + (iDay < 10 ? "0" : "") + iDay;
    }

    function getText(sKey, aArgs) {
        return oAnchor.getModel("i18n").getResourceBundle().getText(sKey, aArgs);
    }

    function closeDialog() {
        if (oDialog) {
            oDialog.close();
        }
    }

    function navigateToContext(oContext) {
        closeDialog();
        oRoutingApi.navigate(oContext);
    }

    var oExtensionActions = {

        // ---------------------------------------------------------------
        // Entry point: table toolbar action "Open Bookings"
        // ---------------------------------------------------------------
        onOpenBookings: function () {
            oAnchor = this.routing.getView();
            oRoutingApi = this.routing;

            oDialogModel = new JSONModel({
                dateChosen: false,
                selectedDate: null,
                selectedDateDisplay: "",
                busy: false,
                flights: [],
                noFlightsText: "",
                newFlight: {
                    Carrid: "",
                    Connid: "",
                    Fldate: "",
                    Planetype: "",
                    Price: 0,
                    CurrencyCode: "USD",
                    SeatsMax: 0
                }
            });

            Fragment.load({
                name: "zflights4.flights4.ext.fragment.OpenBookingsDialog",
                controller: oExtensionActions
            }).then(function (oLoadedDialog) {
                oDialog = oLoadedDialog;
                oNavContainer = oDialog.getContent()[0];
                oFlightsPage = oNavContainer.getPages()[1];
                oCreatePage = oNavContainer.getPages()[2];

                oAnchor.addDependent(oDialog);
                oDialog.setModel(oDialogModel, "ob");
                oDialog.open();
            });
        },

        // ---------------------------------------------------------------
        // Step 1: calendar
        // ---------------------------------------------------------------
        onCalendarDateSelected: function (oEvent) {
            var aSelectedDates = oEvent.getSource().getSelectedDates();
            var oDate = aSelectedDates.length ? aSelectedDates[0].getStartDate() : null;
            var sIsoDate = oDate ? toIsoDate(oDate) : null;

            oDialogModel.setProperty("/selectedDate", sIsoDate);
            oDialogModel.setProperty("/selectedDateDisplay", oDate ? oDate.toLocaleDateString() : "");
            oDialogModel.setProperty("/dateChosen", !!sIsoDate);
        },

        // ---------------------------------------------------------------
        // Step 2: flights available on the chosen date
        // ---------------------------------------------------------------
        onNavigateToFlightsPage: function () {
            var sIsoDate = oDialogModel.getProperty("/selectedDate");
            var oModel = oAnchor.getModel();

            oDialogModel.setProperty("/busy", true);
            oDialogModel.setProperty("/newFlight/Fldate", sIsoDate);
            oNavContainer.to(oFlightsPage);

            var oFilter = new Filter("fldate", FilterOperator.EQ, sIsoDate);
            var oListBinding = oModel.bindList("/user", undefined, [], [oFilter]);

            oListBinding.requestContexts(0, 100).then(function (aContexts) {
                var aFlights = aContexts.map(function (oContext) {
                    var oData = oContext.getObject();
                    var iMax = oData.seatsmax || 0;
                    var iOcc = oData.seatsocc || 0;
                    var iAvailable = iMax - iOcc;
                    oData.SeatsAvailableText = getText("openBookingsSeatsAvailable", [iAvailable, iMax]);
                    // kept alongside the plain data so the row can navigate back to its real context
                    oData.__context = oContext;
                    return oData;
                });

                oDialogModel.setProperty("/flights", aFlights);
                oDialogModel.setProperty("/noFlightsText", getText("openBookingsNoFlights", [oDialogModel.getProperty("/selectedDateDisplay")]));
                oDialogModel.setProperty("/busy", false);
            }).catch(function (oError) {
                oDialogModel.setProperty("/flights", []);
                oDialogModel.setProperty("/noFlightsText", getText("openBookingsNoFlights", [oDialogModel.getProperty("/selectedDateDisplay")]));
                oDialogModel.setProperty("/busy", false);
                MessageBox.error(getText("openBookingsLoadError") + (oError && oError.message ? ": " + oError.message : ""));
            });
        },

        onFlightItemPress: function (oEvent) {
            var oData = oEvent.getSource().getBindingContext("ob").getObject();
            navigateToContext(oData.__context);
        },

        // ---------------------------------------------------------------
        // Step 3: no flight found -> create one
        // ---------------------------------------------------------------
        onNavigateToCreatePage: function () {
            oNavContainer.to(oCreatePage);
        },

        onSaveNewFlight: function () {
            var oModel = oAnchor.getModel();
            var oNewFlight = oDialogModel.getProperty("/newFlight");

            if (!oNewFlight.Carrid || !oNewFlight.Connid) {
                MessageBox.warning(getText("openBookingsFieldCarrier") + " / " + getText("openBookingsFieldConnection"));
                return;
            }

            oDialogModel.setProperty("/busy", true);

            var oListBinding = oModel.bindList("/user");
            var oNewContext;

            try {
                oNewContext = oListBinding.create({
                    carrid: String(oNewFlight.Carrid).toUpperCase(),
                    connid: String(oNewFlight.Connid),
                    fldate: oNewFlight.Fldate,
                    planetype: oNewFlight.Planetype,
                    price: parseFloat(oNewFlight.Price) || 0,
                    currency: oNewFlight.CurrencyCode,
                    seatsmax: parseInt(oNewFlight.SeatsMax, 10) || 0,
                    seatsocc: 0
                });
            } catch (oError) {
                oDialogModel.setProperty("/busy", false);
                MessageBox.error(getText("openBookingsCreateError") + (oError && oError.message ? ": " + oError.message : ""));
                return;
            }

            oNewContext.created().then(function () {
                oDialogModel.setProperty("/busy", false);
                MessageToast.show(getText("openBookingsCreateSuccess"));
                navigateToContext(oNewContext);
            }).catch(function (oError) {
                oDialogModel.setProperty("/busy", false);
                MessageBox.error(getText("openBookingsCreateError") + (oError && oError.message ? ": " + oError.message : ""));
            });
        },

        // ---------------------------------------------------------------
        // Shared dialog navigation / lifecycle
        // ---------------------------------------------------------------
        onNavigateBack: function () {
            oNavContainer.back();
        },

        onOpenBookingsCancel: function () {
            closeDialog();
        },

        onOpenBookingsDialogAfterClose: function (oEvent) {
            oEvent.getSource().destroy();
            oDialog = null;
            oDialogModel = null;
            oNavContainer = null;
            oFlightsPage = null;
            oCreatePage = null;
        }
    };

    return oExtensionActions;
});
