*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_ALV_FRM
*&---------------------------------------------------------------------*
FORM user_command USING  r_ucomm     LIKE sy-ucomm
                         rs_selfield TYPE slis_selfield.
  IF r_ucomm = '&IC1'.
    IF rs_selfield-fieldname = 'VBELN'.
      READ TABLE gt_vbak INTO gs_vbak INDEX rs_selfield-tabindex.
      IF sy-subrc IS INITIAL AND gs_vbak-vbeln IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD gs_vbak-vbeln.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
      ENDIF.
    ELSEIF rs_selfield-fieldname = 'VBELN_VL' .
      READ TABLE gt_vbak INTO gs_vbak INDEX rs_selfield-tabindex.
      IF gs_vbak-vbeln_vl IS NOT INITIAL.
        lv_vbeln_vl = gs_vbak-vbeln_vl.
        SELECT SINGLE *
           FROM zdyp12_teslimat AS tes
          INTO @gs_teslimat
          WHERE tes~vbeln_vl = @lv_vbeln_vl.

        SELECT SINGLE landx FROM t005t WHERE spras = @sy-langu
          AND land1 = @gs_teslimat-delivery_counrty  INTO @lv_landx.

        IF sy-subrc EQ 0.
          CALL SCREEN 100 STARTING AT 1 1 ENDING AT 100 50.
        ELSEIF sy-subrc IS INITIAL AND gs_vbak-vbeln_vl IS INITIAL.
          MESSAGE 'Bu kayıt da bir teslimat numarası sistemde mevcut değil.' TYPE 'I'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR lv_count.

  LOOP AT gt_vbak INTO gs_vbak WHERE chk = 'X'.
    lv_count = lv_count + 1.
  ENDLOOP.

  CASE r_ucomm.
    WHEN '&DETAY'.

      READ TABLE gt_vbak INTO gs_vbak INDEX rs_selfield-tabindex.
      IF sy-subrc = 0 AND gs_vbak-vbeln IS NOT INITIAL.
        " Store the selected VBELN
        lv_vbeln = gs_vbak-vbeln.
        PERFORM check_lines.
        IF lv_count = 1.
          PERFORM show_details USING lv_vbeln.
        ENDIF.
      ENDIF.

    WHEN'&TESLIMAT'.
      CLEAR lv_flag.
      lv_flag = 1.
      PERFORM check_lines.
      READ TABLE gt_vbak INTO gs_vbak INDEX rs_selfield-tabindex.
      IF sy-subrc = 0 AND gs_vbak-vbeln IS NOT INITIAL.
        " Store the selected VBELN
        lv_vbeln = gs_vbak-vbeln.
      ENDIF.
      gs_teslimat-vbeln_va = lv_vbeln.

      SELECT * FROM zdyp12_teslimat
        WHERE zdyp12_teslimat~vbeln_va = @lv_vbeln
        INTO @DATA(ls_teslimat).
      ENDSELECT.
      IF sy-subrc EQ 0.
        MESSAGE 'Bu kaydın daha önce teslimatı oluşturulmuştur.' TYPE 'I'.
        RETURN.
      ENDIF.
      CALL SCREEN 100 STARTING AT 1 1 ENDING AT 50 50.

    WHEN'&EXCEL'.
      DATA: lv_filename        TYPE string,
            lv_path            TYPE string,
            lv_fullpath        TYPE string,
            lv_string_cells    TYPE string,
            lv_string_rows     TYPE string,
            lv_buffer          TYPE xstring,
            lt_binary          TYPE solix_tab,
            lv_netwr_char(15)  TYPE c,
            lv_kwmeng_char(15) TYPE c.

      CALL METHOD cl_gui_frontend_services=>file_save_dialog
        EXPORTING
          window_title              = 'Save file'                 " Window Title
          default_extension         = 'XLS'                 " Default Extension
*         default_file_name         =                  " Default File Name
*         with_encoding             =
*         file_filter               =                  " File Type Filter Table
*         initial_directory         =                  " Initial Directory
*         prompt_on_overwrite       = 'X'
        CHANGING
          filename                  = lv_filename                 " File Name to Save
          path                      = lv_path                  " Path to File
          fullpath                  = lv_fullpath                 " Path + File Name
