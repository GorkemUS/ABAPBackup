FUNCTION zdyp12_fm_odev.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_DATA) TYPE  ZDYP12_TT_ODEV2 OPTIONAL
*"     REFERENCE(IS_DATA) TYPE  ZDYP12_S_ODEV2 OPTIONAL
*"  EXPORTING
*"     VALUE(EV_MESSAGE) TYPE  TEXT100
*"     VALUE(EV_TYPE) TYPE  CHAR1
*"----------------------------------------------------------------------

  DATA: ls_data TYPE zdyp12_s_odev2.
  DATA: ls_zdyp00_t_003 TYPE zdyp00_t_003.

  LOOP AT it_data INTO ls_data.


    ls_zdyp00_t_003-material      = ls_data-matnr.
    ls_zdyp00_t_003-begda         = ls_data-fkdat.
    ls_zdyp00_t_003-endda         = ls_data-fkdat.
    ls_zdyp00_t_003-ernam         = ls_data-ernam.
    ls_zdyp00_t_003-material_desc = ls_data-material_desc.
    ls_zdyp00_t_003-aenam         = ls_data-aenam.

    MODIFY zdyp00_t_003 FROM ls_zdyp00_t_003.
    COMMIT WORK.
  ENDLOOP.
  IF sy-subrc IS INITIAL.
    ev_type = 'S'.
    ev_message = 'Tablo edit-insert başarılı.' .
  ELSE.
    ev_type = 'E'.
    ev_message = 'Tablo edit-insert yapılamadı.' .
  ENDIF.


  "Struct yapısı


*is_data-material_desc = 'BESIKTAS'.
  MOVE-CORRESPONDING is_data TO ls_zdyp00_t_003.
  IF ls_zdyp00_t_003-material_desc(1) NE 'B'.
    ls_zdyp00_t_003-material_desc = 'BESIKTAS'.
  ENDIF.
  MODIFY zdyp00_t_003 FROM ls_zdyp00_t_003.



ENDFUNCTION.
