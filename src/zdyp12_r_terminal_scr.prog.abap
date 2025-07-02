*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_TERMINAL_SCR
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN '&F03' OR '&F12' OR '&F15'.
      LEAVE TO SCREEN 0.
    WHEN '&GOSTER'.

      SELECT  ekko~ebeln,
              ekko~bukrs,
              ekko~bstyp,
              ekko~bsart
         FROM ekko
         WHERE ekko~bukrs = @lv_data
         INTO CORRESPONDING FIELDS OF TABLE @lt_ekko.

      DATA(lv_lines) = lines( lt_ekko ).
      lv_number_of_scr_f = ceil( lv_lines / 8 ).
      lv_number_of_scr = lv_number_of_scr_f.

      DATA(lv_counter) = 0.
      LOOP AT lt_ekko INTO ls_ekko.
        lv_counter += 1.
        ls_ekko-sira_no = lv_counter.
        MODIFY lt_ekko FROM ls_ekko.
      ENDLOOP.

    WHEN '&BACK'.
      LEAVE TO SCREEN 0.
    WHEN '&GERI'.
      IF lv_current_page LE 1.
      ELSE.
        lv_current_page = lv_current_page - 1.
        gv_line = ( lv_current_page - 1 ) * 8.
      ENDIF.
    WHEN '&ILERI'.
      IF lv_current_page = lv_number_of_scr.
      ELSE.
        lv_current_page = lv_current_page + 1.
        gv_line = ( lv_current_page - 1 ) * 8.
      ENDIF.
    WHEN '&FIRST'.
      lv_current_page = 1.
      gv_line = ( lv_current_page - 1 ) * 8.
    WHEN '&LAST'.
      lv_current_page = lv_number_of_scr.
      gv_line = ( lv_current_page - 1 ) * 8.
    WHEN '&CHK'.
      IF ls_ekko-bukrs IS INITIAL.
        MESSAGE 'Lütfen Şirket kodu giriniz' TYPE 'E' DISPLAY LIKE 'S'.
      ELSEIF ls_ekko-bukrs is NOT INITIAL.
        CLEAR lt_ekpo.

        LOOP AT lt_ekko INTO ls_ekko WHERE cbox = abap_true.
          SELECT ekpo~ebelp,
                 ekpo~matnr,
                 ekpo~lgort,
                 ekpo~matkl,
                 ekpo~idnlf
         FROM ekpo
            WHERE ekpo~ebeln = @ls_ekko-ebeln
*       INNER JOIN @lt_ekko AS ekko ON ekko~ebeln = ekpo~ebeln
*       WHERE ekko~cbox = @abap_true
         INTO CORRESPONDING FIELDS OF TABLE @lt_ekpo.
        ENDLOOP.

        DATA(lv_lines_ekpo) = lines( lt_ekpo ).

        DATA(lv_counter100) = 0.
        LOOP AT lt_ekpo INTO ls_ekpo.
          lv_counter100 += 1.
          ls_ekpo-sira_no = lv_counter100.
          MODIFY lt_ekpo FROM ls_ekpo.
        ENDLOOP.

        CALL SCREEN 0110.

        CLEAR ls_ekko.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STANDARD'.
  SET TITLEBAR 'Hand Terminal'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set100 OUTPUT.
  idx = sy-stepl + gv_line.
  READ TABLE lt_ekko INTO ls_ekko INDEX idx.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TRANSP_ITAB_IN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE transp_itab_in100 INPUT.

  lines = sy-loopc.
  idx = sy-stepl + gv_line.
  MODIFY lt_ekko FROM ls_ekko INDEX idx.


ENDMODULE.
******************************************************************************************************************************
MODULE user_command_0110 INPUT.

  CASE sy-ucomm.
    WHEN '&F03' OR '&F12' OR '&F15'.
      LEAVE TO SCREEN 0.
    WHEN '&BACK'.
      LOOP AT lt_ekko INTO ls_ekko WHERE cbox IS NOT INITIAL.
        ls_ekko-cbox = ' '.
        MODIFY lt_ekko FROM ls_ekko.
      ENDLOOP.
      LEAVE TO SCREEN 0.
    WHEN '&GERI'.
      IF lv_current_page > 1.
        lv_current_page = lv_current_page - 1.
        gv_line_ekpo = ( lv_current_page - 1 ) * 2.
      ENDIF.

    WHEN '&ILERI'.
      IF ( lv_current_page * 2 ) < lv_lines_ekpo.
        lv_current_page = lv_current_page + 1.
        gv_line_ekpo = ( lv_current_page - 1 ) * 2.
      ENDIF.

    WHEN '&FIRST'.
      lv_current_page = 1.
      gv_line_ekpo = 0.

    WHEN '&LAST'.
      lv_current_page = lv_lines_ekpo.
      gv_line_ekpo = ( lv_current_page - 1 ) .

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0110 OUTPUT.
  SET PF-STATUS 'STANDARD'.
  SET TITLEBAR 'Hand Terminal'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set110 OUTPUT.
*  idx = ( lv_current_page - 1 ) * 8 + sy-stepl.
  idx = sy-stepl + gv_line_ekpo.
  READ TABLE lt_ekpo INTO ls_ekpo INDEX idx.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TRANSP_ITAB_IN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE transp_itab_in110 INPUT.

  lines = sy-loopc.
*  idx = ( lv_current_page - 1 ) * 8 + sy-stepl.
  idx = sy-stepl + gv_line_ekpo.
  MODIFY lt_ekpo FROM ls_ekpo INDEX idx.


ENDMODULE.
