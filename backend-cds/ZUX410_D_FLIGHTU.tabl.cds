*&---------------------------------------------------------------------*
*& Database Table : ZUX410_D_FLIGHTU  (draft table)
*& Synced from Eclipse/ADT on: 2026-11-18
*& Note       : Currently UNUSED — draft was removed from the active
*&              behavior definition because activation kept failing
*&              (see notes in ZUX410_C_FLIGHTUI00_14.bdef below).
*&              Kept here in case draft is revisited later. Table name
*&              is 16 chars (classic DDIC transparent table limit),
*&              which is why it doesn't match "zux410_d_flightui00".
*&---------------------------------------------------------------------*

@EndUserText.label : 'Draft table for entity ZUX410_C_FLIGHTUI00_14'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zux410_d_flightu {
  key mandt         : mandt not null;
  key carrid        : s_carr_id not null;
  key connid        : s_conn_id not null;
  key fldate        : s_date not null;
  carrname          : s_carrname;
  cityfrom          : s_from_cit;
  cityto            : s_to_city;
  planetype         : s_planetye;
  @Semantics.amount.currencyCode : 'zux410_d_flightu.currency'
  price             : s_price;
  currency          : s_currcode;
  pricecriticality  : abap.int1;
  pricefieldcontrol : abap.int1;
  total             : abap.dec(25,2);
  seatsmax          : s_seatsmax;
  seatsocc          : s_seatsocc;
  url               : s_carrurl;
  @Semantics.amount.currencyCode : 'zux410_d_flightu.currency'
  paymentsum        : s_sum;
  seatsmax_b        : s_smax_b;
  seatsocc_b        : s_socc_b;
  seatsmax_f        : s_smax_f;
  seatsocc_f        : s_socc_f;
  "%admin"          : include structure sych_bdl_draft_admin_inc;
}
