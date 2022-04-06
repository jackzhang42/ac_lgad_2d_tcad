#define _Vc_ -500
#define _Voper_ -100
#define _Vwcathode_ -99
#define _Vwpad_ 100
#define _Vwanode_ 1
#define _QC_ 
#define _Tmodel_ 
#define _DF_ GradQuasiFermi
#define _EQ_ Poisson Electron Hole
#define _devEQ_ lgad.Poisson lgad.Electron lgad.Hole lgad.Contact circuit
#define _Imax_ 1e-8
#define _pad_ @pad@

File {
	Grid = "@tdr@"
	Plot = "@tdrdat@"
	Current = "@plot@"
	Output = "@log@"
	param = "@parameter@"
#	param = "models.par"
	ACExtract = "@acplot@"
}

Device LGAD {
	Electrode {
#if "@type@" == "ac"
		{ Name="Anode_left" Voltage= 0.0 }
		{ Name="Anode_right" Voltage= 0.0 }
		{ Name="pad_1" Voltage= 0.0 }
		{ Name="pad_2" Voltage= 0.0 }
		{ Name="pad_3" Voltage= 0.0 }

#if @pad_arrange@ == 5

		{ Name="pad_4" Voltage= 0.0 }
		{ Name="pad_5" Voltage= 0.0 }

#endif

#else
		{ Name="Anode" Voltage= 0.0 }
#endif
		{ Name="Cathode" Voltage= 0.0 }
		{ Name="gr_left" Voltage= 0.0 }
		{ Name="gr_right" Voltage= 0.0 }
	}
#if "@type@" == "ac"
	Thermode {
		{ Name="Anode_left" Temperature=300 }
		{ Name="Anode_right" Temperature=300 }
		{ Name="pad_1" Temperature=300 }
		{ Name="pad_2" Temperature=300 }
		{ Name="pad_3" Temperature=300 }

#if @pad_arrange@ == 5

		{ Name="pad_4" Temperature=300 }
		{ Name="pad_5" Temperature=300 }

#endif

		{ Name="Cathode" Temperature=300 }
		{ Name="gr_left" Temperature=300 }
		{ Name="gr_right" Temperature=300 }
	 }
#else
	Thermode {
		{ Name="Anode" Temperature=300 }
		{ Name="Cathode" Temperature=300 }
		{ Name="gr_left" Temperature=300 }
		{ Name="gr_right" Temperature=300 }
	}
#endif
}

System {
#if "@type@" == "ac"
#if @pad@ != 0
	Vsource_pset v0 (n@pad@ gnd_gr) {
		pwl = (
					0.0e+00 0.0
					2.0e-12 0.5
					4.0e-12 1.0
				)
	}
# never do pad 0 for ac type
#endif
#endif

#if @pad_arrange@ == 5
	LGAD lgad ("Anode_left" = gnd_anode_l "Anode_right" = gnd_anode_r "Cathode" = n0 "pad_1" = n1 
						 "pad_2" = n2 "pad_3" = n3 "pad_4" = n4 "pad_5" = n5 "gr_left" = gnd_gr "gr_right" = gnd_gr)
#else if @pad_arrange@ == 3
	LGAD lgad ("Anode_left" = gnd_anode_l "Anode_right" = gnd_anode_r "Cathode" = n0 "pad_1" = n1 
						 "pad_2" = n2 "pad_3" = n3 "gr_left" = gnd_gr "gr_right" = gnd_gr)

#endif

# nodes where pwl is applied should be commented except for gnd

#if @pad@ != 0
	Set (n0 = 0)
#endif
#if @pad@ !=1
	Set (n1 = 0)
#endif
#if @pad@ !=2
	Set (n2 = 0)
#endif
#if @pad@ !=3
	Set (n3 = 0)
#endif

#if @pad_arrange@ == 5

#if @pad@ !=4
	Set (n4 = 0)
#endif
#if @pad@ !=5
	Set (n5 = 0)
#endif

#endif

	Set (gnd_anode_l = 0)
	Set (gnd_anode_r = 0)

	Set (gnd_gr = 0)

#	Plot "nodes.plt" (time() gnd n@pad@)
}

