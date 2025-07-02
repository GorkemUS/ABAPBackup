CLASS zgg_ce_websrv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_rap_query_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zgg_ce_websrv IMPLEMENTATION.

  METHOD if_rap_query_provider~select.
    DATA: lr_proxy TYPE REF TO zggco_yzft_fm,
          input    TYPE zggyzft_fm,
          output   TYPE zggyzft_fmresponse,
          ls_item  TYPE zggrsparams,
          iv_input TYPE char40.

    DATA: ls_leagues    TYPE zgg_s_league1,
          ls_leaguestr  TYPE zgg_s_league,
          ls_custentity TYPE zgg_ce_ws,
          lt_custentity TYPE TABLE OF zgg_ce_ws,
          lt_result     TYPE TABLE OF zgg_ce_ws,
          lt_filtered   TYPE TABLE OF zgg_ce_ws.



    iv_input = 'LIG'.

    input-iv_selection = iv_input.
*    IF iv_input = 'LIG'.
*      ls_item-selname = 'COUNTRY'.
*      ls_item-sign    = 'I'.
*      ls_item-option  = 'EQ'.
*      ls_item-low     = 'GB'.
*      APPEND ls_item TO input-it_rsparams-item.
*    ENDIF.

    TRY.
        CREATE OBJECT lr_proxy
          EXPORTING
            logical_port_name = 'ZPORT1'.

        CALL METHOD lr_proxy->yzft_fm
          EXPORTING
            input  = input
          IMPORTING
            output = output.

      CATCH cx_ai_system_fault.
    ENDTRY.


    CALL TRANSFORMATION zgg_transleague
        SOURCE XML output-ev_xml
        RESULT response = ls_leagues.


    LOOP AT ls_leagues-leagues INTO DATA(ls_str)." WHERE country = 'GB'.
      APPEND CORRESPONDING #( ls_str ) TO lt_custentity.
    ENDLOOP.

    SORT lt_custentity BY country id ASCENDING.

    DATA(lo_paging) = io_request->get_paging( ).
    DATA(lv_sort) = io_request->get_sort_elements( ).
    DATA(lv_offset) = lo_paging->get_offset( ).
    DATA(lv_page_size) = lo_paging->get_page_size( ).
    DATA(lv_elements) = io_request->get_requested_elements( ).
    DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                                ELSE lv_page_size ).
    TRY.
        DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        CLEAR lt_filter.
    ENDTRY.
    IF line_exists( lt_filter[ name = 'COUNTRY' ] ) .
      DATA(lt_range_country) = lt_filter[ name = 'COUNTRY' ]-range.
    ENDIF.

    lv_max_rows = lv_offset + lv_page_size.
    IF lv_offset > 0.
      lv_offset = lv_offset + 1.
    ENDIF.

    LOOP AT lt_custentity INTO DATA(ls_entity) WHERE country IN lt_range_country.
      APPEND ls_entity TO lt_filtered.
    ENDLOOP.


    LOOP AT lt_filtered ASSIGNING FIELD-SYMBOL(<fs_paging>) FROM lv_offset TO lv_max_rows.

      APPEND <fs_paging> TO lt_result.

    ENDLOOP.

    IF io_request->is_total_numb_of_rec_requested(  ).
      io_response->set_total_number_of_records( iv_total_number_of_records = lines( lt_custentity ) ).
    ENDIF.

    IF io_request->is_data_requested(  ).
      io_response->set_data( it_data = lt_result ).
    ENDIF.


  ENDMETHOD.


ENDCLASS.
