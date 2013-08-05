

      SUBROUTINE UNSAT(SW,DSWDP,RELK,PRES,KREG)                          UNSAT.........1900
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)                                UNSAT.........2000
      DIMENSION KTYPE(2)                                                 UNSAT.........2100
      COMMON /CONTRL/ GNUP,GNUU,UP,DTMULT,DTMAX,ME,ISSFLO,ISSTRA,ITCYC,  UNSAT.........2200
     1   NPCYC,NUCYC,NPRINT,NBCFPR,NBCSPR,NBCPPR,NBCUPR,IREAD,           UNSAT.........2300
     2   ISTORE,NOUMAT,IUNSAT,KTYPE,MET,MAR,MSR,MSC,MHT,MVT,MFT,MRK
C     2   ISTORE,NOUMAT,IUNSAT,KTYPE                                      UNSAT.........2400
C                                                                        UNSAT.........2500
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- UNSAT.........2600
C     E X A M P L E   C O D I N G   FOR                                  UNSAT.........2700
C     MESH WITH TWO REGIONS OF UNSATURATED PROPERTIES USING              UNSAT.........2800
C     THREE PARAMETER-UNSATURATED FLOW RELATIONSHIPS OF                  UNSAT.........2900
C     VAN GENUCHTEN(1980)                                                UNSAT.........3000
C        RESIDUAL SATURATION, SWRES, GIVEN IN UNITS {L**0}               UNSAT.........3100
C        PARAMETER, AA, GIVEN IN INVERSE PRESSURE UNITS {m*(s**2)/kg}    UNSAT.........3200
C        PARAMETER, VN, GIVEN IN UNITS {L**0}                            UNSAT.........3300
C                                                                        UNSAT.........3400
C      REAL SWRES,AA,VN,SWRM1,AAPVN,VNF,AAPVNN,DNUM,DNOM,SWSTAR           UNSAT.........3500
C   WARNING !!!!!!!!!!
C     THIS WATER RETENTION CURVE FUNCTION HAS BEEN MODIFIED SO THAT
C  1. ALL OF THE PARAMETERS ARE STORED IN THE PROGRAM RATHER THAN .INP 
C FILE. THEN WE DICIDED TO
C LET IT MOVE BACK INTO .INP FILE BECAUSE 1. SUBROUTINE FOR SURFACE 
C RESISTANCE ALSO REQUIRES
C SOIL CHARACTERISTICS PARAMETERS 
C  2. THE UNIT OF ALPHA IS [M-1] RATHER THAN [MS2KG-1]
      COMMON /UNSA/ SWRES1,AA1,VN1,SWRES2,AA2,VN2,SWRES3,DLAM3,PHICB3,
     1   SWRES4,DLAM4,PHICB4,PHIC0,ECTO
      COMMON /PARAMS/ COMPFL,COMPMA,DRWDU,CW,CS,RHOS,SIGMAW,SIGMAS,
     1   RHOW0,URHOW0,VISC0,PRODF1,PRODS1,PRODF0,PRODS0,CHI1,CHI2,
     2   DVIDU,RELPW,PERMVAC,SURFT,PI,ELECTRC,BOTZC,CL,CA,DMAIR,
     3   RC,SATM,STM,GVA,WMW,ZETA
