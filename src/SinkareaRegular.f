C       SINKAREA IS TO CALCULATE THE AREA THAT GOES ACROSS THE NODE 
!!!!!!! THIS IS VERY IMPORTANT!!!!!!!!!!!!!!!!
C STORING AT
C HAREA(HORIZONTAL AREA), VAREA(VERTICAL AREA) AND FAREA(FACEAREA)
C , AS WELL AS THE
C SIZE OF THE AREA (XX,YY,ZZ). 
C ALL OF THESE RESULTS IS STORED IN THE FILE BCO.DAT
C THE SECOND PART OF THE BCO.DAT WILL BE OUTPUT BY SUBROUTINE ETOPT
C THE EXPLANATION OF THIS PART CAN BE FOUND FROM NOTEBOOK 3 PAGE 103
C IT HAS BEEN PROVED THAT THIS METHOD WILL APLLY FOR THE SYLINDRICAL
C PROBLEM IN 2D
C IN BUILD0008 THE ARGORITHM HAS BEEN CHANGED SO THAT THE HAREA ARE 
C NOLONGER DEVIDED AT THE MIDDLE OF THE 
C ELEMENT. THIS IS TRUE WHEN THE NEIGHBOURING NODE HAS TWO DIFFERENT 
C SIZE.
C IN BUILD0008, SINKAREA IS PRESERVED FOR REGULAR Z. FOR IRREGULAR Z, 
C ONE HAS TO CONSIDER CALLING SINKAREACYLINDER
C   HANN -- THE CROSS SECTION AREA OF THE TOP FACE STORED IN THE 
C           SEQUENCE OF NN
C   VANN -- THE CROSS SECTION AREA OF THE LEFT FACE STORED IN THE
C           SEQUENCE OF NN
C   FANN -- THE CROSS SECTION AREA OF THE FRONT FACE STORED IN THE
C   SEQUENCE OF NN
      SUBROUTINE SINKAREA(X,Y,Z,HAREA,VAREA,FAREA,IQSOP,NDPT,NREF
     1,YY,XX,VOL,HANN,VANN,FANN)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON /DIMS/ NN,NE,NIN,NBI,NCBI,NB,NBHALF,NPBC,NUBC,
     1   NSOP,NSOU,NBCN,NCIDB
      COMMON /SOLVI/ KSOLVP, KSOLVU, NN1, NN2, NN3
      COMMON /DEPTH/  MXD,NFY
      DIMENSION X(NN),Y(NN),Z(NN),HAREA(NSOP),VAREA(NSOP),FAREA(NSOP)
     1,IQSOP(NSOP),YY(NN),XX(NN),VOL(NN)
      DIMENSION HANN(NN),VANN(NN),FANN(NN)
	INTEGER NDPT(NSOP)
	INTEGER NREF(NSOP)
C.....NSOPI IS ACTUAL NUMBER OF FLUID SOURCE NODES 
	NSOPI=NSOP-1
	DO 600 IQP=1,NSOPI
      I=IQSOP(IQP)                                                   
      IF(I) 500,600,600 
 ! ASSIGN P-E VALUE, IQP=1 INDICATES ASSIGNMENT ON THE FIRST NODE
500   IF (NREF(IQP).EQ.1) THEN 
	   XX(IABS(I))=(X(IABS(I)+NN1)-X(IABS(I)))/2.D0
	 ELSEIF (NREF(IQP).EQ.NFY) THEN
	   XX(IABS(I))=(X(IABS(I))-X(IABS(I)-NN1))/2.D0
	 ELSE
	   XX(IABS(I))=(X(IABS(I)+NN1)-X(IABS(I)-NN1))/2.E0
	 ENDIF
	 
	 
	IF (NDPT(IQP).EQ.1) THEN
	   YY(IABS(I))=(Y(IABS(I))-Y(IABS(I)-1))/2.D0
	ELSEIF (NDPT(IQP).EQ.MXD)THEN
	   YY(IABS(I))=(Y(IABS(I)+1)-Y(IABS(I)))/2.D0
	ELSE
	   YY(IABS(I))=(Y(IABS(I)+1)-Y(IABS(I)-1))/2.D0
	ENDIF
	

