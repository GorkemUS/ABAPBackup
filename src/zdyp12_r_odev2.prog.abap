*&---------------------------------------------------------------------*
*& Report ZDYP12_R_ODEV2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdyp12_r_odev2.

TABLES: vbrk, vbrp, kna1.

DATA : gs_data TYPE zdyp12_s_odev2,
       gt_data TYPE TABLE OF zdyp12_s_odev2.

DATA: alv_fieldcat   TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      alv_event_exit TYPE TABLE OF slis_event_exit WITH HEADER LINE,
      alv_tabname    TYPE slis_tabname,
      alv_structure  TYPE tabname,
      alv_repid      LIKE sy-repid,
      alv_variant    LIKE disvariant,
      alv_layout     TYPE slis_layout_alv.


SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME.

  SELECT-OPTIONS: s_vkorg FOR vbrk-vkorg NO-EXTENSION NO INTERVALS  .
  SELECT-OPTIONS: s_vbeln FOR vbrk-vbeln .
  SELECT-OPTIONS: s_fkdat FOR vbrk-fkdat .
  SELECT-OPTIONS: s_matnr FOR vbrp-matnr .


SELECTION-SCREEN END OF BLOCK a1 .

START-OF-SELECTION.

  PERFORM get_data.

  IF gt_data[] IS NOT INITIAL.
    PERFORM alv_list.
  ENDIF.


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

   FROM vbrp
    INNER JOIN vbrk ON
      vbrp~vbeln = vbrk~vbeln
    INNER JOIN kna1 ON
      vbrk~kunag = kna1~kunnr
    LEFT JOIN makt ON
      vbrp~matnr = makt~matnr
    AND makt~spras = sy-langu
    INTO CORRESPONDING FIELDS OF TABLE gt_data

    WHERE vbrk~vkorg IN s_vkorg
      AND vbrk~vbeln IN s_vbeln
      AND vbrk~fkdat IN s_fkdat
      AND vbrp~werks IN s_matnr
      AND vbrk~vbtyp EQ 'M'
      AND kna1~land1 EQ 'US'.


  ENDFORM.

FORM alv_list .
  alv_variant-report             = sy-repid.
*  alv_variant-variant            = p_varint.
  alv_repid                      = sy-repid.
  alv_tabname                    = 'GT_DATA'.
  alv_structure                  = 'ZDYP12_S_ODEV2'.


  alv_layout-zebra               = 'X'.
  alv_layout-get_selinfos        = 'X'.
  alv_layout-confirmation_prompt = ''.
  alv_layout-key_hotspot         = ''.
*  alv_layout-box_fieldname       = 'CHK'."sol seçim kısmı,itab field
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

  DELETE alv_fieldcat WHERE fieldname = 'CHK'.

  LOOP AT alv_fieldcat INTO DATA(fieldcat).
    IF fieldcat-fieldname = 'VBELN'.
      fieldcat-hotspot = 'X'.
      MODIFY alv_fieldcat FROM fieldcat.
    ENDIF.
      IF fieldcat-fieldname = 'VBELN' OR fieldcat-fieldname = 'POSNR'.
      fieldcat-emphasize = 'C311'.
      MODIFY alv_fieldcat from fieldcat.
      ENDIF.
      IF fieldcat-fieldname = 'MATNR'.
      fieldcat-emphasize = 'C111'.
      MODIFY alv_fieldcat FROM fieldcat.
    ENDIF.
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
*     i_callback_top_of_page   = 'TOP_OF_PAGE'
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

  IF r_ucomm = '&IC1'.
    IF rs_selfield-fieldname = 'VBELN'.
      READ TABLE gt_data INTO gs_data INDEX rs_selfield-tabindex.
      IF sy-subrc IS INITIAL AND gs_data-vbeln IS NOT INITIAL.
        SET PARAMETER ID 'VF' FIELD gs_data-vbeln.
        CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
      ENDIF.
      ELSEIF rs_selfield-fieldname = 'MATNR'.
        READ TABLE gt_data INTO gs_data INDEX rs_selfield-tabindex.
        IF sy-subrc IS INITIAL AND gs_data-matnr IS NOT INITIAL.
        SET PARAMETER ID 'MAT' FIELD gs_data-matnr.
        CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
       ENDIF.
    ENDIF.

  ELSEIF  r_ucomm = 'GERI'.
    SET SCREEN 0.
  ELSEIF  r_ucomm = 'YUKARI'.
    SET SCREEN 0.
  ELSEIF  r_ucomm = 'CIK'.
    SET SCREEN 0.
  ELSEIF  r_ucomm = '&YES'.


  ENDIF.

ENDFORM.
