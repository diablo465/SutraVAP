
!  FUNCTION TO CALCULATE SURFACE RESISTANCE 
!  WHEN MSR=0, SYRFSIS=0
!  WHEN MSR=1, USING CAMILO(1986) FORMULAR
!  WHEN MSR=2, USING SUN (1982) FORMULAR
!  WHEN MSR=3, USING DAAMEN (1996) FORMULAR
!  WHEN MSR=4, USING VAN DER GRIEND (1994) FORMULAR
!  WHEN MSR=5, USING HYPERGEOMETRIC FUNCTIONS SEE PAGE 142 OF 
!              BLUEBOOK, 98(5)
!  WHEN MSR=6, USING APPROXIMATED EQUATION GIVEN BY PAPER 2, USING THE
!      POTENTIAL RESULT AT THE TOPMOST CELL
!  WHEN MSR=7, USING APPROXIMATED EQUATION GIVEN BY PAPER 2, BUT THE 
!      CONTRIBUTION OF VAPOR HAS BEEN CHANGED INTO PHYSICAL BASED METHOD
   DOUBLE PRECISION FUNCTION SURFRSIS(PP,POR,SW,MSR,KREG,TSK,YY)
   USE MOD_SURFR
   USE M_PARAMS
   IMPLICIT DOUBLE PRECISION (A-H,O-Z)
   COMMON /UNSA/ SWRES1,AA1,VN1,SWRES2,AA2,VN2,SWRES3,DLAM3,PSICB3, &
  SWRES4,DLAM4,PSICB4,PSIC0,ECTO
!   COMMON /SURFR/ TAL,EC,ETR 
   COMMON /AERORESIS/ RAVT,RAVS,SWRAT
   OPEN(100,FILE='RESISTANCE.DAT',STATUS='UNKNOWN')
   OPEN(200,FILE='VARIABLE.DAT',STATUS='UNKNOWN')
! PP --PORE WATER PRESSURE
   IF (MSR.EQ.0) THEN
   SURFRSIS=0.D0
   ELSEIF(MSR.EQ.1)THEN
   SURFRSIS=-8.05D2+4.14D3*POR*(1-SW)
   ELSEIF(MSR.EQ.2)THEN
   SURFRSIS=3.5D0*SW**(-2.3D0)+33.5D0
   ELSEIF(MSR.EQ.3)THEN
   SURFRSIS=3.D10*(POR*(1-SW))**16.6D0
   ELSEIF(MSR.EQ.4)THEN
   SURFRSIS=10.D0*EXP(35.63D0*POR*(0.375D0-SW))
!  SEE PAGE 98(4) FOR REFERENCE
   ELSEIF(MSR.EQ.5)THEN
!  AA IS THE FIRST ARGUMENT OF THE HYPERGEOMETRIC FUNCTION WARNING:
!    ONE SHOULD INPUT A VARIABLE IN
!    FUNCTION HYGFX RATHER THAN A VALUE!!!
     AA=1.D0
!  CONVERT PORE WATER PRESSURE (NEGATIVE) [PP] INTO CAPLIIARY HEAD
!    (M)
     PSIC=-PP/9.8D3
!    CHECKING THE SOIL CHARACTERISTIC PARAMETERS
     IF(KREG.EQ.3)THEN
       DLAM=DLAM3
       PSICB=PSICB3
     ELSEIF(KERG.EQ.4)THEN
       DLAM=DLAM4   
       PSICB=PSICB4   
     ENDIF
!    EVALUATING RS BY DIFFERENT PSIC VALUE
     IF (PSIC.LE.PSICB)THEN
       SURFRSIS=0.D0
     ELSEIF (PSIC.GT.PSICB)THEN
       ETI=ETR*DLOG(PSIC0/PSIC)/DLOG(PSIC0)
       ETRMS=1.D0-ETI
       ETB=ETR*DLOG(PSIC0/PSICB)/DLOG(PSIC0)
       ETBMS=1.D0-ETB
!      (E)FFECTIVE (S)ATURATION
       SE=(PSICB/PSIC)**DLAM
!      PORSE
       PORSE=POR*SE
!      PARAMETER IN THE HYPERGEOMETRIC
       C=(1/PORSE-1/SQRT(PORSE))/2.D0/TAL
