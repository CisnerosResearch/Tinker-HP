c
c     Sorbonne University
c     Washington University in Saint Louis
c     University of Texas at Austin
c
c     ##################################################################
c     ##                                                              ##
c     ##  module angle  --  bond angles within the current structure  ##
c     ##                                                              ##
c     ##################################################################
c
c
c     ak       harmonic angle force constant (kcal/mole/rad**2)
c     winak    window object corresponding to ak
c     anat     ideal bond angle or phase shift angle (degrees)
c     winanat    window object corresponding to anat
c     afld     periodicity for Fourier bond angle term
c     winafld    window object corresponding to afld
c     nangle   total number of bond angles in the system
c     iang     numbers of the atoms in each bond angle
c     winiang    window object corresponding to iang
c     nangleloc numbers of bond angles in the local domain
c     angleloc correspondance between global and local bond angles
c
c
      module angle
      implicit none
      integer nangle,nangleloc
      integer, allocatable :: angleloc(:)
      integer, pointer :: iang(:,:)
      real*8, pointer ::  ak(:),anat(:),afld(:)
      integer :: winiang,winak,winanat,winafld
      save
      end
