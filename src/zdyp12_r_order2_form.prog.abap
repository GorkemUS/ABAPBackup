*&---------------------------------------------------------------------*
*& Include          ZDHP12_R_HW_FORM
*&---------------------------------------------------------------------*

FORM get_data.

  SELECT
    vbrk~vbeln
    vbrp~posnr
    vbrk~fkart
    vbrk~fkdat
    vbrk~kunag
    kna1~kunnr
    vbrp~matnr
    makt~maktx
    vbrp~fkimg
    vbrp~vrkme
    vbrp~netwr
    vbrk~waerk
    zdyp00_t_003~material_desc
    zdyp00_t_003~aenam
    zdyp00_t_003~ernam
   FROM vbrk
    INNER JOIN vbrp ON
      vbrk~vbeln = vbrp~vbeln
    INNER JOIN kna1 ON
      vbrk~kunag = kna1~kunnr
    INNER JOIN zdyp12_t_k001 ON
      vbrk~kunag = zdyp12_t_k001~kunag
    INNER JOIN zdyp12_t_v001 ON
      vbrk~vbtyp = zdyp12_t_v001~vbtyp
    LEFT JOIN makt ON
      vbrp~matnr = makt~matnr
    AND makt~spras = sy-langu
    LEFT JOIN zdyp00_t_003 ON vbrp~matnr = zdyp00_t_003~material
    INTO CORRESPONDING FIELDS OF TABLE gt_data

    WHERE vbrk~vkorg IN s_vkorg
      AND vbrk~vbeln IN s_vbeln
      AND vbrk~fkdat IN s_fkdat
      AND vbrp~werks IN s_matnr.

  IF check = 'X'.
    DELETE gt_data WHERE fkimg < 20.
  ENDIF.

  IF check2 = 'X'.
    DELETE gt_data WHERE netwr < 10000.
  ENDIF.


  LOOP AT gt_data INTO gs_data.

**satır-sütun renklendirme
    IF gs_data-fkimg > '20' AND gs_data-netwr > '10000'.
      gs_color-fname = 'FKIMG'.
      MOVE '6'         TO gs_color-color-col."renk
      MOVE '0'         TO gs_color-color-int.
      MOVE '3'         TO gs_color-color-inv. "koyuluk
      APPEND gs_color  TO gs_data-clrt.
      gs_color-fname = 'NETWR'.
      MOVE '6'         TO gs_color-color-col."renk
      MOVE '0'         TO gs_color-color-int.
      MOVE '3'         TO gs_color-color-inv. "koyuluk
      APPEND gs_color  TO gs_data-clrt.
    ENDIF.

    MODIFY  gt_data FROM gs_data.
  ENDLOOP.


ENDFORM.

FORM alv_list .
  alv_variant-report             = sy-repid.
*  alv_variant-variant            = p_varint.
  alv_repid                      = sy-repid.
  alv_tabname                    = 'GT_DATA'.
  alv_structure                  = 'ZDYP12_S_ODEV2'.
  alv_layout-coltab_fieldname    = 'CLRT'."


  alv_layout-zebra               = 'X'.
  alv_layout-get_selinfos        = 'X'.
  alv_layout-confirmation_prompt = ''.
  alv_layout-key_hotspot         = ''.
  alv_layout-box_fieldname       = 'CONTROL'."sol seçim kısmı,itab field
  alv_layout-colwidth_optimize   = 'X'.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     i_program_name     = alv_repid
