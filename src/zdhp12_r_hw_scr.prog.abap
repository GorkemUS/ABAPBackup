*&---------------------------------------------------------------------*
*& Include          ZDHP12_R_HW_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME.

  SELECT-OPTIONS: s_vkorg FOR vbrk-vkorg NO-EXTENSION NO INTERVALS  .
  SELECT-OPTIONS: s_vbeln FOR vbrk-vbeln .
  SELECT-OPTIONS: s_fkdat FOR vbrk-fkdat .
  SELECT-OPTIONS: s_matnr FOR vbrp-matnr MODIF ID c1.


SELECTION-SCREEN END OF BLOCK a1 .


SELECTION-SCREEN BEGIN OF BLOCK a2 WITH FRAME.

  SELECTION-SCREEN PUSHBUTTON 1(20) pbutton USER-COMMAND pushbutton.
  SELECTION-SCREEN FUNCTION KEY 1.
  SELECTION-SCREEN FUNCTION KEY 2.
  PARAMETERS check AS CHECKBOX USER-COMMAND c1.

SELECTION-SCREEN END OF BLOCK a2 .


INITIALIZATION.

  pbutton = 'Edit Invoice'.
  sscrfields-functxt_01 = '@0Z@ Checkbox Doldur'.
  sscrfields-functxt_02 = '@0Z@ Checkbox Kaldır'.


AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
*    IF screen-group4 = '004'.
    IF screen-group1 = 'C1'.
      IF check = 'X'.
        screen-active = '0'.
      ELSE.
        screen-active = '1'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


AT SELECTION-SCREEN .
  IF sscrfields-ucomm = 'FC01'.
    check = 'X'.
    IF check = 'X'.
      sscrfields-ucomm = 'FC01'.
    ENDIF.
  ENDIF.

  IF sscrfields-ucomm = 'FC02'.
    check = ' '.
    IF check = ' '.
      sscrfields-ucomm = 'FC02'.
    ENDIF.
  ENDIF.



  CASE sy-ucomm.
    WHEN 'PUSHBUTTON'.
      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
        EXPORTING
          action                       = 'U'
*         CORR_NUMBER                  = '          '
*         GENERATE_MAINT_TOOL_IF_MISSING       = ' '
*         SHOW_SELECTION_POPUP         = ' '
          view_name                    = 'ZDYP12_T_FATURA'
*         NO_WARNING_FOR_CLIENTINDEP   = ' '
*         RFC_DESTINATION_FOR_UPGRADE  = ' '
*         CLIENT_FOR_UPGRADE           = ' '
*         VARIANT_FOR_SELECTION        = ' '
*         COMPLEX_SELCONDS_USED        = ' '
*         CHECK_DDIC_MAINFLAG          = ' '
*         SUPPRESS_WA_POPUP            = ' '
*                  TABLES
*         DBA_SELLIST                  =
*         EXCL_CUA_FUNCT               =
        EXCEPTIONS
          client_reference             = 1
          foreign_lock                 = 2
          invalid_action               = 3
          no_clientindependent_auth    = 4
          no_database_function         = 5
          no_editor_function           = 6
          no_show_auth                 = 7
          no_tvdir_entry               = 8
          no_upd_auth                  = 9
          only_show_allowed            = 10
          system_failure               = 11
          unknown_field_in_dba_sellist = 12
          view_not_found               = 13
          maintenance_prohibited       = 14
          OTHERS                       = 15.
      IF sy-subrc IS NOT INITIAL.
        MESSAGE 'Bozuk buton' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.