*         user_action               =                  " User Action (C Class Const ACTION_OK, ACTION_OVERWRITE etc)
*         file_encoding             =
        EXCEPTIONS
          cntl_error                = 1                " Control error
          error_no_gui              = 2                " No GUI available
          not_supported_by_gui      = 3                " GUI does not support this
          invalid_default_file_name = 4                " Invalid default file name
          OTHERS                    = 5.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      IF lv_flag = 0.
        DATA(lv_length) = lines( gt_vbak ).
        SORT gt_vbak DESCENDING.
        LOOP AT gt_vbak  INTO gs_vbak.
          lv_netwr_char = gs_vbak-netwr.
          CONCATENATE gs_vbak-vbeln
                      gs_vbak-auart
                      gs_vbak-bezei
                      gs_vbak-erdat
                      gs_vbak-audat
                      gs_vbak-kunnr
                      gs_vbak-musteri_adi
                      gs_vbak-augru
                      lv_netwr_char
                      gs_vbak-waerk
                      gs_vbak-vkorg
                      gs_vbak-vtweg
                      gs_vbak-vbeln_vl
                      INTO lv_string_cells SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
          CONCATENATE lv_string_cells lv_string_rows INTO lv_string_rows SEPARATED BY cl_abap_char_utilities=>newline.
        ENDLOOP.
        SORT gt_vbak ASCENDING.

        CONCATENATE 'Sales Document'
                    'Sales Document Type'
                    'Name'
                    'Created On'
                    'Document Date'
                    'Sold-to party'
                    'Customer Name'
                    'Order Reason'
                    'Net Value'
                    'Document Currency'
                    'Sales Organization'
                    'Distribution Channel'
                    'Delivery Document'
                    INTO lv_string_cells SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
      ELSEIF lv_flag = 1.
        lv_length = lines( gt_vbak_d ).
        SORT gt_vbak_d DESCENDING.
        LOOP AT gt_vbak_d INTO gs_vbak_d FROM 1 TO lv_length.
          lv_netwr_char = gs_vbak_d-netwr.
          lv_kwmeng_char = gs_vbak_d-kwmeng.
          CONCATENATE gs_vbak_d-vbeln
                      gs_vbak_d-auart
                      gs_vbak_d-bezei
                      gs_vbak_d-erdat
                      gs_vbak_d-audat
                      gs_vbak_d-kunnr
                      gs_vbak_d-musteri_adi
                      gs_vbak_d-augru
                      lv_netwr_char
                      gs_vbak_d-waerk
                      gs_vbak_d-vkorg
                      gs_vbak_d-vtweg
                      gs_vbak_d-vbeln_vl
                      gs_vbak_d-matnr
                      gs_vbak_d-maktx
                      lv_kwmeng_char
                      gs_vbak_d-meins
                      INTO lv_string_cells SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
          CONCATENATE lv_string_cells lv_string_rows INTO lv_string_rows SEPARATED BY cl_abap_char_utilities=>newline.
        ENDLOOP.
        SORT gt_vbak_d ASCENDING.
        CONCATENATE 'Sales Document'
                    'Sales Document Type'
                    'Name'
                    'Created On'
                    'Document Date'
                    'Sold-to party'
                    'Customer Name'
                    'Order Reason'
                    'Net Value'
                    'Document Currency'
                    'Sales Organization'
                    'Distribution Channel'
                    'Delivery Document'
                    'Material'
                    'Material Description'
                    'Order Quantity'
                    'Base Unit Of Measure'
                    INTO lv_string_cells SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
      ENDIF.
      CONCATENATE lv_string_cells lv_string_rows INTO lv_string_rows SEPARATED BY cl_abap_char_utilities=>newline.
      CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
        EXPORTING
          text   = lv_string_rows
        IMPORTING
          buffer = lv_buffer
        EXCEPTIONS
          failed = 1
          OTHERS = 2.
      IF sy-subrc <> 0.
      ENDIF.

      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer     = lv_buffer
        TABLES
          binary_tab = lt_binary.

      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          filename                = lv_filename
          filetype                = 'BIN'
        TABLES
          data_tab                = lt_binary
        EXCEPTIONS
          file_write_error        = 1
          no_batch                = 2
          gui_refuse_filetransfer = 3
          invalid_type            = 4
          no_authority            = 5
          unknown_error           = 6
          header_not_allowed      = 7
          separator_not_allowed   = 8
          filesize_not_allowed    = 9
          header_too_long         = 10
          dp_error_create         = 11
          dp_error_send           = 12
          dp_error_write          = 13
          unknown_dp_error        = 14
          access_denied           = 15
          dp_out_of_memory        = 16
          disk_full               = 17
          dp_timeout              = 18
          file_not_found          = 19
          dataprovider_exception  = 20
          control_flush_error     = 21
          OTHERS                  = 22.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

  ENDCASE.

