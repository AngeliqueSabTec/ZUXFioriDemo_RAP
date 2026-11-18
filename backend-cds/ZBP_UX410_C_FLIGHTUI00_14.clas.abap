" Synced from Eclipse/ADT on: 2026-11-18
" Behavior implementation class for ZUX410_C_FLIGHTUI00_14 (alias Flight)

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
        FIELDS ( Fldate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_flight).

    result = VALUE #( FOR ls_flight IN lt_flight
      ( %tky                  = ls_flight-%tky
        %field-Price          = COND #( WHEN ls_flight-Fldate < cl_abap_context_info=>get_system_date( )
                                         THEN if_abap_behv=>fc-f-read_only
                                         ELSE if_abap_behv=>fc-f-unrestricted )
        %action-applyDiscount = COND #( WHEN ls_flight-Fldate < cl_abap_context_info=>get_system_date( )
                                         THEN if_abap_behv=>fc-o-disabled
                                         ELSE if_abap_behv=>fc-o-enabled ) ) ).

  ENDMETHOD.

  METHOD applyDiscount.

    READ ENTITIES OF zux410_c_flightui00_14 IN LOCAL MODE
      ENTITY Flight
        FIELDS ( Price )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_flight).

    MODIFY ENTITIES OF zux410_c_flightui00_14 IN LOCAL MODE
      ENTITY Flight
        UPDATE FIELDS ( Price )
        WITH VALUE #( FOR ls_flight IN lt_flight
                       ( %tky  = ls_flight-%tky
                         Price = ls_flight-Price * '0.9' ) )
      FAILED   DATA(lt_failed)
      REPORTED DATA(lt_reported).

    result = VALUE #( FOR ls_key IN keys ( %tky = ls_key-%tky ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.

    result = VALUE #( FOR ls_key IN keys
      ( %tky                  = ls_key-%tky
        %update                = if_abap_behv=>auth-allowed
        %delete                = if_abap_behv=>auth-allowed
        %action-applyDiscount  = if_abap_behv=>auth-allowed ) ).

  ENDMETHOD.

ENDCLASS.
