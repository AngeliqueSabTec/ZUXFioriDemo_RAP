*&---------------------------------------------------------------------*
*& Database Table : ZUX410_FLT_DISC  (applied flight discounts)
*& Synced from Eclipse/ADT on: 2026-11-18
*& Note       : One row per flight that had "Apply Discount" pressed.
*&              Written only by the saver (lsc_zux410_c_flightui00_14 ->
*&              save_modified) of ZBP_UX410_C_FLIGHTUI00_14.
*&              Read by ZUX410_C_FLIGHTUI00_14 via association _Disc.
*&              SFLIGHT-PRICE is never changed, so the original price
*&              stays available next to the discounted one.
*&              Rules: price >= 450 and future flight; > 1000 -> 15%,
*&              otherwise 10%; one discount per flight.
*&---------------------------------------------------------------------*

@EndUserText.label : 'UX410 Applied flight discounts'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zux410_flt_disc {
  key client   : abap.clnt not null;
  key carrid   : s_carr_id not null;
  key connid   : s_conn_id not null;
  key fldate   : s_date not null;
  discount_pct : abap.int1;
  @Semantics.amount.currencyCode : 'zux410_flt_disc.currency'
  disc_price   : s_price;
  currency     : s_currcode;
  applied_at   : timestampl;
}