C	DOUBLE PRECISION SWRES,AA,VN,SWRM1,AAPVN,VNF,AAPVNN,DNUM,DNOM
C     1,SWSTAR
C        DOUBLE PRECISION PHIC0
C        DATA PMM/-5.D9/
C        SAVE PMM
C                                                                       UNSAT.........3700
C       DATA FOR REGION 1:                                              UNSAT.........3800
C       THIS DATA IS FOR 7C SAND, OBTAINED BY EVAPORATION PROCESS
C       CKECK FILE WRC.GNUMERIC->7C FOR REFERENCE
C        DATA   SWRES1/0.1/,   AA1/15.E0/,   VN1/4.2E0/
C        SAVE SWRES1, AA1, VN1                                           UNSAT.........4000
CC       DATA FOR REGION 2:                                              UNSAT.........4100
C        DATA   SWRES2/0.06/,   AA2/15/,   VN2/9.2/
C        SAVE SWRES2, AA2, VN2                                            UNSAT.........4300
CC       DATA FOR REGION 3:
C
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- UNSAT.........4400
C                                                                        UNSAT.........4500
C *** BECAUSE THIS ROUTINE IS CALLED OFTEN FOR UNSATURATED FLOW RUNS,    UNSAT.........4600
C *** EXECUTION TIME MAY BE SAVED BY CAREFUL CODING OF DESIRED           UNSAT.........4700
C *** RELATIONSHIPS USING ONLY INTEGER AND SINGLE PRECISION VARIABLES!   UNSAT.........4800
C *** RESULTS OF THE CALCULATIONS MUST THEN BE PLACED INTO DOUBLE        UNSAT.........4900
C *** PRECISION VARIABLES SW, DSWDP AND RELK BEFORE LEAVING              UNSAT.........5000
C *** THIS SUBROUTINE.                                                   UNSAT.........5100
C                                                                        UNSAT.........5200
C                                                                        UNSAT.........5300
C*********************************************************************** UNSAT.........5400
C*********************************************************************** UNSAT.........5500
C                                                                        UNSAT.........5600
C     SET PARAMETERS FOR CURRENT REGION, KREG                            UNSAT.........5700
      IF(KREG.EQ.0)THEN                                                   UNSAT.........5800
      SWRES=SWRES1                                                       UNSAT.........5900
      AA=AA1                                                             UNSAT.........6000
      VN=VN1                                                             UNSAT.........6100
      ELSEIF(KREG.EQ.1)THEN                                                           
      SWRES=SWRES2                                                       UNSAT.........6300
      AA=AA2                                                             UNSAT.........6400
      VN=VN2                                                             UNSAT.........6500
      ELSEIF(KREG.EQ.3)THEN
      DLAM=DLAM3
      PHICB=PHICB3
      SWRES=SWRES3
      ELSEIF(KREG.EQ.4)THEN
      DLAM=DLAM4   
      PHICB=PHICB4   
      SWRES=SWRES4
      ENDIF          
C  CHANGE THE PORE WATER PRESSURE (NEGATIVE) INTO CAPILLARY HEAD
C  (POSITIVE) 
      PHIC=-PRES/9.8D3
      SI=SWRES*DLOG(PHIC0/PHIC)/DLOG(PHIC0)
      SWRMS1=1.D0-SI

C  USING VAN GENUCHTEN WATER RETENTION CURVE WITH FAYER EXTENTION
      IF (KREG.EQ.0.OR.EKRG.EQ.1)THEN
C                                                                        UNSAT.........6700
C                                                                        UNSAT.........6800
C*********************************************************************** UNSAT.........6900
C*********************************************************************** UNSAT.........7000
C.....SECTION (1):                                                       UNSAT.........7100
C     SW VS. PRES   (VALUE CALCULATED ON EACH CALL TO UNSAT)             UNSAT.........7200
C     CODING MUST GIVE A VALUE TO SATURATION, SW.                        UNSAT.........7300
C                                                                        UNSAT.........7400
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  UNSAT.........7500
C     THREE PARAMETER MODEL OF VAN GENUCHTEN(1980)                       UNSAT.........7600
C      SWRM1=1.E0-SWRES                                                   UNSAT.........7700
C      AAPVN=1.E0+(AA*(-PRES))**VN                                        UNSAT.........7800
C      VNF=(VN-1.E0)/VN                                                   UNSAT.........7900
C      AAPVNN=AAPVN**VNF                                                  UNSAT.........8000
C      S W   =   DBLE (SWRES+SWRM1/AAPVNN)                                UNSAT.........8100
      AAPVN=1.D0+(AA*PHIC)**VN
      VNF=(VN-1.D0)/VN                                                   UNSAT.........7900
      AAPVNN=AAPVN**VNF                                                  UNSAT.........8000
      SW=SI+SWRMS1/AAPVNN
C      IF(SW.GT.1.D0) SW=1.D0
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  UNSAT.........8200
C*********************************************************************** UNSAT.........8300
C*********************************************************************** UNSAT.........8400
C                                                                        UNSAT.........8500
C                                                                        UNSAT.........8600
C                                                                        UNSAT.........8700
C                                                                        UNSAT.........8800
C                                                                        UNSAT.........8900
C                                                                        UNSAT.........9000
      IF(IUNSAT-2) 600,1200,1800                                         UNSAT.........9100