!      PARAMETER WHEN SE=1
       C0=(1/POR-1/SQRT(POR))/2.D0/TAL
       DNUM=SE**EC*HYGFX(AA,DLAM,1+DLAM,C*ZETA/PSIC)*ETRMS+ETI
       DNOM=HYGFX(AA,DLAM,1+DLAM,C0*ZETA/PSICB)*ETBMS+ETB
       DNET=DNUM/DNOM
! IS A QUESTION WHY THE EQUATION IS FORMULATED AS THIS?
       SURFRSIS=RAVT/DNET-RAVT
     ENDIF
! SURFACE RESISTANCE AFTER THE APPROXIMATION SEE PAGE 
   ELSEIF(MSR.EQ.6)THEN
!  CONVERT PORE WATER PRESSURE (NEGATIVE) [PP] INTO CAPLIIARY HEAD 
!    (M)
     PSIC=-PP/GVA/RHOW0
!    CHECKING THE SOIL CHARACTERISTIC PARAMETERS
     IF(KREG.EQ.3)THEN
       DLAM=DLAM3
       PSICB=PSICB3
     ELSEIF(KERG.EQ.4)THEN
       DLAM=DLAM4   
       PSICB=PSICB4   
     ENDIF
!    EVALUATING RS BY DIFFERENT PSIC VALUE
     IF (PSIC.LE.PSICB)THEN
       SURFRSIS=0.D0
     ELSEIF (PSIC.GT.PSICB)THEN
       ETI=ETR*DLOG(PSIC0/PSIC)/DLOG(PSIC0)
       ETRMS=1.D0-ETI
!      (E)FFECTIVE (S)ATURATION AFTER G FUNCTION
       SET=(PSICB/PSIC)**(DLAM*(1+EC))
!      POR*SET
       PORSE=POR*SET
!      PARAMETER IN THE HYPERGEOMETRIC
       C=(1/PORSE-1/SQRT(PORSE))/2.D0/TAL
!      EXPECTANT VALUE OF R1 AT GIVEN MATRIC POTENTIAL 
!      (UNDER BROOKS&COREY)
!      SEE EQUATION (A1) OF PAPER 2
       R1EFF=-DLAM*ZETA/(DLAM+1)/PSIC
       RELKV=1/(1+C*R1EFF)*ETRMS+ETI
       SURFRSIS=TAL/DVA(TSK)/RELKV
     ENDIF
! SURFACE RESISTANCE AFTER THE APPROXIMATION SEE PAGE 229
   ELSEIF(MSR.EQ.7)THEN
!  CONVERT PORE WATER PRESSURE (NEGATIVE) [PP] INTO CAPLIIARY HEAD 
!    (M)
     PSIC=-PP/GVA/RHOW0
!    CHECKING THE SOIL CHARACTERISTIC PARAMETERS
     IF(KREG.EQ.3)THEN
       DLAM=DLAM3
       PSICB=PSICB3
     ELSEIF(KERG.EQ.4)THEN
       DLAM=DLAM4   
       PSICB=PSICB4   
     ENDIF
!    EVALUATING RS BY DIFFERENT PSIC VALUE
     IF (PSIC.LE.PSICB)THEN
       SURFRSIS=0.D0
     ELSEIF (PSIC.GT.PSICB)THEN
!      KVRV INDUCED BY VAPOR AT STAGE IV SEE PAGE 229
       ETI=COER*0.66D0*TAL*POR*DLOG(PSIC0)/(YY*DLOG(PSIC+PSIP))
!      (E)FFECTIVE (S)ATURATION AFTER G FUNCTION
       SET=(PSICB/PSIC)**(DLAM*(1+EC))
!      POR*SET
       PORSE=POR*SET
!      PARAMETER IN THE HYPERGEOMETRIC
       C=(1/PORSE-1/SQRT(PORSE))/2.D0/TAL
!      EXPECTANT VALUE OF R1 AT GIVEN MATRIC POTENTIAL 
!      (UNDER BROOKS&COREY)
!      SEE EQUATION (A1) OF PAPER 2
       R1EFF=-DLAM*ZETA/(DLAM+1)/PSIC
       RELKV=1/(1+C*R1EFF)+(1-SW)*ETI
       SURFRSIS=TAL/DVA(TSK)/RELKV
     ENDIF
   ELSEIF(MSR.EQ.8)THEN
