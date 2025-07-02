*&---------------------------------------------------------------------*
*& Report ZDYP12_R_ORDER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdyp12_r_order.

TABLES: ekpo, ekko.

DATA : gs_data TYPE zdyp12_s_order,
       gt_data TYPE TABLE OF zdyp12_s_order.

DATA: alv_fieldcat   TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      alv_event_exit TYPE TABLE OF slis_event_exit WITH HEADER LINE,
      alv_tabname    TYPE slis_tabname,
      alv_structure  TYPE tabname,
      alv_repid      LIKE sy-repid,
      alv_variant    LIKE disvariant,
      alv_layout     TYPE slis_layout_alv.


SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME.

  PARAMETERS: s_bukrs TYPE ekpo-bukrs.
  SELECT-OPTIONS: s_ebeln FOR ekko-ebeln NO-EXTENSION NO INTERVALS  .
  SELECT-OPTIONS: s_lifnr FOR ekko-lifnr NO-EXTENSION NO INTERVALS .
  SELECT-OPTIONS: s_matnr FOR ekpo-matnr NO-EXTENSION.

SELECTION-SCREEN END OF BLOCK a1 .

START-OF-SELECTION.

  PERFORM get_data.

  IF gt_data[] IS NOT INITIAL.
    PERFORM alv_list.
  ENDIF.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
*
*  DATA: lt_t023t TYPE  wsti_t_t023t,
*        ls_t023t TYPE t023t.

  SELECT

    ekko~ebeln
    ekko~ernam
    ekko~lifnr
    ekpo~matnr
    ekpo~ebelp
    ekpo~bukrs
    ekpo~werks
    ekpo~matkl
    t023t~wgbez
    ekpo~netpr
    ekpo~peinh
    ekpo~netwr
    ekko~waers
    makt~maktx
    t001~butxt
*    t023t~matkl

    FROM ekko
    INNER JOIN ekpo ON
      ekko~ebeln = ekpo~ebeln
    LEFT JOIN lfa1 ON
      ekko~lifnr = lfa1~lifnr
    LEFT JOIN makt ON
      ekpo~matnr = makt~matnr AND
      makt~spras = sy-langu
    LEFT JOIN t001 ON
      ekpo~bukrs = t001~bukrs
    LEFT JOIN t023t ON
      ekpo~matkl = t023t~matkl
    INTO CORRESPONDING FIELDS OF TABLE gt_data
    WHERE ekpo~bukrs = s_bukrs
      AND ekko~ebeln IN s_ebeln
      AND ekko~lifnr IN s_lifnr
      AND ekpo~matnr IN s_matnr.
*  IF sy-subrc IS NOT INITIAL.
*    WRITE: 'No data'.
*  ENDIF.

  IF gt_data[] IS INITIAL.
    MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

SORT gt_data BY Ebeln ebelp matnr.

ENDFORM.

FORM alv_list .
  alv_variant-report             = sy-repid.
*  alv_variant-variant            = p_varint.
  alv_repid                      = sy-repid.
  alv_tabname                    = 'GT_DATA'.
  alv_structure                  = 'ZDYP12_S_ORDER'.


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
*    READ TABLE wt_rapor INDEX rs_selfield-tabindex.
    CALL TRANSACTION 'ME23N'.
  ELSEIF  r_ucomm = 'GERI'.
    SET SCREEN 0.
  ELSEIF  r_ucomm = 'YUKARI'.
    SET SCREEN 0.
  ELSEIF  r_ucomm = 'CIK'.
    SET SCREEN 0.
  ELSEIF  r_ucomm = '&YES'.


  ENDIF.

ENDFORM.
