Device "MOS" {
  File {
    Grid    = "@tdr@"
    Plot    = "@tdrdat@"
    Current = "@plot@"
    Parameter = "@parameter@"
  }

  Electrode {
    { Name="SN" Voltage=0.0 }
    { Name="DN" Voltage=0.0 }
    { Name="G"  Voltage=0.0 }
    { Name="SP" Voltage=0.0 }
    { Name="DP" Voltage=0.0 }
  }

  Physics {
    eQuantumPotential
    hQuantumPotential
    Mobility( PhuMob DopingDep HighFieldsaturation(GradQuasiFermi) Enormal )
    EffectiveIntrinsicDensity(BandGapNarrowing(OldSlotboom))
    Recombination( SRH(DopingDependence) Auger(WithGeneration) )
  }

  Physics (Material="Silicon") {
    eMultiValley(MLDA kpDOS -Density)
    hMultiValley(MLDA kpDOS -Density)
    Mobility( Enormal(Lombardi_highk) HighFieldSaturation(EparallelToInterface) )
  }
}

File {
  Output    = "@log@"
  ACExtract = "@acplot@"
}

Math {
  # Efficiency solver for DC to avoid "Unable to allocate memory"
  Method=ILS(MaxIter=100)
  SubMethod=Super
  Number_of_Threads=Maximum
  
  Digits=8
  RelErrControl
  Extrapolate
  Derivatives
  Damping
  LineSearch

  # Robust solver for AC to prevent spikes and negative values
  ACMethod=Blocked
  ACSubMethod=Pardiso
}

System {
  MOS nmos1 ("SN"=sn "DN"=dn "G"=g "SP"=sp "DP"=dp)
  Vsource_pset vsn (sn 0) { dc = 0.0 }
  Vsource_pset vdn (dn 0) { dc = 0.0 }
  Vsource_pset vsp (sp 0) { dc = 0.0 }
  Vsource_pset vdp (dp 0) { dc = 0.0 }
  Vsource_pset vg  (g  0) { dc = 0.0 }
}

Solve {
  # 1. Robust Initial Solutions
  Coupled(Iterations=100) { Poisson eQuantumPotential hQuantumPotential }
  Coupled { Poisson Electron Hole eQuantumPotential hQuantumPotential }

  # 2. Ramp Drain Voltages
  NewCurrentPrefix="RampVd_"
  Quasistationary (
    InitialStep=0.01 MaxStep=0.05 
    Goal { Parameter=vdn.dc Voltage=1.0 }
    Goal { Parameter=vdp.dc Voltage=-1.0 }
  ) { Coupled { Poisson Electron Hole eQuantumPotential hQuantumPotential } }

  # 3. Stabilized AC Sweep for Cgg
  NewCurrentPrefix="AC_"
  Quasistationary (
    InitialStep=0.01 
    MaxStep=0.02    # Larger step for faster completion with ILS backbone
    Goal { Parameter=vg.dc Voltage=1.0 }
  ) {
    ACCoupled (
      StartFrequency=1e6 EndFrequency=1e6 NumberOfPoints=1 Decade
      Node(g) Exclude(vg) 
    ) { Poisson Electron Hole }
  }
}
