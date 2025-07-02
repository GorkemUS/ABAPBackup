*&---------------------------------------------------------------------*
*& Report ZDYP12_R_DYNALVTEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdyp12_r_dynalvtest.
TABLES : ekko, ekpo.


DATA : gt_ekko TYPE STANDARD TABLE OF ekko,  "po header
       gs_ekko TYPE ekko,
       gt_ekpo TYPE STANDARD TABLE OF ekpo, "po item
       gs_ekpo TYPE ekpo.

"varaibles
DATA : gv_ebelp     TYPE ekpo-ebelp,       "for
       gv_max_ebelp TYPE ekpo-ebelp.   "to select max number of items in data

"for dynamic table
FIELD-SYMBOLS : <dyn_table> TYPE STANDARD TABLE,  "for dynamic table
                <dyn_wa>,
                <fs1>.

* Create the dynamic internal table
DATA : new_table TYPE REF TO data,
       new_line  TYPE REF TO data.


DATA: fieldname(20)  TYPE c,
      fieldvalue(60) TYPE c.


DATA: it_fldcat  TYPE lvc_t_fcat,
      wa_fldcat  TYPE lvc_s_fcat,
      gs_layout1 TYPE lvc_s_layo.                "slis_layout_alv,


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_ebeln FOR ekko-ebeln,
                   s_aedat FOR ekko-aedat,
                   s_bsart FOR ekko-bsart.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM build_dynamic_table.
  PERFORM build_data.
  PERFORM alv_display.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .


  "select header data
  SELECT * FROM ekko INTO CORRESPONDING FIELDS OF TABLE gt_ekko
  WHERE ebeln IN s_ebeln
    AND aedat IN s_aedat
    AND bsart IN s_bsart.

  "select line item
  IF gt_ekko[] IS NOT INITIAL.
    SELECT * FROM ekpo INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
    FOR ALL ENTRIES IN gt_ekko WHERE ebeln = gt_ekko-ebeln.

    SORT gt_ekpo DESCENDING BY ebelp.

    CLEAR : gs_ekpo.

    READ TABLE gt_ekpo INTO gs_ekpo INDEX 1.
    gv_max_ebelp = gs_ekpo-ebelp.

    SORT gt_ekpo BY ebeln ebelp.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BUILD_DYNAMIC_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_dynamic_table .

  CLEAR wa_fldcat.
  wa_fldcat-fieldname = 'EBELN'.
  wa_fldcat-coltext   = 'PO No.'.
  wa_fldcat-datatype  = 'CHAR'.
  wa_fldcat-outputlen  = '10'.
  wa_fldcat-emphasize  = 'C5'.
  APPEND wa_fldcat TO it_fldcat.

  gv_ebelp = 10.

  DO.

    CLEAR wa_fldcat.
    CONCATENATE gv_ebelp '_MATNR' INTO wa_fldcat-fieldname.
    CONCATENATE 'Material Code_' gv_ebelp INTO wa_fldcat-coltext.
    wa_fldcat-datatype  = 'CHAR'.
    wa_fldcat-outputlen  = '18'.
    wa_fldcat-no_zero  = 'X'.
    APPEND wa_fldcat TO it_fldcat.

    CLEAR wa_fldcat.
    CONCATENATE gv_ebelp '_TXZ01' INTO wa_fldcat-fieldname.
    wa_fldcat-coltext   = 'Description'.
    wa_fldcat-datatype  = 'CHAR'.
    wa_fldcat-outputlen  = '40'.
    APPEND wa_fldcat TO it_fldcat.

    CLEAR wa_fldcat.
    CONCATENATE gv_ebelp '_MENGE' INTO wa_fldcat-fieldname.
    wa_fldcat-coltext   = 'Quantity'.
    wa_fldcat-datatype  = 'CURR'.
    APPEND wa_fldcat TO it_fldcat.

    CLEAR wa_fldcat.
    CONCATENATE gv_ebelp '_NETWR' INTO wa_fldcat-fieldname.
    wa_fldcat-coltext   = 'Amount'.
    wa_fldcat-datatype  = 'CURR'.
    APPEND wa_fldcat TO it_fldcat.

    IF gv_ebelp = gv_max_ebelp.
      EXIT.
    ELSE.
      gv_ebelp = gv_ebelp + 10.
    ENDIF.

  ENDDO.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