ENDFORM.
FORM get_data.
  SELECT
    vbak~vbeln,
    vbak~auart,
    tvakt~bezei,
    vbak~erdat,
    vbak~audat,
    vbak~kunnr,
    concat_with_space( kna1~name1, kna1~name2, 1 ) AS Musteri_Adi,
    vbak~augru,
    vbak~netwr,
    vbak~waerk,
    vbak~vkorg,
    vbak~vtweg,
    tes~vbeln_vl
    FROM vbak
    LEFT JOIN kna1 ON  kna1~kunnr = vbak~kunnr
    LEFT JOIN tvakt ON tvakt~auart = vbak~auart
                    AND tvakt~spras = @sy-langu
    LEFT JOIN zdyp12_teslimat AS tes ON vbak~vbeln = tes~vbeln_va
    WHERE vbak~vbeln IN @s_vbeln
      AND vbak~erdat IN @s_erdat
      AND vbak~audat IN @s_audat
      AND vbak~kunnr IN @s_kunnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_vbak.

  IF gt_vbak[] IS INITIAL.
    MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

  LOOP AT gt_vbak INTO gs_vbak.

*satır-sütun renklendirme
    IF gs_vbak-netwr > '20000'.
      gs_color-fname = 'NETWR'.
      MOVE '6'         TO gs_color-color-col."renk
      MOVE '0'         TO gs_color-color-int.
      MOVE '3'         TO gs_color-color-inv. "koyuluk
      APPEND gs_color  TO gs_vbak-clrt.
    ELSEIF gs_vbak-netwr < '20000' OR gs_vbak-netwr = '20000'.
      gs_color-fname = 'NETWR'.
      MOVE '5'         TO gs_color-color-col."renk
      MOVE '0'         TO gs_color-color-int.
      MOVE '3'         TO gs_color-color-inv. "koyuluk
      APPEND gs_color  TO gs_vbak-clrt.
    ENDIF.

    MODIFY  gt_vbak FROM gs_vbak.
  ENDLOOP.
ENDFORM.
FORM show_details USING lv_vbeln.
  SELECT
    vbap~matnr,
    makt~maktx,
    vbap~kwmeng,
    vbap~meins
    FROM vbap
    LEFT JOIN makt ON makt~matnr = vbap~matnr
                  AND makt~spras = @sy-langu
    WHERE vbeln = @lv_vbeln
    INTO TABLE @gt_vbap.

  DATA: it_fieldcat TYPE  slis_t_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_screen_start_column = 30
      i_screen_start_line   = 4
      i_screen_end_column   = 120
      i_screen_end_line     = 15
      i_tabname             = 'GT_VBAP'
      i_structure_name      = 'ZDYP12_S_ALV01'
      it_fieldcat           = it_fieldcat
      i_callback_program    = sy-repid
    TABLES
      t_outtab              = gt_vbap
    EXCEPTIONS
      program_error         = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.
FORM alv_display.
  alv_variant-report             = sy-repid.
