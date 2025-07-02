*&---------------------------------------------------------------------*
*& Include          ZDHP12_R_HW_SCR
*&---------------------------------------------------------------------*


SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME.

  SELECT-OPTIONS: s_vkorg FOR vbrk-vkorg NO-EXTENSION NO INTERVALS  .
  SELECT-OPTIONS: s_vbeln FOR vbrk-vbeln .
  SELECT-OPTIONS: s_fkdat FOR vbrk-fkdat .
  SELECT-OPTIONS: s_matnr FOR vbrp-matnr MODIF ID c1.

SELECTION-SCREEN END OF BLOCK a1 .

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
  PARAMETERS check  AS CHECKBOX USER-COMMAND c1 MODIF ID ck1.
  PARAMETERS check2 AS CHECKBOX USER-COMMAND c2 MODIF ID ck1.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK a2 WITH FRAME.

  SELECTION-SCREEN PUSHBUTTON 1(20) pbutton USER-COMMAND pushbutton.
  SELECTION-SCREEN PUSHBUTTON 30(20) pbutton2 USER-COMMAND pushbutton2.
  SELECTION-SCREEN FUNCTION KEY 1.
  SELECTION-SCREEN FUNCTION KEY 2.

SELECTION-SCREEN END OF BLOCK a2 .

INITIALIZATION.

  pbutton = 'Payer'.
  pbutton2 = 'Document Type'.
  sscrfields-functxt_01 = '@05@ Hide Checkboxes'.
  sscrfields-functxt_02 = '@04@ Show Checkboxes'.



AT SELECTION-SCREEN .

  CASE sscrfields-ucomm.
    WHEN 'FC01'.
      gv_flag = abap_true.
    WHEN 'FC02'.
      CLEAR gv_flag.
  ENDCASE.

  IF sscrfields-ucomm = 'FC01'.
    check = ''."abap_false.
    check2 = ''. "abap_false.
  ENDIF.

  DATA: lv_tabname TYPE dd02v-tabname.

  IF sy-ucomm = 'PUSHBUTTON'.
    lv_tabname = 'ZDYP12_T_K001'.
    PERFORM view_maintenance_call USING lv_tabname.
  ELSEIF sy-ucomm = 'PUSHBUTTON2'.
    lv_tabname = 'ZDYP12_T_V001'.
    PERFORM view_maintenance_call USING lv_tabname.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.

  IF gv_flag IS INITIAL.
    PERFORM show_checkboxes.
  ELSE.
    PERFORM hide_checkboxes.
  ENDIF.
