FUNCTION ZDYP12_FM_002.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_DATA) TYPE  ZDYP12_TT_FATURA OPTIONAL
*"----------------------------------------------------------------------

DATA: ls_data TYPE ZDYP12_S_FATURA.


  LOOP AT IV_DATA INTO ls_data.
       UPDATE ZDYP12_T_FATURA SET FATURA_BAS = '20221005' WHERE FATURA_NO = ls_data-fatura_no.
       DELETE FROM ZDYP12_T_FATURA WHERE FATURA_NO = ls_data-fatura_no.

  ENDLOOP.


ENDFUNCTION.