C.......THE ARGORITM FOR HAREA HAS BEEN PROVED APPROPRIATE FOR 
C       CYLINDRICAL AXIS COORDINATES SEE P103-104 OF NOTEBOOK 3
C.......THIS METHOD IS ALSO APPLICATABLE FOR REGULAR Z
C.......THE P103-P104 METHOD IS NOT WORKING FOR THE RADIUS PROBLEMS
C       DUE TO GAUSSIAN QUADRATURE BEING NOT DEVIDED AT THE MIDDLE.
C.......SO THE MOST PRECISE WAY OF CALCULATING HAREA WOULD BE USING
CVOL/Y. THIS NEW METHOD WORKS WHEN NODE HEIGHT AT VERTICAL DIRECTION (Y)
C       DOES NOT CHANGE(WHICH MEANS THE CELL IS SHAPED LIKE A POLE)
        IF (NREF(IQP).EQ.1)THEN
         HAREA(IQP)=XX(IABS(I))*(0.75*Z(IABS(I))+0.25*Z(IABS(I)+NN1))
        ELSEIF (NREF(IQP).EQ.NFY) THEN
         HAREA(IQP)=XX(IABS(I))*(0.75*Z(IABS(I))+0.25*Z(IABS(I)-NN1)) 
        ELSE
	 HAREA(IQP)=XX(IABS(I))*Z(IABS(I))
        ENDIF
	VAREA(IQP)=YY(IABS(I))*Z(IABS(I))
	FAREA(IQP)=XX(IABS(I))*YY(IABS(I))
        HANN(IABS(I))=HAREA(IQP)
        VANN(IABS(I))=VAREA(IQP)
        FANN(IABS(I))=FAREA(IQP)
600	CONTINUE
	OPEN(21,FILE='BCO.DAT',STATUS='UNKNOWN')
	WRITE(21,2)

2	FORMAT('NODE',13X,'X',12X,'Y',12X,'Z',8X,'XX',11X,'YY',11X
     2,'HAREA',8X
     1,'VAREA',8X,'FAREA',11X,'VOL')
	DO 1 IQP=1,NSOPI
	I=IQSOP(IQP)
        WRITE(21,3) IABS(I), X(IABS(I)),Y(IABS(I)),Z(IABS(I)),
     1 XX(IABS(I)),YY(IABS(I)),HAREA(IQP),VAREA(IQP),FAREA(IQP)
     2,VOL(IABS(I))
3	FORMAT(I5,1X,9(1PE12.5,1X))
1	CONTINUE
	CLOSE(21)
	RETURN
	END

C......SUBROUTINE SINKAREACYLINDER IS SET TO CALCULATE HAREA(NSOP)(AREA
C       FROM AERIAL VIEW XZ PLANE), VAREA(NSOP)(AREA IN THE YZ PLANE)
C      AND FAREA(NSOP)(AREA IN THE XY PLANE)
C......THE ARGORITHM FOR HAREA IS ( THE VOLUME OF THE CELL )/(DEPTH OR 
CSAY DISTANCE OF Y OF THE CELL). THIS METHOD IS USEFULL WHEN Z VALUE IS
C NOT THE SAME
C      IN EACH CELL, BUT YY (HEIGHT OF THE CELL) OF THE TOP CELL ROW IS
C       THE SAME.
C......FOR CYLINDRICAL PROBLEMS, BASED ON THE SURFACE AREA HAREA, ONE
C CAN WORK OUT WHERE IS THE LOCATION OF THE SEPARATION EXACTLY. THIS
C      LOCATION IS VERY IMPORTANT
C      FOR FINDING THE EXACT RESULT OF VAREA, WHICH IS USED FOR 
C CALCULATING THE WATER VAPOR FLOW.
C......HOWEVER, IT IS STILL NOT KNOWN HOW THE FOUR GAUSSIAN INTEGRATION
C REPRESENTS. THIS NEEDS TO BE DONE IN THE FUTURE WORK.
C......WARNING!!!!IF APPLYING THIS ALGORITHM, THE HORIZONTAL
C VAPOR TRANSPORT EQUATION HAS TO BE REPLACED
       SUBROUTINE SINKAREACYLINDRICAL(X,Y,Z,HAREA,VAREA,FAREA,IQSOP,NDPT
     1,NREF,YY,XX,VOL)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON /DIMS/ NN,NE,NIN,NBI,NCBI,NB,NBHALF,NPBC,NUBC,
     1   NSOP,NSOU,NBCN,NCIDB
      COMMON /SOLVI/ KSOLVP, KSOLVU, NN1, NN2, NN3
      COMMON /DEPTH/  MXD,NFY
      DIMENSION X(NN),Y(NN),Z(NN),HAREA(NSOP),VAREA(NSOP),FAREA(NSOP)
     1   ,IQSOP(NSOP),YY(NN),XX(NN),VOL(NN)
      INTEGER NDPT(NSOP)
      INTEGER NREF(NSOP)