!  CONVERT PORE WATER PRESSURE (NEGATIVE) [PP] INTO CAPLIIARY HEAD 
!    (M)
     PSIC=-PP/GVA/RHOW0
!    CHECKING THE SOIL CHARACTERISTIC PARAMETERS
     IF(KREG.EQ.3)THEN
       DLAM=DLAM3
       PSICB=PSICB3
     ELSEIF(KERG.EQ.4)THEN
       DLAM=DLAM4   
       PSICB=PSICB4   
     ENDIF
!    EVALUATING RS BY DIFFERENT PSIC VALUE
     IF (PSIC.LE.PSICB)THEN
       SURFRSIS=0.D0
     ELSEIF (PSIC.GT.PSICB)THEN
!      KVRV INDUCED BY VAPOR AT STAGE IV SEE PAGE 229
       ETI=COER*0.66D0*TAL*POR*DLOG(PSIC0)/(YY*DLOG(PSIC+PSIP))
       ETRMS=1.D0-ETI
!      (E)FFECTIVE (S)ATURATION AFTER G FUNCTION
       SET=(PSICB/PSIC)**(DLAM*(1+EC))
!      POR*SET
       PORSE=POR*SET
!      PARAMETER IN THE HYPERGEOMETRIC
       C=(1/PORSE-1/SQRT(PORSE))/2.D0/TAL
!      EXPECTANT VALUE OF R1 AT GIVEN MATRIC POTENTIAL 
!      (UNDER BROOKS&COREY)
!      SEE EQUATION (A1) OF PAPER 2
       R1EFF=-DLAM*ZETA/(DLAM+1)/PSIC
       RELKV=1/(1+C*R1EFF)*ETRMS+ETI
       SURFRSIS=TAL/DVA(TSK)/RELKV
     ENDIF !PSIC
!  SEE PAGE 230, THE RESISTANCE INDUCED BY VAPOR BECOMES NON-TRIVAL WHEN THE 
!  NSL IS THIN.
   ELSEIF(MSR.EQ.9)THEN
!  CONVERT PORE WATER PRESSURE (NEGATIVE) [PP] INTO CAPLIIARY HEAD 
!    (M)
     PSIM=PP/GVA/RHOW0
     PSIC=-PSIM
!    CHECKING THE SOIL CHARACTERISTIC PARAMETERS
     IF(KREG.EQ.3)THEN
       DLAM=DLAM3
       PSICB=PSICB3
     ELSEIF(KERG.EQ.4)THEN
       DLAM=DLAM4   
       PSICB=PSICB4   
     ENDIF
!    EVALUATING RS BY DIFFERENT PSIC VALUE
     IF (PSIC.LE.PSICB)THEN
       SURFRSIS=0.D0
     ELSEIF (PSIC.GT.PSICB)THEN
!      KVRV INDUCED BY VAPOR AT STAGE IV SEE PAGE 229,231
       ETI=COER*0.66D0*TAL*POR*DLOG(PSIC0)/(YY*DLOG(PSIC+PSIP))
       ETI=1.D0/(1.D0/ETI+ETR)
       ETRMS=1.D0-ETI
!      (E)FFECTIVE (S)ATURATION AFTER G FUNCTION
       SET=(PSICB/PSIC)**(DLAM*(1+EC))
!      POR*SET
       PORSE=POR*SET
!      PARAMETER IN THE HYPERGEOMETRIC
       C=(1/PORSE-1/SQRT(PORSE))/2.D0/TAL
!      EXPECTANT VALUE OF R1 AT GIVEN MATRIC POTENTIAL 
!      (UNDER BROOKS&COREY)
!      SEE EQUATION (A1) OF PAPER 2
       R1EFF=-DLAM*ZETA/(DLAM+1)/PSIC
       RELKV=1/(1+C*R1EFF)*ETRMS+ETI
       SURFRSIS=TAL/DVA(TSK)/RELKV
	   SLENSL=(PSICB/PSIC)**DLAM
     ENDIF !PSIC
   ELSEIF(MSR.EQ.10)THEN
