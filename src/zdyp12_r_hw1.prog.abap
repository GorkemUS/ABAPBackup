*&---------------------------------------------------------------------*
*& Report ZDYP12_R_ODEV2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdyp12_r_hw1.

INCLUDE ZDYP12_R_HW1_TOP.
INCLUDE ZDYP12_R_HW1_SCR.
INCLUDE ZDYP12_R_HW1_FORM.

START-OF-SELECTION.

  PERFORM get_data.

  IF gt_data[] IS NOT INITIAL.
    PERFORM alv_list.
  ELSE.
    MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*& Form VIEW_MAINTENANCE_CALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_TABNAME
*&---------------------------------------------------------------------*
FORM view_maintenance_call  USING    p_tabname.

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
        EXPORTING
          action                       = 'U'
*         CORR_NUMBER                  = '          '
*         GENERATE_MAINT_TOOL_IF_MISSING       = ' '
*         SHOW_SELECTION_POPUP         = ' '
          view_name                    = p_tabname
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

ENDFORM.