C..... R(NN) IS USED TO STORE THE RADIUS OF CELL AT THE RIGHTOUS 
CFACE SEE NB3P125
      DIMENSION R(NN)
C.....NSOPI IS ACTUAL NUMBER OF FLUID SOURCE NODES 
	NSOPI=NSOP-1
      DO 600 IQP=1,NSOPI
      I=IQSOP(IQP)                                                   
      IF(I) 500,600,600 
 500  IF (NDPT(IQP).EQ.1) THEN
           YY(IABS(I))=(Y(IABS(I))-Y(IABS(I)-1))/2.D0
      ELSEIF (NDPT(IQP).EQ.MXD)THEN
           YY(IABS(I))=(Y(IABS(I)+1)-Y(IABS(I)))/2.D0
      ELSE
           YY(IABS(I))=(Y(IABS(I)+1)-Y(IABS(I)-1))/2.D0
      ENDIF

C....CALCULATING HAREA BASED ON HAREA=VOLUME OF CELL/HEIGHT OF CELL. 
CTHE HAREA IS AT THE SURFACE WHERE
C    THE NODE CROSSES
      HAREA(IQP)=VOL(IABS(I))/YY(IABS(I))
C....CALCULATING VAREA BASED ON VAREA=2*PI*R*YY. HERE R IS THE RADIUS 
COF THE CELL [[AT THE RIGHT SURFACE]]
C    SEE P125NB3, BECAUSE VAREA IS ONLY USED IN WATER VAPOR
C FLOW CALCULATION, AND VAREA SHOULD PRECISELY LOCATED
C    AT THE INTERFACE BETWEEN THE ELEMENT, WHICH IS PROVED NOT AT THE
C MIDDLE WHEN Z IS NOT REGULAR DUE TO GAUSSIAN
C    INTEGRATION
      IF(NREF(IQP).EQ.1)THEN ! NREF(IQP)=1 INDICATES NODE IS AT THE
C LEFTMOST COLUMN
        R(IABS(I))=SQRT(HAREA(IQP)/3.1415926)
        XX(IABS(I))=R(IABS(I))
      ELSE   ! THIS APPLIES FOR ALL OF THE NODES NOT IN THE FIRST COLUMN
        R(IABS(I))=SQRT(HAREA(IQP)/3.1415926+R(IABS(I)-NN1)**2)
        XX(IABS(I))=R(IABS(I))-R(IABS(I)-NN1)
      ENDIF
C.....VAREA IS ALSO DEFINED AS THE AREA AT THE RIGHTMOST SURFACE 
COF THE CELL, THIS METHOD APPLIES WHEN YY DOES NOT
C     CHANGE IN ONE ROW OF ELEMENT. SEARCH" AET=AET*RHOWP*VAREA(IQP) "
	VAREA(IQP)=YY(IABS(I))*2.*3.1415926*R(IABS(I))
C.....FAREA IS THE AREA AT XY PLANE
	FAREA(IQP)=XX(IABS(I))*YY(IABS(I))
600	CONTINUE
	OPEN(21,FILE='BCO.DAT',STATUS='UNKNOWN')
	WRITE(21,2)
2	FORMAT('NODE',13X,'X',12X,'Y',12X,'Z',8X,'XX',11X,'YY',11X,
     1'HAREA',8X
     1,'VAREA',8X,'FAREA',11X,'R')
	DO 1 IQP=1,NSOPI
	I=IQSOP(IQP)
        WRITE(21,3) IABS(I), X(IABS(I)),Y(IABS(I)),Z(IABS(I)),
     1 XX(IABS(I)),YY(IABS(I)),HAREA(IQP),VAREA(IQP),FAREA(IQP)
     2,R(IABS(I))
3	FORMAT(I5,1X,9(1PE12.5,1X))
1	CONTINUE
	CLOSE(21)
	RETURN
	END

