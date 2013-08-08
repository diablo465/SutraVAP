
C SUBROUTINE PERFILM IS TO CALCULATE THE PERMEABILITY (M2) DUE TO FILM
C ONLY BUT AT THIS STAGE WE ASSUME IT IS ONLY A FUNCTION OF INITIAL TEMP
C ERATURE SEE PAGE 165
      SUBROUTINE PERFILM (SPF,RPF,POR,TPT,PRES,SWG,KREG,MFT)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      COMMON /PARAMS/ COMPFL,COMPMA,DRWDU,CW,CS,RHOS,SIGMAW,SIGMAS,
     1   RHOW0,URHOW0,VISC0,PRODF1,PRODS1,PRODF0,PRODS0,CHI1,CHI2,
     2   DVIDU,RELPW,PERMVAC,SURFT,PI,ELECTRC,BOTZC,CL,CA,DMAIR,
     3   RC,SATM,STM,GVA,WMW,ZETA
      COMMON /FILMFLOW/ CORF,AGR,SWM3,SWM4,PHICM,ASVL
C     BP IS A CONSTANT CONSDIERING A LARGE AMOUNT OF CONSTANTS. 
C     SEE PAGE 165 FOR REFERENCE.
      DOUBLE PRECISION BP
      DATA BP/3.00061397378356D-24/
      SAVE BP
C.....MFT=1, FILM TRANSPORT IS ENABLED BASED ON TOKUNAKA (2009) 
C      AND ZHANG(2010) 
      IF (MFT.EQ.1)THEN
C      A PARAMETER IN B SEE PAGE 165
C     BP=2.D0**5.D-1*PI**2*(RELPW*PERMVAC/2.D0/SURFT)**1.5*
C    1 (BOTZ/ECECTR)**3
C     B=BP*(TPT)**3.D0
C     NOW ASSUMING FILM TEMPERATURE IS CONSTANT
      B=BP*(298.15D0)**3.D0
C     (S)ATURATED (P)ERMEABILITY DUE TO (F)ILM FLOW (SPF) [M2]
      SPF=CORF*B*(1-POR)*(2*AGR)**5.D-1

      IF(PRES.LE.0)THEN
C     CAPILLARY PRESSURE HEAD
      PHIC=-PRES/RHOW0/GVA
C    （R)ELATIVE (P)ERMEABILITY DUE TO (F)ILM FLOW (RPF) [-]
      RPF=(1+AGR*2.D0*PHIC/ZETA)**(-1.5D0)
      ELSE
      RPF=1.D0
      ENDIF
C.....MFT=3, FILM TRANSPORT IS ENABLED BASED ON LEBEAU AND KONRAD (2010)
c      SEE PAGE 178-179
      ELSEIF (MFT.EQ.3) THEN
      IF (KREG.EQ.3)THEN
      SWM=SWM3
      ELSEIF (KREG.EQ.4)THEN
      SWM=SWM4
      ENDIF
C.....EFFECTIVE DIAMETER 
      ED=6.D0*(1-POR)* (-ASVL/(6.D0*PI*RHOW0*GVA*PHICM))**(1.D0/3.D0)
     1 /POR/SWM
C.....FILM THICKNESS (WARNING) THIS IS NOT THE FULL PART
      DEL=(RELPW*PERMVAC/(2*RHOW0*GVA))**.5D0*(PI*BOTZC*298.15/ELECTRC)
      SPF=4.D0*(1-POR)*DEL**3.D0/PI/ED

C.....RELATIVE PERMEABILITY DUE TO FILM FLOW
      IF (PRES.LT.0)THEN
C     CAPILLARY PRESSURE HEAD
      PHIC=-PRES/RHOW0/GVA           
      RPF=(1-SWG)*PHIC**(-1.5D0)
C.....FOR CHECKING THE SPF AND RPF VALUE SEE PAGE 179 AND RELATIVEK.SAGE
C      IF (PHIC.GT.1.D3)THEN
C        REAPL=SPF*RPF
C      ENDIF
      ELSEIF (PRES.GE.0)THEN
      RPF=0.D0
      ENDIF
      ENDIF
      RETURN 
      END