C*********************************************************************** UNSAT.........9200
C*********************************************************************** UNSAT.........9300
C.....SECTION (2):                                                       UNSAT.........9400
C     DSWDP VS. PRES, OR DSWDP VS. SW   (CALCULATED ONLY WHEN IUNSAT=1)  UNSAT.........9500
C     CODING MUST GIVE A VALUE TO DERIVATIVE OF SATURATION WITH          UNSAT.........9600
C     RESPECT TO PRESSURE, DSWDP.                                        UNSAT.........9700
C                                                                        UNSAT.........9800
  600 CONTINUE                                                           UNSAT.........9900
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  UNSAT........10000
C      DNUM=AA*(VN-1.E0)*SWRM1*(AA*(-PRES))**(VN-1.E0)                    UNSAT........10100
C	DNUM=AA*(VN-1.D0)*SWRMS1*(AA*(-PRES)/9.8D3)**(VN-1.D0)
C      DNUM=AA*(VN-1.D0)*SWRMS1*(AA*(-PRES)/9.8D3)**(VN-1.D0)/9.8D3
      DNUM=AA*(1.D0-VN)*SWRMS1*(AA*PHIC)**(VN-1.D0)
C      DSIDP=-SWRES/LOG(-PHIC0/9.8D3)/PRES
      DSIDP=-SWRES/LOG(PHIC0)/PHIC
      DNOM=AAPVN*AAPVNN                                                  UNSAT........10200
C      D S W D P   =   DBLE (DNUM/DNOM)                                   UNSAT........10300
C      HERE DSWDP=DSW/DPHIC * DPHIC/DP AND DPHIC/DP=-/9800
	DSWDP = ( -DSIDP+DSIDP/AAPVNN-DNUM/DNOM)/9.8D3
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  UNSAT........10400
      GOTO 1800                                                          UNSAT........10500
C*********************************************************************** UNSAT........10600
C*********************************************************************** UNSAT........10700
C                                                                        UNSAT........10800
C                                                                        UNSAT........10900
C                                                                        UNSAT........11000
C                                                                        UNSAT........11100
C                                                                        UNSAT........11200
C                                                                        UNSAT........11300
C*********************************************************************** UNSAT........11400
C*********************************************************************** UNSAT........11500
C.....SECTION (3):                                                       UNSAT........11600
C     RELK VS. P, OR RELK VS. SW   (CALCULATED ONLY WHEN IUNSAT=2)       UNSAT........11700
C     CODING MUST GIVE A VALUE TO RELATIVE PERMEABILITY, RELK.           UNSAT........11800
C                                                                        UNSAT........11900
 1200 CONTINUE                                                           UNSAT........12000
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  UNSAT........12100
C     GENERAL RELATIVE PERMEABILITY MODEL FROM VAN GENUCHTEN(1980)       UNSAT........12200
C      SWSTAR=(SW-SWRES)/SWRM1                                            UNSAT........12300
C THE FOLLOWING APPROACH MAY NOT BE CORRECT. JUST TRY TO USE THE
C ORIGINAL EQUATION 
C      SWSTAR=(SW-SI)/SWRMS1
C WARNING: USING SWSTAR=(SW-SI)/SWRMS1 TO CALCULATE EFFECTIVE SATURATION
C IS NOT CORRECT WHEN
C SW IS CALCULATED BY FAYER RETENTION CURVE BECAUSE SW CAN GO TO 
C NEGATIVE IN THAT CASE. 
C THE APPROPRICATE WAY IS TO USE 1.D0/AAPVNN
C THROUGH THIS APPROACH, IT IS ASSUMED THAT LIQUID WATER MOVEMENT IS 
CINDUCED BY FREE WATER
C MOVEMENT THAT FORMS THE MENISCI IN BETWEEN THE PORE SPACE, THE WATER 
CBELOW RESIDUAL IS 
C JUST FILM WATER THAT IS BOUNDED BY VAN DER WAAL FORCE
C    SEE RELATIVEK.SAGE FOR REFERENCE
      SWSTAR=1.D0/AAPVNN
      R E L K   =   DBLE (SQRT(SWSTAR)*                                  UNSAT........12400
     1                   (1.D0-(1.D0-SWSTAR**(1.D0/VNF))**(VNF))**2.D0)  UNSAT........12500
C         LET RELK EQUALS TO ZERO IS TO REDUCE A BUG IN *.ELE OUTPUT
C         WHEN PHIC IS VERY SMALL, RELK MAY GO BELOW 1E-101, BUT THE 
C         OUTPUT MAY NOT BE ABLE TO GENERATE IT AS 1-101 WHICH OTHER
C         POSTPROCESSING PROGRAM DOES NOT UNDERSTAND
          IF (RELK.LT.1.D-50) RELK=0.D0
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  UNSAT........12600
C                                                                        UNSAT........12700
C*********************************************************************** UNSAT........12800
C*********************************************************************** UNSAT........12900
C                                                                        UNSAT........13000
C                                                                        UNSAT........13100
C                                                                        UNSAT........13200
C                                                                        UNSAT........13300
C                                                                        UNSAT........13400
C                                                                        UNSAT........13500