Physics {
	_QC_
	_Tmodel_
	AreaFactor=1
	Fermi
	Mobility(
		DopingDependence
#		eHighFieldSaturation (_DF_)
#		hHighFieldSaturation (GradQuasiFermi)
		HighFieldSaturation(GradQuasiFermi)
		Enormal
		)
	Recombination(
		SRH( DopingDep )	
#		eAvalanche (_DF_)
		Auger(WithGeneration)
		Avalanche(Eparallel)
		Band2Band(E2)
		)
	EffectiveIntrinsicDensity(OldSlotboom)
}

CurrentPlot {
  AvalancheGeneration(Integrate(Semiconductor))
}

Plot {
	Potential
	ElectricField/Vector
	eDensity hDensity
	eMobility hMobility
	eCurrent/Vector hCurrent/Vector TotalCurrent/Vector
	Doping DonorConcentration AcceptorConcentration
	eTemperature hTemperature Temperature
	eAvalancheGeneration hAvalancheGeneration AvalancheGeneration
	HeavyIonChargeDensity
	eIonIntegral hIonIntegral MeanIonIntegral eAlphaAvalanche hAlphaAvalanche
	SRH Band2Band * Auger
}

Math {
	ImplicitACSystem
	NumberOfThreads= maximum
	Extrapolate
	digits= 8
	Notdamped= 100
	Iterations= 30
	RelErrControl
	Method= Blocked
	SubMethod= Pardiso
	Transient= BE
	ErRef(Electron)=1e10
	ErRef(Hole)=1e10
	CurrentWeighting
#	AvalPostProcessing
#	BreakCriteria{Current(Contact= "Anode_left" AbsVal= _Imax_)}
	ComputeIonizationIntegrals
#	BreakAtIonIntegral(3 1.1)
#	BreakCriteria{Current(Contact= "Cathode" AbsVal= _Imax_)}
}

Solve {
	NewCurrentPrefix= "init_"
	Coupled(Iterations=200){ Poisson _QC_ }
	Coupled{ _EQ_ _QC_}
	NewCurrentPrefix= "IV_"
	Quasistationary(
		InitialStep= 1e-7 MinStep= 1e-10 MaxStep= 0.01 Increment= 1.41
#		Goal{ Name="Cathode" Voltage= _Voper_ }
		Goal{ Node="n0" Voltage= _Voper_ }
# just for check
#		Goal{ Node="n2" Voltage= _Vwpad_ }
	)
#if "@type@" == "ac"
	{ Coupled { _devEQ_ _QC_}
#		CurrentPlot(Time=(Range=(0 1) Intervals=50))
		Plot (FilePrefix="normal_bias_@node@" Time=(1.0) NoOverwrite)
		}
#else
#	{ ACCoupled (
#		StartFrequency=1e3 EndFrequency=1e3 NumberOfPoints=1 Decade
#		Node(gnd_anode n0) Exclude(v0)
#		ACCompute (Time = (Range = (0 1.0) Intervals=50))
#		){ _devEQ_ _QC_ }
#		Plot (Time=(1.0) NoOverwrite)
#	}
	{ Coupled { _devEQ_ _QC_ }
		Plot (FilePrefix="normal_bias_@node@" Time=(1.0) NoOverwrite)
	}
#endif

#if "@type@" == "ac"
#if @pad@ != 0
	NewCurrentPrefix= "transramp_"
	Transient(
		InitialTime=0
		FinalTime=5e-9
		InitialStep=1e-14
		MaxStep=1e-10
		MinStep=1e-15
#		Plot { Range = (4e-12 5e-10) Intervals=5 decade }
	) { Coupled { _devEQ_ } 
		 Plot (
				FilePreFix="dynamic_n@node@"
				Time = (range=(4e-12 5e-9) intervals=50 decade)
				NoOverwrite
				) }
#endif
#endif
#if @pad@ == 0
	NewCurrentPrefix= "transramp"
			Quasistationary(
			InitialStep= 1e-5 MinStep= 1e-10 MaxStep=0.025 Increment= 1.41
			Goal{ Node="n0" Voltage= _Vwcathode_ }
			){ Coupled { _devEQ_ _QC_ } 
					Plot (FilePrefix="cathode_@node@" Time=(1.0) NoOverwrite)
			}
#endif
	System("rm init_lgad_LGAD_n@node@_des.plt")
}
