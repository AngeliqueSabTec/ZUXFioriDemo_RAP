" Synced from Eclipse/ADT on: 2026-11-18
" Behavior implementation class for ZUX410_C_FLIGHTUI00_14 (alias Flight)
"
" Changes 2026-11-18 (discount feature):
"   - applyDiscount: price >= 450 and future flight only; > 1000 -> 15%,
"     otherwise 10%; one discount per flight. SFLIGHT-PRICE is NOT changed:
"     the discount is buffered (lcl_buffer) and written to ZUX410_FLT_DISC
"     by the saver. The action returns the full record (%param) so the
"     object page shows the new values straight away.
"   - get_instance_features: applyDiscount disabled for past flights,
"     price < 450, or already discounted.
"   - Saver lsc_zux410_c_flightui00_14 (needs "managed with additional
"     save" in the BDEF).
"
" ADT keeps the class in two tabs - both are below.

"======================================================================
" Tab: Global Class
"======================================================================
CLASS zbp_ux410_c_flightui00_14 DEFINITION
  PUBLIC
  ABSTRACT
  FINAL
  FOR BEHAVIOR OF zux410_c_flightui00_14.
ENDCLASS.

CLASS zbp_ux410_c_flightui00_14 IMPLEMENTATION.
ENDCLASS.

"======================================================================
" Tab: Local Types
"======================================================================

"----------------------------------------------------------------------
" Transactional buffer: discounts collected by the action, written by
" the saver during the save sequence (SFLIGHT-PRICE is never changed)
"----------------------------------------------------------------------
CLASS lcl_buffer DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-DATA mt_discounts TYPE STANDARD TABLE OF zux410_flt_disc WITH EMPTY KEY.
ENDCLASS.

"----------------------------------------------------------------------
" Handler
"----------------------------------------------------------------------
CLASS lhc_Flight DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Flight RESULT result.

    METHODS applyDiscount FOR MODIFY
      IMPORTING keys FOR ACTION Flight~applyDiscount RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Flight RESULT result.

ENDCLASS.

CLASS lhc_Flight IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF zux410_c_flightui00_14 IN LOCAL MODE
      ENTITY Flight
        FIELDS ( fldate price DiscountPercent )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_flight).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    result = VALUE #( FOR ls_flight IN lt_flight
      ( %tky                  = ls_flight-%tky
        %field-Price          = COND #( WHEN ls_flight-fldate < lv_today
                                        THEN if_abap_behv=>fc-f-read_only
                                        ELSE if_abap_behv=>fc-f-unrestricted )
        %action-applyDiscount = COND #( WHEN ls_flight-fldate < lv_today
                                          OR ls_flight-price  < 450
                                          OR ls_flight-DiscountPercent IS NOT INITIAL
                                        THEN if_abap_behv=>fc-o-disabled
                                        ELSE if_abap_behv=>fc-o-enabled ) ) ).

  ENDMETHOD.

  METHOD applyDiscount.

    DATA lv_ts TYPE timestampl.
    GET TIME STAMP FIELD lv_ts.
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    READ ENTITIES OF zux410_c_flightui00_14 IN LOCAL MODE
      ENTITY Flight
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_flight).

    LOOP AT lt_flight ASSIGNING FIELD-SYMBOL(<ls_flight>).

      " Rules: future flight, price >= 450, not discounted yet
      IF <ls_flight>-price < 450
         OR <ls_flight>-fldate < lv_today
         OR <ls_flight>-DiscountPercent IS NOT INITIAL.
        APPEND VALUE #( %tky = <ls_flight>-%tky ) TO failed-flight.
        APPEND VALUE #( %tky = <ls_flight>-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Flight is not eligible for a discount' ) )
               TO reported-flight.
        CONTINUE.
      ENDIF.

      " 15% above 1000, otherwise 10%
      DATA(lv_pct)   = COND int1( WHEN <ls_flight>-price > 1000 THEN 15 ELSE 10 ).
      DATA(lv_price) = CONV s_price( <ls_flight>-price * ( 100 - lv_pct ) / 100 ).

      APPEND VALUE #( carrid       = <ls_flight>-carrid
                      connid       = <ls_flight>-connid
                      fldate       = <ls_flight>-fldate
                      discount_pct = lv_pct
                      disc_price   = lv_price
                      currency     = <ls_flight>-currency
                      applied_at   = lv_ts )
             TO lcl_buffer=>mt_discounts.

      " Return new values immediately so the object page refreshes
      <ls_flight>-DiscountedPrice     = lv_price.
      <ls_flight>-DiscountPercent     = lv_pct.
      <ls_flight>-DiscountedPriceText = |{ lv_price } { <ls_flight>-currency }|.

      APPEND VALUE #( %tky   = <ls_flight>-%tky
                      %param = CORRESPONDING #( <ls_flight> ) ) TO result.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_authorizations.

    result = VALUE #( FOR ls_key IN keys
      ( %tky                  = ls_key-%tky
        %update               = if_abap_behv=>auth-allowed
        %delete               = if_abap_behv=>auth-allowed
        %action-applyDiscount = if_abap_behv=>auth-allowed ) ).

  ENDMETHOD.

ENDCLASS.

"----------------------------------------------------------------------
" Saver (requires "managed with additional save" in the BDEF)
"----------------------------------------------------------------------
CLASS lsc_zux410_c_flightui00_14 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified    REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_zux410_c_flightui00_14 IMPLEMENTATION.

  METHOD save_modified.
    IF lcl_buffer=>mt_discounts IS NOT INITIAL.
      MODIFY zux410_flt_disc FROM TABLE @lcl_buffer=>mt_discounts.
      CLEAR lcl_buffer=>mt_discounts.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
    CLEAR lcl_buffer=>mt_discounts.
  ENDMETHOD.

ENDCLASS.
