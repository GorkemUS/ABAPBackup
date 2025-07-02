*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_ALV_SCR
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
*  SET PF-STATUS 'STANDARD'.
  DATA: lv_text TYPE char50.
  lv_text = |{ lv_vbeln_vl } Nolu siparişin teslimat bilgisi görüntüleniyor. |.

  IF lv_flag = 1.
    SET TITLEBAR '100' WITH 'Yeni Teslimat Yaratma Ekranı'.
  ELSEIF lv_flag = 0.
    SET TITLEBAR '100'  WITH lv_text.
  ENDIF.

  IF lv_flag = 0.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'KAYDET'.
          screen-active = 0.
      ENDCASE.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF p_vbap = abap_true.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'KAYDET'.
          screen-active = 0.
      ENDCASE.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN '&F03' OR '&F15' OR '&F12'.
      IF lv_flag = 1.
        DATA lv_answer TYPE char1.
        DATA lv_question TYPE char80.
        lv_question = 'Teslimat Yaratılmadı. Emin misiniz?'.
      ELSE.
        lv_question = 'Çıkmak istediğinizden emin misiniz?'.
      ENDIF.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          text_question         = lv_question
          text_button_1         = 'Yes'
          icon_button_1         = 'ICON_CHECKED'
          text_button_2         = 'No'
          icon_button_2         = 'ICON_INCOMPLETE'
          display_cancel_button = space
        IMPORTING
          answer                = lv_answer
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.

      IF lv_answer = '1'.
        LEAVE TO SCREEN 0.
        RETURN.
      ENDIF.

    WHEN '&KAYDET'.
      PERFORM save_button.
    WHEN 'ENTER'.
      SELECT SINGLE
        landx
        FROM t005t WHERE spras = @sy-langu
        AND land1 = @gs_teslimat-delivery_counrty
        INTO @lv_landx.
      IF sy-subrc <> 0.
        MESSAGE 'Böyle bir ülke anahtarı sistemde mevcut değil.' TYPE 'I'.
        RETURN.
      ENDIF.
  ENDCASE.

ENDMODULE.
