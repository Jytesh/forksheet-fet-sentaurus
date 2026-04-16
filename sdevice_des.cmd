File {
Grid = "@tdr@"
Plot = "@tdrdat@"
Parameter= "sdevice.par"
Current = "@plot@"
ACExtract = "@acplot@"
Output = "@log@" }

Electrode {
{ Name="SN" Voltage=0.0  }
{ Name="DN" Voltage=0.0  }
{ Name="G" Voltage=0.0 }
{ Name="SP" Voltage=0.0  }
{ Name="DP" Voltage=0.0 }
*{ Name="Sub" Voltage=0.0  }
 }

* DriftDiffusion  

Thermode {
{ Name = "G" Temperature = 300}
{ Name = "DN" Temperature = 300 }
{ Name = "SN" Temperature = 300 }
{ Name = "DP" Temperature = 300 }
{ Name = "SP" Temperature = 300 }
}


Physics(Material="TiN")
{MetalWorkFunction(WorkFunction=4.915)
}

Physics(Material="Aluminum")
{MetalWorkFunction(WorkFunction=4.58)
}




Physics{
  hQuantumPotential
  eQuantumPotential
  Mobility(
    PhuMob
    DopingDep
    HighFieldsaturation( GradQuasiFermi )
       Enormal
    )
   EffectiveIntrinsicDensity(BandGapNarrowing ( OldSlotboom ))
  Recombination(
  SRH(DopingDependence)

)
  Recombination( Auger(WithGeneration))
  
 
 }
Physics (Material = "Silicon"){
  hQuantumPotential
  eQuantumPotential
  eMultiValley(MLDA kpDOS -Density)
  hMultiValley(MLDA kpDOS -Density)
  #Piezo(
   # Model(
    #  DeformationPotential(ekp hkp minimum)
     # DOS( emass hmass ) 
      #Mobility( eSubband(Fermi  EffectiveMass Scattering(MLDA) )
      #eSaturationFactor= 0.0
      #)
      #Mobility( hSubband(Doping EffectiveMass Scattering(MLDA) )
      #hSaturationFactor= 0.0
      #)
    #)
  #)
  Mobility(
    Enormal (Lombardi_highk )
    HighFieldSaturation( EparallelToInterface )
  )
 
     
  Recombination(
    SRH(DopingDependence TempDependence) 
    Auger 
  )
}

Physics {
Mobility (
DopingDependence ( PhuMob BalMob(Lch = 18.0) )
)
}


   
Math {
	Method=ILS                
  	Number_of_Threads=Maximum
   	Extrapolate     Iterations=50     Notdamped =100
   	RelErrControl     ErRef(Electron)=1.e12   ErRef(Hole)=1.e12 
}


Plot{
*--Density and Currents, etc
   eDensity hDensity   TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
   eMobility hMobility   eVelocity hVelocity ElectricField Potential SpaceCharge
   eQuasiFermi hQuasiFermi

*--Temperature
   eTemperature Temperature hTemperature

*--Fields and charges
   ElectricField/Vector Potential SpaceCharge

*--Doping Profiles
   Doping DonorConcentration AcceptorConcentration

*--Band structure/Composition
   BandGap    BandGapNarrowing   Affinity
   ConductionBand ValenceBand
   eQuantumPotential hQuantumPotential
}

Solve {
Poisson
Coupled { Poisson eQuantumPotential 
hQuantumPotential }

##############################################

Quasistationary
(InitialStep=0.01 Maxstep=0.05 MinStep=0.001
Goal { name="DN" voltage = 1 }
)
{ Coupled { Poisson Electron Hole eQuantumPotential hQuantumPotential}
CurrentPlot (time=(range=(0 1) intervals=20))
}
Save (FilePrefix="IdVdn")


Quasistationary
(InitialStep=0.01 Maxstep=0.05 MinStep=0.001
Goal { name="DP" voltage = -1 }
)
{ Coupled { Poisson Electron Hole eQuantumPotential hQuantumPotential}
CurrentPlot (time=(range=(0 1) intervals=20)) }

Save (FilePrefix="IdVdp")


##############################################

Load(FilePrefix="IdVdn")
NewCurrentPrefix="IdVgn"
Quasistationary
(InitialStep=0.001 Maxstep=0.05 MinStep=0.001
Goal{ name="G" voltage= 1 }
){ Coupled {Poisson Electron Hole eQuantumPotential hQuantumPotential}
CurrentPlot (time=(range = (0 1) intervals=20))}


Load(FilePrefix="IdVdp")
NewCurrentPrefix="IdVgp"
Quasistationary
(InitialStep=0.001 Maxstep=0.05 MinStep=0.001
Goal{ name="G" voltage= -1 }
){ Coupled {Poisson Electron Hole eQuantumPotential hQuantumPotential}
CurrentPlot (time=(range = (0 1) intervals=20))}
}


