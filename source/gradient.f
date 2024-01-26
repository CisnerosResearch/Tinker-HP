c
c     Sorbonne University
c     Washington University in Saint Louis
c     University of Texas at Austin
c     University of North Texas
c
c     ##################################################################
c     ##                                                              ##
c     ##  subroutine gradient  --  find energy & gradient components  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     "gradient" calls subroutines to calculate the potential energy
c     and first derivatives with respect to Cartesian coordinates
c
c
      subroutine gradient (energy,derivs)
      use sizes
      use deriv
      use domdec
      use energi
      ! GAC
      use gemstuff
      use mdstuf, only : useGEM
      !GAC
      use inter
      use iounit
      use potent
      use timestat
      use vdwpot
      use virial
      use mpi
      implicit none
      integer h,j,k
      real*8 energy
      real*8 derivs(3,nbloc)
      real*8 time0,time1,time2
      logical isnan
c
c
c     zero out each of the potential energy components
c
      eb = 0.0d0
      ea = 0.0d0
      eba = 0.0d0
      eub = 0.0d0
      eaa = 0.0d0
      eopb = 0.0d0
      eopd = 0.0d0
      eid = 0.0d0
      eit = 0.0d0
      et = 0.0d0
      ept = 0.0d0
      ebt = 0.0d0
      ett = 0.0d0
      ev = 0.0d0
      er = 0.0d0
      edsp = 0.0d0
      ect = 0.0d0
      ec = 0.0d0
      em = 0.0d0
      ep = 0.0d0
      eg = 0.0d0
      ensmd = 0.0d0
      ex = 0.0d0
c
c     zero out each of the first derivative components
c
      deb = 0d0
      dea = 0d0
      deba = 0d0
      deub = 0d0
      deaa = 0d0
      deopb = 0d0
      deopd = 0d0
      deid = 0d0
      deit = 0d0
      det = 0d0
      dept = 0d0
      debt = 0d0
      dett = 0d0
      dev = 0d0
      der = 0d0
      dedsp = 0d0
      dect = 0d0
      dec = 0d0
      dem = 0d0
      dep = 0d0
      deg = 0d0
      desmd = 0d0
      dex = 0d0
c
c     zero out the virial and the intermolecular energy
c
      vir = 0d0
      virsave = 0d0
      einter = 0.0d0
c
c     call the local geometry energy and gradient routines
c
      time0 = mpi_wtime()
      if (use_bond)  call ebond1
      if (use_strbnd)  call estrbnd1
      if (use_urey)  call eurey1
      if (use_angang)  call eangang1
      if (use_opbend)  call eopbend1
      if (use_opdist)  call eopdist1
      if (use_improp)  call eimprop1
      if (use_imptor)  call eimptor1
      if (use_tors)  call etors1
      if (use_pitors)  call epitors1
      if (use_strtor)  call estrtor1
      if (use_tortor)  call etortor1
      if (use_angle)  call eangle1
      time1 = mpi_wtime()
      timebonded = timebonded + time1-time0
c
c     call the van der Waals energy and gradient routines
c
      if (use_vdw) then
         if (.not. useGEM) then
            if (vdwtyp .eq. 'LENNARD-JONES')  call elj1
            if (vdwtyp .eq. 'BUFFERED-14-7')  call ehal1
         else
            ! GAC: call modified Halgren for GEM dispersion
            call ehalgem
         end if
      end if
      if (use_repuls)  call erepel1
      if (use_disp)  call edisp1
c
c     call the electrostatic energy and gradient routines
c
      if (use_charge) then
         if(.not. useGEM)  call echarge1
      endif
      !if (use_mpole)  call empole1
      ! GAC for GEM NOTE: mpole needs to be set to true for frames
      if (use_mpole) then
         if (.not. useGEM) then
            call empole1
         else ! GAC: this calculates Coulomb AND Exchange!
            call empoleGEM
            if (rank .eq. 0) call egemcx ! make sure to run on one cpu
         endif
      endif
      ! GAC end for GEM 
      !do j = 1,nbloc
      !   write(iout,*)'der ',(dev(k,j)+dem(k,j)+demrec(k,j),k=1,3)
      !enddo 
      !write(iout,*)'--------------------------------------------------'
      if (use_polar)  call epolar1
      !print *,'polarization = ',ep

      if (use_chgtrn)  call echgtrn1
c
c     call any miscellaneous energy and gradient routines
c
      if (use_geom)  call egeom1
      if (use_extra)  call extra1
      time2 = mpi_wtime()
      timenonbonded = timenonbonded + time2-time1
c
      if (use_smd_velconst .or. use_smd_forconst) call esmd1
c
c     sum up to get the total energy and first derivatives
c
      esum = eit + eopd + eopb + eaa + eub + eba + ea + eb + em + ep
     $       + ec + ev + er + edsp + ect +et + ept + ebt + ett + eg 
     $       + ex + eid + ensmd
      energy = esum
c
      desum = deaa + deba + dea + deb + dec + dem + deopb + deopd + deid
     $ + dep + dev + der + dedsp + dect +deub + deit + det + dept + debt
     $ + dett + deg + dex + desmd
c
      debond = deaa + deba + dea + deb + deopb + deopd + deid 
     $ + deub + deit + det + dept + debt + dett + deg

c
      derivs(:,1:nloc) = derivs(:,1:nloc) + desum(:,1:nloc)
c
c     check for an illegal value for the total energy
c
      if (isnan(esum)) then
         write (iout,10)
   10    format (/,' GRADIENT  --  Illegal Value for the Total',
     &              ' Potential Energy')
         call fatal
      end if
      return
      end