C USING BROOKES AND COREY WATER RETENTION CURVE SEE PAGE 143 OF THE
C BLUEBOOK
      ELSEIF(KREG.EQ.3.OR.KREG.EQ.4)THEN
       IF (PHIC.LE.PHICB)THEN
        SW=1.D0
        DSWDP=0.D0
        RELK=1.D0
       ELSEIF (PHIC.GT.PHICB)THEN
C       (E)FFECTIVE (S)ATURATION
        SE=(PHICB/PHIC)**DLAM
C       (S)ATURATION
        SW=SWRMS1*SE+SI
C       WHEN IUNSAT=1 DERIVATIVE OF SATURATION WITH RESPECTIVE TO PHI 
C       (PORE WHATER PRESSURE) IS
C       REQUIRED
         IF (IUNSAT.EQ.1)THEN
          DSIDP=-SWRES/LOG(PHIC0)/PHIC
          DSWDP=(-DSIDP+DSIDP*SE+DLAM*SWRMS1*SE/PHIC)/9.8D3
C         WHEN IUNSAT=2 RELATIVE HYDRAULIC CONDUCTIVITY IS REQUIRED. 
C         SEE MUALEM PAPER, PAGE 153
C         AND PAGE 143 OF THE BLUEBOOK FOR REFERENCE
C         HERE THE RELATIVE K EQUATION BY FAYER IS NOT USED BECAUSE WE 
C         STRICTLY ASSUME RELATIVE K 
C         IS INDUCED BY MOVEABLE WATER RATHER THAN BOUNDED WATER
         ELSEIF(IUNSAT.EQ.2)THEN
C         USE ACTUAL SATURATION AS MENISCUS PORES SEE PAGE 170, FAYER 
C         (1995)
C         AND GRANSANDU1.NB IN MATHEMATICA AND RELATIVE K IN SAGE
          IF (MFT.EQ.2)THEN
C         TERM1 IS NOT NEEDED SEE PAGE 170
          DLAMP1=DLAM+1.D0
          DLAM1P1=DLAM*DLAMP1
          DLAMP12=DLAMP1**2.D0
          DLPHIC0=DLOG(PHIC0)
          DLPHICB=DLOG(PHICB)
          DLPHIC =DLOG(PHIC)
          SE0=(PHICB/PHIC0)**DLAM
C          TERM1=ZETA/DLAMP12/DLPHIC0
          TERM2=DLAM*DLAMP1*DLPHIC0
C         GAMC=TERM1*SE/PHIC*(TERM2+SWRES*(-1+DLAMP12/SE-DLAM*DLAMP1*
C     1(DLPHIC0-DLPHIC)))
C         TERM1 IS CROSSED OUT IN ALL OF THE GAMAS
        GAMC=SE/PHIC*(TERM2+SWRES*(-1.D0+DLAMP12/SE-
     1        (TERM2-DLAM1P1*DLPHIC)))
        GAM0=SE0/PHIC0*(TERM2+SWRES*(-1.D0+DLAMP12/SE0))
        GAMB=(TERM2+SWRES*(-1.D0+DLAMP12-(TERM2-DLAM1P1*DLPHICB)))/PHICB
        RELK=SW**ECTO*((GAMC-GAM0)/(GAMB-GAM0) )**2.D0
C         USE EFFECTIVE SATURATION AS MENISCUS PORES
          ELSE
          RELK=SE**(2.D0+2.D0/DLAM+ECTO)          
          ENDIF
         ENDIF  !IUNSAT
        ENDIF   !PHIC AND PHICB
C         LET RELK EQUALS TO ZERO IS TO REDUCE A BUG IN *.ELE OUTPUT
C         WHEN PHIC IS VERY SMALL, RELK MAY GO BELOW 1E-101, BUT THE 
C         OUTPUT MAY NOT BE ABLE TO GENERATE IT AS 1-101 WHICH OTHER
C         POSTPROCESSING PROGRAM DOES NOT UNDERSTAND
        IF (RELK.LT.1.D-50) RELK=0.D0
      ENDIF     !KREG




 1800 RETURN                                                             UNSAT........13600
C                                                                        UNSAT........13700
      END                                                                UNSAT........13800