*     i_internal_tabname = alv_tabname
*     i_inclname         = alv_repid
      i_structure_name   = alv_structure
      i_bypassing_buffer = 'X'
    CHANGING
      ct_fieldcat        = alv_fieldcat[].

  DELETE alv_fieldcat WHERE fieldname = 'CONTROL'.

  LOOP AT alv_fieldcat INTO DATA(fieldcat).
    IF fieldcat-fieldname = 'VBELN'.
      fieldcat-hotspot = 'X'.
      MODIFY alv_fieldcat FROM fieldcat.
    ENDIF.
    IF fieldcat-fieldname = 'VBELN'.
      fieldcat-emphasize = 'C311'.
      MODIFY alv_fieldcat FROM fieldcat.
    ENDIF.
    IF fieldcat-fieldname = 'MATNR' OR fieldcat-fieldname = 'MATNR'.
      fieldcat-emphasize = 'C511'.
      MODIFY alv_fieldcat FROM fieldcat.
    ENDIF.
  ENDLOOP.

  LOOP AT alv_fieldcat INTO alv_fieldcat_s.
    CASE alv_fieldcat_s-fieldname.
      WHEN 'MATERIAL_DESC' .
        alv_fieldcat_s-edit = abap_true.
      WHEN 'ERNAM'.
        alv_fieldcat_s-edit = abap_true.
      WHEN 'AENAM'.
        alv_fieldcat_s-edit = abap_true.
    ENDCASE.
    MODIFY alv_fieldcat FROM alv_fieldcat_s.
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
*     i_callback_top_of_page   = 'ALV FORM'
      is_layout                = alv_layout
      it_fieldcat              = alv_fieldcat[]
      i_save                   = 'A'
*     is_variant               = alv_variant
      it_event_exit            = alv_event_exit[]
    TABLES
      t_outtab                 = gt_data[].

ENDFORM.
*---------------------------------------------------------------------*
*       FORM set_pf_status                                            *
*---------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD'.
ENDFORM.                    "set_pf_status

*---------------------------------------------------------------------*
*       FORM user_command                                             *
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  PERFORM refresh_table.

  IF r_ucomm = '&IC1'.
    IF rs_selfield-fieldname = 'VBELN'.
      READ TABLE gt_data INTO gs_data INDEX rs_selfield-tabindex.
      IF sy-subrc IS INITIAL AND gs_data-vbeln IS NOT INITIAL.
        SET PARAMETER ID 'VF' FIELD gs_data-vbeln.
        CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
      ENDIF.
    ENDIF.

  ELSEIF  r_ucomm = 'GERI'.
    SET SCREEN 0.
  ELSEIF  r_ucomm = 'YUKARI'.
    SET SCREEN 0.
  ELSEIF  r_ucomm = 'CIK'.
    SET SCREEN 0.
  ELSEIF  r_ucomm = '&YES'.

    PERFORM save_data.
  ENDIF.
ENDFORM.

FORM hide_checkboxes.
  LOOP AT SCREEN.
    IF screen-group1 = 'CK1'. "OR screen-group4 = '013'.
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.

FORM show_checkboxes.
  LOOP AT SCREEN.
    IF screen-group1 = 'CK1'. " OR screen-group4 = '013'.
      screen-active = '1'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.

FORM refresh_table .
  DATA : ld_grid TYPE REF TO cl_gui_alv_grid.

  IF ld_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ld_grid.
  ENDIF.
  ld_grid->check_changed_data( ).

  DATA : BEGIN OF ls_stable,
           row TYPE c,
           col TYPE c,
         END OF ls_stable.
  ls_stable-row = 'X'.
  ls_stable-col = 'X'.
  CALL METHOD ld_grid->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = ls_stable.

ENDFORM.

FORM save_data .
  DATA: lv_message TYPE text100.
  DATA: lv_type    TYPE char1.

  LOOP AT gt_data INTO gs_data WHERE control EQ 'X'.
    EXIT.
  ENDLOOP.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE 'Lütfen Satır seçiniz' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  gt_data_func[] = CORRESPONDING #( gt_data[] ).

  DELETE gt_data_func WHERE control IS INITIAL.

  CALL FUNCTION 'ZDYP12_FM_ODEV'
    EXPORTING
      it_data    = gt_data_func
    IMPORTING
      ev_type    = lv_type
      ev_message = lv_message.

  MESSAGE lv_message TYPE lv_type.

*  LOOP AT gt_data INTO gs_data WHERE CONTROL EQ 'X'.
*
*
*    UPDATE zdyp00_t_003 SET material_desc = gs_data-material_desc
*                            ernam         = gs_data-ernam
*                            aenam         = gs_data-aenam
*                            WHERE material = gs_data-matnr.
*    COMMIT WORK.
*
*  ENDLOOP.

ENDFORM.
