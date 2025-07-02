*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZGG_LOG_CH_PLAY
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZGG_LOG_CH_PLAY    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