*     I_STYLE_TABLE             =
      it_fieldcatalog           = it_fldcat
*     I_LENGTH_IN_BYTE          =
    IMPORTING
      ep_table                  = new_table
*     E_STYLE_FNAME             =
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  ASSIGN new_table->* TO <dyn_table>.

* Create dynamic work area and assign to FS
  CREATE DATA new_line LIKE LINE OF <dyn_table>.
  ASSIGN new_line->* TO <dyn_wa>.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BUILD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_data .

  SORT gt_ekko BY ebeln.
  SORT gt_ekpo BY ebeln ebelp.

  LOOP AT gt_ekko INTO gs_ekko.

    CLEAR : <dyn_wa>.

    CLEAR : fieldname, fieldvalue.
    fieldname  = 'EBELN'.
    fieldvalue = gs_ekko-ebeln.
    CONDENSE fieldvalue.
    ASSIGN COMPONENT fieldname OF STRUCTURE <dyn_wa> TO <fs1>.
    <fs1> = fieldvalue.

    LOOP AT gt_ekpo INTO gs_ekpo WHERE ebeln = gs_ekko-ebeln.

      CLEAR : fieldname, fieldvalue.
      CONCATENATE gs_ekpo-ebelp '_MATNR' INTO fieldname.
      fieldvalue = gs_ekpo-matnr.
      CONDENSE fieldvalue.
      ASSIGN COMPONENT fieldname OF STRUCTURE <dyn_wa> TO <fs1>.
      <fs1> = fieldvalue.

      CLEAR : fieldname, fieldvalue.
      CONCATENATE gs_ekpo-ebelp '_TXZ01' INTO fieldname.
      fieldvalue = gs_ekpo-txz01.
      CONDENSE fieldvalue.
      ASSIGN COMPONENT fieldname OF STRUCTURE <dyn_wa> TO <fs1>.
      <fs1> = fieldvalue.

      CLEAR : fieldname, fieldvalue.
      CONCATENATE gs_ekpo-ebelp '_MENGE' INTO fieldname.
      fieldvalue = gs_ekpo-menge.
      CONDENSE fieldvalue.
      ASSIGN COMPONENT fieldname OF STRUCTURE <dyn_wa> TO <fs1>.
      <fs1> = fieldvalue.

      CLEAR : fieldname, fieldvalue.
      CONCATENATE gs_ekpo-ebelp '_NETWR' INTO fieldname.
      fieldvalue = gs_ekpo-netwr.
      CONDENSE fieldvalue.
      ASSIGN COMPONENT fieldname OF STRUCTURE <dyn_wa> TO <fs1>.
      <fs1> = fieldvalue.


      CLEAR : gs_ekpo.
    ENDLOOP.

    APPEND <dyn_wa> TO <dyn_table>.

    CLEAR : gs_ekko.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_display .

  gs_layout1-col_opt   = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program = sy-repid
      is_layout_lvc      = gs_layout1
      it_fieldcat_lvc    = it_fldcat[]
*     I_GRID_SETTINGS    = gs_grid
*     IT_EVENTS          = lt_evts[]
*     IT_EVENTS          = I_EVENTS
      i_default          = 'X'
      i_save             = 'A'
*     IS_VARIANT         = GS_VARIANT1
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab           = <dyn_table>
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.                       " CALL_SCREEN
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       PBO Module- Display both the tables in alv
*---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'MENUBAR'.
  SET TITLEBAR 'ALV REPORT'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       PAI Module
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN '&F03' OR '&F15'.
      LEAVE TO  SCREEN 0.
    WHEN '&F12'.
      LEAVE PROGRAM.
  ENDCASE.                             " CASE SY-UCOMM
ENDMODULE.                             " USER_COMMAND_0100  INPUT
