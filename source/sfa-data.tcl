#-------------------------------------------------------------------------------
# version numbers, software and user guide, contact
proc getVersion {}   {return 3.10}
proc getVersionUG {} {return 3.0}
proc getContact {}   {return [list "Robert Lipman" "robert.lipman@nist.gov"]}

# -------------------------------------------------------------------------------
proc whatsNew {} {
  global progtime sfaVersion
  
  if {$sfaVersion > 0 && $sfaVersion < [getVersion]} {outputMsg "\nThe previous version of the STEP File Analyzer and Viewer was: $sfaVersion" red}

outputMsg "\nWhat's New (Version: [getVersion]  Updated: [string trim [clock format $progtime -format "%e %b %Y"]])" blue
outputMsg "- Visualization of Part Geometry (See Help > Part Geometry)
- Graphical PMI colored by saved view
- Improved processing of tolerance zone form, supplemental geometry, and annotation placeholder
- Explanation of Report errors (Help > Syntax Errors)
- Support for AP242 Edition 2 DIS (Draft International Standard)
- More STEP related Websites
- Bug fixes and minor improvements"

if {$sfaVersion > 0 && $sfaVersion <= 2.60} {
  outputMsg "\nRenamed output files:\n Spreadsheets from  myfile_stp.xlsx  to  myfile-sfa.xlsx\n Visualizations from  myfile-x3dom.html  to  myfile-sfa.html" red
}

  .tnb select .tnb.status
  update idletasks
}

