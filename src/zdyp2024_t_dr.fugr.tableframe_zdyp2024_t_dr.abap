*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZDYP2024_T_DR
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZDYP2024_T_DR      .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
