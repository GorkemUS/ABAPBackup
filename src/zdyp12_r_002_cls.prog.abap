*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_002_CLS
*&---------------------------------------------------------------------*

CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: get_data,
      display_alv.


ENDCLASS.

CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD get_data.

    SELECT * FROM vbap INTO CORRESPONDING FIELDS OF TABLE @gt_data UP TO 50 ROWS.


  ENDMETHOD.

  METHOD display_alv.

    DATA: lt_fieldcatalog TYPE TABLE OF lvc_s_fcat,
          ls_layout       TYPE lvc_s_layo.

    IF grid IS NOT BOUND.
      CREATE OBJECT grid
        EXPORTING
          i_parent = cl_gui_container=>screen0.


      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
*         I_BUFFER_ACTIVE        =
          i_structure_name       = 'ZDYP12_S_002'
*         I_CLIENT_NEVER_DISPLAY = 'X'
          i_bypassing_buffer     = 'X'
*         I_INTERNAL_TABNAME     =
        CHANGING
          ct_fieldcat            = lt_fieldcatalog[]
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.


      LOOP AT lt_fieldcatalog ASSIGNING FIELD-SYMBOL(<ls_fieldcatalog>).
        IF <ls_fieldcatalog>-fieldname = 'MATNR'.
          <ls_fieldcatalog>-scrtext_s = 'deneme'.
          <ls_fieldcatalog>-scrtext_m = 'deneme'.
          <ls_fieldcatalog>-scrtext_l = 'deneme'.
        ENDIF.
        IF <ls_fieldcatalog>-fieldname = 'MATNR'.
          <ls_fieldcatalog>-emphasize = 'C301'.
        ENDIF.

      ENDLOOP.


      CALL METHOD grid->set_table_for_first_display
        EXPORTING
          is_layout       = ls_layout
          i_save          = 'X'
        CHANGING
          it_fieldcatalog = lt_fieldcatalog
          it_outtab       = gt_data.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