*  alv_variant-variant            = p_varint.
  alv_repid                      = sy-repid.
  alv_tabname                    = 'GT_VBAK'.
  alv_structure                  = 'ZDYP12_S_ALV'.


  alv_layout-zebra               = 'X'.
  alv_layout-get_selinfos        = 'X'.
  alv_layout-key_hotspot         = 'X'.
  alv_layout-colwidth_optimize   = 'X'.
  alv_layout-info_fieldname      = 'color'.
  alv_layout-coltab_fieldname    = 'CLRT'.
  alv_layout-box_fieldname = 'CHK'.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     i_program_name     = alv_repid
*     i_internal_tabname = alv_tabname
*     i_inclname         = alv_repid
      i_structure_name   = alv_structure
      i_bypassing_buffer = 'X'
    CHANGING
      ct_fieldcat        = alv_fieldcat[].

  LOOP AT alv_fieldcat INTO DATA(fieldcat).
    IF fieldcat-fieldname = 'VBELN'.
      fieldcat-hotspot = 'X'.
    ELSEIF fieldcat-fieldname = 'VBELN_VL'.
      fieldcat-hotspot = 'X'.
    ENDIF.
    MODIFY alv_fieldcat FROM fieldcat.
  ENDLOOP.

*Exit event
  alv_event_exit-ucomm = '&OUP'.
  alv_event_exit-after = 'X'.
  alv_event_exit-before = ' '.
  APPEND alv_event_exit.



  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = alv_repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      i_callback_top_of_page   = 'TOP_OF_PAGE'
      is_layout                = alv_layout
      it_fieldcat              = alv_fieldcat[]
      i_save                   = 'A'
      it_event_exit            = alv_event_exit[]
    " it_excluding             = lt_exclude[]
    TABLES
      t_outtab                 = gt_vbak[].

ENDFORM.
FORM top_of_page.

  DATA: lt_list_comment TYPE slis_t_listheader,
        ls_list_comment TYPE LINE OF slis_t_listheader.

  ls_list_comment-typ = 'H'.
  ls_list_comment-info = |Sipariş Sayısı: { lines( gt_vbak ) }|.
  APPEND ls_list_comment TO lt_list_comment.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_list_comment.
ENDFORM.

FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  IF p_vbap = abap_true.
    APPEND '&DETAY' TO rt_extab.
  ENDIF.

  SET PF-STATUS 'STANDARD' EXCLUDING rt_extab.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_button
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_button .
  IF ( gs_teslimat-plate IS NOT INITIAL AND gs_teslimat-driver IS NOT INITIAL ) AND ( gs_teslimat-vbeln_vl IS NOT INITIAL AND gs_teslimat-delivery_counrty IS NOT INITIAL ).
    gs_teslimat-ernam = sy-uname.
    gs_teslimat-erdat = sy-datum.
    gs_teslimat-erzet = sy-uzeit.
    INSERT zdyp12_teslimat FROM gs_teslimat.
    DATA: lv_message TYPE char80.
    CONCATENATE  'Teslimat numarası' gs_teslimat-vbeln_vl 'olan kayıt başarı bir şekilde kaydedildi.' INTO lv_message SEPARATED BY space.
    MESSAGE lv_message TYPE 'I' DISPLAY LIKE 'S'.
  ELSE.
    IF gs_teslimat-vbeln_vl IS INITIAL OR gs_teslimat-delivery_counrty IS INITIAL.
      MESSAGE 'Teslimat numarası ve ülkesini boş bırakılamaz.Lütfen doldurunuz.' TYPE 'I' DISPLAY LIKE 'E'.
    ELSE.
      MESSAGE 'Plaka ve Şoför bilgisi boş bırakılamaz.Lütfen doldurunuz.' TYPE 'I' DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.

FORM check_lines.
  " If no rows or more than one row selected, Show info message
  IF lv_count = 0.
    MESSAGE 'Lütfen satır seçiniz.' TYPE 'I'.
    RETURN.
  ELSEIF lv_count > 1.
    MESSAGE 'Birden fazla satır seçtiniz.' TYPE 'I'.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form alv_detailed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alv_detailed .



ENDFORM.
