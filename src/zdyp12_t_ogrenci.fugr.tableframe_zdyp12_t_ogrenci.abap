*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZDYP12_T_OGRENCI
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZDYP12_T_OGRENCI   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
