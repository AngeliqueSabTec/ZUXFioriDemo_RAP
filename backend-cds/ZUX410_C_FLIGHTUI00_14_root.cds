*&---------------------------------------------------------------------*
*& CDS View  : ZUX410_C_FLIGHTUI00_14  (root view entity)
*& Synced from Eclipse/ADT on: 2026-11-18
*& Note       : This is the actual RAP root view entity as it exists
*&              in the S4D system today. It differs from the older
*&              ZUX410_C_FLIGHTUI00_14.cds already in this repo/root,
*&              which appears to be an earlier/different demo snapshot.
*&---------------------------------------------------------------------*

@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'UX410 Flight UI'

@UI.headerInfo.typeName: 'Flight'
@UI.headerInfo.typeNamePlural: 'Flights'
@UI.headerInfo.title.value: 'carrid'
@UI.headerInfo.description.value: 'carrname'

@Search.searchable: true

define root view entity ZUX410_C_FLIGHTUI00_14
  as select from sflight as sf

  association to scarr as sc
    on sf.carrid = sc.carrid

  association to spfli as sp
    on  sf.carrid = sp.carrid
    and sf.connid = sp.connid

  composition [0..*] of ZUX410_C_BOOKINGUI00 as _Bookings
{
  @UI.facet: [
    { purpose: #HEADER,   type: #FIELDGROUP_REFERENCE, targetQualifier: 'flightinfo', position: 10 },
    { purpose: #HEADER,   type: #FIELDGROUP_REFERENCE, targetQualifier: 'seatinfo',    position: 20 },
    { purpose: #STANDARD, type: #FIELDGROUP_REFERENCE, targetQualifier: 'seatdata',    position: 10 },
    { purpose: #STANDARD, type: #FIELDGROUP_REFERENCE, targetQualifier: 'seatdata2',   position: 20 },
    { purpose: #STANDARD, id: 'seat1', label: 'Seatsinfo 1', type: #COLLECTION, position: 30 },
    { purpose: #STANDARD, id: 'seat2', label: 'Seatsinfo 2', type: #COLLECTION, position: 40 }
  ]

  @UI.lineItem: [{ position: 10 }]
  key sf.carrid,

  @UI.lineItem: [{ position: 20 }]
  key sf.connid,

  @UI.identification: [{ position: 20 }]
  @UI.lineItem:       [{ position: 30 }]
  key sf.fldate,

  @UI.identification:           [{ position: 10 }]
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold:   0.7
  @UI.selectionField:           [{ position: 10 }]
  @UI.lineItem: [
    { position: 40 },
    { type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'Airline', semanticObjectAction: 'displayFactSheet' }
  ]
  sc.carrname,

  // BOUND action — needs a selected row
  // @UI.lineItem: [{ type: #FOR_ACTION, dataAction: 'cancelFlight' }]
  // UNBOUND action — always available in the toolbar
  //@UI.lineItem: [{ type: #FOR_ACTION, dataAction: 'openBookingWindow' }]

  @UI.identification: [{ position: 30 }]
  @UI.fieldGroup:     [{ qualifier: 'flightinfo', position: 10 }]
  @UI.selectionField: [{ position: 20 }]
  @UI.lineItem:       [{ position: 70 }]
  sp.cityfrom,

  @UI.identification: [{ position: 40 }]
  @UI.fieldGroup:     [{ qualifier: 'flightinfo', position: 20 }]
  @UI.selectionField: [{ position: 30 }]
  @UI.lineItem:       [{ position: 80 }]
  sp.cityto,

  @UI.identification: [{ position: 50 }]
  @UI.lineItem:       [{ position: 50, importance: #HIGH }]
  sf.planetype,

  @Semantics.amount.currencyCode: 'currency'
  @UI.lineItem: [
    { position: 60, importance: #LOW, criticality: 'PriceCriticality' },
    { type: #FOR_ACTION, dataAction: 'applyDiscount', label: 'Apply 10% Discount' }
  ]
  sf.price,

  sf.currency,

  @UI.hidden: true
  case
    when sf.price <= 500  then 3
    when sf.price <= 1000 then 2
    else 1
  end as PriceCriticality,

  @UI.hidden: true
  case
    when sf.fldate < $session.system_date then 1   /* Read-Only */
    else                                       3    /* Optional  */
  end as PriceFieldControl,

  @UI.lineItem: [{ position: 90, importance: #MEDIUM }]
  @Semantics.amount.currencyCode: 'currency'
  cast( sf.price as abap.dec( 15, 2 ) ) * sf.seatsocc as Total,

  @UI.fieldGroup: [{ qualifier: 'seatinfo', position: 10 }]
  sf.seatsmax,

  @UI.fieldGroup: [{ qualifier: 'seatinfo', position: 20 }]
  sf.seatsocc,

  @UI.fieldGroup: [{ qualifier: 'flightinfo', position: 30 }]
  sc.url,

  @Semantics.amount.currencyCode: 'currency'
  sf.paymentsum,

  @UI.fieldGroup: [{ qualifier: 'seatdata', position: 10 }]
  sf.seatsmax_b,

  @UI.fieldGroup: [{ qualifier: 'seatdata2', position: 10 }]
  sf.seatsocc_b,

  @UI.fieldGroup: [{ qualifier: 'seatdata', position: 20 }]
  sf.seatsmax_f,

  @UI.fieldGroup: [{ qualifier: 'seatdata2', position: 10 }]
  sf.seatsocc_f,

  _Bookings
}
