Controls { meshengine="snmesh" }


Definitions {

	Refinement "global" {
		MaxElementSize = (5 100)
		MinElementSize = (0.1 1)
		RefineFunction = MaxTransDiff(Variable = "DopingConcentration",Value = 1)
	}
  Refinement "nitride" {
		MaxElementSize = (0.02 2)
		MinElementSize = (0.01 0.1)
	}
	Refinement "others" {
		MaxElementSize = (0.2 2)
		MinElementSize = (0.1 0.1)
	}

	SubMesh "doping" {
		Geofile = "n@node|sprocess@_fps.tdr"
	}

}

Placements {

	SubMesh "doping" {
		Reference = "doping"
		SelectWindow {
			AttachPoint = (0 0 0)
			ToPoint = (0 0 0)
		}
		EvaluateWindow {
			Element = rectangle [ (-5 -5), (55 1305) ]
		}
		Replace
	}

	Refinement "global" {
		Reference = "global"
		RefineWindow=Material["Silicon"]
	}

	Refinement "nitride" {
		Reference = "nitride"
		RefineWindow=Material["Si3N4"]
	}

	Refinement "Al" {
		Reference = "others"
		RefineWindow=Material["Aluminum"]
	}

	Refinement "oxide" {
		Reference = "others"
		RefineWindow=Material["Oxide"]
	}
}
