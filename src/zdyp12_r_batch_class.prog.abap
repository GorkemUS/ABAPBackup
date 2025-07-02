*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_BATCH_CLASS
*&---------------------------------------------------------------------*

CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,

      handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.

    METHODS: upload_excel,
      display_alv.

ENDCLASS.

CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD handle_user_command.

    grid->get_selected_rows(
    IMPORTING
     et_index_rows = lt_selected_rows
     ).

    IF lt_selected_rows IS INITIAL.
      MESSAGE 'Satır seçmediniz' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

    CASE e_ucomm.
      WHEN '&GUNCELLE'.
        REFRESH lt_message .
        LOOP AT lt_selected_rows INTO ls_selected_row.
          REFRESH bdcdata.
          READ TABLE gt_data INTO gs_data INDEX ls_selected_row-index.
          IF sy-subrc NE 0.
            MESSAGE 'Hata var,lütfen düzelt' TYPE 'S' DISPLAY LIKE 'E'.
          ENDIF.
          PERFORM bdc_dynpro      USING 'SAPMF05L' '0100'.
          PERFORM bdc_field       USING 'BDC_CURSOR'
                                        'RF05L-GJAHR'.
          PERFORM bdc_field       USING 'BDC_OKCODE'
                                        '=WEITE'.
          PERFORM bdc_field       USING 'RF05L-BELNR'
                                        gs_data-belnr.
          PERFORM bdc_field       USING 'RF05L-BUKRS'
                                        gs_data-bukrs.
          PERFORM bdc_field       USING 'RF05L-GJAHR'
                                        gs_data-gjahr.
          PERFORM bdc_dynpro      USING 'SAPMF05L' '0700'.
          PERFORM bdc_field       USING 'BDC_CURSOR'
                                        'BKPF-BELNR'.
          PERFORM bdc_field       USING 'BDC_OKCODE'
                                        '=VK'.
          PERFORM bdc_dynpro      USING 'SAPMF05L' '1710'.
          PERFORM bdc_field       USING 'BDC_CURSOR'
                                        'BKPF-BKTXT'.
          PERFORM bdc_field       USING 'BDC_OKCODE'
                                        '=ENTR'.
          PERFORM bdc_field       USING 'BKPF-BKTXT'
                                        gs_data-bktxt.
          PERFORM bdc_dynpro      USING 'SAPMF05L' '0700'.
          PERFORM bdc_field       USING 'BDC_CURSOR'
                                        'BKPF-BELNR'.
          PERFORM bdc_field       USING 'BDC_OKCODE'
                                        '=AE'.
*          PERFORM bdc_transaction USING 'FB02'.
          CALL TRANSACTION 'FB02' USING bdcdata "call transaction
            MODE 'N' "N-no screen mode, A-all screen mode, E-error screen mode
            UPDATE 'A' "A-assynchronous, S-synchronous
            MESSAGES INTO bdcmsg.

        ENDLOOP.

        LOOP AT bdcmsg INTO DATA(ls_bdcmsg).
          CLEAR:ls_message.
          ls_message-type   = ls_bdcmsg-msgtyp.
          ls_message-id     = ls_bdcmsg-msgid.
          ls_message-number = ls_bdcmsg-msgnr.
          ls_message-message_v1 = ls_bdcmsg-msgv1.
          ls_message-message_v2 =  ls_bdcmsg-msgv2.
          ls_message-message_v3 = ls_bdcmsg-msgv3.
          ls_message-message_v4 = ls_bdcmsg-msgv4.

          APPEND ls_message TO lt_message.

        ENDLOOP.

        CALL FUNCTION 'OXT_MESSAGE_TO_POPUP'
          EXPORTING
            it_message = lt_message
*          IMPORTING
*           ev_continue = lv_continue
          EXCEPTIONS
            bal_error  = 1
            OTHERS     = 2.

    ENDCASE.

    REFRESH bdcmsg.

  ENDMETHOD.
  METHOD handle_toolbar.

    CLEAR gs_toolbar.
    gs_toolbar-function = '&GUNCELLE'.
    gs_toolbar-butn_type = 0.
    gs_toolbar-icon = icon_system_save.
    gs_toolbar-text      = 'Güncelle'.
    gs_toolbar-quickinfo = 'Güncelle'.
    APPEND gs_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.
  METHOD upload_excel.

    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      EXPORTING
        window_title            = 'Excel File Upload'
        default_extension       = c_ext_xls
      CHANGING
        file_table              = lt_filetable
        rc                      = lv_return_code
      EXCEPTIONS
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        OTHERS                  = 5.

    READ TABLE lt_filetable INTO lx_filetable INDEX 1.
    p_file = lx_filetable-filename.

    CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING
        filename                = p_file
        i_begin_col             = 1
        i_begin_row             = 2
        i_end_col               = 1000
        i_end_row               = 1000
      TABLES
        intern                  = t_upload[]
      EXCEPTIONS
        inconsistent_parameters = 1
        upload_ole              = 2
        OTHERS                  = 3.


    MOVE-CORRESPONDING t_upload TO lt_rows.
    SORT lt_rows BY row.
    DELETE ADJACENT DUPLICATES FROM lt_rows COMPARING row.

    LOOP AT lt_rows ASSIGNING <ls_row>.
      CLEAR : gs_data , t_tmp_excel.

      LOOP AT t_upload INTO t_tmp_excel
        WHERE row EQ <ls_row>-row.
        IF t_tmp_excel-col EQ 1.
          gs_data-bukrs = t_tmp_excel-value.
          CLEAR t_tmp_excel-value.

        ELSEIF t_tmp_excel-col EQ 2.
          gs_data-belnr = t_tmp_excel-value.
          CLEAR t_tmp_excel-value.

        ELSEIF t_tmp_excel-col EQ 3.
          gs_data-gjahr = t_tmp_excel-value.
          CLEAR t_tmp_excel-value.

        ELSEIF t_tmp_excel-col EQ 4.
          gs_data-bktxt = t_tmp_excel-value.
          CLEAR t_tmp_excel-value.
        ENDIF.
      ENDLOOP.

      APPEND gs_data TO gt_data.
    ENDLOOP.

  ENDMETHOD.
  METHOD display_alv.

    IF  grid IS NOT BOUND.

      CREATE OBJECT grid
        EXPORTING
          i_parent = cl_gui_container=>screen0.

      SET HANDLER: lcl_event_receiver=>handle_toolbar      FOR grid,
                   lcl_event_receiver=>handle_user_command FOR grid.

      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name       = 'ZDYP12_S_BATCH'
        CHANGING
          ct_fieldcat            = lt_fieldcatalog
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.

      LOOP AT lt_fieldcatalog INTO ls_fieldcatalog.
        IF ls_fieldcatalog-fieldname = 'BKTXT'.
          ls_fieldcatalog-edit = abap_true.
          MODIFY lt_fieldcatalog FROM ls_fieldcatalog.
        ENDIF.
      ENDLOOP.

      grid->register_edit_event(
      EXPORTING
        i_event_id =   cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error      = 1                " Error
      OTHERS     = 2 ).


      CALL METHOD grid->set_table_for_first_display
        EXPORTING
          is_layout       = ls_layout
        CHANGING
          it_fieldcatalog = lt_fieldcatalog
          it_outtab       = gt_data.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
