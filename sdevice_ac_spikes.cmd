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

  Thermode {
    { Name="G"  Temperature=300 }
    { Name="DN" Temperature=300 }
    { Name="SN" Temperature=300 }
    { Name="DP" Temperature=300 }
    { Name="SP" Temperature=300 }
  }

  Physics(Material="TiN") {
    MetalWorkFunction(WorkFunction=4.915)
  }

  Physics(Material="Aluminum") {
    MetalWorkFunction(WorkFunction=4.58)
  }

  Physics {
    eQuantumPotential
    hQuantumPotential
    Mobility(
      PhuMob
      DopingDep
      HighFieldsaturation( GradQuasiFermi )
      Enormal
    )
    EffectiveIntrinsicDensity(BandGapNarrowing(OldSlotboom))
    Recombination(
      SRH(DopingDependence)
      Auger(WithGeneration)
    )
  }

  Physics (Material="Silicon") {
    eMultiValley(MLDA kpDOS -Density)
    hMultiValley(MLDA kpDOS -Density)
    Mobility(
      Enormal(Lombardi_highk)
      HighFieldSaturation(EparallelToInterface)
    )
  }
}

File {
  Output    = "@log@"
  ACExtract = "@acplot@"
}

Math {
  Method=ILS
  Number_of_Threads=Maximum
  Digits=10
  Iterations=50
  Notdamped=100
  RelErrControl
  ErRef(Electron)=1.e12
  ErRef(Hole)=1.e12
 
  # AC Settings
  ACMethod=Blocked
  ACSubMethod=Super
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
  # 1. Initial solution: Step-by-step coupling to ensure convergence at t=0
  Coupled(Iterations=100) { Poisson eQuantumPotential hQuantumPotential }
  Coupled { Poisson Electron Hole eQuantumPotential hQuantumPotential }

  # 2. Ramp Drains to operating voltage
  NewCurrentPrefix="RampVd_"
  Quasistationary (
    InitialStep=0.01 MaxStep=0.05 MinStep=1e-5
    Goal { Parameter=vdn.dc Voltage=1.0 }
    Goal { Parameter=vdp.dc Voltage=-1.0 }
  ) { Coupled { Poisson Electron Hole eQuantumPotential hQuantumPotential } }

  # 3. AC Sweep (Gate Voltage sweep from 0V to 1V)
  NewCurrentPrefix="AC_"
  Quasistationary (
    InitialStep=0.005 MaxStep=0.05 MinStep=1e-6
    Goal { Parameter=vg.dc Voltage=1.0 }
  ) {
    ACCoupled (
      StartFrequency=1e6 EndFrequency=1e6 NumberOfPoints=1 Decade
      Node(sn dn sp dp g) Exclude(vsn vdn vsp vdp vg)
      ACCompute (Time = (Range = (0 1) Intervals = 40))
    ) { Poisson Electron Hole eQuantumPotential hQuantumPotential }
  }
}