#-------------------------------------------------------------------------------
proc initData {} {

global entCategory entColorIndex badAttributes roseLogical defaultColor
global aoEntTypes gpmiTypes spmiEntTypes dimSizeNames tolNames tzfNames dimModNames pmiModifiers pmiModifiersRP pmiUnicode
global spmiTypes recPracNames modelPictures schemaLinks modelURLs legendColor
global ap203all ap214all ap242all
global feaIndex feaElemFace cadApps allVendor numSavedViews andEntAP209

set defaultColor [list "0.818 0.512 0.266" brown]

set roseLogical(0) "FALSE"
set roseLogical(1) "TRUE"
set roseLogical(2) "UNKNOWN"

set andEntAP209 [list "_and_location" "_and_volume_location" "_and_coefficient" "_and_frequencies" "_and_parameters" "_and_value_definition" "_and_freedom"]

# names of CAx-IF Recommended Practices
set recPracNames(model)    "Model Styling and Organization"
set recPracNames(pmi242)   "Representation and Presentation of PMI (AP242)"
set recPracNames(pmi203)   "PMI Polyline Presentation (AP203/AP214)"
set recPracNames(valprop)  "Geometric and Assembly Validation Properties"
set recPracNames(tessgeom) "3D Tessellated Geometry"
set recPracNames(uda)      "User Defined Attributes"
set recPracNames(comp)     "Composite Structure Validation Properties"

# links to schema documentation
set schemaLinks(AP203)   "https://www.cax-if.org/documents/AP203e2_html/AP203e2.htm"
set schemaLinks(AP203e1) "http://web.archive.org/web/20160322005246/www.steptools.com/support/stdev_docs/express/ap203/html/index.html"
set schemaLinks(AP209)   "https://www.cax-if.org/documents/AP209_HTML/AP209ed2_mim_lf_v1.46.htm"
set schemaLinks(AP209e1) "http://web.archive.org/web/20160322005246/www.steptools.com/support/stdev_docs/express/ap209/index.html"
set schemaLinks(AP210)   "http://web.archive.org/web/20160322005246/www.steptools.com/support/stdev_docs/express/ap210/html/index.html"
set schemaLinks(AP214e3) "https://www.cax-if.org/documents/AP214E3/AP214_e3.htm"
set schemaLinks(AP238)   "http://web.archive.org/web/20160322005246/www.steptools.com/support/stdev_docs/express/ap238/html/index.html"
set schemaLinks(AP239)   "http://web.archive.org/web/20160322005246/www.steptools.com/support/stdev_docs/express/ap239/html/index.html"
set schemaLinks(AP242)   "https://www.cax-if.org/documents/AP242/AP242_mim_lf_1.36.htm"
set schemaLinks(CIS/2)   "http://web.archive.org/web/20160322005246/www.steptools.com/support/stdev_docs/express/cis/html/index.html"
  
# all app names for STEP and IFC software that might appear in header section
set cadApps {"3D_Evolution" ACIS "Alias - OpenModel" "Alias AutoStudio" "Alias OpenModel" "Alias Studio" Alibre AutoCAD "Autodesk Inventor" \
  CADDS CADfix CADIF CATIA "CATIA V4" "CATIA V5" "CATIA V6" "CATIA Version 5" CgiStepCamp CoreTechnologie Creo "CV - CADDS 5" \
  DATAKIT Datakit "Datakit CrossCad" DATAVISION Elysium EXPRESSO FEMAP FiberSim HiCAD IDA-STEP "I-DEAS" "Implementor Forum Team" "ITI TranscenData" \
  "jt_step translator" Kubotek "Kubotek KeyCreator" "Mechanical Desktop" "Mentor Graphics" NX "OneSpace Designer" "Open CASCADE" \
  Parasolid Patran PlanetCAD PolyTrans "PRO/ENGINEER" Siemens "SIEMENS PLM Software NX 10.0" "SIEMENS PLM Software NX 11.0" "SIEMENS PLM Software NX 12.0" \
  "SIEMENS PLM Software NX 7.0" "SIEMENS PLM Software NX 7.5" "SIEMENS PLM Software NX 8.0" "SIEMENS PLM Software NX 8.5" \
  "SIEMENS PLM Software NX 9.0" "SIEMENS PLM Software NX" "Solid Edge" SolidEdge "ST-ACIS" "STEP Caselib" \
  "STEP-NC Explorer" "STEP-NC Maker" "T3D tool generator" THEOREM Theorem "THEOREM SOLUTIONS" "Theorem Solutions" "T-Systems" \
  "UGS - NX" "UGS-NX" Unigraphics CoCreate Adobe Elysium ASFALIS CAPVIDIA 3DTransVidia MBDVidia NAFEMS COM209 CADCAM-E 3DEXPERIENCE ECCO SimDM \
  SDS/2 Tekla Revit RISA SAP2000 ETABS SmartPlant CADWorx "Advance Steel" ProSteel STAAD RAM Cype Parabuild RFEM RSTAB BuiltWorks EDMsix Mastercam \
  "3D Reviewer" "3D Converter" "HOOPS Exchange" HOOPS MicroStation SolidWorks Solidworks SOLIDWORKS "SOLIDWORKS MBD" ASCON PSStep Anark XStep \
  Spatial "Spatial InterOp 3D" "STEP-NC Maker" CADverter}
  
set allVendor(3DE) "3D Evolution"
set allVendor(3de) "3D Evolution"
set allVendor(a3) "Acrobat 3D"
set allVendor(a5) "Acrobat 3D (CATIA_V5)"
set allVendor(ac) "AutoCAD"
set allVendor(al) "Autodesk AliasStudio"
set allVendor(ap) "Acrobat_3D (Pro/E)"
set allVendor(au) "Acrobat_3D (NX)"
set allVendor(c3e) "3D Experience"
set allVendor(c4) "CATIA V4"
set allVendor(c5) "CATIA V5"
set allVendor(c6) "CATIA V6"
set allVendor(cg) "CgiStepCamp"
set allVendor(cm) "PTC CoCreate Modeling"
set allVendor(cr) "PTC Creo"
set allVendor(d5) "Datakit CrossCad (CATIA_V5)"
set allVendor(dc) "Datakit CrossCad"
set allVendor(di) "Datakit CrossCad (Inventor)"
set allVendor(do) "Datakit CrossCad (Creo)"
set allVendor(dp) "Datakit CrossCad (PRO/E)"
set allVendor(dw) "Datakit CrossCad (SolidWorks)"
set allVendor(dx) "Datakit CrossCad (NX)"
set allVendor(eb) "Electric Boat"
set allVendor(ec) "Elysium CadDoctor"
set allVendor(e5) "Elysium Asfalis (CATIA_V5)"
set allVendor(ei) "Elysium Asfalis (Inventor)"
set allVendor(eo) "Elysium Asfalis (Creo)"
set allVendor(ew) "Elysium Asfalis (SolidWorks)"
set allVendor(ex) "Elysium Asfalis (NX)"
set allVendor(fs) "Vistagy FiberSim"
set allVendor(h3) "HOOPS 3D Exchange"
set allVendor(h5) "HOOPS 3D (CATIA_V5)"
set allVendor(hc) "HOOPS 3D (Creo)"
set allVendor(hx) "HOOPS 3D (NX)"
set allVendor(i4) "ITI CADifx (CATIA_V4)"
set allVendor(i5) "ITI CADfix (CATIA_V5)"
set allVendor(ic) "ITI CADfix (Creo)"
set allVendor(id) "NX I-DEAS"
set allVendor(if) "ITI CADfix"
set allVendor(in) "Autodesk Inventor"
set allVendor(iq) "ITI CADfix"
set allVendor(iw) "ITI CADfix (SolidWorks)"
set allVendor(ix) "ITI CADfix (NX)"
set allVendor(jn) "Jotne EPM NASTRAN"
set allVendor(jo) "Jotne EPM openSimDM"
set allVendor(kc) "Kubotek KeyCreator"
set allVendor(kr) "Kubotek REALyze"
set allVendor(lk) "LKSoft IDA-STEP"
set allVendor(mp) "MSC Patran"
set allVendor(nas) "NASTRAN"
set allVendor(nx) "Siemens NX"
set allVendor(oc) "Datakit CrossCad (OpenCascade)"
set allVendor(pc) "PTC CADDS"
set allVendor(pe) "PTC Pro/E"
set allVendor(s4) "T-Systems COM/STEP (CATIA_V4)"
set allVendor(s5) "T-Systems COM/FOX (CATIA_V5)"
set allVendor(se) "SolidEdge"
set allVendor(sp) "Spatial ACIS"
set allVendor(sw) "SolidWorks"
set allVendor(t3d) "TechSoft3D"
set allVendor(t4) "Theorem Cadverter (CATIA_V4)"
set allVendor(t5) "Theorem Cadverter (CATIA_V5)"
set allVendor(tc) "Theorem Cadverter (CADDS)"
set allVendor(td) "Theorem Solutions (CATIA_AP209)"
set allVendor(to) "Theorem Cadverter (Creo)"
set allVendor(tp) "Theorem Cadverter (PRO/E)"
set allVendor(ts) "Theorem Cadverter (I-DEAS)"
set allVendor(tx) "Theorem Cadverter (NX)"
set allVendor(ug) "Unigraphics"

# sort cadApps by string length
set cadApps [sortlength2 $cadApps]

# list of annotation occurrence entities, *order is important* (removed draughting_annotation_occurrence, not in RP)
set aoEntTypes [list \
  tessellated_annotation_occurrence \
  annotation_placeholder_occurrence \
  annotation_fill_area_occurrence \
  annotation_curve_occurrence \
  annotation_occurrence \
]

# list of semantic PMI entities, *order is important*, not including tolerances
set spmiEntTypes [list \
  datum_reference_element \
  datum_reference_compartment \
  datum_system \
  datum_reference \
  referenced_modified_datum \
  datum_feature \
  composite_shape_aspect_and_datum_feature \
  composite_group_shape_aspect_and_datum_feature \
  placed_datum_target_feature \
  datum_target \
  dimensional_characteristic_representation \
]

# -----------------------------------------------------------------------------------------------------
# dimensional_size names (Section 5.1.5, Table 4), controlled radius and square are not included

set dimSizeNames [list \
  "curve length" "diameter" "thickness" "spherical diameter" "radius" "spherical radius" \
  "toroidal minor diameter" "toroidal major diameter" "toroidal minor radius" "toroidal major radius" \
  "toroidal high major diameter" "toroidal high minor diameter" "toroidal high major radius" "toroidal high minor radius"]
                   
# dimension modifiers (Section 5.3, Table 8)
set dimModNames [list \
  "any cross section" "any part of the feature" "area diameter calculated size" "average rank order size" \
  "circumference diameter calculated size" "common tolerance" "continuous feature" "controlled radius" \
  "free state condition" "least squares association criteria" "local size defined by a sphere" \
  "maximum inscribed association criteria" "maximum rank order size" "median rank order size" \
  "mid range rank order size" "minimum circumscribed association criteria" "minimum rank order size" \
  "range rank order size" "specific fixed cross section" "square" "statistical" \
  "two point size" "volume diameter calculated size"]

# -----------------------------------------------------------------------------------------------------
# tolerance entity names (Section 6.8, Table 10)

set tolNames [list \
  angularity_tolerance circular_runout_tolerance coaxiality_tolerance concentricity_tolerance cylindricity_tolerance \
  flatness_tolerance line_profile_tolerance parallelism_tolerance perpendicularity_tolerance position_tolerance \
  roundness_tolerance straightness_tolerance surface_profile_tolerance symmetry_tolerance total_runout_tolerance]
                   
# tolerance zone form names (Section 6.9.2, Tables 11, 12)
set tzfNames [list \
  "cylindrical or circular" "spherical" "within a circle" "within a sphere" "between two concentric circles" "between two equidistant curves" \
  "within a cylinder" "between two coaxial cylinders" "between two equidistant surfaces" "non uniform" "unknown"]

# -----------------------------------------------------------------------------------------------------
# *Graphical PMI* names (Section 8.2, Table 13)

set gpmiTypes [list \
  "angularity" "circular runout" "circularity" "coaxiality" "concentricity" "cylindricity" \
  "flatness" "parallelism" "perpendicularity" "position" "profile of line" "profile of surface" \
  "roundness" "straightness" "symmetry" "total runout" "general tolerance" "linear dimension" \
  "radial dimension" "diameter dimension" "angular dimension" "ordinate dimension" "curve dimension" \
  "general dimension" "datum" "datum target" "note" "label" "surface roughness" "weld symbol" \
  "general note" "over riding style set"]

# -----------------------------------------------------------------------------------------------------
# Semantic PMI types for coverage analysis, order is important

set spmiTypes $tolNames

foreach item [list \
  "tolerance zone diameter (6.9.2, Table 11)" "tolerance zone spherical diameter (6.9.2, Table 11)" "tolerance zone within a cylinder (6.9.2, Table 12)" \
  "tolerance zone other (6.9.2, Table 12)" "affected plane tolerance zone (6.9.2.1)" "non-uniform tolerance zone (6.9.2.3)" "tolerance with max value (6.9.5)" \
  "unit-basis tolerance (6.9.6)" "all_around \u232E (6.4.2)" "between \u2194 (6.4.3)" "composite tolerance (6.9.9)" \
  "unequally_disposed \u24CA (6.9.4)" "projected \u24C5 (6.9.2.2)" "free_state \u24BB (6.9.3)" "tangent_plane \u24C9 (6.9.3)" \
  "statistical_tolerance <ST> (6.9.3)" "separate_requirement SEP REQT (6.9.3)" \
  "dimensions (Row 37+38)" "dimensional location (5.1.1)" "dimensional size (5.1.5)" "angular location (5.1.2)" "angular size (5.1.6)" \
  "directed dimension \u2331 (5.1.1)"  "oriented dimensional location (5.1.3)" "derived shapes dimensional location (5.1.4)" "repetitive dimensions 'nX' (5.1, User Guide 5.1.3)" \
  "bilateral tolerance (5.2.3)" "non-bilateral tolerance (5.2.3)" "value range (5.2.4)" \
  "diameter \u2205 (5.1.5)" "radius R (5.1.5)" "spherical diameter S\u2205 (5.1.5)" "spherical radius SR (5.1.5)" "controlled radius CR (5.3)" \
  "basic dimension (5.3)" "reference dimension (5.3)" "statistical_dimension <ST> (5.3)" "type qualifier (5.2.2)" "tolerance class (5.2.5)" \
  "location with path (5.1.7)" "square \u25A1 (5.3)" "decimal places (5.4)" \
  "datum (6.5)" "multiple datum features (6.9.8)" "datum with axis system (6.9.7)" "datum with modifiers (6.9.7)" \
  "point placed datum target (6.6)" "line placed datum target (6.6)" "rectangle placed datum target (6.6)" "circle placed datum target (6.6)" \
  "circular curve placed datum target (6.6)" \
  "curve datum target (6.6)" "area datum target (6.6)" "placed datum target geometry (6.6.2)" "movable datum target (6.6.3)" \
] {lappend spmiTypes $item}

# -----------------------------------------------------------------------------------------------------
# pmiModifiers are the symbols associated with many strings such as dimModNames and others

set pmiModifiersArray(all_around,6.4.2)                     "\u232E"
set pmiModifiersArray(all_over,6.3)                         "ALL OVER"
set pmiModifiersArray(any_cross_section,5.3)                "ACS"
set pmiModifiersArray(any_longitudinal_section,6.9.7)       "ALS"
set pmiModifiersArray(any_part_of_the_feature,5.3)          "/Length"
set pmiModifiersArray(arc_length)                           "\u2322"
set pmiModifiersArray(area_diameter_calculated_size,5.3)    "(CA)"
set pmiModifiersArray(average_rank_order_size,5.3)          "(SA)"
set pmiModifiersArray(basic,6.9.7)                          "\[BASIC\]"
set pmiModifiersArray(between,6.4.3)                        "\u2194"
set pmiModifiersArray(circumference_diameter_calculated_size,5.3) "(CC)"
set pmiModifiersArray(common_tolerance,5.3)                 "CT"
set pmiModifiersArray(common_zone,6.9.3)                    "CZ"
set pmiModifiersArray(conical_taper)                        "\u2332"
set pmiModifiersArray(contacting_feature,6.9.7)             "CF"
set pmiModifiersArray(continuous_feature,5.3)               "<CF>"
set pmiModifiersArray(controlled_radius,5.3)                "CR"
set pmiModifiersArray(counterbore)                          "\u2334"
set pmiModifiersArray(countersink)                          "\u2335"
set pmiModifiersArray(degree_of_freedom_constraint_u,6.9.7) "u"
set pmiModifiersArray(degree_of_freedom_constraint_v,6.9.7) "v"
set pmiModifiersArray(degree_of_freedom_constraint_w,6.9.7) "w"
set pmiModifiersArray(degree_of_freedom_constraint_x,6.9.7) "x"
set pmiModifiersArray(degree_of_freedom_constraint_y,6.9.7) "y"
set pmiModifiersArray(degree_of_freedom_constraint_z,6.9.7) "z"
set pmiModifiersArray(depth)                                "\u21A7"
set pmiModifiersArray(distance_variable,6.9.7)              "DV"
set pmiModifiersArray(each_radial_element,6.9.3)            "ERE"
set pmiModifiersArray(envelope_requirement,5.2.1)           "\u24BA"
set pmiModifiersArray(free_state_condition,5.3)             "\u24BB"
set pmiModifiersArray(free_state,6.9.3)                     "\u24BB"
set pmiModifiersArray(hole_thread)                          ""
set pmiModifiersArray(independency,5.2.1)                   "\u24BE"
set pmiModifiersArray(least_material_condition)             "\u24C1"
set pmiModifiersArray(least_material_requirement,6.9.3-6.9.7) "\u24C1"
set pmiModifiersArray(least_square_association_criteria,5.3)  "(GG)"
set pmiModifiersArray(line)                                 "SL"
set pmiModifiersArray(line_element,6.9.3)                   "LE"
set pmiModifiersArray(local_size_defined_by_a_sphere,5.3)   "(LS)"
set pmiModifiersArray(major_diameter,6.9.3)                 "MD"
set pmiModifiersArray(maximum_inscribed_association_criteria,5.3) "(GX)"
set pmiModifiersArray(maximum_material_condition)           "\u24C2"
set pmiModifiersArray(maximum_material_requirement,6.9.3-6.9.7) "\u24C2"
set pmiModifiersArray(maximum_rank_order_size,5.3)          "(SX)"
set pmiModifiersArray(median_rank_order_size,5.3)           "(SM)"
set pmiModifiersArray(mid_range_rank_order_size,5.3)        "(SD)"
set pmiModifiersArray(minimum_circumscribed_association_criteria,5.3) "(GN)"
set pmiModifiersArray(minimum_rank_order_size,5.3)          "(SN)"
set pmiModifiersArray(minor_diameter,6.9.3)                 "LD"
set pmiModifiersArray(not_convex,6.9.3)                     "NC"
set pmiModifiersArray(orientation,6.9.7)                    "\u003E\u003C"
set pmiModifiersArray(pitch_diameter,6.9.7)                 "PD"
set pmiModifiersArray(plane,6.9.7)                          "PL"
set pmiModifiersArray(point,6.9.7)                          "PT"
set pmiModifiersArray(projected,6.9.2.2)                    "\u24C5"
set pmiModifiersArray(range_rank_order_size,5.3)            "(SR)"
set pmiModifiersArray(reciprocity_requirement,6.9.3)        "\u24C7"
set pmiModifiersArray(regardless_of_feature_size)           "\u24C8"
set pmiModifiersArray(separate_requirement,6.9.3)           "SEP REQT"
set pmiModifiersArray(simultaneous_requirement)             "SIM REQT"
set pmiModifiersArray(slope)                                "\u2333"
set pmiModifiersArray(specific_fixed_cross_section,5.3)     "SCS"
set pmiModifiersArray(spotface)                             "SF"
set pmiModifiersArray(square,5.3)                           "\u25A1"
set pmiModifiersArray(statistical_dimension,5.3)            "<ST>"
set pmiModifiersArray(statistical_tolerance,6.9.3)          "<ST>"
set pmiModifiersArray(tangent_plane,6.9.3)                  "\u24C9"
set pmiModifiersArray(translation,6.9.7)                    "\u25B7"
set pmiModifiersArray(two_point_size,5.3)                   "(LP)"
set pmiModifiersArray(unequally_disposed,6.9.4)             "\u24CA"
set pmiModifiersArray(volume_diameter_calculated_size,5.3)  "(CV)"

# new ISO 1101 modifiers
set pmiModifiersArray(united_feature,6.9.3)                       "UF"
set pmiModifiersArray(derived_feature,6.9.3)                      "\u24B6"
set pmiModifiersArray(associated_minmax_feature,6.9.3)            "\u24B8"
set pmiModifiersArray(associated_least_square_feature,6.9.3)      "\u24BC"
set pmiModifiersArray(associated_minimum_inscribed_feature,6.9.3) "\u24C3"
set pmiModifiersArray(associated_tangent_feature,6.9.3)           "\u24C9"
set pmiModifiersArray(associated_maximum_inscribed_feature,6.9.3) "\u24CD"

foreach item [array names pmiModifiersArray] {
  set ids [split $item ","]
  set pmiModifiers([lindex $ids 0]) $pmiModifiersArray($item)
  if {[llength $ids] > 1} {set pmiModifiersRP([lindex $ids 0]) [lindex $ids 1]}
}

# pmfirst are features in the NIST models to list before the rest of the modifiers
set pmfirst [list maximum_material_requirement least_material_requirement simultaneous_requirement \
                  counterbore depth hole_thread countersink slope conical_taper arc_length]
foreach pmf $pmfirst {             
  foreach item [lsort [array names pmiModifiers]] {
    set idx [lindex [split $item ","] 0]
    if {$pmf == $idx} {lappend spmiTypes $item}
  }
}

# pmnot are already included in spmiTypes above
set pmnot [list all_around between unequally_disposed projected free_state tangent_plane separate_requirement \
                statistical_dimension statistical_tolerance]
foreach item [lsort [array names pmiModifiers]] {
  set idx [lindex [split $item ","] 0]
  if {[lsearch $pmfirst $idx] == -1 && [lsearch $pmnot $idx] == -1} {lappend spmiTypes $item}
}

# -----------------------------------------------------------------------------------------------------
# pmiUnicode are the symbols associated with tolerances and a few others

set idx "cylindrical or circular"
set pmiUnicode($idx)             "\u2205"
set pmiUnicode(angularity)       "\u2220"
set pmiUnicode(circular)         "\u2205"
set pmiUnicode(circular_runout)  "\u2197"
set pmiUnicode(coaxiality)       "\u25CE"
set pmiUnicode(concentricity)    "\u25CE"
set pmiUnicode(cylindrical)      "\u2205"
set pmiUnicode(cylindricity)     "\u232D"
set pmiUnicode(degree)           "\u00B0"
set pmiUnicode(diameter)         "\u2205"
set pmiUnicode(flatness)         "\u25B1"
set pmiUnicode(line_profile)     "\u2312"
set pmiUnicode(parallelism)      "\u2215\u2215"
set pmiUnicode(perpendicularity) "\u23CA"
set pmiUnicode(plusminus)        "\u00B1"
set pmiUnicode(position)         "\u2295"
set pmiUnicode(radius)           "R"
set pmiUnicode(roundness)        "\u25EF"
set idx "spherical diameter"
set pmiUnicode($idx)             "S\u2205"
set idx "spherical radius"
set pmiUnicode($idx)             "SR"
set pmiUnicode(straightness)     "\u2212"
set pmiUnicode(square)           "\u25A1"
set pmiUnicode(surface_profile)  "\u2313"
set pmiUnicode(symmetry)         "\u232F"
set pmiUnicode(thickness)        "\u2346\u2345"
set pmiUnicode(total_runout)     "\u2330"

set idx "within a cylinder"
set pmiUnicode($idx)             "\u2205"

set pmiUnicode(angular)          $pmiUnicode(angularity)
set pmiUnicode(parallel)         $pmiUnicode(parallelism)
set pmiUnicode(perpendicular)    $pmiUnicode(perpendicularity)
set pmiUnicode(including)        $pmiUnicode(symmetry)


# -----------------------------------------------------------------------------------------------------
# colors, the number determines the order that the group of entities is processed
# do not use numbers less than 10  (dmcritchie.mvps.org/excel/colors.htm)

set entColorIndex(PR_STEP_FEAT) 19	
set entColorIndex(PR_STEP_KINE) 34	
set entColorIndex(PR_STEP_COMP) 35
set entColorIndex(PR_STEP_AP242) 36	
set entColorIndex(PR_STEP_TOLR) 37			
set entColorIndex(PR_STEP_PRES) 38			
set entColorIndex(PR_STEP_REPR) 39			
set entColorIndex(PR_STEP_SHAP) 40			
set entColorIndex(PR_STEP_COMM) 42			
set entColorIndex(PR_STEP_GEOM) 43			
set entColorIndex(PR_STEP_CPNT) 43			
set entColorIndex(PR_STEP_QUAN) 44

# PMI coverage colors

set legendColor(green)   [expr {int (128) << 16 | int (255) << 8 | int(128)}]
set legendColor(yellow)  [expr {int (128) << 16 | int (255) << 8 | int(255)}]
set legendColor(red)     [expr {int (128) << 16 | int (128) << 8 | int(255)}]
set legendColor(cyan)    [expr {int (255) << 16 | int (255) << 8 | int(128)}]
set legendColor(magenta) [expr {int (255) << 16 | int (128) << 8 | int(255)}]
set legendColor(gray)    [expr {int (208) << 16 | int (208) << 8 | int(208)}]

# -----------------------------------------------------------------------------------------------------
# entity attributes that cause a crash, LIST of LIST, i.e., something of something
# this is caused by a limitation of the IFCsvr toolkit

set badattributes(axisymmetric_curve_2d_element_descriptor) {purpose}
set badattributes(axisymmetric_surface_2d_element_descriptor) {purpose}
set badAttributes(axisymmetric_volume_2d_element_descriptor) {purpose}
set badAttributes(b_spline_surface_with_knots) {control_points_list}
set badAttributes(b_spline_surface_with_knots_and_rational_b_spline_surface) {control_points_list weights_data}
set badAttributes(bezier_surface) {control_points_list}
set badAttributes(bezier_surface_and_rational_b_spline_surface) {control_points_list weights_data}
set badAttributes(cc_design_approval) {items}
set badattributes(complex_shelled_solid) {thickened_face_list}
set badAttributes(complex_triangulated_face) {normals triangle_fans triangle_strips}
set badAttributes(complex_triangulated_surface_set) {normals triangle_fans triangle_strips}
set badAttributes(coordinates_list) {position_coords}
set badAttributes(curve_3d_element_descriptor) {purpose}
set badattributes(explicit_element_matrix) {node_dof_list}
set badattributes(extruded_face_solid_with_multiple_draft_angles) {drafted_edges}
set badattributes(finite_function) {pairs}
set badattributes(indices_list) {indices}
set badattributes(plane_curve_2d_element_descriptor) {purpose}
set badattributes(plane_surface_2d_element_descriptor) {purpose}
set badattributes(plane_volume_2d_element_descriptor) {purpose}
set badAttributes(point_cloud_dataset) {point_coordinates}
set badAttributes(point_cloud_dataset_with_colours) {point_coordinates colour_indices}
set badAttributes(point_cloud_dataset_with_intensities) {point_coordinates}
set badAttributes(point_cloud_dataset_with_normals) {point_coordinates normals}
set badAttributes(quasi_uniform_surface) {control_points_list}
set badAttributes(quasi_uniform_surface_and_rational_b_spline_surface) {control_points_list weights_data}
set badAttributes(rational_b_spline_surface) {weights_data}
set badAttributes(rational_b_spline_surface_and_uniform_surface) {control_points_list weights_data}
set badAttributes(rectangular_composite_surface) {segments}
set badAttributes(solid_with_incomplete_rectangular_pattern) {omitted_instances}
set badattributes(solid_with_slot) {end_exit_faces}
set badAttributes(surface_3d_element_descriptor) {purpose}
set badAttributes(tessellated_curve_set) {line_strips}
set badAttributes(tessellated_face) {normals}
set badAttributes(tessellated_surface_set) {normals}
set badAttributes(triangulated_face) {normals triangles}
set badAttributes(triangulated_point_cloud_dataset) {triangles}
set badAttributes(triangulated_surface_set) {normals triangles}

# -----------------------------------------------------------------------------------------------------
# pictures that are embedded in a spreadsheet based on STEP file name
set modelPictures  {{sp3-1101  caxif-1101.jpg  E4 0} \
                    {sp3-16792 caxif-16792.jpg E4 0} \
                    {sp3-box   caxif-boxy123.jpg E4 0} \
                    {STEP-File-Analyzer nist_ctc_01.jpg E4 0} \
                    {nist_ctc_01 nist_ctc_01.jpg E4 0} \
                    {nist_ctc_02 nist_ctc_02abc.jpg E4 0} \
                    {nist_ctc_03 nist_ctc_03.jpg E4 0} \
                    {nist_ctc_04 nist_ctc_04.jpg E4 0} \
                    {nist_ctc_05 nist_ctc_05ab.jpg E4 0} \
                    {nist_ftc_06 nist_ftc_06abc.jpg E4 0} \
                    {nist_ftc_07 nist_ftc_07abc.jpg E4 0} \
                    {nist_ftc_07 nist_ftc_07d.jpg T4 20} \
                    {nist_ftc_08 nist_ftc_08abcd.jpg E4 0} \
                    {nist_ftc_09 nist_ftc_09abcd.jpg E4 0} \
                    {nist_ftc_10 nist_ftc_10abc.jpg E4 0} \
                    {nist_ftc_10 nist_ftc_10de.jpg T4 20} \
                    {nist_ftc_11 nist_ftc_11ab.jpg E4 0} \
                    {sp6-base    sp6-base.jpg E4 0} \
                    {sp6-cheek   sp6-cheek.jpg E4 0} \
                    {sp6-pole    sp6-pole.jpg E4 0} \
                    {sp6-spindle sp6-spindle.jpg E4 0}}

set modelURLs [list nist_ctc_01_asme1_rd.pdf \
                    nist_ctc_02_asme1_rc.pdf \
                    nist_ctc_03_asme1_rc.pdf \
                    nist_ctc_04_asme1_rd.pdf \
                    nist_ctc_05_asme1_rd.pdf \
                    nist_ftc_06_asme1_rd.pdf \
                    nist_ftc_07_asme1_rc.pdf \
                    nist_ftc_08_asme1_rc.pdf \
                    nist_ftc_09_asme1_rd.pdf \
                    nist_ftc_10_asme1_rb.pdf \
                    nist_ftc_11_asme1_rb.pdf]

set numSavedViews(nist_ctc_01) 1
set numSavedViews(nist_ctc_02) 3
set numSavedViews(nist_ctc_03) 1
set numSavedViews(nist_ctc_04) 1
set numSavedViews(nist_ctc_05) 2
set numSavedViews(nist_ftc_06) 3
set numSavedViews(nist_ftc_07) 4
set numSavedViews(nist_ftc_08) 4
set numSavedViews(nist_ftc_09) 4
set numSavedViews(nist_ftc_10) 5
set numSavedViews(nist_ftc_11) 2

# -----------------------------------------------------------------------------------------------------
# AP209 element index based on ISO 10303 Part 104 ordering
# line is for the wireframe mesh, surf is for faces of 2D elements, face is for faces of 3D elements
# ordered so that normals point outward

# 2D tri
set feaIndex(surface_3d,3,line) [list 0 1 2 0 -1] 
set feaIndex(surface_3d,3,surf) [list 0 1 2 -1] 
set feaIndex(surface_3d,6,line) [list 0 3 1 4 2 5 0 -1] 
set feaIndex(surface_3d,6,surf) [list 0 3 5 -1 3 1 4 -1 3 4 5 -1 5 4 2 -1] 

# 2D quad
set feaIndex(surface_3d,4,line) [list 0 1 2 3 0 -1] 
set feaIndex(surface_3d,4,surf) [list 0 1 2 3 -1] 
set feaIndex(surface_3d,8,line) [list 0 4 1 5 2 6 3 7 0 -1] 
set feaIndex(surface_3d,8,surf) [list 0 4 7 -1 4 1 5 -1 5 2 6 -1 6 3 7 -1 4 5 7 -1 7 5 6 -1] 
set feaIndex(surface_3d,9,line) [list 0 4 1 5 2 6 3 7 0 -1] 
set feaIndex(surface_3d,9,surf) [list 0 4 7 -1 4 1 5 -1 5 2 6 -1 6 3 7 -1 4 8 7 -1 4 5 8 -1 7 8 6 -1 8 5 6 -1] 

# 3D tetra
set feaIndex(volume_3d,4,line)  [list 0 1 2 0 3 1 -1 2 3 -1] 
set feaIndex(volume_3d,4,face)  [list 0 2 1 -1 0 1 3 -1 1 2 3 -1 0 3 2 -1] 
set feaIndex(volume_3d,10,line) [list 0 4 3 6 2 9 0 7 1 5 3 -1 1 8 2 -1] 
set feaIndex(volume_3d,10,face) [list 0 9 2 8 1 7 -1 0 7 1 5 3 4 -1 1 8 2 6 3 5 -1 0 4 3 6 2 9 -1] 

# 3D pyra
set feaIndex(volume_3d,5,line)  [list 0 1 4 0 3 2 1 4 2 -1 3 2 4 3 0 4 -1] 
set feaIndex(volume_3d,5,face)  [list 0 3 2 1 -1 0 4 3 -1 2 3 4 -1 1 2 4 -1] 
set feaIndex(volume_3d,13,line) [list 0 5 4 8 3 12 0 9 1 6 4 7 2 10 1 -1 0 9 1 -1 3 11 2 -1] 
set feaIndex(volume_3d,13,face) [list 0 5 4 8 3 12 -1 3 8 4 7 2 11 -1 2 7 4 6 1 10 -1 1 6 4 5 0 9 -1 0 12 3 11 2 10 1 9 -1] 
set feaIndex(volume_3d,14,line) $feaIndex(volume_3d,13,line)
set feaIndex(volume_3d,14,face) $feaIndex(volume_3d,13,face)

# 3D wedge
set feaIndex(volume_3d,6,line)  [list 0 1 2 0 -1 3 4 5 3 -1 0 3 -1 1 4 -1 2 5 -1] 
set feaIndex(volume_3d,6,face)  [list 0 2 1 -1 3 4 5 -1 0 3 5 2 -1 0 1 4 3 -1 1 2 5 4 -1]
set feaIndex(volume_3d,15,line) [list 0 6 3 12 4 7 1 9 0 11 2 8 5 14 3 -1 1 10 2 -1 4 13 5 -1] 
set feaIndex(volume_3d,15,face) [list 0 9 11 -1 1 9 10 -1 9 10 11 -1 2 10 11 -1 3 12 14 -1 4 12 13 -1 12 13 14 -1 5 13 14 -1 \
                                      0 6 3 14 5 8 2 11 -1 0 9 1 7 4 12 3 6 -1 1 10 2 8 5 13 4 7 -1]
set feaIndex(volume_3d,18,line) $feaIndex(volume_3d,15,line)
set feaIndex(volume_3d,18,face) $feaIndex(volume_3d,15,face)

# 3D hexa
set feaIndex(volume_3d,8,line)  [list 0 1 2 3 0 -1 4 5 6 7 4 -1 0 4 -1 1 5 -1 2 6 -1 3 7 -1] 
set feaIndex(volume_3d,8,face)  [list 0 3 2 1 -1 0 4 7 3 -1 3 7 6 2 -1 4 5 6 7 -1 0 1 5 4 -1 1 2 6 5 -1]
set feaIndex(volume_3d,20,line) [list 0 8 4 19 7 11 3 15 0 12 1 13 2 10 6 17 5 9 1 -1 3 14 2 -1 7 18 6 -1 4 16 5 -1] 
set feaIndex(volume_3d,20,face) [list 0 15 3 14 2 13 1 12 -1 0 8 4 19 7 11 3 15 -1 3 11 7 18 6 10 2 14 -1 \
                                      4 16 5 17 6 18 7 19 -1 0 12 1 9 5 16 4 8 -1 1 13 2 10 6 17 5 9 -1]
set feaIndex(volume_3d,27,line) $feaIndex(volume_3d,20,line)
set feaIndex(volume_3d,27,face) $feaIndex(volume_3d,20,face)


# element faces on volume_3d elements for surface pressures
foreach i {8 20 27} {
  set feaElemFace($i,1) [list 0 3 2 1]
  set feaElemFace($i,2) [list 4 5 6 7]
  set feaElemFace($i,3) [list 0 1 5 4]
  set feaElemFace($i,4) [list 2 6 5 1]
  set feaElemFace($i,5) [list 2 3 7 6]
  set feaElemFace($i,6) [list 0 4 7 3]
}

foreach i {6 15 18} {
  set feaElemFace($i,1) [list 0 2 1]
  set feaElemFace($i,2) [list 3 4 5]
  set feaElemFace($i,3) [list 0 1 4 3]
  set feaElemFace($i,4) [list 1 2 5 4]
  set feaElemFace($i,5) [list 0 3 5 2]
}

foreach i {4 10} {
  set feaElemFace($i,1) [list 0 1 2]
  set feaElemFace($i,2) [list 0 3 1]
  set feaElemFace($i,3) [list 1 3 2]
  set feaElemFace($i,4) [list 2 3 0]
}

# -----------------------------------------------------------------------------------------------------
# STEP geometry

set entCategory(PR_STEP_GEOM) [lsort [list \
advanced_face axis1_placement axis2_placement_2d axis2_placement_3d \
b_spline_curve b_spline_curve_with_knots b_spline_surface b_spline_surface_with_knots bezier_curve bezier_surface block boolean_result \
boundary_curve bounded_curve bounded_pcurve bounded_surface bounded_surface_curve box_domain boxed_half_space brep_with_voids \
cartesian_transformation_operator cartesian_transformation_operator_2d cartesian_transformation_operator_3d circle closed_shell \
complex_triangulated_face complex_triangulated_surface_set \
composite_curve composite_curve_on_surface composite_curve_segment conic conical_surface connected_edge_set connected_face_set \
connected_face_sub_set csg_solid curve curve_bounded_surface curve_replica cylindrical_surface \
degenerate_pcurve degenerate_toroidal_surface direction \
edge edge_based_wireframe_model edge_curve edge_loop elementary_surface ellipse evaluated_degenerate_pcurve extruded_area_solid \
extruded_face_solid face \
face_based_surface_model face_bound face_outer_bound face_surface faceted_brep \
geometric_curve_set geometric_set \
half_space_solid hyperbola intersection_curve line loop manifold_solid_brep \
offset_curve_2d offset_curve_3d offset_surface open_shell oriented_closed_shell oriented_edge oriented_face oriented_open_shell \
oriented_path oriented_surface outer_boundary_curve \
parabola path pcurve placement planar_box planar_extent plane point point_on_curve point_on_surface point_replica poly_loop polyline \
quasi_uniform_curve quasi_uniform_surface \
rational_b_spline_curve rational_b_spline_surface rectangular_composite_surface rectangular_trimmed_surface \
reparametrised_composite_curve_segment repositioned_tessellated_item revolved_area_solid revolved_face_solid right_angular_wedge \
right_circular_cone right_circular_cylinder \
ruled_surface_swept_area_solid \
seam_curve shell_based_surface_model solid_model solid_replica sphere spherical_surface subedge subface surface surface_curve \
surface_curve_swept_area_solid surface_of_linear_extrusion surface_of_revolution surface_patch surface_replica swept_area_solid \
swept_disk_solid swept_face_solid swept_surface \
tessellated_connecting_edge \
tessellated_curve_set tessellated_edge tessellated_face tessellated_geometric_set tessellated_item tessellated_point_set \
tessellated_shell tessellated_solid tessellated_structured_item tessellated_surface_set tessellated_vertex tessellated_wire \
toroidal_surface torus triangulated_face triangulated_surface_set trimmed_curve \
uniform_curve uniform_surface vector vertex vertex_loop vertex_point \
point_array cylindrical_point spherical_point polar_point point_and_vector \
b_spline_basis b_spline_curve_knot_locator b_spline_curve_segment b_spline_function b_spline_surface_knot_locator \
b_spline_surface_patch b_spline_surface_strip \
csg_primitive_solid_2d csg_solid_2d \
solid_curve_font solid_with_angle_based_chamfer solid_with_chamfered_edges solid_with_circular_pattern \
solid_with_circular_pocket solid_with_circular_protrusion solid_with_conical_bottom_round_hole solid_with_constant_radius_edge_blend \
solid_with_curved_slot solid_with_depression solid_with_double_offset_chamfer solid_with_flat_bottom_round_hole solid_with_general_pocket \
solid_with_general_protrusion solid_with_groove solid_with_hole solid_with_incomplete_circular_pattern solid_with_incomplete_rectangular_pattern \
solid_with_pocket solid_with_protrusion solid_with_rectangular_pattern solid_with_rectangular_pocket solid_with_rectangular_protrusion \
solid_with_shape_element_pattern solid_with_single_offset_chamfer solid_with_slot solid_with_spherical_bottom_round_hole \
solid_with_stepped_round_hole solid_with_stepped_round_hole_and_conical_transitions solid_with_straight_slot solid_with_tee_section_slot \
solid_with_through_depression solid_with_trapezoidal_section_slot solid_with_variable_radius_edge_blend source_for_requirement \
complex_shelled_solid shell_based_wireframe_model shelled_solid boundary_curve_of_b_spline_or_rectangular_composite_surface surfaced_open_shell vertex_shell \
b_spline_volume b_spline_volume_with_knots bezier_volume block_volume \
circular_involute clothoid convex_hexahedron \
cubic_bezier_tessellated_edge cubic_bezier_triangulated_face cubic_tessellated_connecting_edge cylindrical_volume cyclide_segment_solid \
eccentric_cone eccentric_conical_volume edge_with_length ellipsoid ellipsoid_volume \
faceted_primitive hexahedron_volume local_b_spline locally_refined_spline_curve locally_refined_spline_surface locally_refined_spline_volume \
point_cloud_superdataset point_in_volume pyramid_volume quasi_uniform_volume \
rational_b_spline_volume rational_locally_refined_spline_curve rational_locally_refined_spline_surface rational_locally_refined_spline_volume \
rectangular_pyramid uniform_volume wedge_volume vertex_on_edge volume_with_faces volume_with_parametric_boundary volume_with_shell \
tetrahedron tetrahedron_volume toroidal_volume dupin_cyclide_surface \
fixed_reference_swept_surface open_path seam_edge spherical_volume surface_curve_swept_surface \
point_cloud_dataset point_cloud_dataset_with_colours point_cloud_dataset_with_intensities point_cloud_dataset_with_normals triangulated_point_cloud_dataset \
]]

# STEP cartesian point, etc.

set entCategory(PR_STEP_CPNT) [list cartesian_point coordinates_list]

# -----------------------------------------------------------------------------------------------------
# STEP shape aspect

set entCategory(PR_STEP_SHAP) [lsort [list \
all_around_shape_aspect apex between_shape_aspect centre_of_symmetry component_path_shape_aspect composite_group_shape_aspect composite_shape_aspect \
composite_unit_shape_aspect continuous_shape_aspect derived_shape_aspect extension geometric_alignment geometric_contact geometric_intersection \
geometric_item_specific_usage item_identified_representation_usage parallel_offset perpendicular_to \
shape_aspect shape_aspect_associativity shape_aspect_deriving_relationship shape_aspect_relationship shape_aspect_relationship_representation_association \
shape_aspect_transition symmetric_shape_aspect tangent \
assembly_shape_constraint assembly_shape_joint connectivity_definition constituent_shape_aspect contact_feature shape_aspect_occurrence \
]]

# -----------------------------------------------------------------------------------------------------
# STEP presentation, annotation

set entCategory(PR_STEP_PRES) [lsort [list \
annotation_placeholder_occurrence draughting_model_item_association_with_placeholder \
angular_dimension annotation_curve_occurrence annotation_fill_area annotation_fill_area_occurrence annotation_occurrence annotation_occurrence_associativity \
annotation_occurrence_relationship annotation_plane annotation_subfigure_occurrence annotation_symbol annotation_symbol_occurrence annotation_text \
annotation_text_character annotation_text_occurrence area_in_set background_colour \
camera_image camera_image_3d_with_scale camera_model camera_model_d3 camera_model_d3_multi_clipping camera_model_d3_multi_clipping_intersection \
camera_image_2d_with_scale camera_model_d2 \
camera_model_d3_multi_clipping_union camera_model_d3_with_hlhsr camera_model_with_light_sources camera_usage \
character_glyph_font_usage character_glyph_style_outline character_glyph_style_stroke character_glyph_symbol character_glyph_symbol_outline \
character_glyph_symbol_stroke \
colour colour_rgb colour_specification composite_text composite_text_with_associated_curves composite_text_with_blanking_box \
composite_text_with_delineation composite_text_with_extent context_dependent_invisibility context_dependent_over_riding_styled_item \
curve_dimension curve_style curve_style_font curve_style_font_and_scaling curve_style_font_pattern curve_style_rendering \
datum_feature_callout datum_target_callout defined_character_glyph defined_symbol diameter_dimension \
dimension_callout dimension_callout_component_relationship dimension_callout_relationship dimension_curve dimension_curve_directed_callout \
dimension_curve_terminator dimension_pair dimension_related_tolerance_zone_element dimension_text_associativity \
draughting_annotation_occurrence draughting_callout draughting_callout_relationship draughting_elements draughting_model draughting_model_item_association \
draughting_pre_defined_colour draughting_pre_defined_curve_font draughting_pre_defined_text_font draughting_specification_reference \
draughting_subfigure_representation draughting_symbol_representation draughting_text_literal_with_delineation draughting_title \
drawing_definition drawing_revision drawing_revision_sequence drawing_sheet_layout drawing_sheet_revision drawing_sheet_revision_sequence \
drawing_sheet_revision_usage \
externally_defined_character_glyph externally_defined_class externally_defined_colour externally_defined_curve_font externally_defined_hatch_style \
externally_defined_item externally_defined_item_relationship externally_defined_marker externally_defined_style externally_defined_symbol \
externally_defined_terminator_symbol externally_defined_text_font externally_defined_tile_style \
fill_area_style fill_area_style_colour fill_area_style_hatching fill_area_style_tile_coloured_region fill_area_style_tile_curve_with_style \
fill_area_style_tile_symbol_with_style fill_area_style_tiles \
generic_character_glyph_symbol generic_literal geometrical_tolerance_callout hidden_element_over_riding_styled_item invisibility \
leader_curve leader_directed_callout leader_directed_dimension leader_terminator linear_dimension \
mechanical_design_and_draughting_relationship ordinate_dimension over_riding_styled_item point_style \
pre_defined_character_glyph pre_defined_colour pre_defined_curve_font pre_defined_dimension_symbol pre_defined_geometrical_tolerance_symbol \
pre_defined_item pre_defined_marker pre_defined_point_marker_symbol pre_defined_surface_condition_symbol pre_defined_surface_side_style \
pre_defined_symbol pre_defined_terminator_symbol pre_defined_text_font \
presentation_area presentation_layer_assignment presentation_representation presentation_set presentation_size presentation_style_assignment \
presentation_style_by_context presentation_view \
projection_curve projection_directed_callout radius_dimension structured_dimension_callout \
styled_item surface_condition_callout surface_rendering_properties surface_side_style surface_style_boundary surface_style_control_grid \
surface_style_fill_area surface_style_parameter_line surface_style_reflectance_ambient surface_style_reflectance_ambient_diffuse \
surface_style_reflectance_ambient_diffuse_specular surface_style_rendering surface_style_rendering_with_properties surface_style_segmentation_curve \
surface_style_silhouette surface_style_transparent surface_style_usage surface_texture_representation \
symbol_colour symbol_representation symbol_representation_map symbol_style symbol_target terminator_symbol tessellated_annotation_occurrence \
tagged_text_format tagged_text_item text_font text_font_family text_font_in_family \
text_literal text_literal_with_associated_curves text_literal_with_blanking_box text_literal_with_delineation text_literal_with_extent \
text_string_representation text_style text_style_for_defined_font text_style_with_box_characteristics text_style_with_mirror text_style_with_spacing \
vector_style view_volume \
annotation_point_occurrence \
]]

# -----------------------------------------------------------------------------------------------------
# STEP tolerance

set entCategory(PR_STEP_TOLR) [lsort [list \
angular_location angular_size angularity_tolerance \
circular_runout_tolerance coaxiality_tolerance common_datum concentricity_tolerance cylindricity_tolerance \
datum datum_feature datum_reference datum_reference_compartment datum_reference_element datum_reference_modifier_with_value datum_system datum_target \
default_tolerance_table default_tolerance_table_cell \
dimensional_characteristic_representation dimensional_location dimensional_location_with_datum_feature dimensional_location_with_path dimensional_size \
dimensional_size_with_datum_feature dimensional_size_with_path directed_dimensional_location \
externally_defined_dimension_definition feature_for_datum_target_relationship flatness_tolerance \
geometric_tolerance geometric_tolerance_relationship geometric_tolerance_with_datum_reference geometric_tolerance_with_defined_area_unit \
geometric_tolerance_with_defined_unit geometric_tolerance_with_maximum_tolerance geometric_tolerance_with_modifiers \
limits_and_fits line_profile_tolerance modified_geometric_tolerance non_uniform_zone_definition \
parallelism_tolerance perpendicularity_tolerance placed_datum_target_feature plus_minus_tolerance position_tolerance \
projected_zone_definition projected_zone_definition_with_offset \
referenced_modified_datum roundness_tolerance runout_zone_definition runout_zone_orientation runout_zone_orientation_reference_direction \
shape_dimension_representation straightness_tolerance surface_profile_tolerance symmetry_tolerance \
tolerance_value tolerance_zone tolerance_zone_definition tolerance_zone_form total_runout_tolerance type_qualifier \
unequally_disposed_geometric_tolerance value_format_type_qualifier \
counterbore_definition counterbore_hole_definition counterbore_hole_occurrence counterbore_hole_occurrence_in_assembly counterdrill_hole_definition \
counterdrill_hole_occurrence counterdrill_hole_occurrence_in_assembly countersink_hole_definition countersink_hole_occurrence \
countersink_hole_occurrence_in_assembly \
geometric_tolerance_auxiliary_classification hole_depth hole_diameter length_tolerance_value oriented_tolerance_zone plane_angle_tolerance_value \
tolerance_zone_with_datum directed_tolerance_zone \
simplified_counterbore_hole_definition simplified_counterdrill_hole_definition simplified_countersink_hole_definition simplified_spotface_hole_definition \
spotface_definition spotface_hole_definition spotface_occurrence spotface_occurrence_in_assembly \
]]

# -----------------------------------------------------------------------------------------------------
# STEP composites

set entCategory(PR_STEP_COMP) [lsort [list \
composite_assembly_definition composite_assembly_sequence_definition composite_assembly_table composite_material_designation \
composite_sheet_representation flat_pattern_ply_representation_relationship laid_defined_transformation \
laminate_table min_and_major_ply_orientation_basis part_laminate_table percentage_laminate_definition \
percentage_laminate_table percentage_ply_definition ply_laminate_definition ply_laminate_sequence_definition \
ply_laminate_table smeared_material_definition thickness_laminate_definition thickness_laminate_table zone_structural_makeup \
draped_orientation_angle laid_orientation_angle ply_angle_representation ply_orientation_angle reinforcement_orientation_basis \
cartesian_11 curve_11 cylindrical_11 polar_11 user_defined_11 \
]]

# -----------------------------------------------------------------------------------------------------
# STEP kinematics

set entCategory(PR_STEP_KINE) [lsort [list \
actuated_kinematic_pair \
circular_path constrained_kinematic_motion_representation context_dependent_kinematic_link_representation \
curve_based_path curve_based_path_with_orientation curve_based_path_with_orientation_and_parameters \
cylindrical_pair cylindrical_pair_range cylindrical_pair_value cylindrical_pair_with_range \
externally_defined_feature_definition \
founded_kinematic_path free_kinematic_motion_representation fully_constrained_pair \
gear_pair gear_pair_range gear_pair_value gear_pair_with_range \
high_order_kinematic_pair homokinetic_pair \
initial_state interpolated_configuration_representation interpolated_configuration_segment item_link_motion_relationship \
kinematic_analysis_consistency kinematic_analysis_result kinematic_control \
kinematic_frame_background_representation kinematic_frame_background_representation_association kinematic_frame_based_transformation \
kinematic_ground_representation kinematic_joint \
kinematic_link kinematic_link_representation kinematic_link_representation_association kinematic_link_representation_relation kinematic_loop \
kinematic_pair kinematic_path kinematic_path_defined_by_curves kinematic_path_defined_by_nodes kinematic_path_segment \
kinematic_property_definition kinematic_property_definition_representation kinematic_property_mechanism_representation \
kinematic_property_representation_relation kinematic_property_topology_representation \
kinematic_structure kinematic_topology_directed_structure kinematic_topology_network_structure kinematic_topology_structure kinematic_topology_substructure \
kinematic_topology_tree_structure \
linear_flexible_and_pinion_pair linear_flexible_and_planar_curve_pair linear_flexible_link_representation linear_path \
link_motion_relationship link_motion_representation_along_path link_motion_transformation low_order_kinematic_pair low_order_kinematic_pair_value \
low_order_kinematic_pair_with_motion_coupling low_order_kinematic_pair_with_range \
mechanism mechanism_base_placement mechanism_representation mechanism_state_representation \
pair_actuator pair_representation_relationship pair_value path_node planar_curve_pair planar_curve_pair_range planar_pair planar_pair_range \
planar_pair_value planar_pair_with_range \
point_on_planar_curve_pair point_on_planar_curve_pair_range point_on_planar_curve_pair_value point_on_planar_curve_pair_with_range \
point_on_surface_pair point_on_surface_pair_range point_on_surface_pair_value point_on_surface_pair_with_range point_to_point_path \
prescribed_path prismatic_pair prismatic_pair_range prismatic_pair_value prismatic_pair_with_range product_definition_kinematics \
product_definition_relationship_kinematics \
rack_and_pinion_pair rack_and_pinion_pair_range rack_and_pinion_pair_value rack_and_pinion_pair_with_range revolute_pair revolute_pair_range \
revolute_pair_value revolute_pair_with_range \
rigid_link_representation rolling_curve_pair rolling_curve_pair_value rolling_surface_pair rolling_surface_pair_value rotation_about_direction \
screw_pair screw_pair_range screw_pair_value screw_pair_with_range simple_pair_range sliding_curve_pair sliding_curve_pair_value sliding_surface_pair \
sliding_surface_pair_value \
spherical_pair spherical_pair_range spherical_pair_value spherical_pair_with_pin spherical_pair_with_pin_and_range spherical_pair_with_range \
surface_pair surface_pair_range surface_pair_with_range \
unconstrained_pair unconstrained_pair_value universal_pair universal_pair_range universal_pair_value universal_pair_with_range \
]]

# -----------------------------------------------------------------------------------------------------
# STEP measure and unit (quantity)

set entCategory(PR_STEP_QUAN) [lsort [list \
absorbed_dose_measure_with_unit absorbed_dose_unit acceleration_measure_with_unit acceleration_unit amount_of_substance_measure_with_unit \
amount_of_substance_unit area_measure_with_unit area_unit \
binary_representation_item boolean_representation_item bytes_representation_item \
capacitance_measure_with_unit capacitance_unit celsius_temperature_measure_with_unit conductance_measure_with_unit conductance_unit context_dependent_unit \
conversion_based_unit currency_measure_with_unit \
date_representation_item date_time_representation_item \
derived_unit derived_unit_element derived_unit_variable dielectric_constant_measure_with_unit dimensional_exponents dose_equivalent_measure_with_unit \
dose_equivalent_unit \
electric_charge_measure_with_unit electric_charge_unit electric_current_measure_with_unit electric_current_unit electric_potential_measure_with_unit \
electric_potential_unit energy_measure_with_unit energy_unit \
externally_defined_context_dependent_unit externally_defined_currency externally_defined_conversion_based_unit \
force_measure_with_unit force_unit frequency_measure_with_unit frequency_unit \
global_uncertainty_assigned_context global_unit_assigned_context \
illuminance_measure_with_unit illuminance_unit inductance_measure_with_unit inductance_unit \
integer_representation_item descriptive_representation_item \
length_measure_with_unit length_unit loss_tangent_measure_with_unit luminous_flux_measure_with_unit luminous_flux_unit \
logical_representation_item \
luminous_intensity_measure_with_unit luminous_intensity_unit \
magnetic_flux_density_measure_with_unit magnetic_flux_density_unit magnetic_flux_measure_with_unit magnetic_flux_unit mass_measure_with_unit \
mass_unit measure_qualification measure_representation_item measure_with_unit named_unit named_unit_variable \
plane_angle_measure_with_unit plane_angle_unit power_measure_with_unit power_unit precision_qualifier pressure_measure_with_unit pressure_unit \
qualified_representation_item \
radioactivity_measure_with_unit radioactivity_unit ratio_measure_with_unit ratio_unit resistance_measure_with_unit resistance_unit \
real_representation_item \
si_absorbed_dose_unit \
si_capacitance_unit si_conductance_unit si_dose_equivalent_unit si_electric_charge_unit si_electric_potential_unit si_energy_unit si_force_unit \
si_frequency_unit si_illuminance_unit si_inductance_unit si_magnetic_flux_density_unit si_magnetic_flux_unit si_power_unit si_pressure_unit \
si_radioactivity_unit si_resistance_unit si_unit solid_angle_measure_with_unit solid_angle_unit \
thermal_resistance_measure_with_unit thermal_resistance_unit thermodynamic_temperature_measure_with_unit thermodynamic_temperature_unit \
time_measure_with_unit time_unit uncertainty_measure_with_unit value_representation_item \
velocity_measure_with_unit velocity_unit volume_measure_with_unit volume_unit \
positive_length_measure_with_unit positive_plane_angle_measure_with_unit \
]]

# -----------------------------------------------------------------------------------------------------
# STEP representation

set entCategory(PR_STEP_REPR) [lsort [list \
advanced_brep_shape_representation auxiliary_geometric_representation_item \
characterized_item_within_representation characterized_representation \
compound_representation_item compound_shape_representation constructive_geometry_representation constructive_geometry_representation_relationship \
context_dependent_shape_representation csg_shape_representation csg_2d_shape_representation curve_swept_solid_shape_representation \
definitional_representation document_representation_type \
edge_based_wireframe_shape_representation \
faceted_brep_shape_representation \
general_material_property general_property general_property_association general_property_relationship \
geometric_representation_context geometric_representation_item geometrically_bounded_2d_wireframe_representation \
geometrically_bounded_surface_shape_representation geometrically_bounded_wireframe_shape_representation \
hardness_representation \
item_defined_transformation \
manifold_subsurface_shape_representation manifold_surface_shape_representation mapped_item material_property_representation \
material_property externally_defined_general_property \
mechanical_design_geometric_presentation_representation moments_of_inertia_representation \
non_manifold_surface_shape_representation null_representation_item \
parametric_representation_context picture_representation_item predefined_picture_representation_item presented_item_representation \
point_placement_shape_representation \
property_definition property_definition_relationship property_definition_representation \
rational_representation_item representation representation_context representation_item representation_map representation_relationship \
representation_relationship_with_transformation row_representation_item \
shape_definition_representation shape_representation shape_representation_relationship shape_representation_with_parameters \
table_representation_item tactile_appearance_representation tessellated_shape_representation topological_representation_item \
uncertainty_assigned_representation \
value_range variational_representation_item visual_appearance_representation \
single_area_csg_2d_shape_representation single_boundary_csg_2d_shape_representation planar_shape_representation \
face_shape_representation_relationship representative_shape_representation direction_shape_representation elementary_brep_shape_representation \
face_shape_representation location_shape_representation path_shape_representation shell_based_wireframe_shape_representation \
tessellated_shape_representation_with_accuracy_parameters \
representation_context_reference representation_proxy_item representation_reference shape_representation_reference \
]]

# -----------------------------------------------------------------------------------------------------
# STEP feature

set entCategory(PR_STEP_FEAT) [lsort [list \
boss boss_top chamfer chamfer_offset circular_closed_profile circular_pattern closed_path_profile composite_hole compound_feature edge_round \
feature_component_definition feature_component_relationship feature_definition feature_pattern \
fillet hole_bottom instanced_feature linear_profile ngon_closed_profile open_path_profile outside_profile \
partial_circular_profile path_feature_component placed_feature pocket pocket_bottom rectangular_closed_profile rectangular_pattern \
replicate_feature revolved_profile rib round_hole rounded_u_profile slot slot_end \
square_u_profile tee_profile thread transition_feature vee_profile \
]]

# -----------------------------------------------------------------------------------------------------
# STEP AP242

set entCategory(PR_STEP_AP242) [lsort [list \
abrupt_change_of_surface_normal abstracted_expression_function add_element agc_with_dimension \
angle_assembly_constraint_with_dimension angle_geometric_constraint application_defined_function area_with_outer_boundary array_placement_group \
assembly_bond_definition assembly_component assembly_geometric_constraint assembly_group_component assembly_group_component_definition_placement_link \
assembly_joint atom_based_literal basic_sparse_matrix binary_assembly_constraint binary_literal boolean_result_2d \
bound_parameter_environment bound_variational_parameter cartesian_complex_number_region \
cdgc_with_dimension chain_based_geometric_item_specific_usage chain_based_item_identified_representation_usage change_composition_relationship \
change_element change_element_sequence change_group change_group_assignment characterized_chain_based_item_within_representation circular_area \
clgc_with_dimension coaxial_assembly_constraint coaxial_geometric_constraint complex_area complex_number_literal complex_number_literal_polar \
closed_curve_style_parameters curve_style_parameters_representation curve_style_parameters_with_ends \
component_definition component_feature component_feature_joint \
component_feature_relationship component_mating_constraint_condition component_terminal composite_curve_transition_locator \
connection_zone_based_assembly_joint connection_zone_interface_plane_relationship constant_function contacting_feature \
current_change_element_assignment curve_distance_geometric_constraint \
curve_length_geometric_constraint curve_segment_set curve_smoothness_geometric_constraint curve_with_excessive_segments \
curve_with_small_curvature_radius data_quality_assessment_measurement_association data_quality_assessment_specification \
data_quality_criteria_representation data_quality_criterion data_quality_criterion_assessment_association data_quality_criterion_measurement_association \
data_quality_definition data_quality_definition_relationship data_quality_definition_representation_relationship data_quality_inspection_criterion_report \
data_quality_inspection_criterion_report_item data_quality_inspection_instance_report data_quality_inspection_instance_report_item \
data_quality_inspection_report data_quality_inspection_result data_quality_inspection_result_representation data_quality_inspection_result_with_judgement \
data_quality_measurement_requirement data_quality_report_measurement_association data_quality_report_request defined_constraint \
definite_integral_expression definite_integral_function delete_element detailed_report_request detailed_report_request_with_number_of_data \
disallowed_assembly_relationship_usage disconnected_face_set discontinuous_geometry edge_with_excessive_segments elementary_function \
elementary_space elliptic_area entirely_narrow_face entirely_narrow_solid entirely_narrow_surface equal_parameter_constraint \
erroneous_b_spline_curve_definition erroneous_b_spline_surface_definition erroneous_data erroneous_geometry erroneous_manifold_solid_brep \
erroneous_topology erroneous_topology_and_geometry_relationship evaluated_characteristic_of_product_as_individual_test_result excessive_use_of_groups \
excessive_use_of_layers excessively_high_degree_curve excessively_high_degree_surface explicit_constraint explicit_geometric_constraint \
explicit_table_function expression_denoted_function expression_extension_numeric expression_extension_string expression_extension_to_select \
extended_tuple_space externally_conditioned_data_quality_criteria_representation externally_conditioned_data_quality_criterion \
externally_conditioned_data_quality_inspection_instance_report_item externally_conditioned_data_quality_inspection_result \
externally_conditioned_data_quality_inspection_result_representation externally_defined_item_with_multiple_references externally_defined_representation \
externally_listed_data extreme_instance extreme_patch_width_variation \
face_surface_with_excessive_patches_in_one_direction feature_definition_with_connection_area finite_function finite_integer_interval \
finite_real_interval finite_space fixed_constituent_assembly_constraint fixed_element_geometric_constraint fixed_instance_attribute_set flat_face \
free_edge free_form_assignment free_form_constraint free_form_relation frozen_assignment function_application function_space \
g1_discontinuity_between_adjacent_faces g1_discontinuous_curve g1_discontinuous_surface g2_discontinuity_between_adjacent_faces g2_discontinuous_curve \
g2_discontinuous_surface gap_between_adjacent_edges_in_loop gap_between_edge_and_base_surface gap_between_faces_related_to_an_edge \
gap_between_pcurves_related_to_an_edge gap_between_vertex_and_base_surface gap_between_vertex_and_edge gear general_datum_reference \
general_linear_function generated_finite_numeric_space generic_product_definition_reference geometric_gap_in_topology \
geometric_representation_context_with_parameter geometry_with_local_irregularity geometry_with_local_near_degeneracy half_space_2d \
high_degree_axi_symmetric_surface high_degree_conic high_degree_linear_curve high_degree_planar_surface homogeneous_linear_function \
implicit_explicit_positioned_sketch_relationship implicit_intersection_curve implicit_model_intersection_curve implicit_planar_curve \
implicit_planar_intersection_point implicit_planar_projection_point implicit_point_on_plane implicit_projected_curve implicit_silhouette_curve \
imported_curve_function imported_point_function imported_surface_function imported_volume_function inappropriate_element_visibility \
inappropriate_use_of_layer inapt_data inapt_geometry inapt_manifold_solid_brep inapt_topology inapt_topology_and_geometry_relationship \
incidence_assembly_constraint incidence_geometric_constraint inconsistent_adjacent_face_normals inconsistent_curve_transition_code \
inconsistent_edge_and_curve_directions inconsistent_element_reference inconsistent_face_and_closed_shell_normals inconsistent_face_and_surface_normals \
inconsistent_surface_transition_code indistinct_curve_knots indistinct_surface_knots instance_attribute_reference \
instance_report_item_with_extreme_instances integer_interval_from_min integer_interval_to_max integer_tuple_literal interfaced_group_component \
intersecting_connected_face_sets intersecting_loops_in_face intersecting_shells_in_solid linear_array_component_definition_link \
linear_array_placement_group_component linearized_table_function listed_data listed_product_space location_in_aggregate_representation_item \
make_from_feature_relationship marking mated_part_relationship maths_enum_literal maths_function maths_space maths_tuple_literal maths_variable \
modify_element multi_level_reference_designator multiply_defined_cartesian_points multiply_defined_curves multiply_defined_directions \
multiply_defined_edges multiply_defined_faces multiply_defined_geometry multiply_defined_placements multiply_defined_solids multiply_defined_surfaces \
multiply_defined_vertices narrow_surface_patch near_point_relationship nearly_degenerate_geometry nearly_degenerate_surface_boundary \
nearly_degenerate_surface_patch neutral_sketch_representation non_agreed_accuracy_parameter_usage non_agreed_scale_usage non_agreed_unit_usage \
non_manifold_at_edge non_manifold_at_vertex non_referenced_coordinate_system non_smooth_geometry_transition_across_edge open_closed_shell open_edge_loop \
oriented_joint outer_round over_used_vertex overcomplex_geometry overcomplex_topology_and_geometry_relationship overlapping_geometry \
parallel_assembly_constraint parallel_assembly_constraint_with_dimension parallel_composed_function parallel_geometric_constraint \
parallel_offset_geometric_constraint partial_derivative_expression partial_derivative_function partly_overlapping_curves partly_overlapping_edges \
partly_overlapping_faces partly_overlapping_solids partly_overlapping_surfaces path_area_with_parameters path_parameter_representation \
path_parameter_representation_context pdgc_with_dimension perpendicular_assembly_constraint perpendicular_geometric_constraint pgc_with_dimension \
physical_component physical_component_feature physical_component_terminal plane_angle_and_length_pair plane_angle_and_ratio_pair pogc_with_dimension \
point_distance_geometric_constraint point_on_edge_curve point_on_face_surface polar_complex_number_region polygonal_area \
previous_change_element_assignment primitive_2d primitive_2d_with_inner_boundary product_as_planned product_data_and_data_quality_relationship \
product_definition_reference product_definition_reference_with_local_representation product_design_to_individual product_design_version_to_individual \
product_planned_to_realized product_relationship profile_floor protrusion quantifier_expression radius_geometric_constraint rationalize_function \
real_interval_from_min real_interval_to_max real_tuple_literal rectangular_area rectangular_array_placement_group_component \
rectangular_composite_surface_transition_locator reindexed_array_function removal_volume repackaging_function \
repositioned_neutral_sketch representation_proxy_item restriction_function \
rgc_with_dimension rib_top rib_top_floor rigid_subsketch rounded_end sdgc_with_dimension selector_function self_intersecting_curve \
self_intersecting_geometry self_intersecting_loop self_intersecting_shell self_intersecting_surface series_composed_function \
shape_criteria_representation_with_accuracy shape_data_quality_assessment_by_logical_test shape_data_quality_assessment_by_numerical_test \
shape_data_quality_criteria_representation shape_data_quality_criterion shape_data_quality_criterion_and_accuracy_association \
shape_data_quality_inspected_shape_and_result_relationship shape_data_quality_inspection_criterion_report shape_data_quality_inspection_instance_report \
shape_data_quality_inspection_instance_report_item shape_data_quality_inspection_result shape_data_quality_inspection_result_representation \
shape_data_quality_lower_value_limit shape_data_quality_upper_value_limit shape_data_quality_value_limit shape_data_quality_value_range \
shape_inspection_result_accuracy_association shape_inspection_result_representation_with_accuracy shape_measurement_accuracy \
shape_summary_request_with_representative_value short_length_curve short_length_curve_segment short_length_edge simultaneous_constraint_group \
single_property_is_definition \
skew_line_distance_geometric_constraint small_area_face small_area_surface small_area_surface_patch small_volume_solid software_for_data_quality_check \
solid_with_excessive_number_of_voids solid_with_wrong_number_of_voids spherical_cap steep_angle_between_adjacent_edges \
steep_angle_between_adjacent_faces steep_geometry_transition_across_edge step su_parameters subsketch summary_report_request \
surface_distance_assembly_constraint_with_dimension surface_distance_geometric_constraint surface_patch_set surface_smoothness_geometric_constraint \
surface_with_excessive_patches_in_one_direction surface_with_small_curvature_radius swept_curve_surface_geometric_constraint \
swept_point_curve_geometric_constraint symmetry_geometric_constraint tangent_assembly_constraint tangent_geometric_constraint \
thermal_component \
thread_runout topology_related_to_multiply_defined_geometry topology_related_to_nearly_degenerate_geometry topology_related_to_overlapping_geometry \
topology_related_to_self_intersecting_geometry turned_knurl unbound_parameter_environment \
unbound_variational_parameter unbound_variational_parameter_semantics uniform_product_space unused_patches unused_shape_element variable_expression \
variational_current_representation_relationship variational_parameter variational_representation volume wrong_element_name wrongly_oriented_void \
wrongly_placed_loop wrongly_placed_void zero_surface_normal \
additive_manufacturing_build_plate_relationship additive_manufacturing_setup additive_manufacturing_setup_relationship \
additive_manufacturing_setup_workpiece_relationship additive_manufacturing_support_structure_geometry_relationship \
aggregate_id_attribute analysis_assignment analysis_item \
applied_description_text_assignment applied_location_assignment applied_location_representation_assignment applied_organization_type_assignment \
applied_state_observed_assignment applied_state_type_assignment \
ascribable_state ascribable_state_relationship \
assembly_shape_constraint_item_relationship assembly_shape_joint_item_relationship \
assigned_analysis attachment_slot_as_planned attachment_slot_as_realized attachment_slot_design attachment_slot_design_to_planned \
attachment_slot_design_to_realized attachment_slot_on_product attachment_slot_planned_to_realized \
characterized_location_object characterized_object_relationship characterized_product_concept_feature characterized_product_concept_feature_category \
collection collection_assignment collection_membership collection_relationship collection_version collection_version_relationship \
collection_version_sequence_relationship collection_view_definition \
component_feature_group_identification condition conditional_effectivity \
connected_edge_with_length_set_representation connected_volume_set connected_volume_sub_set \
connectivity_definition_item_relationship \
contact_feature_definition contact_feature_definition_fit_relationship contact_feature_fit_relationship \
containing_message cross_sectional_alternative_shape_element cross_sectional_group_shape_element cross_sectional_group_shape_element_with_lacing \
cross_sectional_group_shape_element_with_tubular_cover cross_sectional_occurrence_shape_element cross_sectional_part_shape_element \
default_model_geometric_view definitional_product_definition_usage derived_component_terminal description_text description_text_assignment \
draughting_specification_reference \
envelope envelope_relationship evidence \
harness_node harness_segment \
hierarchical_interface_connection \
in_zone interface_component interface_connection interface_connector_as_planned interface_connector_as_realized interface_connector_definition \
interface_connector_design interface_connector_design_to_planned interface_connector_design_to_realized interface_connector_occurrence \
interface_connector_planned_to_realized interface_connector_version interface_definition_connection interface_definition_for \
interface_specification_definition interface_specification_version \
location location_assignment location_relationship location_representation_assignment location_representation_role location_role \
machining_process_executable mating_material mating_material_items mechanical_design_requirement_item_association \
message_contents_assignment message_contents_group message_relationship model_geometric_view \
organization_type organization_type_assignment organization_type_role \
physical_component_interface_terminal \
pmi_requirement_item_association \
procedural_solid_representation_sequence \
product_definition_occurrence product_definition_occurrence_reference product_definition_occurrence_reference_with_local_representation \
product_definition_relationship_relationship product_definition_specified_occurrence product_definition_usage_relationship product_group \
product_group_attribute_assignment product_group_attribute_set product_group_attributes product_group_context product_group_membership \
product_group_membership_rules product_group_purpose product_group_relationship product_group_rule product_group_rule_assignment product_group_rules \
product_in_attachment_slot \
scan_3d_model scan_data_shape_representation scanned_data_item scanner_basic_properties scanner_property \
shape_feature_definition_element_relationship shape_feature_definition_relationship \
sql_mappable_defined_function state_observed state_observed_assignment state_observed_relationship state_observed_role state_predicted state_type \
state_type_assignment state_type_relationship state_type_role \
statechar_applied_object statechar_object statechar_relationship_object statechar_type_applied_object statechar_type_object statechar_type_relationship_object \
structured_message \
system_breakdown_context system_element_usage \
terminal_feature terminal_location_group \
transport_feature \
twisted_cross_sectional_group_shape_element \
validation verification verification_relationship \
zone_breakdown_context zone_element_usage \
]]

# -----------------------------------------------------------------------------------------------------
# STEP common

set entCategory(PR_STEP_COMM) [lsort [list \
abs_function abstract_variable acos_function action action_assignment action_directive action_method action_method_assignment \
action_method_relationship action_method_role action_property action_property_representation action_relationship action_request_assignment \
action_request_solution action_request_status action_resource action_resource_requirement action_resource_type action_status address \
alternate_product_relationship and_expression angle_direction_reference application_context application_context_element \
application_context_relationship application_protocol_definition applied_action_assignment applied_action_method_assignment \
applied_action_request_assignment applied_approval_assignment applied_area applied_attribute_classification_assignment \
applied_certification_assignment applied_classification_assignment applied_contract_assignment applied_date_and_time_assignment \
applied_date_assignment applied_document_reference applied_document_usage_constraint_assignment applied_effectivity_assignment \
applied_event_occurrence_assignment applied_external_identification_assignment applied_group_assignment applied_identification_assignment \
applied_ineffectivity_assignment applied_name_assignment applied_organization_assignment applied_organizational_project_assignment \
applied_person_and_organization_assignment applied_presented_item applied_security_classification_assignment applied_time_interval_assignment \
applied_usage_right approval approval_assignment approval_date_time approval_person_organization approval_relationship approval_role \
approval_status approximation_tolerance approximation_tolerance_deviation approximation_tolerance_parameter asin_function assembly_component_usage \
assembly_component_usage_substitute assigned_requirement atan_function atomic_formula attribute_assertion attribute_classification_assignment \
attribute_language_assignment attribute_value_assignment attribute_value_role \
back_chaining_rule back_chaining_rule_body barring_hole bead bead_end beveled_sheet_representation binary_boolean_expression binary_function_call \
binary_generic_expression binary_numeric_expression boolean_defined_function boolean_expression boolean_literal boolean_variable breakdown_context \
breakdown_element_group_assignment breakdown_element_realization breakdown_element_usage breakdown_of \
calendar_date cc_design_approval cc_design_certification cc_design_contract cc_design_date_and_time_assignment \
cc_design_person_and_organization_assignment cc_design_security_classification cc_design_specification_reference certification \
certification_assignment certification_type change change_request characteristic_data_column_header characteristic_data_column_header_link \
characteristic_data_table_header characteristic_data_table_header_decomposition characteristic_type characterized_class characterized_object \
class class_by_extension class_by_intension class_system class_usage_effectivity_context_assignment classification_assignment classification_role \
comparison_equal comparison_expression comparison_greater comparison_greater_equal comparison_less comparison_less_equal comparison_not_equal \
complex_clause complex_conjunctive_clause complex_disjunctive_clause concat_expression concept_feature_operator \
concept_feature_relationship concept_feature_relationship_with_condition conditional_concept_feature configurable_item configuration_definition \
configuration_design configuration_effectivity configuration_interpolation configuration_item configuration_item_hierarchical_relationship \
configuration_item_relationship configuration_item_revision_sequence configured_effectivity_assignment configured_effectivity_context_assignment \
conical_stepped_hole_transition contact_ratio_representation contract contract_assignment contract_relationship contract_type \
coordinated_universal_time_offset cos_function currency \
data_environment date date_and_time date_and_time_assignment date_assignment date_role date_time_role dated_effectivity defined_function \
definitional_representation_relationship definitional_representation_relationship_with_same_context description_attribute design_context \
design_make_from_relationship dimension_curve_terminator_to_projection_curve_associativity directed_action directed_angle \
div_expression document document_file document_identifier document_identifier_assignment \
document_product_association document_product_equivalence document_reference document_relationship document_type document_usage_constraint \
document_usage_constraint_assignment document_usage_role double_offset_shelled_solid draped_defined_transformation \
edge_blended_solid effectivity effectivity_assignment effectivity_context_assignment effectivity_context_role effectivity_relationship \
element_delivery entity_assertion enum_reference_prefix environment equals_expression \
evaluated_characteristic evaluation_product_definition event_occurrence event_occurrence_assignment event_occurrence_context_assignment \
event_occurrence_context_role event_occurrence_relationship event_occurrence_role exclusive_product_concept_feature_category executed_action \
exp_function expanded_uncertainty explicit_procedural_geometric_representation_item_relationship \
explicit_procedural_representation_item_relationship explicit_procedural_representation_relationship \
explicit_procedural_shape_representation_relationship expression expression_conversion_based_unit extent \
external_class_library external_identification_assignment external_source external_source_relationship \
externally_defined_picture_representation_item externally_defined_representation_item externally_defined_string \
externally_defined_tile extruded_face_solid_with_draft_angle extruded_face_solid_with_multiple_draft_angles \
extruded_face_solid_with_trim_conditions \
fact_type feature_in_panel featured_shape format_function forward_chaining_rule forward_chaining_rule_premise \
founded_item func functional_breakdown_context functional_element_usage functionally_defined_transformation \
general_feature generic_expression generic_variable geometric_model_element_relationship global_assignment ground_fact group \
group_assignment group_relationship \
hole_in_panel \
id_attribute identification_assignment identification_role included_text_block inclusion_product_concept_feature index_expression \
indirectly_selected_elements indirectly_selected_shape_elements information_right information_usage_right \
instance_usage_context_assignment int_literal int_numeric_variable int_value_function integer_defined_function \
interpolated_configuration_sequence interval_expression iso4217_currency \
joggle joggle_termination \
known_source \
language language_assignment length_function light_source light_source_ambient light_source_directional light_source_positional light_source_spot \
like_expression literal_conjunction literal_disjunction literal_number local_time locator log_function \
log10_function log2_function logical_literal lot_effectivity \
make_from_usage_option material_designation material_designation_characterization maximum_function mechanical_context \
mechanical_design_geometric_presentation_area mechanical_design_presentation_representation_with_draughting \
mechanical_design_shaded_presentation_area mechanical_design_shaded_presentation_representation minimum_function minus_expression \
minus_function mod_expression modified_pattern modified_solid modified_solid_with_placed_configuration motion_link_relationship \
mult_expression multi_language_attribute_assignment multiple_arity_boolean_expression multiple_arity_function_call \
multiple_arity_generic_expression multiple_arity_numeric_expression \
name_assignment name_attribute next_assembly_usage_occurrence not_expression numeric_defined_function numeric_expression numeric_variable \
object_role odd_function one_direction_repeat_factor or_expression ordinal_date organization organization_assignment organization_relationship \
organization_role organizational_address organizational_project organizational_project_assignment organizational_project_relationship \
organizational_project_role \
package_product_concept_feature partial_document_with_structured_text_representation_assignment \
pattern_offset_membership pattern_omit_membership person person_and_organization person_and_organization_address \
person_and_organization_assignment person_and_organization_role personal_address physical_breakdown_context physical_element_usage \
physically_modelled_product_definition picture_representation plus_expression point_path polar_complex_number_literal \
positioned_sketch power_expression pre_defined_presentation_style pre_defined_tile presented_item procedural_representation \
procedural_representation_sequence procedural_shape_representation procedural_shape_representation_sequence process_operation \
process_plan process_product_association process_property_association product product_category product_category_relationship \
product_class product_concept product_concept_context product_concept_feature product_concept_feature_association \
product_concept_feature_category product_concept_feature_category_usage product_concept_relationship product_context \
product_definition product_definition_context product_definition_context_association product_definition_context_role \
product_definition_effectivity product_definition_element_relationship product_definition_formation product_definition_formation_relationship \
product_definition_formation_with_specified_source product_definition_group_assignment product_definition_occurrence_relationship \
product_definition_process product_definition_relationship product_definition_resource product_definition_shape \
product_definition_substitute product_definition_usage product_definition_with_associated_documents product_identification \
product_material_composition_relationship product_process_plan product_related_product_category product_specification product_type \
promissory_usage_occurrence property_process \
qualitative_uncertainty quantified_assembly_component_usage \
range_characteristic real_defined_function real_literal real_numeric_variable relative_event_occurrence rep_item_group \
representation_item_relationship requirement_assigned_object requirement_assignment requirement_for_action_resource \
requirement_source requirement_view_definition_relationship resource_property resource_property_representation resource_requirement_type \
resulting_path retention revolved_face_solid_with_trim_conditions right_to_usage_association role_association row_value row_variable rule_action \
rule_condition rule_definition rule_set rule_set_group rule_software_definition rule_superseded_assignment rule_supersedence \
satisfied_requirement satisfies_requirement satisfying_item scalar_variable scattering_parameter sculptured_solid seam_edge \
security_classification security_classification_assignment security_classification_level serial_numbered_effectivity \
shape_defining_relationship shape_feature_definition \
simple_boolean_expression simple_clause simple_generic_expression simple_numeric_expression simple_string_expression sin_function \
slash_expression \
sourced_requirement specification_definition specified_higher_usage_occurrence sql_mappable_defined_function square_root_function \
standard_uncertainty start_request start_work string_defined_function string_expression string_literal string_variable \
structured_text_composition structured_text_representation substring_expression supplied_part_relationship symbol \
tan_function taper thickened_face_solid time_interval time_interval_assignment time_interval_based_effectivity time_interval_relationship \
time_interval_role time_interval_with_bounds track_blended_solid track_blended_solid_with_end_conditions transformation_with_derived_angle \
two_direction_repeat_factor \
unary_boolean_expression unary_function_call unary_generic_expression unary_numeric_expression uncertainty_qualifier uniform_resource_identifier \
usage_association user_defined_curve_font user_defined_marker user_defined_terminator_symbol user_selected_elements user_selected_shape_elements \
value_function variable variable_semantics versioned_action_request versioned_action_request_relationship \
week_of_year_and_day_date wire_shell xor_expression year_month \
auto_design_actual_date_and_time_assignment auto_design_actual_date_assignment auto_design_approval_assignment auto_design_date_and_person_assignment \
auto_design_document_reference auto_design_group_assignment auto_design_nominal_date_and_time_assignment auto_design_nominal_date_assignment \
auto_design_organization_assignment auto_design_person_and_organization_assignment auto_design_presented_item auto_design_security_classification_assignment \
action_actual action_happening identification_assignment_relationship \
]]

# -----------------------------------------------------------------------------------------------------
# all AP203 entities
set ap203all [lsort [list absorbed_dose_measure_with_unit absorbed_dose_unit abstract_variable acceleration_measure_with_unit acceleration_unit action action_assignment action_directive action_method action_method_assignment action_method_relationship action_method_role action_property action_property_representation action_relationship action_request_assignment action_request_solution action_request_status action_status address advanced_brep_shape_representation advanced_face alternate_product_relationship amount_of_substance_measure_with_unit amount_of_substance_unit angle_direction_reference angularity_tolerance angular_dimension angular_location angular_size annotation_curve_occurrence annotation_fill_area annotation_fill_area_occurrence annotation_occurrence annotation_occurrence_associativity annotation_occurrence_relationship annotation_plane annotation_subfigure_occurrence annotation_symbol annotation_symbol_occurrence annotation_text annotation_text_character annotation_text_occurrence apex application_context application_context_element application_protocol_definition applied_action_assignment applied_action_method_assignment applied_action_request_assignment applied_approval_assignment applied_attribute_classification_assignment applied_certification_assignment applied_classification_assignment applied_contract_assignment applied_date_and_time_assignment applied_date_assignment applied_document_reference applied_document_usage_constraint_assignment applied_effectivity_assignment applied_event_occurrence_assignment applied_external_identification_assignment applied_group_assignment applied_identification_assignment applied_name_assignment applied_organizational_project_assignment applied_organization_assignment applied_person_and_organization_assignment applied_presented_item applied_security_classification_assignment applied_time_interval_assignment applied_usage_right approval approval_assignment approval_date_time approval_person_organization approval_relationship approval_role approval_status area_in_set area_measure_with_unit area_unit assembly_component_usage assembly_component_usage_substitute assigned_requirement atomic_formula attribute_assertion attribute_classification_assignment attribute_language_assignment attribute_value_assignment attribute_value_role auxiliary_geometric_representation_item axis1_placement axis2_placement_2d axis2_placement_3d background_colour back_chaining_rule back_chaining_rule_body beveled_sheet_representation bezier_curve bezier_surface binary_generic_expression binary_numeric_expression binary_representation_item block boolean_expression boolean_literal boolean_representation_item boolean_result boundary_curve bounded_curve bounded_pcurve bounded_surface bounded_surface_curve boxed_half_space box_domain breakdown_context breakdown_element_group_assignment breakdown_element_realization breakdown_element_usage breakdown_of brep_with_voids bytes_representation_item b_spline_curve b_spline_curve_with_knots b_spline_surface b_spline_surface_with_knots calendar_date camera_image camera_image_3d_with_scale camera_model camera_model_d3 camera_model_d3_multi_clipping camera_model_d3_multi_clipping_intersection camera_model_d3_multi_clipping_union camera_model_d3_with_hlhsr camera_model_with_light_sources camera_usage capacitance_measure_with_unit capacitance_unit cartesian_point cartesian_transformation_operator cartesian_transformation_operator_2d cartesian_transformation_operator_3d cc_design_approval cc_design_certification cc_design_contract cc_design_date_and_time_assignment cc_design_person_and_organization_assignment cc_design_security_classification cc_design_specification_reference celsius_temperature_measure_with_unit centre_of_symmetry certification certification_assignment certification_type change change_request characteristic_data_column_header characteristic_data_column_header_link characteristic_data_table_header characteristic_data_table_header_decomposition characteristic_type characterized_class characterized_object character_glyph_font_usage character_glyph_style_outline character_glyph_style_stroke character_glyph_symbol character_glyph_symbol_outline character_glyph_symbol_stroke circle circular_runout_tolerance class classification_assignment classification_role class_by_extension class_by_intension class_system class_usage_effectivity_context_assignment closed_shell coaxiality_tolerance colour colour_rgb colour_specification common_datum comparison_expression complex_clause complex_conjunctive_clause complex_disjunctive_clause complex_shelled_solid composite_assembly_definition composite_assembly_sequence_definition composite_assembly_table composite_curve composite_curve_on_surface composite_curve_segment composite_material_designation composite_shape_aspect composite_sheet_representation composite_text composite_text_with_associated_curves composite_text_with_blanking_box composite_text_with_delineation composite_text_with_extent compound_representation_item compound_shape_representation concentricity_tolerance concept_feature_operator concept_feature_relationship concept_feature_relationship_with_condition conditional_concept_feature conductance_measure_with_unit conductance_unit configurable_item configuration_design configuration_effectivity configuration_item configuration_item_hierarchical_relationship configuration_item_relationship configuration_item_revision_sequence configured_effectivity_assignment configured_effectivity_context_assignment conic conical_stepped_hole_transition conical_surface connected_edge_set connected_face_set connected_face_sub_set constructive_geometry_representation constructive_geometry_representation_relationship contact_ratio_representation context_dependent_invisibility context_dependent_over_riding_styled_item context_dependent_shape_representation context_dependent_unit contract contract_assignment contract_relationship contract_type conversion_based_unit coordinated_universal_time_offset csg_shape_representation csg_solid currency currency_measure_with_unit curve curve_bounded_surface curve_dimension curve_replica curve_style curve_style_font curve_style_font_and_scaling curve_style_font_pattern curve_style_rendering curve_swept_solid_shape_representation cylindrical_surface cylindricity_tolerance data_environment date dated_effectivity date_and_time date_and_time_assignment date_assignment date_representation_item date_role date_time_representation_item date_time_role datum datum_feature datum_feature_callout datum_reference datum_target datum_target_callout default_tolerance_table default_tolerance_table_cell defined_symbol definitional_representation definitional_representation_relationship definitional_representation_relationship_with_same_context degenerate_pcurve degenerate_toroidal_surface derived_shape_aspect derived_unit derived_unit_element description_attribute descriptive_representation_item design_context design_make_from_relationship diameter_dimension dielectric_constant_measure_with_unit dimensional_characteristic_representation dimensional_exponents dimensional_location dimensional_location_with_path dimensional_size dimensional_size_with_path dimension_callout dimension_callout_component_relationship dimension_callout_relationship dimension_curve dimension_curve_directed_callout dimension_curve_terminator dimension_curve_terminator_to_projection_curve_associativity dimension_pair dimension_related_tolerance_zone_element dimension_text_associativity directed_action directed_dimensional_location direction document document_file document_identifier document_identifier_assignment document_product_association document_product_equivalence document_reference document_relationship document_representation_type document_type document_usage_constraint document_usage_constraint_assignment document_usage_role dose_equivalent_measure_with_unit dose_equivalent_unit double_offset_shelled_solid draped_defined_transformation draughting_annotation_occurrence draughting_callout draughting_callout_relationship draughting_elements draughting_model draughting_model_item_association draughting_pre_defined_colour draughting_pre_defined_curve_font draughting_pre_defined_text_font draughting_subfigure_representation draughting_symbol_representation draughting_text_literal_with_delineation draughting_title drawing_definition drawing_revision drawing_revision_sequence drawing_sheet_revision drawing_sheet_revision_sequence drawing_sheet_revision_usage edge edge_based_wireframe_model edge_based_wireframe_shape_representation edge_blended_solid edge_curve edge_loop effectivity effectivity_assignment effectivity_context_assignment effectivity_context_role effectivity_relationship electric_charge_measure_with_unit electric_charge_unit electric_current_measure_with_unit electric_current_unit electric_potential_measure_with_unit electric_potential_unit elementary_brep_shape_representation elementary_surface ellipse energy_measure_with_unit energy_unit entity_assertion enum_reference_prefix environment evaluated_characteristic evaluated_degenerate_pcurve evaluation_product_definition event_occurrence event_occurrence_assignment event_occurrence_relationship event_occurrence_role exclusive_product_concept_feature_category executed_action expanded_uncertainty explicit_procedural_geometric_representation_item_relationship explicit_procedural_representation_item_relationship explicit_procedural_representation_relationship explicit_procedural_shape_representation_relationship expression expression_conversion_based_unit extension extent externally_defined_class externally_defined_colour externally_defined_context_dependent_unit externally_defined_conversion_based_unit externally_defined_currency externally_defined_curve_font externally_defined_dimension_definition externally_defined_general_property externally_defined_hatch_style externally_defined_item externally_defined_item_relationship externally_defined_marker externally_defined_picture_representation_item externally_defined_representation_item externally_defined_string externally_defined_symbol externally_defined_terminator_symbol externally_defined_text_font externally_defined_tile externally_defined_tile_style external_class_library external_identification_assignment external_source external_source_relationship extruded_area_solid extruded_face_solid extruded_face_solid_with_draft_angle extruded_face_solid_with_multiple_draft_angles extruded_face_solid_with_trim_conditions face faceted_brep faceted_brep_shape_representation face_based_surface_model face_bound face_outer_bound face_surface fact_type fill_area_style fill_area_style_colour fill_area_style_hatching fill_area_style_tiles fill_area_style_tile_coloured_region fill_area_style_tile_curve_with_style fill_area_style_tile_symbol_with_style flatness_tolerance flat_pattern_ply_representation_relationship force_measure_with_unit force_unit forward_chaining_rule forward_chaining_rule_premise founded_item frequency_measure_with_unit frequency_unit func functionally_defined_transformation functional_breakdown_context functional_element_usage general_material_property general_property general_property_association general_property_relationship generic_character_glyph_symbol generic_expression generic_literal generic_variable geometrically_bounded_2d_wireframe_representation geometrically_bounded_surface_shape_representation geometrically_bounded_wireframe_shape_representation geometrical_tolerance_callout geometric_alignment geometric_curve_set geometric_intersection geometric_item_specific_usage geometric_model_element_relationship geometric_representation_context geometric_representation_item geometric_set geometric_tolerance geometric_tolerance_relationship geometric_tolerance_with_datum_reference geometric_tolerance_with_defined_unit global_assignment global_uncertainty_assigned_context global_unit_assigned_context ground_fact group group_assignment group_relationship half_space_solid hardness_representation hidden_element_over_riding_styled_item hyperbola identification_assignment identification_role id_attribute illuminance_measure_with_unit illuminance_unit included_text_block inclusion_product_concept_feature indirectly_selected_elements indirectly_selected_shape_elements inductance_measure_with_unit inductance_unit information_right information_usage_right instanced_feature instance_usage_context_assignment integer_representation_item intersection_curve interval_expression int_literal invisibility iso4217_currency item_defined_transformation item_identified_representation_usage known_source laid_defined_transformation laminate_table language leader_curve leader_directed_callout leader_directed_dimension leader_terminator length_measure_with_unit length_unit light_source light_source_ambient light_source_directional light_source_positional light_source_spot limits_and_fits line linear_dimension line_profile_tolerance literal_conjunction literal_disjunction literal_number local_time logical_literal logical_representation_item loop loss_tangent_measure_with_unit lot_effectivity luminous_flux_measure_with_unit luminous_flux_unit luminous_intensity_measure_with_unit luminous_intensity_unit magnetic_flux_density_measure_with_unit magnetic_flux_density_unit magnetic_flux_measure_with_unit magnetic_flux_unit make_from_usage_option manifold_solid_brep manifold_subsurface_shape_representation manifold_surface_shape_representation mapped_item mass_measure_with_unit mass_unit material_designation material_designation_characterization material_property material_property_representation measure_qualification measure_representation_item measure_with_unit mechanical_context mechanical_design_and_draughting_relationship mechanical_design_geometric_presentation_area mechanical_design_geometric_presentation_representation mechanical_design_presentation_representation_with_draughting mechanical_design_shaded_presentation_area mechanical_design_shaded_presentation_representation min_and_major_ply_orientation_basis modified_geometric_tolerance modified_solid modified_solid_with_placed_configuration moments_of_inertia_representation multiple_arity_boolean_expression multiple_arity_generic_expression multiple_arity_numeric_expression multi_language_attribute_assignment named_unit name_assignment name_attribute next_assembly_usage_occurrence non_manifold_surface_shape_representation null_representation_item numeric_expression object_role offset_curve_2d offset_curve_3d offset_surface one_direction_repeat_factor open_shell ordinal_date ordinate_dimension organization organizational_address organizational_project organizational_project_assignment organizational_project_relationship organizational_project_role organization_assignment organization_relationship organization_role oriented_closed_shell oriented_edge oriented_face oriented_open_shell oriented_path oriented_surface outer_boundary_curve over_riding_styled_item package_product_concept_feature parabola parallelism_tolerance parallel_offset parametric_representation_context partial_document_with_structured_text_representation_assignment part_laminate_table path pcurve percentage_laminate_definition percentage_laminate_table percentage_ply_definition perpendicularity_tolerance perpendicular_to person personal_address person_and_organization person_and_organization_address person_and_organization_assignment person_and_organization_role physical_breakdown_context physical_element_usage picture_representation picture_representation_item placed_datum_target_feature placed_feature placement planar_box planar_extent plane plane_angle_measure_with_unit plane_angle_unit plus_minus_tolerance ply_laminate_definition ply_laminate_sequence_definition ply_laminate_table point point_and_vector point_on_curve point_on_surface point_path point_replica point_style polar_complex_number_literal polyline poly_loop positioned_sketch position_tolerance power_measure_with_unit power_unit precision_qualifier predefined_picture_representation_item presentation_area presentation_layer_assignment presentation_representation presentation_set presentation_size presentation_style_assignment presentation_style_by_context presentation_view presented_item presented_item_representation pressure_measure_with_unit pressure_unit pre_defined_colour pre_defined_curve_font pre_defined_dimension_symbol pre_defined_geometrical_tolerance_symbol pre_defined_item pre_defined_marker pre_defined_point_marker_symbol pre_defined_surface_condition_symbol pre_defined_surface_side_style pre_defined_symbol pre_defined_terminator_symbol pre_defined_text_font pre_defined_tile procedural_representation procedural_representation_sequence procedural_shape_representation procedural_shape_representation_sequence product product_category product_class product_concept product_concept_context product_concept_feature product_concept_feature_association product_concept_feature_category product_concept_feature_category_usage product_concept_relationship product_context product_definition product_definition_context product_definition_context_association product_definition_context_role product_definition_effectivity product_definition_element_relationship product_definition_formation product_definition_formation_relationship product_definition_formation_with_specified_source product_definition_group_assignment product_definition_occurrence_relationship product_definition_relationship product_definition_shape product_definition_substitute product_definition_usage product_definition_with_associated_documents product_identification product_material_composition_relationship product_related_product_category product_specification projected_zone_definition projection_curve projection_directed_callout promissory_usage_occurrence property_definition property_definition_relationship property_definition_representation qualified_representation_item qualitative_uncertainty quantified_assembly_component_usage quasi_uniform_curve quasi_uniform_surface radioactivity_measure_with_unit radioactivity_unit radius_dimension range_characteristic rational_b_spline_curve rational_b_spline_surface rational_representation_item ratio_measure_with_unit ratio_unit real_literal real_representation_item rectangular_composite_surface rectangular_trimmed_surface referenced_modified_datum relative_event_occurrence reparametrised_composite_curve_segment representation representation_context representation_item representation_item_relationship representation_map representation_relationship representation_relationship_with_transformation rep_item_group requirement_assigned_object requirement_assignment requirement_source requirement_view_definition_relationship resistance_measure_with_unit resistance_unit revolved_area_solid revolved_face_solid revolved_face_solid_with_trim_conditions right_angular_wedge right_circular_cone right_circular_cylinder right_to_usage_association role_association roundness_tolerance row_representation_item row_value row_variable ruled_surface_swept_area_solid rule_action rule_condition rule_definition rule_set rule_set_group rule_software_definition rule_superseded_assignment rule_supersedence runout_zone_definition runout_zone_orientation runout_zone_orientation_reference_direction satisfied_requirement satisfies_requirement satisfying_item scalar_variable scattering_parameter sculptured_solid seam_curve security_classification security_classification_assignment security_classification_level serial_numbered_effectivity shape_aspect shape_aspect_associativity shape_aspect_deriving_relationship shape_aspect_relationship shape_definition_representation shape_dimension_representation shape_feature_definition shape_representation shape_representation_relationship shape_representation_with_parameters shelled_solid shell_based_surface_model shell_based_wireframe_model shell_based_wireframe_shape_representation simple_boolean_expression simple_clause simple_generic_expression simple_numeric_expression si_absorbed_dose_unit si_capacitance_unit si_conductance_unit si_dose_equivalent_unit si_electric_charge_unit si_electric_potential_unit si_energy_unit si_force_unit si_frequency_unit si_illuminance_unit si_inductance_unit si_magnetic_flux_density_unit si_magnetic_flux_unit si_power_unit si_pressure_unit si_radioactivity_unit si_resistance_unit si_unit slash_expression smeared_material_definition solid_angle_measure_with_unit solid_angle_unit solid_curve_font solid_model solid_replica solid_with_angle_based_chamfer solid_with_chamfered_edges solid_with_circular_pattern solid_with_circular_pocket solid_with_circular_protrusion solid_with_conical_bottom_round_hole solid_with_constant_radius_edge_blend solid_with_curved_slot solid_with_depression solid_with_double_offset_chamfer solid_with_flat_bottom_round_hole solid_with_general_pocket solid_with_general_protrusion solid_with_groove solid_with_hole solid_with_incomplete_circular_pattern solid_with_incomplete_rectangular_pattern solid_with_pocket solid_with_protrusion solid_with_rectangular_pattern solid_with_rectangular_pocket solid_with_rectangular_protrusion solid_with_shape_element_pattern solid_with_single_offset_chamfer solid_with_slot solid_with_spherical_bottom_round_hole solid_with_stepped_round_hole solid_with_stepped_round_hole_and_conical_transitions solid_with_straight_slot solid_with_tee_section_slot solid_with_through_depression solid_with_trapezoidal_section_slot solid_with_variable_radius_edge_blend sourced_requirement source_for_requirement specification_definition specified_higher_usage_occurrence sphere spherical_surface standard_uncertainty start_request start_work straightness_tolerance structured_dimension_callout structured_text_composition structured_text_representation styled_item subedge subface supplied_part_relationship surface surfaced_open_shell surface_condition_callout surface_curve surface_curve_swept_area_solid surface_of_linear_extrusion surface_of_revolution surface_patch surface_profile_tolerance surface_rendering_properties surface_replica surface_side_style surface_style_boundary surface_style_control_grid surface_style_fill_area surface_style_parameter_line surface_style_reflectance_ambient surface_style_reflectance_ambient_diffuse surface_style_reflectance_ambient_diffuse_specular surface_style_rendering surface_style_rendering_with_properties surface_style_segmentation_curve surface_style_silhouette surface_style_transparent surface_style_usage surface_texture_representation swept_area_solid swept_disk_solid swept_face_solid swept_surface symbol symbol_colour symbol_representation symbol_representation_map symbol_style symbol_target symmetric_shape_aspect symmetry_tolerance table_representation_item tactile_appearance_representation tagged_text_format tagged_text_item tangent terminator_symbol text_font text_font_family text_font_in_family text_literal text_literal_with_associated_curves text_literal_with_blanking_box text_literal_with_delineation text_literal_with_extent text_string_representation text_style text_style_for_defined_font text_style_with_box_characteristics text_style_with_mirror text_style_with_spacing thermal_resistance_measure_with_unit thermal_resistance_unit thermodynamic_temperature_measure_with_unit thermodynamic_temperature_unit thickened_face_solid thickness_laminate_definition thickness_laminate_table time_interval time_interval_assignment time_interval_based_effectivity time_interval_relationship time_interval_role time_interval_with_bounds time_measure_with_unit time_unit tolerance_value tolerance_zone tolerance_zone_definition tolerance_zone_form topological_representation_item toroidal_surface torus total_runout_tolerance track_blended_solid track_blended_solid_with_end_conditions transformation_with_derived_angle trimmed_curve two_direction_repeat_factor type_qualifier unary_generic_expression unary_numeric_expression uncertainty_assigned_representation uncertainty_measure_with_unit uncertainty_qualifier uniform_curve uniform_resource_identifier uniform_surface usage_association user_defined_curve_font user_defined_marker user_defined_terminator_symbol user_selected_elements user_selected_shape_elements value_range value_representation_item variable_semantics variational_representation_item vector vector_style velocity_measure_with_unit velocity_unit versioned_action_request vertex vertex_loop vertex_point vertex_shell view_volume visual_appearance_representation volume_measure_with_unit volume_unit week_of_year_and_day_date wire_shell year_month zone_structural_makeup]]

# all AP214 entities
set ap214all  [lsort [list abs_function acos_function action action_assignment action_directive action_method action_method_relationship action_property action_property_representation action_relationship action_request_assignment action_request_solution action_request_status action_resource action_resource_requirement action_resource_type action_status address advanced_brep_shape_representation advanced_face alternate_product_relationship amount_of_substance_measure_with_unit amount_of_substance_unit and_expression angularity_tolerance angular_dimension angular_location angular_size annotation_curve_occurrence annotation_fill_area annotation_fill_area_occurrence annotation_occurrence annotation_occurrence_associativity annotation_occurrence_relationship annotation_plane annotation_subfigure_occurrence annotation_symbol annotation_symbol_occurrence annotation_text annotation_text_character annotation_text_occurrence apex application_context application_context_element application_context_relationship application_protocol_definition applied_action_assignment applied_action_request_assignment applied_approval_assignment applied_area applied_certification_assignment applied_classification_assignment applied_contract_assignment applied_date_and_time_assignment applied_date_assignment applied_document_reference applied_document_usage_constraint_assignment applied_effectivity_assignment applied_event_occurrence_assignment applied_external_identification_assignment applied_group_assignment applied_identification_assignment applied_ineffectivity_assignment applied_name_assignment applied_organizational_project_assignment applied_organization_assignment applied_person_and_organization_assignment applied_presented_item applied_security_classification_assignment applied_time_interval_assignment approval approval_assignment approval_date_time approval_person_organization approval_relationship approval_role approval_status approximation_tolerance approximation_tolerance_deviation approximation_tolerance_parameter area_in_set area_measure_with_unit area_unit asin_function assembly_component_usage assembly_component_usage_substitute atan_function attribute_classification_assignment attribute_language_assignment attribute_value_assignment attribute_value_role axis1_placement axis2_placement_2d axis2_placement_3d background_colour barring_hole bead bead_end bezier_curve bezier_surface binary_boolean_expression binary_function_call binary_generic_expression binary_numeric_expression block boolean_defined_function boolean_expression boolean_literal boolean_result boolean_variable boss boss_top boundary_curve bounded_curve bounded_pcurve bounded_surface bounded_surface_curve boxed_half_space box_domain brep_with_voids b_spline_curve b_spline_curve_with_knots b_spline_surface b_spline_surface_with_knots calendar_date camera_image camera_image_2d_with_scale camera_image_3d_with_scale camera_model camera_model_d2 camera_model_d3 camera_model_d3_with_hlhsr camera_usage cartesian_point cartesian_transformation_operator cartesian_transformation_operator_2d cartesian_transformation_operator_3d celsius_temperature_measure_with_unit centre_of_symmetry certification certification_assignment certification_type chamfer chamfer_offset characterized_class characterized_object character_glyph_symbol circle circular_closed_profile circular_pattern circular_runout_tolerance class classification_assignment classification_role class_system class_usage_effectivity_context_assignment closed_path_profile closed_shell coaxiality_tolerance colour colour_rgb colour_specification common_datum comparison_equal comparison_expression comparison_greater comparison_greater_equal comparison_less comparison_less_equal comparison_not_equal composite_curve composite_curve_on_surface composite_curve_segment composite_hole composite_shape_aspect composite_text composite_text_with_associated_curves composite_text_with_blanking_box composite_text_with_extent compound_feature compound_representation_item compound_shape_representation concat_expression concentricity_tolerance concept_feature_operator concept_feature_relationship concept_feature_relationship_with_condition conditional_concept_feature configurable_item configuration_definition configuration_design configuration_effectivity configuration_interpolation configuration_item configured_effectivity_assignment configured_effectivity_context_assignment conic conical_surface connected_edge_set connected_face_set connected_face_sub_set constructive_geometry_representation constructive_geometry_representation_relationship contact_ratio_representation context_dependent_invisibility context_dependent_over_riding_styled_item context_dependent_shape_representation context_dependent_unit contract contract_assignment contract_type conversion_based_unit coordinated_universal_time_offset cos_function csg_shape_representation csg_solid curve curve_bounded_surface curve_dimension curve_replica curve_style curve_style_font curve_style_font_pattern curve_style_rendering curve_swept_solid_shape_representation cylindrical_pair cylindrical_pair_range cylindrical_pair_value cylindrical_surface cylindricity_tolerance data_environment date dated_effectivity date_and_time date_and_time_assignment date_assignment date_role date_time_role datum datum_feature datum_feature_callout datum_reference datum_target datum_target_callout default_tolerance_table default_tolerance_table_cell defined_character_glyph defined_function defined_symbol definitional_representation degenerate_pcurve degenerate_toroidal_surface derived_shape_aspect derived_unit derived_unit_element derived_unit_variable description_attribute descriptive_representation_item diameter_dimension dimensional_characteristic_representation dimensional_exponents dimensional_location dimensional_location_with_path dimensional_size dimensional_size_with_path dimension_callout dimension_callout_component_relationship dimension_callout_relationship dimension_curve dimension_curve_directed_callout dimension_curve_terminator dimension_pair dimension_related_tolerance_zone_element dimension_text_associativity directed_action directed_angle directed_dimensional_location direction direction_shape_representation div_expression document document_file document_product_association document_product_equivalence document_reference document_relationship document_representation_type document_type document_usage_constraint document_usage_constraint_assignment document_usage_role draughting_annotation_occurrence draughting_callout draughting_callout_relationship draughting_elements draughting_model draughting_model_item_association draughting_pre_defined_colour draughting_pre_defined_curve_font draughting_pre_defined_text_font draughting_specification_reference draughting_subfigure_representation draughting_symbol_representation draughting_text_literal_with_delineation draughting_title drawing_definition drawing_revision drawing_revision_sequence drawing_sheet_layout drawing_sheet_revision drawing_sheet_revision_usage edge edge_based_wireframe_model edge_based_wireframe_shape_representation edge_curve edge_loop edge_round effectivity effectivity_assignment effectivity_context_assignment effectivity_context_role effectivity_relationship electric_current_measure_with_unit electric_current_unit elementary_surface element_delivery ellipse environment equals_expression evaluated_degenerate_pcurve event_occurrence event_occurrence_assignment event_occurrence_context_assignment event_occurrence_context_role event_occurrence_role exclusive_product_concept_feature_category executed_action expression expression_conversion_based_unit exp_function extension externally_defined_character_glyph externally_defined_class externally_defined_curve_font externally_defined_dimension_definition externally_defined_feature_definition externally_defined_general_property externally_defined_hatch_style externally_defined_item externally_defined_item_relationship externally_defined_style externally_defined_symbol externally_defined_text_font externally_defined_tile_style external_identification_assignment external_source extruded_area_solid extruded_face_solid face faceted_brep faceted_brep_shape_representation face_based_surface_model face_bound face_outer_bound face_shape_representation face_surface featured_shape feature_component_definition feature_component_relationship feature_definition feature_in_panel feature_pattern fillet fill_area_style fill_area_style_colour fill_area_style_hatching fill_area_style_tiles fill_area_style_tile_symbol_with_style flatness_tolerance format_function founded_item founded_kinematic_path fully_constrained_pair functionally_defined_transformation gear_pair gear_pair_range gear_pair_value general_feature general_material_property general_property general_property_association general_property_relationship generic_character_glyph_symbol generic_expression generic_literal generic_variable geometrically_bounded_2d_wireframe_representation geometrically_bounded_surface_shape_representation geometrically_bounded_wireframe_shape_representation geometrical_tolerance_callout geometric_alignment geometric_curve_set geometric_intersection geometric_item_specific_usage geometric_representation_context geometric_representation_item geometric_set geometric_tolerance geometric_tolerance_relationship geometric_tolerance_with_datum_reference geometric_tolerance_with_defined_unit global_uncertainty_assigned_context global_unit_assigned_context group group_assignment group_relationship half_space_solid hardness_representation hidden_element_over_riding_styled_item hole_bottom hole_in_panel homokinetic_pair hyperbola identification_assignment identification_role id_attribute inclusion_product_concept_feature index_expression initial_state instanced_feature integer_defined_function interpolated_configuration_sequence intersection_curve interval_expression int_literal int_numeric_variable int_value_function invisibility item_defined_transformation item_identified_representation_usage joggle joggle_termination kinematic_analysis_consistency kinematic_analysis_result kinematic_control kinematic_frame_background_representation kinematic_frame_background_representation_association kinematic_frame_based_transformation kinematic_ground_representation kinematic_joint kinematic_link kinematic_link_representation kinematic_link_representation_association kinematic_link_representation_relation kinematic_pair kinematic_path kinematic_property_definition kinematic_property_representation_relation kinematic_structure known_source language language_assignment leader_curve leader_directed_callout leader_directed_dimension leader_terminator length_function length_measure_with_unit length_unit light_source light_source_ambient light_source_directional light_source_positional light_source_spot like_expression limits_and_fits line linear_dimension line_profile_tolerance literal_number local_time location_shape_representation locator log10_function log2_function log_function loop lot_effectivity luminous_intensity_measure_with_unit luminous_intensity_unit make_from_usage_option manifold_solid_brep manifold_subsurface_shape_representation manifold_surface_shape_representation mapped_item mass_measure_with_unit mass_unit material_designation material_designation_characterization material_property material_property_representation maximum_function measure_qualification measure_representation_item measure_with_unit mechanical_context mechanical_design_geometric_presentation_area mechanical_design_geometric_presentation_representation mechanism mechanism_base_placement minimum_function minus_expression minus_function modified_geometric_tolerance modified_pattern mod_expression moments_of_inertia_representation motion_link_relationship multiple_arity_boolean_expression multiple_arity_function_call multiple_arity_generic_expression multiple_arity_numeric_expression multi_language_attribute_assignment mult_expression named_unit named_unit_variable name_assignment name_attribute next_assembly_usage_occurrence ngon_closed_profile non_manifold_surface_shape_representation not_expression numeric_defined_function numeric_expression numeric_variable object_role odd_function offset_curve_2d offset_curve_3d offset_surface one_direction_repeat_factor open_path_profile open_shell ordinate_dimension organization organizational_address organizational_project organizational_project_assignment organizational_project_relationship organizational_project_role organization_assignment organization_relationship organization_role oriented_closed_shell oriented_edge oriented_face oriented_open_shell oriented_path oriented_surface or_expression outer_boundary_curve over_riding_styled_item package_product_concept_feature pair_actuator pair_value parabola parallelism_tolerance parallel_offset parametric_representation_context partial_circular_profile path path_feature_component path_shape_representation pattern_offset_membership pattern_omit_membership pcurve perpendicularity_tolerance perpendicular_to person personal_address person_and_organization person_and_organization_address person_and_organization_assignment person_and_organization_role physically_modelled_product_definition placed_datum_target_feature placed_feature placement planar_box planar_curve_pair planar_curve_pair_range planar_extent planar_pair planar_pair_range planar_pair_value planar_shape_representation plane plane_angle_measure_with_unit plane_angle_unit plus_expression plus_minus_tolerance pocket pocket_bottom point point_on_curve point_on_planar_curve_pair point_on_planar_curve_pair_range point_on_planar_curve_pair_value point_on_surface point_on_surface_pair point_on_surface_pair_range point_on_surface_pair_value point_placement_shape_representation point_replica point_style polyline poly_loop position_tolerance power_expression precision_qualifier presentation_area presentation_layer_assignment presentation_representation presentation_set presentation_size presentation_style_assignment presentation_style_by_context presentation_view presented_item presented_item_representation pre_defined_colour pre_defined_curve_font pre_defined_dimension_symbol pre_defined_geometrical_tolerance_symbol pre_defined_item pre_defined_marker pre_defined_point_marker_symbol pre_defined_presentation_style pre_defined_surface_condition_symbol pre_defined_symbol pre_defined_terminator_symbol pre_defined_text_font prismatic_pair prismatic_pair_range prismatic_pair_value process_operation process_plan process_product_association process_property_association product product_category product_category_relationship product_class product_concept product_concept_context product_concept_feature product_concept_feature_association product_concept_feature_category product_concept_feature_category_usage product_concept_relationship product_context product_definition product_definition_context product_definition_context_association product_definition_context_role product_definition_effectivity product_definition_formation product_definition_formation_relationship product_definition_formation_with_specified_source product_definition_occurrence_relationship product_definition_process product_definition_relationship product_definition_resource product_definition_shape product_definition_substitute product_definition_usage product_definition_with_associated_documents product_identification product_process_plan product_related_product_category product_specification product_type projected_zone_definition projection_curve projection_directed_callout promissory_usage_occurrence property_definition property_definition_relationship property_definition_representation property_process qualified_representation_item qualitative_uncertainty quantified_assembly_component_usage quasi_uniform_curve quasi_uniform_surface rack_and_pinion_pair rack_and_pinion_pair_range rack_and_pinion_pair_value radius_dimension rational_b_spline_curve rational_b_spline_surface ratio_measure_with_unit ratio_unit real_defined_function real_literal real_numeric_variable rectangular_closed_profile rectangular_composite_surface rectangular_pattern rectangular_trimmed_surface referenced_modified_datum relative_event_occurrence reparametrised_composite_curve_segment replicate_feature representation representation_context representation_item representation_map representation_relationship representation_relationship_with_transformation rep_item_group requirement_for_action_resource resource_property resource_property_representation resource_requirement_type resulting_path retention revolute_pair revolute_pair_range revolute_pair_value revolved_area_solid revolved_face_solid rib right_angular_wedge right_circular_cone right_circular_cylinder role_association rolling_curve_pair rolling_curve_pair_value rolling_surface_pair rolling_surface_pair_value rotation_about_direction rounded_u_profile roundness_tolerance round_hole ruled_surface_swept_area_solid runout_zone_definition runout_zone_orientation runout_zone_orientation_reference_direction screw_pair screw_pair_range screw_pair_value seam_curve seam_edge security_classification security_classification_assignment security_classification_level serial_numbered_effectivity shape_aspect shape_aspect_associativity shape_aspect_deriving_relationship shape_aspect_relationship shape_aspect_transition shape_defining_relationship shape_definition_representation shape_dimension_representation shape_representation shape_representation_relationship shape_representation_with_parameters shell_based_surface_model simple_boolean_expression simple_generic_expression simple_numeric_expression simple_pair_range simple_string_expression sin_function si_unit slash_expression sliding_curve_pair sliding_curve_pair_value sliding_surface_pair sliding_surface_pair_value slot slot_end solid_angle_measure_with_unit solid_angle_unit solid_model solid_replica specified_higher_usage_occurrence sphere spherical_pair spherical_pair_range spherical_pair_value spherical_surface sql_mappable_defined_function square_root_function square_u_profile standard_uncertainty straightness_tolerance string_defined_function string_expression string_literal string_variable structured_dimension_callout styled_item subedge subface substring_expression surface surface_condition_callout surface_curve surface_curve_swept_area_solid surface_of_linear_extrusion surface_of_revolution surface_pair surface_pair_range surface_patch surface_profile_tolerance surface_rendering_properties surface_replica surface_side_style surface_style_boundary surface_style_control_grid surface_style_fill_area surface_style_parameter_line surface_style_reflectance_ambient surface_style_reflectance_ambient_diffuse surface_style_reflectance_ambient_diffuse_specular surface_style_rendering surface_style_rendering_with_properties surface_style_segmentation_curve surface_style_silhouette surface_style_transparent surface_style_usage surface_texture_representation swept_area_solid swept_disk_solid swept_face_solid swept_surface symbol_colour symbol_representation symbol_representation_map symbol_style symbol_target symmetric_shape_aspect symmetry_tolerance tactile_appearance_representation tangent tan_function taper tee_profile terminator_symbol text_literal text_literal_with_associated_curves text_literal_with_blanking_box text_literal_with_delineation text_literal_with_extent text_string_representation text_style text_style_for_defined_font text_style_with_box_characteristics text_style_with_mirror text_style_with_spacing thermodynamic_temperature_measure_with_unit thermodynamic_temperature_unit thread time_interval time_interval_assignment time_interval_based_effectivity time_interval_role time_interval_with_bounds time_measure_with_unit time_unit tolerance_value tolerance_zone tolerance_zone_definition tolerance_zone_form topological_representation_item toroidal_surface torus total_runout_tolerance transition_feature trimmed_curve two_direction_repeat_factor type_qualifier unary_boolean_expression unary_function_call unary_generic_expression unary_numeric_expression uncertainty_assigned_representation uncertainty_measure_with_unit uncertainty_qualifier unconstrained_pair unconstrained_pair_value uniform_curve uniform_surface universal_pair universal_pair_range universal_pair_value value_function value_range value_representation_item variable variable_semantics vector vector_style vee_profile versioned_action_request versioned_action_request_relationship vertex vertex_loop vertex_point view_volume visual_appearance_representation volume_measure_with_unit volume_unit xor_expression auto_design_document_reference auto_design_group_assignment auto_design_nominal_date_and_time_assignment auto_design_nominal_date_assignment auto_design_organization_assignment auto_design_person_and_organization_assignment auto_design_presented_item auto_design_security_classification_assignment auto_design_actual_date_and_time_assignment auto_design_actual_date_assignment auto_design_approval_assignment auto_design_date_and_person_assignment 
]]

# all AP242 edition 1 and 2 entities
set ap242all [lsort [list abrupt_change_of_surface_normal abs_function absorbed_dose_measure_with_unit absorbed_dose_unit abstract_variable abstracted_expression_function acceleration_measure_with_unit acceleration_unit acos_function action action_actual action_assignment action_directive action_happening action_method action_method_assignment action_method_relationship action_method_role action_property action_property_representation action_relationship action_request_assignment action_request_solution action_request_status action_resource action_resource_requirement action_resource_type action_status actuated_kinematic_pair add_element additive_manufacturing_build_plate_relationship additive_manufacturing_setup additive_manufacturing_setup_relationship additive_manufacturing_setup_workpiece_relationship additive_manufacturing_support_structure_geometry_relationship address advanced_brep_shape_representation advanced_face agc_with_dimension aggregate_id_attribute all_around_shape_aspect alternate_product_relationship amount_of_substance_measure_with_unit amount_of_substance_unit analysis_assignment analysis_item and_expression angle_assembly_constraint_with_dimension angle_geometric_constraint angular_dimension angular_location angular_size angularity_tolerance annotation_curve_occurrence annotation_fill_area annotation_fill_area_occurrence annotation_occurrence annotation_occurrence_associativity annotation_occurrence_relationship annotation_placeholder_occurrence annotation_plane annotation_point_occurrence annotation_subfigure_occurrence annotation_symbol annotation_symbol_occurrence annotation_text annotation_text_character annotation_text_occurrence apex application_context application_context_element application_defined_function application_protocol_definition applied_action_assignment applied_action_method_assignment applied_action_request_assignment applied_approval_assignment applied_area applied_attribute_classification_assignment applied_certification_assignment applied_classification_assignment applied_contract_assignment applied_date_and_time_assignment applied_date_assignment applied_description_text_assignment applied_document_reference applied_document_usage_constraint_assignment applied_effectivity_assignment applied_event_occurrence_assignment applied_external_identification_assignment applied_group_assignment applied_identification_assignment applied_ineffectivity_assignment applied_location_assignment applied_location_representation_assignment applied_name_assignment applied_organization_assignment applied_organization_type_assignment applied_organizational_project_assignment applied_person_and_organization_assignment applied_presented_item applied_security_classification_assignment applied_state_observed_assignment applied_state_type_assignment applied_time_interval_assignment applied_usage_right approval approval_assignment approval_date_time approval_person_organization approval_relationship approval_role approval_status area_in_set area_measure_with_unit area_unit area_with_outer_boundary array_placement_group ascribable_state ascribable_state_relationship asin_function assembly_bond_definition assembly_component assembly_component_usage assembly_component_usage_substitute assembly_geometric_constraint assembly_group_component assembly_group_component_definition_placement_link assembly_joint assembly_shape_constraint assembly_shape_constraint_item_relationship assembly_shape_joint assembly_shape_joint_item_relationship assigned_analysis assigned_requirement atan_function atom_based_literal atomic_formula attachment_slot_as_planned attachment_slot_as_realized attachment_slot_design attachment_slot_design_to_planned attachment_slot_design_to_realized attachment_slot_on_product attachment_slot_planned_to_realized attribute_assertion attribute_classification_assignment attribute_language_assignment attribute_value_assignment attribute_value_role auxiliary_geometric_representation_item axis1_placement axis2_placement_2d axis2_placement_3d b_spline_basis b_spline_curve b_spline_curve_knot_locator b_spline_curve_segment b_spline_curve_with_knots b_spline_function b_spline_surface b_spline_surface_knot_locator b_spline_surface_patch b_spline_surface_strip b_spline_surface_with_knots b_spline_volume b_spline_volume_with_knots back_chaining_rule back_chaining_rule_body background_colour barring_hole basic_sparse_matrix bead bead_end between_shape_aspect beveled_sheet_representation bezier_curve bezier_surface bezier_volume binary_assembly_constraint binary_boolean_expression binary_function_call binary_generic_expression binary_literal binary_numeric_expression binary_representation_item block block_volume boolean_defined_function boolean_expression boolean_literal boolean_representation_item boolean_result boolean_result_2d boolean_variable boss boss_top bound_parameter_environment bound_variational_parameter boundary_curve boundary_curve_of_b_spline_or_rectangular_composite_surface bounded_curve bounded_pcurve bounded_surface bounded_surface_curve box_domain boxed_half_space breakdown_context breakdown_element_group_assignment breakdown_element_realization breakdown_element_usage breakdown_of brep_with_voids bytes_representation_item calendar_date camera_image camera_image_2d_with_scale camera_image_3d_with_scale camera_model camera_model_d2 camera_model_d3 camera_model_d3_multi_clipping camera_model_d3_multi_clipping_intersection camera_model_d3_multi_clipping_union camera_model_d3_with_hlhsr camera_model_with_light_sources camera_usage capacitance_measure_with_unit capacitance_unit cartesian_11 cartesian_complex_number_region cartesian_point cartesian_transformation_operator cartesian_transformation_operator_2d cartesian_transformation_operator_3d cc_design_approval cc_design_certification cc_design_contract cc_design_date_and_time_assignment cc_design_person_and_organization_assignment cc_design_security_classification cc_design_specification_reference cdgc_with_dimension celsius_temperature_measure_with_unit centre_of_symmetry certification certification_assignment certification_type chain_based_geometric_item_specific_usage chain_based_item_identified_representation_usage chamfer chamfer_offset change change_composition_relationship change_element change_element_sequence change_group change_group_assignment change_request character_glyph_font_usage character_glyph_style_outline character_glyph_style_stroke character_glyph_symbol character_glyph_symbol_outline character_glyph_symbol_stroke characteristic_data_column_header characteristic_data_column_header_link characteristic_data_table_header characteristic_data_table_header_decomposition characteristic_type characterized_chain_based_item_within_representation characterized_class characterized_item_within_representation characterized_location_object characterized_object characterized_object_relationship characterized_product_concept_feature characterized_product_concept_feature_category characterized_representation circle circular_area circular_closed_profile circular_involute circular_path circular_pattern circular_runout_tolerance class class_by_extension class_by_intension class_system class_usage_effectivity_context_assignment classification_assignment classification_role clgc_with_dimension closed_curve_style_parameters closed_path_profile closed_shell clothoid coaxial_assembly_constraint coaxial_geometric_constraint coaxiality_tolerance collection collection_assignment collection_membership collection_relationship collection_version collection_version_relationship collection_version_sequence_relationship collection_view_definition colour colour_rgb colour_specification common_datum comparison_equal comparison_expression comparison_greater comparison_greater_equal comparison_less comparison_less_equal comparison_not_equal complex_area complex_clause complex_conjunctive_clause complex_disjunctive_clause complex_number_literal complex_number_literal_polar complex_shelled_solid complex_triangulated_face complex_triangulated_surface_set component_definition component_feature component_feature_group_identification component_feature_joint component_feature_relationship component_mating_constraint_condition component_path_shape_aspect component_terminal composite_assembly_sequence_definition composite_assembly_table composite_curve composite_curve_on_surface composite_curve_segment composite_curve_transition_locator composite_group_shape_aspect composite_hole composite_material_designation composite_shape_aspect composite_sheet_representation composite_text composite_text_with_associated_curves composite_text_with_blanking_box composite_text_with_delineation composite_text_with_extent composite_unit_shape_aspect compound_feature compound_representation_item compound_shape_representation concat_expression concentricity_tolerance concept_feature_operator concept_feature_relationship concept_feature_relationship_with_condition condition conditional_concept_feature conditional_effectivity conductance_measure_with_unit conductance_unit configurable_item configuration_design configuration_effectivity configuration_item configuration_item_hierarchical_relationship configuration_item_relationship configuration_item_revision_sequence configured_effectivity_assignment configured_effectivity_context_assignment conic conical_stepped_hole_transition conical_surface connected_edge_set connected_edge_with_length_set_representation connected_face_set connected_face_sub_set connected_volume_set connected_volume_sub_set connection_zone_based_assembly_joint connection_zone_interface_plane_relationship connectivity_definition connectivity_definition_item_relationship constant_function constituent_shape_aspect constrained_kinematic_motion_representation constructive_geometry_representation constructive_geometry_representation_relationship contact_feature contact_feature_definition contact_feature_definition_fit_relationship contact_feature_fit_relationship contact_ratio_representation contacting_feature containing_message context_dependent_invisibility context_dependent_kinematic_link_representation context_dependent_over_riding_styled_item context_dependent_shape_representation context_dependent_unit continuous_shape_aspect contract contract_assignment contract_relationship contract_type conversion_based_unit convex_hexahedron coordinated_universal_time_offset coordinates_list cos_function counterbore_definition counterbore_hole_definition counterbore_hole_occurrence counterbore_hole_occurrence_in_assembly counterdrill_hole_definition counterdrill_hole_occurrence counterdrill_hole_occurrence_in_assembly countersink_hole_definition countersink_hole_occurrence countersink_hole_occurrence_in_assembly cross_sectional_alternative_shape_element cross_sectional_group_shape_element cross_sectional_group_shape_element_with_lacing cross_sectional_group_shape_element_with_tubular_cover cross_sectional_occurrence_shape_element cross_sectional_part_shape_element csg_2d_shape_representation csg_primitive_solid_2d csg_shape_representation csg_solid csg_solid_2d cubic_bezier_tessellated_edge cubic_bezier_triangulated_face cubic_tessellated_connecting_edge currency currency_measure_with_unit current_change_element_assignment curve curve_11 curve_based_path curve_based_path_with_orientation curve_based_path_with_orientation_and_parameters curve_bounded_surface curve_dimension curve_distance_geometric_constraint curve_length_geometric_constraint curve_replica curve_segment_set curve_smoothness_geometric_constraint curve_style curve_style_font curve_style_font_and_scaling curve_style_font_pattern curve_style_parameters_representation curve_style_parameters_with_ends curve_style_rendering curve_swept_solid_shape_representation curve_with_excessive_segments curve_with_small_curvature_radius cyclide_segment_solid cylindrical_11 cylindrical_pair cylindrical_pair_value cylindrical_pair_with_range cylindrical_point cylindrical_surface cylindrical_volume cylindricity_tolerance data_environment data_quality_assessment_measurement_association data_quality_assessment_specification data_quality_criteria_representation data_quality_criterion data_quality_criterion_assessment_association data_quality_criterion_measurement_association data_quality_definition data_quality_definition_relationship data_quality_definition_representation_relationship data_quality_inspection_criterion_report data_quality_inspection_criterion_report_item data_quality_inspection_instance_report data_quality_inspection_instance_report_item data_quality_inspection_report data_quality_inspection_result data_quality_inspection_result_representation data_quality_inspection_result_with_judgement data_quality_measurement_requirement data_quality_report_measurement_association data_quality_report_request date date_and_time date_and_time_assignment date_assignment date_representation_item date_role date_time_representation_item date_time_role dated_effectivity datum datum_feature datum_feature_callout datum_reference datum_reference_compartment datum_reference_element datum_reference_modifier_with_value datum_system datum_target datum_target_callout default_model_geometric_view default_tolerance_table default_tolerance_table_cell defined_character_glyph defined_constraint defined_function defined_symbol definite_integral_expression definite_integral_function definitional_product_definition_usage definitional_representation definitional_representation_relationship definitional_representation_relationship_with_same_context degenerate_pcurve degenerate_toroidal_surface delete_element derived_component_terminal derived_shape_aspect derived_unit derived_unit_element description_attribute description_text description_text_assignment descriptive_representation_item design_context design_make_from_relationship detailed_report_request detailed_report_request_with_number_of_data diameter_dimension dielectric_constant_measure_with_unit dimension_callout dimension_callout_component_relationship dimension_callout_relationship dimension_curve dimension_curve_directed_callout dimension_curve_terminator dimension_curve_terminator_to_projection_curve_associativity dimension_pair dimension_related_tolerance_zone_element dimension_text_associativity dimensional_characteristic_representation dimensional_exponents dimensional_location dimensional_location_with_datum_feature dimensional_location_with_path dimensional_size dimensional_size_with_datum_feature dimensional_size_with_path directed_action directed_angle directed_dimensional_location directed_tolerance_zone direction direction_shape_representation disallowed_assembly_relationship_usage disconnected_face_set discontinuous_geometry div_expression document document_file document_identifier document_identifier_assignment document_product_association document_product_equivalence document_reference document_relationship document_representation_type document_type document_usage_constraint document_usage_constraint_assignment document_usage_role dose_equivalent_measure_with_unit dose_equivalent_unit double_offset_shelled_solid draped_orientation_angle draughting_annotation_occurrence draughting_callout draughting_callout_relationship draughting_elements draughting_model draughting_model_item_association draughting_model_item_association_with_placeholder draughting_pre_defined_colour draughting_pre_defined_curve_font draughting_pre_defined_text_font draughting_specification_reference draughting_subfigure_representation draughting_symbol_representation draughting_text_literal_with_delineation draughting_title drawing_definition drawing_revision drawing_revision_sequence drawing_sheet_layout drawing_sheet_revision drawing_sheet_revision_sequence drawing_sheet_revision_usage dupin_cyclide_surface eccentric_cone eccentric_conical_volume edge edge_based_wireframe_model edge_based_wireframe_shape_representation edge_blended_solid edge_curve edge_loop edge_round edge_with_excessive_segments edge_with_length effectivity effectivity_assignment effectivity_context_assignment effectivity_context_role effectivity_relationship electric_charge_measure_with_unit electric_charge_unit electric_current_measure_with_unit electric_current_unit electric_potential_measure_with_unit electric_potential_unit elementary_brep_shape_representation elementary_function elementary_space elementary_surface ellipse ellipsoid ellipsoid_volume elliptic_area energy_measure_with_unit energy_unit entirely_narrow_face entirely_narrow_solid entirely_narrow_surface entity_assertion enum_reference_prefix envelope envelope_relationship environment equal_parameter_constraint equals_expression erroneous_b_spline_curve_definition erroneous_b_spline_surface_definition erroneous_data erroneous_geometry erroneous_manifold_solid_brep erroneous_topology erroneous_topology_and_geometry_relationship evaluated_characteristic evaluated_characteristic_of_product_as_individual_test_result evaluated_degenerate_pcurve evaluation_product_definition event_occurrence event_occurrence_assignment event_occurrence_relationship event_occurrence_role evidence excessive_use_of_groups excessive_use_of_layers excessively_high_degree_curve excessively_high_degree_surface exclusive_product_concept_feature_category executed_action exp_function expanded_uncertainty explicit_constraint explicit_geometric_constraint explicit_procedural_geometric_representation_item_relationship explicit_procedural_representation_item_relationship explicit_procedural_representation_relationship explicit_procedural_shape_representation_relationship explicit_table_function expression expression_conversion_based_unit expression_denoted_function expression_extension_numeric expression_extension_string expression_extension_to_select extended_tuple_space extension extent external_class_library external_identification_assignment external_source external_source_relationship externally_conditioned_data_quality_criteria_representation externally_conditioned_data_quality_criterion externally_conditioned_data_quality_inspection_instance_report_item externally_conditioned_data_quality_inspection_result externally_conditioned_data_quality_inspection_result_representation externally_defined_character_glyph externally_defined_class externally_defined_colour externally_defined_context_dependent_unit externally_defined_conversion_based_unit externally_defined_currency externally_defined_curve_font externally_defined_dimension_definition externally_defined_feature_definition externally_defined_general_property externally_defined_hatch_style externally_defined_item externally_defined_item_relationship externally_defined_item_with_multiple_references externally_defined_marker externally_defined_picture_representation_item externally_defined_representation externally_defined_representation_item externally_defined_string externally_defined_style externally_defined_symbol externally_defined_terminator_symbol externally_defined_text_font externally_defined_tile externally_defined_tile_style externally_listed_data extreme_instance extreme_patch_width_variation extruded_area_solid extruded_face_solid extruded_face_solid_with_draft_angle extruded_face_solid_with_multiple_draft_angles extruded_face_solid_with_trim_conditions face face_based_surface_model face_bound face_outer_bound face_shape_representation face_shape_representation_relationship face_surface face_surface_with_excessive_patches_in_one_direction faceted_brep faceted_brep_shape_representation faceted_primitive fact_type feature_component_definition feature_component_relationship feature_definition feature_definition_with_connection_area feature_for_datum_target_relationship feature_in_panel feature_pattern fill_area_style fill_area_style_colour fill_area_style_hatching fill_area_style_tile_coloured_region fill_area_style_tile_curve_with_style fill_area_style_tile_symbol_with_style fill_area_style_tiles fillet finite_function finite_integer_interval finite_real_interval finite_space fixed_constituent_assembly_constraint fixed_element_geometric_constraint fixed_instance_attribute_set fixed_reference_swept_surface flat_face flat_pattern_ply_representation_relationship flatness_tolerance force_measure_with_unit force_unit format_function forward_chaining_rule forward_chaining_rule_premise founded_item free_edge free_form_assignment free_form_constraint free_form_relation free_kinematic_motion_representation frequency_measure_with_unit frequency_unit frozen_assignment fully_constrained_pair func function_application function_space functional_breakdown_context functional_element_usage functionally_defined_transformation g1_discontinuity_between_adjacent_faces g1_discontinuous_curve g1_discontinuous_surface g2_discontinuity_between_adjacent_faces g2_discontinuous_curve g2_discontinuous_surface gap_between_adjacent_edges_in_loop gap_between_edge_and_base_surface gap_between_faces_related_to_an_edge gap_between_pcurves_related_to_an_edge gap_between_vertex_and_base_surface gap_between_vertex_and_edge gear gear_pair gear_pair_value gear_pair_with_range general_datum_reference general_feature general_linear_function general_material_property general_property general_property_association general_property_relationship generated_finite_numeric_space generic_character_glyph_symbol generic_expression generic_literal generic_product_definition_reference generic_variable geometric_alignment geometric_contact geometric_curve_set geometric_gap_in_topology geometric_intersection geometric_item_specific_usage geometric_model_element_relationship geometric_representation_context geometric_representation_context_with_parameter geometric_representation_item geometric_set geometric_tolerance geometric_tolerance_auxiliary_classification geometric_tolerance_relationship geometric_tolerance_with_datum_reference geometric_tolerance_with_defined_area_unit geometric_tolerance_with_defined_unit geometric_tolerance_with_maximum_tolerance geometric_tolerance_with_modifiers geometrical_tolerance_callout geometrically_bounded_2d_wireframe_representation geometrically_bounded_surface_shape_representation geometrically_bounded_wireframe_shape_representation geometry_with_local_irregularity geometry_with_local_near_degeneracy global_assignment global_uncertainty_assigned_context global_unit_assigned_context ground_fact group group_assignment group_relationship half_space_2d half_space_solid hardness_representation harness_node harness_segment hexahedron_volume hidden_element_over_riding_styled_item hierarchical_interface_connection high_degree_axi_symmetric_surface high_degree_conic high_degree_linear_curve high_degree_planar_surface high_order_kinematic_pair hole_bottom hole_depth hole_diameter hole_in_panel homogeneous_linear_function homokinetic_pair hyperbola id_attribute identification_assignment identification_assignment_relationship identification_role illuminance_measure_with_unit illuminance_unit implicit_explicit_positioned_sketch_relationship implicit_intersection_curve implicit_model_intersection_curve implicit_planar_curve implicit_planar_intersection_point implicit_planar_projection_point implicit_point_on_plane implicit_projected_curve implicit_silhouette_curve imported_curve_function imported_point_function imported_surface_function imported_volume_function in_zone inappropriate_element_visibility inappropriate_use_of_layer inapt_data inapt_geometry inapt_manifold_solid_brep inapt_topology inapt_topology_and_geometry_relationship incidence_assembly_constraint incidence_geometric_constraint included_text_block inclusion_product_concept_feature inconsistent_adjacent_face_normals inconsistent_curve_transition_code inconsistent_edge_and_curve_directions inconsistent_element_reference inconsistent_face_and_closed_shell_normals inconsistent_face_and_surface_normals inconsistent_surface_transition_code index_expression indirectly_selected_elements indirectly_selected_shape_elements indistinct_curve_knots indistinct_surface_knots inductance_measure_with_unit inductance_unit information_right information_usage_right instance_attribute_reference instance_report_item_with_extreme_instances instance_usage_context_assignment instanced_feature int_literal int_numeric_variable int_value_function integer_defined_function integer_interval_from_min integer_interval_to_max integer_representation_item integer_tuple_literal interface_component interface_connection interface_connector_as_planned interface_connector_as_realized interface_connector_definition interface_connector_design interface_connector_design_to_planned interface_connector_design_to_realized interface_connector_occurrence interface_connector_planned_to_realized interface_connector_version interface_definition_connection interface_definition_for interface_specification_definition interface_specification_version interfaced_group_component interpolated_configuration_representation interpolated_configuration_segment interpolated_configuration_sequence intersecting_connected_face_sets intersecting_loops_in_face intersecting_shells_in_solid intersection_curve interval_expression invisibility iso4217_currency item_defined_transformation item_identified_representation_usage item_link_motion_relationship joggle joggle_termination kinematic_analysis_consistency kinematic_analysis_result kinematic_control kinematic_joint kinematic_link kinematic_link_representation kinematic_link_representation_association kinematic_loop kinematic_pair kinematic_path kinematic_path_defined_by_curves kinematic_path_defined_by_nodes kinematic_path_segment kinematic_property_definition_representation kinematic_property_mechanism_representation kinematic_property_topology_representation kinematic_topology_directed_structure kinematic_topology_network_structure kinematic_topology_structure kinematic_topology_substructure kinematic_topology_tree_structure known_source laid_orientation_angle laminate_table language leader_curve leader_directed_callout leader_directed_dimension leader_terminator length_function length_measure_with_unit length_tolerance_value length_unit light_source light_source_ambient light_source_directional light_source_positional light_source_spot like_expression limits_and_fits line line_profile_tolerance linear_array_component_definition_link linear_array_placement_group_component linear_dimension linear_flexible_and_pinion_pair linear_flexible_and_planar_curve_pair linear_flexible_link_representation linear_path linear_profile linearized_table_function link_motion_relationship link_motion_representation_along_path link_motion_transformation listed_data listed_product_space literal_conjunction literal_disjunction literal_number local_b_spline local_time locally_refined_spline_curve locally_refined_spline_surface locally_refined_spline_volume location location_assignment location_in_aggregate_representation_item location_relationship location_representation_assignment location_representation_role location_role location_shape_representation locator log10_function log2_function log_function logical_literal logical_representation_item loop loss_tangent_measure_with_unit lot_effectivity low_order_kinematic_pair low_order_kinematic_pair_value low_order_kinematic_pair_with_motion_coupling low_order_kinematic_pair_with_range luminous_flux_measure_with_unit luminous_flux_unit luminous_intensity_measure_with_unit luminous_intensity_unit machining_process_executable magnetic_flux_density_measure_with_unit magnetic_flux_density_unit magnetic_flux_measure_with_unit magnetic_flux_unit make_from_feature_relationship make_from_usage_option manifold_solid_brep manifold_subsurface_shape_representation manifold_surface_shape_representation mapped_item marking mass_measure_with_unit mass_unit mated_part_relationship material_designation material_designation_characterization material_property material_property_representation maths_enum_literal maths_function maths_space maths_tuple_literal maths_variable mating_material mating_material_items maximum_function measure_qualification measure_representation_item measure_with_unit mechanical_context mechanical_design_and_draughting_relationship mechanical_design_geometric_presentation_area mechanical_design_geometric_presentation_representation mechanical_design_presentation_representation_with_draughting mechanical_design_requirement_item_association mechanical_design_shaded_presentation_area mechanical_design_shaded_presentation_representation mechanism_representation mechanism_state_representation message_contents_assignment message_contents_group message_relationship minimum_function minus_expression minus_function mod_expression model_geometric_view modified_geometric_tolerance modified_pattern modified_solid modified_solid_with_placed_configuration modify_element moments_of_inertia_representation mult_expression multi_language_attribute_assignment multi_level_reference_designator multiple_arity_boolean_expression multiple_arity_function_call multiple_arity_generic_expression multiple_arity_numeric_expression multiply_defined_cartesian_points multiply_defined_curves multiply_defined_directions multiply_defined_edges multiply_defined_faces multiply_defined_geometry multiply_defined_placements multiply_defined_solids multiply_defined_surfaces multiply_defined_vertices name_assignment name_attribute named_unit narrow_surface_patch near_point_relationship nearly_degenerate_geometry nearly_degenerate_surface_boundary nearly_degenerate_surface_patch neutral_sketch_representation next_assembly_usage_occurrence ngon_closed_profile non_agreed_accuracy_parameter_usage non_agreed_scale_usage non_agreed_unit_usage non_manifold_at_edge non_manifold_at_vertex non_manifold_surface_shape_representation non_referenced_coordinate_system non_smooth_geometry_transition_across_edge non_uniform_zone_definition not_expression null_representation_item numeric_defined_function numeric_expression numeric_variable object_role odd_function offset_curve_2d offset_curve_3d offset_surface one_direction_repeat_factor open_closed_shell open_edge_loop open_path open_path_profile open_shell or_expression ordinal_date ordinate_dimension organization organization_assignment organization_relationship organization_role organization_type organization_type_assignment organization_type_role organizational_address organizational_project organizational_project_assignment organizational_project_relationship organizational_project_role oriented_closed_shell oriented_edge oriented_face oriented_joint oriented_open_shell oriented_path oriented_surface oriented_tolerance_zone outer_boundary_curve outer_round outside_profile over_riding_styled_item over_used_vertex overcomplex_geometry overcomplex_topology_and_geometry_relationship overlapping_geometry package_product_concept_feature pair_representation_relationship pair_value parabola parallel_assembly_constraint parallel_assembly_constraint_with_dimension parallel_composed_function parallel_geometric_constraint parallel_offset parallel_offset_geometric_constraint parallelism_tolerance parametric_representation_context part_laminate_table partial_circular_profile partial_derivative_expression partial_derivative_function partial_document_with_structured_text_representation_assignment partly_overlapping_curves partly_overlapping_edges partly_overlapping_faces partly_overlapping_solids partly_overlapping_surfaces path path_area_with_parameters path_feature_component path_node path_parameter_representation path_parameter_representation_context path_shape_representation pattern_offset_membership pattern_omit_membership pcurve pdgc_with_dimension percentage_laminate_table perpendicular_assembly_constraint perpendicular_geometric_constraint perpendicular_to perpendicularity_tolerance person person_and_organization person_and_organization_address person_and_organization_assignment person_and_organization_role personal_address pgc_with_dimension physical_breakdown_context physical_component physical_component_feature physical_component_interface_terminal physical_component_terminal physical_element_usage picture_representation picture_representation_item placed_datum_target_feature placed_feature placement planar_box planar_curve_pair planar_curve_pair_range planar_extent planar_pair planar_pair_value planar_pair_with_range planar_shape_representation plane plane_angle_and_length_pair plane_angle_and_ratio_pair plane_angle_measure_with_unit plane_angle_tolerance_value plane_angle_unit plus_expression plus_minus_tolerance ply_angle_representation ply_laminate_sequence_definition ply_laminate_table ply_orientation_angle pmi_requirement_item_association pocket pocket_bottom pogc_with_dimension point point_and_vector point_array point_cloud_dataset point_cloud_dataset_with_colours point_cloud_dataset_with_intensities point_cloud_dataset_with_normals point_cloud_superdataset point_distance_geometric_constraint point_in_volume point_on_curve point_on_edge_curve point_on_face_surface point_on_planar_curve_pair point_on_planar_curve_pair_value point_on_planar_curve_pair_with_range point_on_surface point_on_surface_pair point_on_surface_pair_value point_on_surface_pair_with_range point_placement_shape_representation point_replica point_style point_to_point_path polar_11 polar_complex_number_region polar_point poly_loop polygonal_area polyline position_tolerance positioned_sketch positive_length_measure_with_unit positive_plane_angle_measure_with_unit power_expression power_measure_with_unit power_unit pre_defined_character_glyph pre_defined_colour pre_defined_curve_font pre_defined_dimension_symbol pre_defined_geometrical_tolerance_symbol pre_defined_item pre_defined_marker pre_defined_point_marker_symbol pre_defined_surface_condition_symbol pre_defined_surface_side_style pre_defined_symbol pre_defined_terminator_symbol pre_defined_text_font pre_defined_tile precision_qualifier predefined_picture_representation_item prescribed_path presentation_area presentation_layer_assignment presentation_representation presentation_set presentation_size presentation_style_assignment presentation_style_by_context presentation_view presented_item presented_item_representation pressure_measure_with_unit pressure_unit previous_change_element_assignment primitive_2d primitive_2d_with_inner_boundary prismatic_pair prismatic_pair_value prismatic_pair_with_range procedural_representation procedural_representation_sequence procedural_shape_representation procedural_shape_representation_sequence procedural_solid_representation_sequence process_operation process_plan process_product_association process_property_association product product_as_planned product_category product_category_relationship product_class product_concept product_concept_context product_concept_feature product_concept_feature_association product_concept_feature_category product_concept_feature_category_usage product_concept_relationship product_context product_data_and_data_quality_relationship product_definition product_definition_context product_definition_context_association product_definition_context_role product_definition_effectivity product_definition_element_relationship product_definition_formation product_definition_formation_relationship product_definition_formation_with_specified_source product_definition_group_assignment product_definition_kinematics product_definition_occurrence product_definition_occurrence_reference product_definition_occurrence_reference_with_local_representation product_definition_occurrence_relationship product_definition_process product_definition_reference product_definition_reference_with_local_representation product_definition_relationship product_definition_relationship_kinematics product_definition_relationship_relationship product_definition_resource product_definition_shape product_definition_specified_occurrence product_definition_substitute product_definition_usage product_definition_usage_relationship product_definition_with_associated_documents product_design_to_individual product_design_version_to_individual product_group product_group_attribute_assignment product_group_attribute_set product_group_attributes product_group_context product_group_membership product_group_membership_rules product_group_purpose product_group_relationship product_group_rule product_group_rule_assignment product_group_rules product_identification product_in_attachment_slot product_material_composition_relationship product_planned_to_realized product_process_plan product_related_product_category product_relationship product_specification profile_floor projected_zone_definition projected_zone_definition_with_offset projection_curve projection_directed_callout promissory_usage_occurrence property_definition property_definition_relationship property_definition_representation property_process protrusion pyramid_volume qualified_representation_item qualitative_uncertainty quantified_assembly_component_usage quantifier_expression quasi_uniform_curve quasi_uniform_surface quasi_uniform_volume rack_and_pinion_pair rack_and_pinion_pair_value rack_and_pinion_pair_with_range radioactivity_measure_with_unit radioactivity_unit radius_dimension radius_geometric_constraint range_characteristic ratio_measure_with_unit ratio_unit rational_b_spline_curve rational_b_spline_surface rational_b_spline_volume rational_locally_refined_spline_curve rational_locally_refined_spline_surface rational_locally_refined_spline_volume rational_representation_item rationalize_function real_defined_function real_interval_from_min real_interval_to_max real_literal real_numeric_variable real_representation_item real_tuple_literal rectangular_area rectangular_array_placement_group_component rectangular_closed_profile rectangular_composite_surface rectangular_composite_surface_transition_locator rectangular_pattern rectangular_pyramid rectangular_trimmed_surface referenced_modified_datum reindexed_array_function reinforcement_orientation_basis relative_event_occurrence removal_volume rep_item_group repackaging_function reparametrised_composite_curve_segment replicate_feature repositioned_neutral_sketch repositioned_tessellated_item representation representation_context representation_context_reference representation_item representation_item_relationship representation_map representation_proxy_item representation_reference representation_relationship representation_relationship_with_transformation representative_shape_representation requirement_assigned_object requirement_assignment requirement_for_action_resource requirement_source requirement_view_definition_relationship resistance_measure_with_unit resistance_unit resource_property resource_property_representation resource_requirement_type restriction_function resulting_path retention revolute_pair revolute_pair_value revolute_pair_with_range revolved_area_solid revolved_face_solid revolved_face_solid_with_trim_conditions revolved_profile rgc_with_dimension rib_top rib_top_floor right_angular_wedge right_circular_cone right_circular_cylinder right_to_usage_association rigid_link_representation rigid_subsketch role_association rolling_curve_pair rolling_curve_pair_value rolling_surface_pair rolling_surface_pair_value rotation_about_direction round_hole rounded_end rounded_u_profile roundness_tolerance row_representation_item row_value row_variable rule_action rule_condition rule_definition rule_set rule_set_group rule_software_definition rule_superseded_assignment rule_supersedence ruled_surface_swept_area_solid runout_zone_definition runout_zone_orientation runout_zone_orientation_reference_direction satisfied_requirement satisfies_requirement satisfying_item scalar_variable scan_3d_model scan_data_shape_representation scanned_data_item scanner_basic_properties scanner_property screw_pair screw_pair_value screw_pair_with_range sculptured_solid sdgc_with_dimension seam_curve seam_edge security_classification security_classification_assignment security_classification_level selector_function self_intersecting_curve self_intersecting_geometry self_intersecting_loop self_intersecting_shell self_intersecting_surface serial_numbered_effectivity series_composed_function shape_aspect shape_aspect_associativity shape_aspect_deriving_relationship shape_aspect_occurrence shape_aspect_relationship shape_aspect_relationship_representation_association shape_criteria_representation_with_accuracy shape_data_quality_assessment_by_logical_test shape_data_quality_assessment_by_numerical_test shape_data_quality_criteria_representation shape_data_quality_criterion shape_data_quality_criterion_and_accuracy_association shape_data_quality_inspected_shape_and_result_relationship shape_data_quality_inspection_criterion_report shape_data_quality_inspection_instance_report shape_data_quality_inspection_instance_report_item shape_data_quality_inspection_result shape_data_quality_inspection_result_representation shape_data_quality_lower_value_limit shape_data_quality_upper_value_limit shape_data_quality_value_limit shape_data_quality_value_range shape_defining_relationship shape_definition_representation shape_dimension_representation shape_feature_definition shape_feature_definition_element_relationship shape_feature_definition_relationship shape_inspection_result_accuracy_association shape_inspection_result_representation_with_accuracy shape_measurement_accuracy shape_representation shape_representation_reference shape_representation_relationship shape_representation_with_parameters shape_summary_request_with_representative_value shell_based_surface_model shell_based_wireframe_model shell_based_wireframe_shape_representation shelled_solid short_length_curve short_length_curve_segment short_length_edge si_absorbed_dose_unit si_capacitance_unit si_conductance_unit si_dose_equivalent_unit si_electric_charge_unit si_electric_potential_unit si_energy_unit si_force_unit si_frequency_unit si_illuminance_unit si_inductance_unit si_magnetic_flux_density_unit si_magnetic_flux_unit si_power_unit si_pressure_unit si_radioactivity_unit si_resistance_unit si_unit simple_boolean_expression simple_clause simple_generic_expression simple_numeric_expression simple_string_expression simplified_counterbore_hole_definition simplified_counterdrill_hole_definition simplified_countersink_hole_definition simplified_spotface_hole_definition simultaneous_constraint_group sin_function single_area_csg_2d_shape_representation single_boundary_csg_2d_shape_representation single_property_is_definition skew_line_distance_geometric_constraint slash_expression sliding_curve_pair sliding_curve_pair_value sliding_surface_pair sliding_surface_pair_value slot slot_end small_area_face small_area_surface small_area_surface_patch small_volume_solid smeared_material_definition software_for_data_quality_check solid_angle_measure_with_unit solid_angle_unit solid_curve_font solid_model solid_replica solid_with_angle_based_chamfer solid_with_chamfered_edges solid_with_circular_pattern solid_with_circular_pocket solid_with_circular_protrusion solid_with_conical_bottom_round_hole solid_with_constant_radius_edge_blend solid_with_curved_slot solid_with_depression solid_with_double_offset_chamfer solid_with_excessive_number_of_voids solid_with_flat_bottom_round_hole solid_with_general_pocket solid_with_general_protrusion solid_with_groove solid_with_hole solid_with_incomplete_circular_pattern solid_with_incomplete_rectangular_pattern solid_with_pocket solid_with_protrusion solid_with_rectangular_pattern solid_with_rectangular_pocket solid_with_rectangular_protrusion solid_with_shape_element_pattern solid_with_single_offset_chamfer solid_with_slot solid_with_spherical_bottom_round_hole solid_with_stepped_round_hole solid_with_stepped_round_hole_and_conical_transitions solid_with_straight_slot solid_with_tee_section_slot solid_with_through_depression solid_with_trapezoidal_section_slot solid_with_variable_radius_edge_blend solid_with_wrong_number_of_voids source_for_requirement sourced_requirement specification_definition specified_higher_usage_occurrence sphere spherical_cap spherical_pair spherical_pair_value spherical_pair_with_pin spherical_pair_with_pin_and_range spherical_pair_with_range spherical_point spherical_surface spherical_volume spotface_definition spotface_hole_definition spotface_occurrence spotface_occurrence_in_assembly sql_mappable_defined_function square_root_function square_u_profile standard_uncertainty start_request start_work state_observed state_observed_assignment state_observed_relationship state_observed_role state_predicted state_type state_type_assignment state_type_relationship state_type_role statechar_applied_object statechar_object statechar_relationship_object statechar_type_applied_object statechar_type_object statechar_type_relationship_object steep_angle_between_adjacent_edges steep_angle_between_adjacent_faces steep_geometry_transition_across_edge step straightness_tolerance string_defined_function string_expression string_literal string_variable structured_dimension_callout structured_message structured_text_composition structured_text_representation styled_item su_parameters subedge subface subsketch substring_expression summary_report_request supplied_part_relationship surface surface_condition_callout surface_curve surface_curve_swept_area_solid surface_curve_swept_surface surface_distance_assembly_constraint_with_dimension surface_distance_geometric_constraint surface_of_linear_extrusion surface_of_revolution surface_pair surface_pair_with_range surface_patch surface_patch_set surface_profile_tolerance surface_rendering_properties surface_replica surface_side_style surface_smoothness_geometric_constraint surface_style_boundary surface_style_control_grid surface_style_fill_area surface_style_parameter_line surface_style_reflectance_ambient surface_style_reflectance_ambient_diffuse surface_style_reflectance_ambient_diffuse_specular surface_style_rendering surface_style_rendering_with_properties surface_style_segmentation_curve surface_style_silhouette surface_style_transparent surface_style_usage surface_texture_representation surface_with_excessive_patches_in_one_direction surface_with_small_curvature_radius surfaced_open_shell swept_area_solid swept_curve_surface_geometric_constraint swept_disk_solid swept_face_solid swept_point_curve_geometric_constraint swept_surface symbol symbol_colour symbol_representation symbol_representation_map symbol_style symbol_target symmetric_shape_aspect symmetry_geometric_constraint symmetry_tolerance system_breakdown_context system_element_usage table_representation_item tactile_appearance_representation tagged_text_format tagged_text_item tan_function tangent tangent_assembly_constraint tangent_geometric_constraint taper tee_profile terminal_feature terminal_location_group terminator_symbol tessellated_annotation_occurrence tessellated_connecting_edge tessellated_curve_set tessellated_edge tessellated_face tessellated_geometric_set tessellated_item tessellated_point_set tessellated_shape_representation tessellated_shape_representation_with_accuracy_parameters tessellated_shell tessellated_solid tessellated_structured_item tessellated_surface_set tessellated_vertex tessellated_wire tetrahedron tetrahedron_volume text_font text_font_family text_font_in_family text_literal text_literal_with_associated_curves text_literal_with_blanking_box text_literal_with_delineation text_literal_with_extent text_string_representation text_style text_style_for_defined_font text_style_with_box_characteristics text_style_with_mirror text_style_with_spacing thermal_component thermal_resistance_measure_with_unit thermal_resistance_unit thermodynamic_temperature_measure_with_unit thermodynamic_temperature_unit thickened_face_solid thickness_laminate_table thread thread_runout time_interval time_interval_assignment time_interval_based_effectivity time_interval_relationship time_interval_role time_interval_with_bounds time_measure_with_unit time_unit tolerance_value tolerance_zone tolerance_zone_definition tolerance_zone_form tolerance_zone_with_datum topological_representation_item topology_related_to_multiply_defined_geometry topology_related_to_nearly_degenerate_geometry topology_related_to_overlapping_geometry topology_related_to_self_intersecting_geometry toroidal_surface toroidal_volume torus total_runout_tolerance track_blended_solid track_blended_solid_with_end_conditions transition_feature transport_feature triangulated_face triangulated_point_cloud_dataset triangulated_surface_set trimmed_curve turned_knurl twisted_cross_sectional_group_shape_element two_direction_repeat_factor type_qualifier unary_boolean_expression unary_function_call unary_generic_expression unary_numeric_expression unbound_parameter_environment unbound_variational_parameter unbound_variational_parameter_semantics uncertainty_assigned_representation uncertainty_measure_with_unit uncertainty_qualifier unconstrained_pair unconstrained_pair_value unequally_disposed_geometric_tolerance uniform_curve uniform_product_space uniform_resource_identifier uniform_surface uniform_volume universal_pair universal_pair_value universal_pair_with_range unused_patches unused_shape_element usage_association user_defined_11 user_defined_curve_font user_defined_marker user_defined_terminator_symbol user_selected_elements user_selected_shape_elements validation value_format_type_qualifier value_function value_range value_representation_item variable variable_expression variable_semantics variational_current_representation_relationship variational_parameter variational_representation variational_representation_item vector vector_style vee_profile velocity_measure_with_unit velocity_unit verification verification_relationship versioned_action_request versioned_action_request_relationship vertex vertex_loop vertex_on_edge vertex_point vertex_shell view_volume visual_appearance_representation volume volume_measure_with_unit volume_unit volume_with_faces volume_with_parametric_boundary volume_with_shell wedge_volume week_of_year_and_day_date wire_shell wrong_element_name wrongly_oriented_void wrongly_placed_loop wrongly_placed_void xor_expression year_month zero_surface_normal zone_breakdown_context zone_element_usage zone_structural_makeup]]
}
