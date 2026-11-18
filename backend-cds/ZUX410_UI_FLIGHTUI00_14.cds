*&---------------------------------------------------------------------*
*& CDS View  : ZUX410_UI_FLIGHTUI00_14  (projection view)
*& Synced from Eclipse/ADT on: 2026-11-18
*& Note       : Exposed via Service Definition ZUX410_SD_FLIGHTUI00_14
*&              / Service Binding ZUX410_SB_FLIGHTUI00_14 as entity set
*&              "user" (the Fiori app's main entity set).
*&              @Metadata.ignorePropagatedAnnotations: true means all
*&              @UI/@Search/@Semantics annotations must be re-declared
*&              here; they do NOT propagate from the base view.
*&
*& Changes 2026-11-18 (discount feature):
*&   - provider contract transactional_query (required for the
*&     projection behavior definition ZUX410_UI_FLIGHTUI00_14.bdef,
*&     which exposes action applyDiscount on "user")
*&   - _Bookings removed (a composition in a transactional projection
*&     must be redirected to a booking projection, which doesn't exist;
*&     it was never exposed in the service anyway)
*&   - "Pricing" object page section (field group 'pricing')
*&   - Apply Discount button moved to the object page header
*&     (@UI.identification #FOR_ACTION)
*&   - Original Price / Discounted Price columns in the list
*&   - labels on seatdata / seatdata2 facets (were "undefined" tabs)
*&---------------------------------------------------------------------*

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true

@UI.headerInfo: {
  typeName: 'Flight',
  typeNamePlural: 'Flights',
  title: { value: 'carrid' },
  description: { value: 'carrname' }
}

define root view entity ZUX410_UI_FLIGHTUI00_14
  provider contract transactional_query
  as projection on ZUX410_C_FLIGHTUI00_14
{
  @UI.facet: [
    { purpose: #HEADER,   type: #FIELDGROUP_REFERENCE, targetQualifier: 'flightinfo', position: 10 },
    { purpose: #HEADER,   type: #FIELDGROUP_REFERENCE, targetQualifier: 'seatinfo',   position: 20 },
    { purpose: #STANDARD, type: #FIELDGROUP_REFERENCE, targetQualifier: 'pricing',
      id: 'pricing', label: 'Pricing', position: 5 },
    { purpose: #STANDARD, type: #FIELDGROUP_REFERENCE, targetQualifier: 'seatdata',
      label: 'Seat Capacity',  position: 10 },
    { purpose: #STANDARD, type: #FIELDGROUP_REFERENCE, targetQualifier: 'seatdata2',
      label: 'Seat Occupancy', position: 20 },
    { purpose: #STANDARD, id: 'seat1', label: 'Seatsinfo 1', type: #COLLECTION, position: 30 },
    { purpose: #STANDARD, id: 'seat2', label: 'Seatsinfo 2', type: #COLLECTION, position: 40 }
  ]

  @UI.lineItem: [{ position: 10 }]
  key carrid,

  @UI.lineItem: [{ position: 20 }]
  key connid,

  @UI.identification: [{ position: 20 }]
  @UI.lineItem:       [{ position: 30 }]
  key fldate,

  @UI.identification:           [{ position: 10 }]
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold:   0.7
  @UI.selectionField:           [{ position: 10 }]
  @UI.lineItem: [
    { position: 40 },
    { type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'Airline', semanticObjectAction: 'displayFactSheet' }
  ]
  carrname,

  @UI.identification: [{ position: 30 }]
  @UI.fieldGroup:     [{ qualifier: 'flightinfo', position: 10 }]
  @UI.selectionField: [{ position: 20 }]
  @UI.lineItem:       [{ position: 70 }]
  cityfrom,

  @UI.identification: [{ position: 40 }]
  @UI.fieldGroup:     [{ qualifier: 'flightinfo', position: 20 }]
  @UI.selectionField: [{ position: 30 }]
  @UI.lineItem:       [{ position: 80 }]
  cityto,

  @UI.identification: [{ position: 50 }]
  @UI.lineItem:       [{ position: 50, importance: #HIGH }]
  planetype,

  /* ---- Pricing ---- */

  @Semantics.amount.currencyCode: 'currency'
  @UI.lineItem:       [{ position: 60, importance: #HIGH, criticality: 'PriceCriticality', label: 'Original Price' }]
  @UI.fieldGroup:     [{ qualifier: 'pricing', position: 10, label: 'Original Price', criticality: 'PriceCriticality' }]
  @UI.identification: [{ type: #FOR_ACTION, dataAction: 'applyDiscount', label: 'Apply Discount' }]
  price,

  @UI.lineItem:   [{ position: 65, importance: #HIGH, label: 'Discounted Price' }]
  @UI.fieldGroup: [{ qualifier: 'pricing', position: 20, label: 'Discounted Price' }]
  DiscountedPriceText,

  @UI.fieldGroup: [{ qualifier: 'pricing', position: 30, label: 'Discount %' }]
  DiscountPercent,

  @UI.hidden: true
  @Semantics.amount.currencyCode: 'currency'
  DiscountedPrice,

  currency,

  @UI.hidden: true
  PriceCriticality,

  @UI.lineItem: [{ position: 90, importance: #MEDIUM }]
  @Semantics.amount.currencyCode: 'currency'
  Total,

  /* ---- Seats ---- */

  @UI.fieldGroup: [{ qualifier: 'seatinfo', position: 10 }]
  seatsmax,

  @UI.fieldGroup: [{ qualifier: 'seatinfo', position: 20 }]
  seatsocc,

  @UI.fieldGroup: [{ qualifier: 'flightinfo', position: 30 }]
  url,

  @Semantics.amount.currencyCode: 'currency'
  paymentsum,

  @UI.fieldGroup: [{ qualifier: 'seatdata', position: 10 }]
  seatsmax_b,

  @UI.fieldGroup: [{ qualifier: 'seatdata2', position: 10 }]
  seatsocc_b,

  @UI.fieldGroup: [{ qualifier: 'seatdata', position: 20 }]
  seatsmax_f,

  @UI.fieldGroup: [{ qualifier: 'seatdata2', position: 10 }]
  seatsocc_f

  /* _Bookings intentionally not projected - see header note */
}