!  NEW SURFACE RESISTANCE MODEL OF FUNNEL SHAPED TSL 
!  WITH VAN GENUCHTEN MODEL
!  CONVERT PORE WATER PRESSURE (NEGATIVE) [PP] INTO CAPLIIARY HEAD 
!    (M)
     PSIM=PP/GVA/RHOW0
     PSIC=-PSIM
!new parameters
	 R_M_AY = ZETA/PSIM
	 R_C_M = 3.5D-5
	 R_PARTICLE=3.5D-5
!    CHECKING THE SOIL CHARACTERISTIC PARAMETERS
     IF(KREG.EQ.1)THEN         
       SWRES=  SWRES1
       AA   =  -AA1
       VN   =  VN1
     ELSEIF(KREG.EQ.2)THEN     
       SWRES=  SWRES2
       AA   =  -AA2
       VN   =  VN2
     ENDIF !KREG
	   R_0_AY= ZETA*AA*(AA*PSIM)**(VN-1)*((1+(AA*PSIM)**-VN)**(1-1/VN)-1)
!      CLEARLY IT IS FOUND THAT THE LAMBDA IN BK AND VN IN VAN IS NOT THE 
!      SAME. HOWEVER, WE ASSUME IT IS EQUIVALENT HERE (HAVEN'T TESTED YET)
!      KVRV INDUCED BY VAPOR AT STAGE IV SEE PAGE 229,231
!      ETI IS EQUATION 20 IN PAPER2
!new
	   R_2_M = R_0_AY + R_C_M
	   IF (R_M_AY.LT.R_0_AY)THEN
		 R_M_AY=R_0_AY
	   ENDIF	
	   THICKNESS_FUNNEL= R_PARTICLE/EXP(1/R_C_M*(R_M_AY-R_0_AY))
!      (E)FFECTIVE (S)ATURATION AFTER G FUNCTION
       SLENSL=(1+ (AA*PSIM)**VN)**(1/VN-1)
       SET = SLENSL**(1.D0+ECTO)
	   ETI=0.66D0*(TAL+THICKNESS_FUNNEL)*POR*DLOG(5.D4)/(YY*DLOG(PSIC+PSIP))
!new
!	   RELATIVE_WETTED_SURFACE=SET*(1-THICKNESS_FUNNEL*(1-POR)/R_PARTICLE)
	   RELATIVE_WETTED_SURFACE=SET*(R_M_AY**2/R_2_M**2)
	   IF (RELATIVE_WETTED_SURFACE.GT.1.D0)THEN
	     RELATIVE_WETTED_SURFACE=1.0D0
	   ENDIF	   
	   R_3_AY=R_M_AY/RELATIVE_WETTED_SURFACE**0.5D0
	   IF (R_2_M.GT.R_3_AY)THEN
		 R_2_AY=R_3_AY
	   ENDIF	
	   FREE_PATH_GAS_M=6.D-8
	   EVAPO_CAPILLARY=1/(1+R_3_AY**2*THICKNESS_FUNNEL/R_2_M**2/TAL+R_M_AY/2/TAL/RELATIVE_WETTED_SURFACE*&
         (2*FREE_PATH_GAS_M/R_M_AY+1/(1+FREE_PATH_GAS_M/R_M_AY)-RELATIVE_WETTED_SURFACE**0.5))
!      PARAMETER IN THE HYPERGEOMETRIC
!       C=(1.D0/PORSE-1.D0/SQRT(PORSE))/2.D0/TAL
!      EXPECTANT VALUE OF R1 AT GIVEN MATRIC POTENTIAL 
!      (UNDER BROOKS&COREY)
!      SEE EQUATION (A1) OF PAPER 2
!      RELKV=1.D0/(1.D0+C*R_0_AY)*ETRMS+ETI
	   RELKV=EVAPO_CAPILLARY*(1-ETI)+ETI
!	   SURFRSIS=TAL/2.62D-5*(1/RELKV-1)
       SURFRSIS=TAL/DVA(TSK)*(1/RELKV-1)
!       RELKV=EVAPO_CAPILLARY*(1-ETI)+ETI
!       SURFRSIS=TAL/DVA(TSK)*(1/RELKV-1)  	
!      WRITE(66,1001)
!	  1001 FORMAT(7X,'PP', 7X, 'PSIM', 7X, 'SLENSL', 7X, 'SURFRSIS') ! MSR
   ELSEIF(MSR.EQ.11)THEN
!  NEW SURFACE RESISTANCE MODEL OF FUNNEL SHAPED TSL 
!  WITH BROOKS&COREY MODEL
!  CONVERT PORE WATER PRESSURE (NEGATIVE) [PP] INTO CAPLIIARY HEAD 
!    (M)
     PSIM=PP/GVA/RHOW0
     PSIC=-PSIM
!new parameters
	 R_M_AY = ZETA/PSIM
	 R_C_M = 3.5D-5
	 R_PARTICLE=3.5D-5
!    CHECKING THE SOIL CHARACTERISTIC PARAMETERS
     IF(KREG.EQ.3)THEN
       DLAM=DLAM3
       PSICB=PSICB3
     ELSEIF(KERG.EQ.4)THEN
       DLAM=DLAM4   
       PSICB=PSICB4   
     ENDIF
	   R_0_AY= (DLAM*R_M_AY)/(DLAM+1)
!      CLEARLY IT IS FOUND THAT THE LAMBDA IN BK AND VN IN VAN IS NOT THE 
!      SAME. HOWEVER, WE ASSUME IT IS EQUIVALENT HERE (HAVEN'T TESTED YET)
!      KVRV INDUCED BY VAPOR AT STAGE IV SEE PAGE 229,231
!      ETI IS EQUATION 20 IN PAPER2
!new
	   R_2_M = R_0_AY + R_C_M
	   IF (R_M_AY.LT.R_0_AY)THEN
		 R_M_AY=R_0_AY
	   ENDIF	
	   THICKNESS_FUNNEL= R_PARTICLE/EXP(1/R_C_M*(R_M_AY-R_0_AY))
!      (E)FFECTIVE (S)ATURATION AFTER G FUNCTION
       SLENSL=(PSICB/PSIC)**DLAM
       SET = SLENSL**(1.D0+ECTO)
	   ETI=0.66D0*(TAL+THICKNESS_FUNNEL)*POR*DLOG(5.D4)/(YY*DLOG(PSIC+PSIP))
!new
!	   RELATIVE_WETTED_SURFACE=SET*(1-THICKNESS_FUNNEL*(1-POR)/R_PARTICLE)
	   RELATIVE_WETTED_SURFACE=SET*(R_M_AY**2/R_2_M**2)
	   IF (RELATIVE_WETTED_SURFACE.GT.1.D0)THEN
	     RELATIVE_WETTED_SURFACE=1.0D0
	   ENDIF	   
	   R_3_AY=R_M_AY/RELATIVE_WETTED_SURFACE**0.5D0
	   IF (R_2_M.GT.R_3_AY)THEN
		 R_2_AY=R_3_AY
	   ENDIF	
	   FREE_PATH_GAS_M=6.D-8
	   EVAPO_CAPILLARY=1/(1+R_3_AY**2*THICKNESS_FUNNEL/R_2_M**2/TAL+R_M_AY/2/TAL/RELATIVE_WETTED_SURFACE*&
         (2*FREE_PATH_GAS_M/R_M_AY+1/(1+FREE_PATH_GAS_M/R_M_AY)-RELATIVE_WETTED_SURFACE**0.5))
	   RELKV=EVAPO_CAPILLARY*(1-ETI)+ETI
!	   SURFRSIS=TAL/2.62D-5*(1/RELKV-1)
       SURFRSIS=TAL/DVA(TSK)*(1/RELKV-1)
   ENDIF ! MSR
	   WRITE(100,1001) PP, PSIM, SLENSL, SURFRSIS
!	   WRITE(200,1002) ETI, EVAPO_CAPILLARY, R_0_AY, RELKV, R_3_AY	   
	   1001 FORMAT(4E15.6,",") 
   IF (SURFRSIS.LT.0.D0) SURFRSIS=0.D0
   RETURN 
   END FUNCTION SURFRSIS

