# start x3dom file for non-FEM graphics
proc x3dFileStart {} {
  global cadSystem entCount gen localName opt stepAP timeStamp viz writeDir writeDirType x3dom x3dFile x3dFileName x3dFiles
  global x3dFileSave x3dFileNameSave x3dHeight x3dMax x3dMin x3dPartClick x3dStartFile x3dTitle x3dViewOK x3dWidth

  if {!$gen(View)} {return}
  set x3dViewOK 1
  if {$x3dStartFile == 0} {return}

  if {![info exists stepAP]} {set stepAP [getStepAP $localName]}
  if {[string first "IFC" $stepAP] == 0 || [string first "ISO" $stepAP] == 0 || $stepAP == "AP210" || \
      $stepAP == "CUTTING_TOOL_SCHEMA_ARM" || $stepAP == "STRUCTURAL_FRAME_SCHEMA" || $stepAP == ""} {
    set msg "The Viewer only works with STEP AP242, AP203, AP214, AP238, and AP209 files.  See Help > Support STEP APs"
    if {$stepAP == "STRUCTURAL_FRAME_SCHEMA"} {append msg "\n Use the NIST SteelVis viewer for CIS/2 files."}
    errorMsg $msg
    set x3dViewOK 0
    return
  } elseif {$opt(partOnly)} {
    set str "Opening [string range $stepAP 0 4] file"
    if {[info exists cadSystem]} {append str " ($cadSystem)"}
    outputMsg $str
  }

  set x3dStartFile 0
  checkTempDir

# x3d output file name
  set x3dir [file rootname $localName]
  if {$opt(writeDirType) == 2} {set x3dir [file join $writeDir [file rootname [file tail $localName]]]}
  set x3dFileName $x3dir\-sfa.html
  set x3dFile [open $x3dFileName w]
  catch {file delete -force -- $x3dFileName}

# start x3d file
  set title [encoding convertto utf-8 [file tail $localName]]
  if {$stepAP != "" && [string range $stepAP 0 1] == "AP"} {append title " | $stepAP"}
  puts $x3dFile "<!DOCTYPE html>\n<html>\n<head>\n<title>$title</title>\n<base target=\"_blank\">\n<meta http-equiv='Content-Type' content='text/html;charset=utf-8'/>"

# see sfa-data.tcl for the x3dom server location and version
  puts $x3dFile "<link rel='stylesheet' type='text/css' href='$x3dom(css)'/>\n<script type='text/javascript' src='$x3dom(js)'></script>"

# styles
  puts $x3dFile "<style>X3D \{border:1px solid black\}</style>"
  puts $x3dFile "<style>details > summary {padding: 4px\; width: 95%\; background-color: \#eeeeee\; border: none\; box-shadow: 1px 1px 2px \#bbbbbb\; cursor: pointer\;}</style>"

# scripts and functions for selecting parts
  set callback {}
  set x3dPartClick 0
  if {[info exists viz(PART)]} {if {$viz(PART)} {set x3dPartClick 1; lappend callback "shape"}}
  if {!$x3dPartClick && $opt(viewPart)} {set x3dPartClick 1; lappend callback "shape"}
  if {$viz(TESSPART)} {set x3dPartClick 1; lappend callback "group"}

  if {$x3dPartClick} {
    puts $x3dFile "\n<script type='text/javascript' src='https://code.jquery.com/jquery-2.1.0.min.js'></script>"
    puts $x3dFile "<script>\n// Mark selection point"
    puts $x3dFile "function handleGroupClick(event) {\$('#marker').attr('translation', event.hitPnt);}"

    puts $x3dFile "// Handle click on '[join $callback]'"
    foreach type $callback {puts $x3dFile "function handleSingleClick($type) {\$('#clickedObject').html(\$($type).attr('id'));}"}

    puts $x3dFile "// Add onclick callback to every '[join $callback]'"
    puts $x3dFile "\$(document).ready(function() \{"
    foreach type $callback {
      puts $x3dFile "  \$('$type').each(function() \{"
      puts $x3dFile "    \$(this).attr('onclick','handleSingleClick(this)');"
      puts $x3dFile "  \});"
    }
    puts $x3dFile "\});"
    puts $x3dFile "</script>"
  }
  puts $x3dFile "</head>"

# x3d title
  set x3dTitle [encoding convertto utf-8 [file tail $localName]]
  if {$stepAP != "" && [string range $stepAP 0 1] == "AP"} {append x3dTitle "&nbsp;&nbsp;&nbsp;$stepAP"}
  if {[info exists timeStamp]} {
    if {$timeStamp != ""} {
      set ts [fixTimeStamp $timeStamp]
      append x3dTitle "&nbsp;&nbsp;&nbsp;$ts"
    }
  }
  if {[info exists cadSystem]} {
    if {$cadSystem != ""} {
      regsub -all "_" $cadSystem " " cs
      regsub -all [format "%c" 10] $cs " " cs
      append x3dTitle "&nbsp;&nbsp;&nbsp;$cs"
    }
  }
  puts $x3dFile "\n<body><font face=\"sans-serif\">\n<h3>$x3dTitle</h3>"
  puts $x3dFile "\n<table>"

# x3d window size
  puts $x3dFile "<tr><td valign='top' width='85%'>\n<noscript>JavaScript must be enabled in the web browser</noscript>"
  set x3dHeight 900
  set x3dWidth [expr {int($x3dHeight*1.78)}]
  catch {
    set x3dHeight [expr {int([winfo screenheight .]*0.758)}]
    set x3Width [expr {int($x3dHeight*[winfo screenwidth .]/[winfo screenheight .])}]
  }

# start x3d with flat-to-screen hud for viewpoint text
  puts $x3dFile "\n<X3D id='x3d' showStat='false' showLog='false' x='0px' y='0px' width='$x3dWidth' height='$x3dHeight'>"
  set txt "<div id='HUDs_Div'><div class='group' style='margin:2px; margin-top:0px; padding:4px; background-color:rgba(0,0,0,1.); position:absolute; float:center; z-index:1000;'>Viewpoint: <span id='clickedView'></span>"
  if {$x3dPartClick} {append txt "<br>Part: <span id='clickedObject'></span>"}
  append txt "</div></div>"
  puts $x3dFile $txt
  puts $x3dFile "<Scene DEF='scene'>"
  puts $x3dFile "<!-- X3D generated by the NIST STEP File Analyzer and Viewer [getVersion] -->"

# read tessellated geometry separately because of IFCsvr limitations
  if {($viz(PMI) && [info exists entCount(tessellated_annotation_occurrence)]) || $viz(TESSPART)} {tessReadGeometry}
  outputMsg " Writing Viewer file to: [truncFileName [file nativename $x3dFileName]]" blue

# coordinate min, max, center
  if {$x3dMax(x) != -1.e8} {
    foreach xyz {x y z} {
      set delt($xyz) [expr {$x3dMax($xyz)-$x3dMin($xyz)}]
      set xyzcen($xyz) [format "%.4f" [expr {0.5*$delt($xyz) + $x3dMin($xyz)}]]
    }
    set maxxyz [expr {max($delt(x),$delt(y),$delt(z))}]
  }

# keep X3D file, write saved views and brep geom
  catch {unset x3dFiles}
  lappend x3dFiles $x3dFile
  if {$opt(x3dSave)} {
    set x3dFileNameSave "[file rootname $localName].x3d"
    catch {file delete -force -- $x3dFileNameSave}
    set x3dFileSave [open $x3dFileNameSave w]
    lappend x3dFiles $x3dFileSave
    puts $x3dFileSave "<?xml version='1.0' encoding='UTF-8'?>\n<X3D>\n<head><meta name='Generator' content='NIST STEP File and Viewer [getVersion]'/></head>\n<Scene>"
  }
  update idletasks
}

# -------------------------------------------------------------------------------
# finish x3d file, write lots of geometry, set viewpoints, add navigation and background color, and close x3dom file
proc x3dFileEnd {} {
  global ao assemblyTransform axesDef brepFile brepFileName brepGeomEntTypes clippingCap clippingDef clipPlaneName cmNameID datumTargetView
  global delt edgeMatID entCount grayBackground leaderCoords matTrans maxxyz meshlines nclipPlane nistName noGroupTransform npart nsketch
  global numTessColor opt parts partstg placeCoords placeSize planeDef rosetteGeom samplingPoints sphereDef spmiTypesPerFile stepAP
  global tessCoord tessEdges tessEnts tessPartFile tessPartFileName tessRepo tessSolid tsName viewsWithPMI viz xyzcen
  global savedPlaceFile savedPlaceFileName savedViewButtons savedViewDMName savedViewFile
  global savedViewFileName savedViewItems savedViewNames savedViewpoint savedViewVP
  global x3dApps x3dAxes x3dBbox x3dCoord x3dFile x3dFileNameSave x3dFiles x3dFileSave x3dIndex x3dMax x3dMin
  global x3dMsg x3dPartClick x3dParts x3dShape x3dStartFile x3dTessParts x3dTitle x3dViewOK
  global objDesign

  if {!$x3dViewOK} {
    foreach var [list x3dCoord x3dFile x3dIndex x3dMax x3dMin x3dShape x3dStartFile] {catch {unset -- $var}}
    return
  }

# PMI is already written to file, generate b-rep part geometry
  set viz(PART) 0
  if {$opt(viewPart)} {
    if {!$opt(partOnly)} {
      set ok 0
      foreach item $brepGeomEntTypes {if {[info exists entCount($item)]} {set ok 1}}
      if {$tessSolid} {set ok 1}
    } else {
      set ok 1
    }
    if {$ok} {x3dBrepGeom}
  }

# coordinate min, max, center
  foreach idx {x y z} {
    if {$x3dMax($idx) == -1.e8 || $x3dMax($idx) > 1.e8} {set x3dMax($idx) 500.}
    if {$x3dMin($idx) == 1.e8 || $x3dMin($idx) < -1.e8} {set x3dMin($idx) -500.}
    set delt($idx) [expr {$x3dMax($idx)-$x3dMin($idx)}]
    set xyzcen($idx) [trimNum [format "%.4f" [expr {0.5*$delt($idx) + $x3dMin($idx)}]]]
  }
  set maxxyz [expr {max($delt(x),$delt(y),$delt(z))}]

# -------------------------------------------------------------------------------
# write tessellated edges
  set viz(TESSEDGE) 0
  if {[info exists tessEdges]} {
    puts $x3dFile "\n<!-- TESSELLATED EDGES -->\n<Switch whichChoice='0' id='swTED'><Group>"
    foreach cid [array names tessEdges] {
      puts $x3dFile "<Shape><Appearance><Material emissiveColor='0 0 0'/></Appearance>"
      puts $x3dFile " <IndexedLineSet coordIndex='[join $tessEdges($cid)]'>"
      puts $x3dFile "  <Coordinate DEF='coord$cid' point='$tessCoord($cid)'/></IndexedLineSet></Shape>"
    }
    puts $x3dFile "</Group></Switch>"
    set viz(TESSEDGE) 1
    unset tessEdges
  }

# -------------------------------------------------------------------------------
# holes
  set ok 0
  set viz(HOLE) 0
  set sphereDef {}
  foreach ent [list basic_round_hole_occurrence counterbore_hole_occurrence counterdrill_hole_occurrence countersink_hole_occurrence spotface_occurrence] {
    if {[info exists entCount($ent)]} {set ok 1}
    set ent1 "$ent\_in_assembly"
    if {[info exists entCount($ent1)]} {set ok 1}
  }
  if {$ok} {x3dHoles}

# -------------------------------------------------------------------------------
# supplemental geometry
  set axesDef {}
  set planeDef {}
  set viz(SUPPGEOM) 0
  if {[info exists entCount(constructive_geometry_representation)]} {
    if {$opt(partSupp) && ($opt(viewPart) || $opt(viewTessPart))} {x3dSuppGeom}
  }

# -------------------------------------------------------------------------------
# camera clipping planes for section views (9.4.3)
  set viz(CLIPPING) 0
  if {[info exists entCount(camera_model_d3_multi_clipping)]} {
    if {$entCount(camera_model_d3_multi_clipping) < 17} {
      outputMsg " Processing clipping planes (section views)" green
      set clippingDef {}
      set nclipPlane 0
      puts $x3dFile "\n<!-- CLIPPING PLANES -->"
      ::tcom::foreach cm [$objDesign FindObjects [string trim camera_model_d3_multi_clipping]] {
        if {[catch {
          set cplanes {}
          set cpname $cmNameID([$cm P21ID])
          set e0 [[[$cm Attributes] Item [expr 4]] Value]
          if {$opt(PMISEM)} {lappend spmiTypesPerFile "section views"}

# follow union and intersection for more planes
          if {[llength $e0] == 1} {
            if {[$e0 Type] == "camera_model_d3_multi_clipping_union"} {
              errorMsg " The intersection and union of clipping planes is not supported" red
              foreach e1 [[[$e0 Attributes] Item [expr 2]] Value] {
                if {[$e1 Type] == "plane"} {
                  lappend cplanes $e1
                } else {
                  foreach e2 [[[$e1 Attributes] Item [expr 2]] Value] {lappend cplanes $e2}
                }
              }

# single plane (most common)
            } else {
              lappend cplanes $e0
            }

# multiple planes (less common)
          } else {
            errorMsg " Multiple clipping planes per section view" red
            foreach e1 $e0 {lappend cplanes $e1}
          }

# write clipping planes
          if {![info exists clippingCap]} {set clippingCap 0}
          if {!$clippingCap && $opt(viewPart)} {errorMsg " Capped surfaces are not generated for clipping planes" red}
          if {[llength $cplanes] > 0} {foreach cplane $cplanes {x3dClipPlane $cplane $cpname}}
        } emsg]} {
          errorMsg "Error adding Clipping Plane: $emsg"
        }
      }
    } else {
      outputMsg " Too many 'camera_model_d3_multi_clipping' to process ($entCount(camera_model_d3_multi_clipping))" red
    }
  }

# -------------------------------------------------------------------------------
# datum targets
  set viz(DTMTAR) 0
  if {[info exists datumTargetView]} {
    x3dDatumTarget
  } elseif {[info exists entCount(placed_datum_target_feature)] || [info exists entCount(datum_target)]} {
    set msg " Datum targets cannot be shown without "
    if {$opt(xlFormat) != "Excel"} {
      append msg "generating a spreadsheet"
    } elseif {!$opt(PMISEM) || $opt(PMISEMDIM)} {
      append msg "selecting Semantic PMI in the Analyzer section"
    } else {
      set msg " Datum targets are not shown due to Syntax Errors above"
    }
    append msg ".  See Help > Viewer > Graphical PMI"
    outputMsg $msg red
  }
  catch {unset datumTargetView}

# -------------------------------------------------------------------------------
# points
  set viz(POINTS) 0
  set pointsLabel ""

# validation property sampling points
  if {[info exists samplingPoints]} {
    set viz(POINTS) 1
    set pointsLabel "Cloud of Points"
    puts $x3dFile "\n<!-- [string toupper $pointsLabel] -->"
    puts $x3dFile "<Switch whichChoice='0' id='swPoints'>"
    puts $x3dFile "<Shape><Appearance><Material emissiveColor='0 0 1'/></Appearance><PointSet><Coordinate point='$samplingPoints'/></PointSet></Shape>\n</Switch>"
    unset samplingPoints

# point cloud
  } elseif {[info exists entCount(point_cloud_dataset)]} {
    if {$entCount(point_cloud_dataset) > 0} {
      tessReadGeometry 2
      set viz(POINTS) 1
      set pointsLabel "Point Cloud"
      puts $x3dFile "\n<!-- [string toupper $pointsLabel] -->"
      puts $x3dFile "<Switch whichChoice='0' id='swPoints'><Group>"
      foreach idx [array names tessCoord] {
        puts $x3dFile "<Shape><Appearance><Material emissiveColor='0 0 1'/></Appearance><PointSet><Coordinate point='$tessCoord($idx)'/></PointSet></Shape>"
      }
      puts $x3dFile "</Group></Switch>"
    }
  }

# -------------------------------------------------------------------------------
# composites rosettes, plies
  set viz(COMPOSITES) 0
  x3dComposites
  if {$rosetteGeom > 0} {set viz(COMPOSITES) 1}

# -------------------------------------------------------------------------------
# write any PMI saved view geometry for multiple saved views
  set torg ""
  set savedViewButtons {}
  if {[info exists savedViewNames]} {
    if {[llength $savedViewNames] > 0} {

# placeholder size
      if {[info exists placeSize]} {
        set phsize1 [trimNum [expr {$maxxyz/1000.}]]
        set phsize2 [trimNum [expr {$phsize1*6.}]]
        set phsize3 [trimNum [expr {$phsize2*0.67}]]
      }

      for {set i 0} {$i < [llength $savedViewNames]} {incr i} {
        set svn [lindex $savedViewNames $i]
        set svnfn "View$i"
        catch {close $savedViewFile($svnfn)}

        if {[info exists savedViewFileName($svnfn)]} {
          if {[file size $savedViewFileName($svnfn)] > 0} {
            set svMap($svn) $svn
            set svWrite 1

# check if same saved view graphics already written
            if {[info exists savedViewItems($svn)]} {
              for {set j 0} {$j < $i} {incr j} {
                set svn1 [lindex $savedViewNames $j]
                if {[info exists savedViewItems($svn1)]} {
                  if {$savedViewItems($svn) == $savedViewItems($svn1)} {
                    set svMap($svn) $svn1
                    set svWrite 0
                    break
                  }
                }
              }
            }

            set svn2 $svn
            if {$svn2 == ""} {
              set svn2 "Missing name"
              set svMap($svn2) $svn2
            }
            lappend savedViewButtons $svn2
            foreach xf $x3dFiles {puts $xf "\n<!-- SAVED VIEW$i PMI - $svn2 -->\n<Switch whichChoice='0' id='sw$svnfn'><Group>"}

# show camera viewpoint
            if {[info exists savedViewpoint($svn2)]} {x3dSavedViewpoint $svn2}

# get saved view graphics from file
            if {$svWrite} {
              set lastTransform ""
              set f [open $savedViewFileName($svnfn) r]
              while {[gets $f line] >= 0} {

# check for similar transforms
                if {![info exists noGroupTransform]} {
                  if {[string first "<Transform" $line] == -1 && [string first "</Transform>" $line] == -1} {
                    foreach xf $x3dFiles {puts $xf $line}
                  } elseif {[string first "<Transform" $line] == 0} {
                    if {$line != $lastTransform} {
                      if {$lastTransform != ""} {foreach xf $x3dFiles {puts $xf "</Transform>"}}
                      foreach xf $x3dFiles {puts $xf $line}
                      set lastTransform $line
                    }
                    set torg "Transform"
                  }
                  if {[string first "<Group" $line]   == 0} {set torg "Group"}
                } else {
                  foreach xf $x3dFiles {puts $xf $line}
                }
              }
              if {$lastTransform != ""} {foreach xf $x3dFiles {puts $xf "</Transform>"}}

              close $f
              catch {unset savedViewFile($svnfn)}

# write placeholder
              set placefn "Place$i"
              if {[info exists savedPlaceFileName($placefn)]} {
                catch {close $savedPlaceFile($placefn)}
                set f [open $savedPlaceFileName($placefn) r]
                foreach xf $x3dFiles {puts $xf "\n<!-- SAVED VIEW$i Placeholder - $svn2 -->\n<Switch whichChoice='0' id='sw$placefn'><Group>"}
                while {[gets $f line] >= 0} {

# placeholder size
                  if {[info exists placeSize]} {
                    if {[string first "placeSize" $line] != -1} {
                      regsub -all "placeSize1" $line $phsize1 line
                      regsub -all "placeSize2" $line $phsize2 line
                      regsub -all "placeSize3" $line $phsize3 line
                    }
                  }
                  foreach xf $x3dFiles {puts $xf $line}
                }
                foreach xf $x3dFiles {puts $xf "</Group></Switch>"}
                close $f
                catch {unset savedPlaceFile($placefn)}
                catch {unset savedPlaceFileName($placefn)}
              }

# duplicate saved views
            } else {
              foreach xf $x3dFiles {puts $xf "<!-- SAME AS $svMap($svn) -->"}
              errorMsg " Two or more Saved Views have identical graphical PMI" red
              set torg ""
            }

# ending group and switch
            foreach xf $x3dFiles {
              if {$torg == "Group"} {puts $xf "</Group>"}
              puts $xf "</Group></Switch>"
            }
            set torg ""
          } else {
            catch {close $savedViewFile($svnfn)}
          }

# saved view with no PMI
        } elseif {$viz(PMI) && $opt(viewPMI) && $opt(viewNoPMI)} {
          set svMap($svn) $svn
          set viewsWithPMI($svn) $i
          lappend savedViewButtons $svn
          if {[info exists savedViewpoint($svn)]} {x3dSavedViewpoint $svn}
          foreach xf $x3dFiles {puts $xf "\n<!-- SAVED VIEW$i NO PMI - $svn -->\n<Switch whichChoice='0' id='sw$svnfn'><Group></Group></Switch>"}
          errorMsg " Some saved views do not have graphical PMI" red
        }
        catch {file delete -force -- $savedViewFileName($svnfn)}
      }
    }
  }
  catch {unset assemblyTransform}
  catch {unset noGroupTransform}
  catch {unset placeSize}

# viewpoints without PMI
  if {![info exists savedViewVP]} {
    if {([info exists entCount(camera_model_d3)] || [info exists entCount(camera_model_d3_multi_clipping)]) && \
         [info exists entCount(view_volume)] && [info exists entCount(planar_box)]} {
      for {set i 0} {$i < [llength $savedViewNames]} {incr i} {
        set svn [lindex $savedViewNames $i]
        if {[info exists savedViewpoint($svn)]} {x3dSavedViewpoint $svn}
      }
    }
  }

# -------------------------------------------------------------------------------
# if not associated with a saved view, placeholder axes, coordinates, text, box
  if {$opt(viewPMI) && ([info exists placeCoords] || [info exists leaderCoords])} {
    set nph 0
    catch {foreach idx [array names placeCoords]  {incr nph}}
    catch {foreach idx [array names leaderCoords] {incr nph}}
    if {$nph > 0} {x3dPlaceholder}
  }
  foreach var {leaderCoords minview placeAxes placeBox placeCoords placeSavedView} {catch {global $var}; catch {unset -- $var}}

# -------------------------------------------------------------------------------
# coordinate axes, if not already written
  if {$x3dAxes} {
    set asize [trimNum [expr {$maxxyz*0.05}]]
    x3dCoordAxes $asize
  }

# -------------------------------------------------------------------------------
# write tessellated part
  set oktpg 0
  if {[info exists tessPartFile]} {
    if {[file size $tessPartFileName] > 0} {
      set oktpg 1
    } else {
      set viz(TESSPART) 0
    }
  }
  if {$oktpg} {
    foreach xf $x3dFiles {puts $xf "\n<!-- TESSELLATED PART GEOMETRY -->\n<Switch whichChoice='0' id='swTPG'><Group>"}
    catch {close $tessPartFile}
    set f [open $tessPartFileName r]
    set npart(TESSPART) -1

# for parts with a transform, append to lines for each part name and transform to group by transform
    if {![info exists tessRepo]} {set tessRepo 0}
    if {$tessRepo} {
      set tgparts {}
      set lineidx {}
      set viz(TESSMESH) 0

      while {[gets $f line] >= 0} {
        if {[string first "<!--" $line] == 0} {
          set part $line
          lappend tgparts $line
        } elseif {[string first "<Transform" $line] == 0} {
          set transform $line
        } elseif {$line != "</Transform>"} {
          if {![info exists transform]} {set transform "<Transform>"}
          set idx "$part,$transform"
          lappend lines($idx) $line
          if {[lsearch $lineidx $idx] == -1} {lappend lineidx $idx}
        }
      }
      close $f

# write parts for each transform
      foreach part $tgparts {
        foreach xf $x3dFiles {puts $xf $part}

# set partname
        set partname [string range $part [string first " " $part]+1 [string last " " $part]-1]
        if {[string first "TESSELLATED" $partname] == 0} {set partname [string tolower [string range $partname 12 end]]}
        incr npart(TESSPART)
        set x3dTessParts($partname) $npart(TESSPART)

# switch if more than one part
        if {[llength $tgparts] > 1} {
          regsub -all "'" $partname "\"" txt
          foreach xf $x3dFiles {puts $xf "<Switch id='swTessPart$npart(TESSPART)' whichChoice='0'><Group id='$txt'>"}
        }

# write
        foreach item $lineidx {
          if {[string first $part $item] == 0} {
            set transform [string range $item [string last "," $item]+1 end]
            if {$transform != "<Transform>"} {foreach xf $x3dFiles {puts $xf $transform}}
            foreach line $lines($item) {foreach xf $x3dFiles {puts $xf $line}}
            if {$transform != "<Transform>"} {foreach xf $x3dFiles {puts $xf "</Transform>"}}
          }
        }
        if {[llength $tgparts] > 1} {foreach xf $x3dFiles {puts $xf "</Group></Switch>"}}
      }

# no grouping if no transforms, add switch
    } else {
      set n 0
      set meshlines {}
      set viz(TESSMESH) 0

      while {[gets $f line] >= 0} {
        if {[string first "<!--" $line] == 0} {

# write any accumulated wireframe mesh
          if {[llength $meshlines] > 0} {
            x3dWireframeMesh
            set meshlines {}
          }

# start tessellated part
          set partname [string range $line [string first " " $line]+1 [string last " " $line]-1]
          if {[string first "TESSELLATED" $partname] == 0} {set partname [string tolower [string range $partname 12 end]]}
          incr npart(TESSPART)
          set x3dTessParts($partname) $npart(TESSPART)
          if {$npart(TESSPART) > 0} {foreach xf $x3dFiles {puts $xf "</Group></Switch>"}}
          regsub -all "'" $partname "\"" txt
          foreach xf $x3dFiles {puts $xf "$line\n<Switch id='swTessPart$npart(TESSPART)' whichChoice='0'><Group id='$txt'>"}

# no wireframe mesh
        } elseif {!$opt(tessPartMesh)} {
          foreach xf $x3dFiles {puts $xf $line}

# for wireframe mesh, write faces, store mesh in meshlines
        } else {
          set viz(TESSMESH) 1
          if {[string first "<Coordinate DEF" $line] == -1} {incr n}
          if {$n < 3} {
            foreach xf $x3dFiles {puts $xf $line}
          } else {
            lappend meshlines $line
            if {$n == 4} {set n 0}
          }
        }
      }

# write accumulated wireframe mesh
      if {[llength $meshlines] > 0} {x3dWireframeMesh}
      foreach xf $x3dFiles {puts $xf "</Group></Switch>"}
      close $f
    }

# close overall switch
    foreach xf $x3dFiles {puts $xf "</Group></Switch>"}
  }
  catch {file delete -force -- $tessPartFileName}
  foreach var {tessPartFile tessPartFileName tsName} {catch {unset -- $var}}

# -------------------------------------------------------------------------------
# part geometry
  if {![info exists x3dFiles]} {set x3dFiles [list $x3dFile]}
  if {$viz(PART)} {

# bounding box
    if {[info exists x3dBbox]} {
      if {$x3dBbox != ""} {
        foreach idx {x y z} {
          set pmin($idx) [trimNum $x3dMin($idx)]
          set pmax($idx) [trimNum $x3dMax($idx)]
        }
        set p(0) "$pmin(x) $pmin(y) $pmin(z)"
        set p(1) "$pmax(x) $pmin(y) $pmin(z)"
        set p(2) "$pmax(x) $pmax(y) $pmin(z)"
        set p(3) "$pmin(x) $pmax(y) $pmin(z)"
        set p(4) "$pmin(x) $pmin(y) $pmax(z)"
        set p(5) "$pmax(x) $pmin(y) $pmax(z)"
        set p(6) "$pmax(x) $pmax(y) $pmax(z)"
        set p(7) "$pmin(x) $pmax(y) $pmax(z)"
        puts $x3dFile "\n<!-- BOUNDING BOX -->"
        puts $x3dFile "<Switch whichChoice='-1' id='swBbox'><Group>"
        puts $x3dFile " <Shape><Appearance><Material emissiveColor='0 0 0'/></Appearance>"
        puts $x3dFile "  <IndexedLineSet coordIndex='0 1 2 3 0 -1 4 5 6 7 4 -1 0 4 -1 1 5 -1 2 6 -1 3 7 -1'><Coordinate point='$p(0) $p(1) $p(2) $p(3) $p(4) $p(5) $p(6) $p(7)'/></IndexedLineSet></Shape>"
        puts $x3dFile "</Group></Switch>"
      }
    }

# add b-rep part geometry from temp file
    if {[info exists brepFileName]} {
      if {[file exists $brepFileName]} {
        close $brepFile
        if {[file size $brepFileName] > 0} {
          foreach xf $x3dFiles {
            set brepFile [open $brepFileName r]
            while {[gets $brepFile line] >= 0} {puts $xf $line}
            close $brepFile
          }
          if {!$opt(debugX3D)} {catch {file delete -force -- $brepFileName}}
        }
      }
    }
  }

# -------------------------------------------------------------------------------
# viewpoints
  foreach xf $x3dFiles {puts $xf "\n<!-- VIEWPOINTS -->"}

# default
  set cor "centerOfRotation='$xyzcen(x) $xyzcen(y) $xyzcen(z)'"
  set fov [trimNum [expr {0.55*max($delt(x),$delt(z))}]]
  set xmin [trimNum [expr {$x3dMin(x) - 1.4*max($delt(y),$delt(z))}]]
  set xmax [trimNum [expr {$x3dMax(x) + 1.4*max($delt(y),$delt(z))}]]
  set ymin [trimNum [expr {$x3dMin(y) - 1.4*max($delt(x),$delt(z))}]]
  set ymax [trimNum [expr {$x3dMax(y) + 1.4*max($delt(x),$delt(z))}]]
  set zmin [trimNum [expr {$x3dMin(z) - 1.4*max($delt(x),$delt(y))}]]
  set zmax [trimNum [expr {$x3dMax(z) + 1.4*max($delt(x),$delt(y))}]]

# front viewpoint, perspective or parallel
  set sfastr ""
  if {[info exists savedViewVP]} {set sfastr " (SFA)"}
  if {[info exists savedViewVP] && $opt(viewParallel)} {
    foreach xf $x3dFiles {puts $xf "<OrthoViewpoint id='Front$sfastr' position='$xyzcen(x) [trimNum [expr {$x3dMin(y) - 1.4*max($delt(x),$delt(z))}]] $xyzcen(z)' $cor orientation='1 0 0 1.5708' fieldOfView='\[-$fov,-$fov,$fov,$fov\]'></OrthoViewpoint>"}
  } else {
    foreach xf $x3dFiles {puts $xf "<Viewpoint id='Front$sfastr' position='$xyzcen(x) $ymin $xyzcen(z)' $cor orientation='1 0 0 1.5708'></Viewpoint>"}
  }

# other front/side/top/isometric viewpoints if no saved views
  if {![info exists savedViewVP]} {
    puts $x3dFile "<Viewpoint id='Side' position='$xmax $xyzcen(y) $xyzcen(z)' $cor orientation='1 1 1 2.094'></Viewpoint>"
    puts $x3dFile "<Viewpoint id='Top' position='$xyzcen(x) $xyzcen(y) $zmax' $cor></Viewpoint>"
    puts $x3dFile "<Viewpoint id='Front 2' position='$xyzcen(x) $xyzcen(y) $zmin' $cor orientation='0 1 0 3.1416'></Viewpoint>"
    puts $x3dFile "<Viewpoint id='Side 2' position='$xmax $xyzcen(y) $xyzcen(z)' $cor orientation='0 1 0 1.5708'></Viewpoint>"
    puts $x3dFile "<Viewpoint id='Top 2' position='$xyzcen(x) $ymax $xyzcen(z)' $cor orientation='1 0 0 -1.5708'></Viewpoint>"
    puts $x3dFile "<Viewpoint id='Isometric' position='$xmax $ymin $zmax' $cor orientation='1. 0.4142 0.8002 1.2171'></Viewpoint>"

# saved views and other viewpoints
  } else {
    foreach xf $x3dFiles {foreach line $savedViewVP {puts $xf $line}}
  }

# front viewpoint, perspective or parallel
  if {[info exists savedViewVP] && $opt(viewParallel)} {
    puts $x3dFile "<Viewpoint id='Front perspective$sfastr' position='$xyzcen(x) $ymin $xyzcen(z)' $cor orientation='1 0 0 1.5708'></Viewpoint>"
  } else {
    puts $x3dFile "<OrthoViewpoint id='Front parallel$sfastr' position='$xyzcen(x) [trimNum [expr {$x3dMin(y) - 1.4*max($delt(x),$delt(z))}]] $xyzcen(z)' $cor orientation='1 0 0 1.5708' fieldOfView='\[-$fov,-$fov,$fov,$fov\]'></OrthoViewpoint>"
  }

# background color, default gray
  set skyBlue ".53 .81 .92"
  set bgcheck1 ""
  set bgcheck2 ""
  set bgcheck3 "checked"
  set bgcolor ".8 .8 .8"

# blue background
  if {!$viz(PMI) && !$viz(SUPPGEOM) && !$viz(DTMTAR) && !$viz(HOLE) && !$viz(COMPOSITES) && [string first "AP209" $stepAP] == -1} {
    set bgcheck2 "checked"
    set bgcheck3 ""
    set bgcolor $skyBlue

# white background
  } elseif {![info exists grayBackground]} {
    set bgcheck1 "checked"
    set bgcheck3 ""
    set bgcolor "1 1 1"
  }

# blue background w/o sketch geometry controlled by CSS instead of BACKGROUND node
  set bgcss 0
  if {![info exists nsketch]} {set nsketch -1}
  if {$bgcolor == $skyBlue && $nsketch == -1} {set bgcss 1}
  catch {unset grayBackground}

# background, navigation, world info
  foreach xf $x3dFiles {puts $xf "\n<!-- BACKGROUND, NAVIGATION, WORLD INFO -->"}
  if {!$bgcss} {puts $x3dFile "<Background id='BG' skyColor='$bgcolor'/>"}
  if {$opt(x3dSave)} {puts $x3dFileSave "<Background skyColor='0.9 0.9 0.9'/>"}

  puts $x3dFile "<NavigationInfo type='\"EXAMINE\",\"ANY\"'/>"

  regsub -all "&nbsp;" $x3dTitle " " title
  foreach xf $x3dFiles {puts $xf "<WorldInfo title='$title' info='Generated by the NIST STEP File Analyzer and Viewer [getVersion]'/>"}
  foreach xf $x3dFiles {puts $xf "</Scene></X3D>"}

# close saved x3d file
  if {$opt(x3dSave)} {
    close $x3dFileSave
    set x3dfn "[file rootname $x3dFileNameSave]-sfa.x3d"
    catch {file delete -force -- $x3dfn}
    catch {
      file copy -force -- $x3dFileNameSave $x3dfn
      outputMsg " Saving X3D file: [truncFileName [file nativename $x3dfn]]" blue
      file delete -force -- $x3dFileNameSave
    }
  }

# credits
  set str "Generated by the <a href=\"https://www.nist.gov/services-resources/software/step-file-analyzer-and-viewer\">NIST STEP File Analyzer and Viewer [getVersion]</a>"
  append str "&nbsp;&nbsp;[clock format [clock seconds] -format "%d %b %G %H:%M"]"
  append str "&nbsp;&nbsp;<a href=\"https://www.nist.gov/disclaimer\">NIST Disclaimer</a>"
  puts $x3dFile $str

# -------------------------------------------------------------------------------
# start right column
  puts $x3dFile "</td>\n\n<!-- RIGHT COLUMN BUTTONS -->\n<td valign='top'>"

# for NIST CAD model - link to drawing
  if {[info exists nistName]} {
    if {$nistName != ""} {
      regsub -all "_" $nistName "-" name
      set name "nist-cad-model-[string range $name 5 end]"
      if {[string first "ctc" $name] != -1 || [string first "ftc" $name] != -1} {
        puts $x3dFile "<a href=\"https://www.nist.gov/document/$name\">NIST Test Case Drawing</a><p>"
      }
    }
  }

# part geometry, sketch geometry, edges checkboxes
  set pcb 0
  if {$viz(PART)} {
    set str ""
    if {$tessEnts && $tessSolid} {set str "Tessellated "}
    puts $x3dFile "\n<!-- Part geometry checkbox -->\n<input type='checkbox' checked onclick='togPRT(this.value)'/>$str\Part Geometry"
    if {[info exists nsketch]} {
      if {$nsketch > -1} {puts $x3dFile "<!-- Sketch geometry checkbox -->\n<br><input type='checkbox' checked onclick='togSKH(this.value)'/>Sketch Geometry"}
      if {$nsketch > 1000} {errorMsg " Sketch geometry ([expr {$nsketch+1}]) might take too long to view.  Turn off Sketch and regenerate the View."}
    }
    if {$opt(partEdges) && $viz(EDGE)} {puts $x3dFile "<!-- Edges checkbox -->\n<br><input type='checkbox' checked onclick='togEDG(this.value)' id='swEDG'/>Edges"}
  }

# part checkboxes
  if {$viz(PART)} {
    if {[info exists x3dParts]} {if {[llength [array names x3dParts]] > 1} {x3dPartCheckbox "Part"; set pcb 1}}
    puts $x3dFile "<p>"
  }

# tessellated part geometry checkbox
  if {$viz(TESSPART)} {
    puts $x3dFile "\n<!-- Tessellated part geometry checkbox -->"
    if {$viz(PART)} {puts $x3dFile "<details><summary>Tessellated Part Geometry</summary><p>"}
    puts $x3dFile "<input type='checkbox' checked onclick='togTPG(this.value)'/>Tessellated Part Geometry"
    if {$viz(TESSMESH)} {puts $x3dFile "<!-- Tessellated mesh checkbox -->\n<br><input type='checkbox' checked onclick='togTPM(this.value)'/>Wireframe"}
    if {$viz(TESSEDGE)} {puts $x3dFile "<!-- Tessellated edges checkbox -->\n<br><input type='checkbox' checked onclick='togTED(this.value)'/>Edges"}

    if {[info exists entCount(next_assembly_usage_occurrence)] || [info exists entCount(repositioned_tessellated_item_and_tessellated_geometric_set)]} {
      set ntess 0
      if {[info exists entCount(tessellated_solid)]} {incr ntess $entCount(tessellated_solid)}
      if {[info exists entCount(tessellated_shell)]} {incr ntess $entCount(tessellated_shell)}
      if {$ntess > 1} {puts $x3dFile "<p><font size='-1'>Tessellated Parts in an assembly might be in the wrong position and orientation or be missing.</font>"}
    }

# tessellated part checkboxes
    if {[info exists x3dTessParts]} {if {[llength [array names x3dTessParts]] > 1} {x3dPartCheckbox "Tess"}}
    puts $x3dFile "<p>"
    if {$pcb} {puts $x3dFile "<hr>"}
    if {$viz(PART)} {puts $x3dFile "</details><p>"}
  }

# more checkboxes
  if {$viz(SUPPGEOM)}   {puts $x3dFile "\n<!-- Supplemental geometry checkbox -->\n<input type='checkbox' checked onclick='togSMG(this.value)'/>Supplemental Geometry<br>"}
  if {$viz(DTMTAR)}     {puts $x3dFile "\n<!-- Datum targets checkbox -->\n<input type='checkbox' checked onclick='togDTR(this.value)'/>Datum Targets<br>"}
  if {$viz(COMPOSITES)} {puts $x3dFile "\n<!-- Composites checkbox -->\n<input type='checkbox' checked onclick='togComposites(this.value)'/>Composite Rosettes<br>"}
  if {$viz(POINTS)}     {puts $x3dFile "\n<!-- $pointsLabel checkbox -->\n<input type='checkbox' checked onclick='togPoints(this.value)'/>$pointsLabel<br>"}
  if {$viz(HOLE)}       {puts $x3dFile "\n<!-- Holes checkbox -->\n<input type='checkbox' checked onclick='togHole(this.value)'/>Holes<br>"}
  if {$viz(CLIPPING)}   {
    puts $x3dFile "\n<!-- Clipping planes checkboxes -->"
    if {$nclipPlane <= 4} {
      puts $x3dFile "<p>Clipping Planes<br>"
    } else {
      puts $x3dFile "<details><summary>Clipping Planes</summary>"
    }
    for {set i 1} {$i <= $nclipPlane} {incr i} {
      puts $x3dFile "<input type='checkbox' onclick='togClipping$i\(this.value)'/>$clipPlaneName($i)<br>"
    }
    if {$nclipPlane > 4} {puts $x3dFile "</details>"}
  }
  if {$viz(SUPPGEOM) || $viz(DTMTAR) || $viz(COMPOSITES) || $viz(POINTS) || $viz(HOLE) || $viz(CLIPPING)} {puts $x3dFile "<p>"}

# for PMI annotations - checkboxes for toggling saved view PMI
  if {$viz(PMI) && [llength $savedViewButtons] > 0} {
    set sv 1
    if {[llength $savedViewButtons] == 1 && [lindex $savedViewNames 0] == "Not in a Saved View"} {
      set sv 0
      set name "Graphical PMI"
      set savedViewButtons [list $name]
      set savedViewNames $savedViewButtons
      set svMap($name) $name
    }
    puts $x3dFile "\n<!-- Saved view PMI checkboxes -->"
    if {$sv} {
      if {[llength $savedViewButtons] <= 10} {
        puts $x3dFile "Saved View Graphical PMI"
      } else {
        puts $x3dFile "<details><summary>Saved View Graphical PMI</summary>"
      }
    }
    if {[info exists savedViewVP]} {puts $x3dFile "<br><font size='-1'>(PageDown to switch Saved Views)</font>"}

    foreach svn $savedViewButtons {
      set str ""
      if {$sv} {append str "<br>"}
      set id [lsearch $savedViewNames $svn]
      set svname $svn

# draughting model name not the same as the camera model name
      if {[info exists savedViewDMName($svn)]} {
        if {$savedViewDMName($svn) != $svn && [string first "\[" $savedViewDMName($svn)] == -1 && [string first "\]" $savedViewDMName($svn)] == -1} {set svname "$savedViewDMName($svn) / $svn"}
      }
      append str "<input type='checkbox' id='cbView$id' checked onclick='togView$id\(this.value)'/>$svname"
      puts $x3dFile $str
    }
    if {[llength $savedViewButtons] > 10} {puts $x3dFile "</details>"}
  }

# PMI placeholder
  if {$viz(PLACE)} {
    if {[llength $savedViewButtons] > 0} {puts $x3dFile "<p>"}
    puts $x3dFile "\n<!-- Placeholder checkbox -->\n<input type='checkbox' checked onclick='togPlaceholder(this.value)'/>PMI Placeholders"
  }

# FEM checkboxes
  if {$viz(FEA)} {feaButtons 1}

# message for saved views with no PMI
  if {[info exists savedViewNames]} {
    if {!$viz(PMI) && [llength $savedViewNames] > 0} {
      set str "<p>PageDown for ([llength $savedViewNames]) user-defined viewpoint"
      if {[llength $savedViewNames] > 1} {append str "s"}
      puts $x3dFile $str
    }
  }

# extra text messages
  if {[info exists x3dMsg]} {
    if {[llength $x3dMsg] > 0} {
      puts $x3dFile "\n<!-- Messages -->"
      puts $x3dFile "<ul style=\"padding-left:20px\">"
      foreach item $x3dMsg {puts $x3dFile "<li>$item"}
      puts $x3dFile "</ul>"
      unset x3dMsg
    }
  }

# common buttons
  puts $x3dFile "\n<!-- Start common buttons -->\n<p>"
  puts $x3dFile "<details><summary>More Options</summary>"

# transparency slider
  set transFunc 0
  set max 0
  if {$viz(PART) || $viz(TESSPART) || \
     ($viz(FEA) && ([info exists entCount(surface_3d_element_representation)] || [info exists entCount(volume_3d_element_representation)]))} {
    set max 1
  }
  if {$max == 1} {
    puts $x3dFile "\n<!-- Transparency slider -->"
    puts $x3dFile "<p><input style='width:80px' type='range' min='0' max='$max' step='0.1' value='0' onchange='matTrans(this.value)'/>&nbsp;Transparency"
    set transFunc 1
  }

# bounding box
  if {$viz(PART) && [info exists x3dBbox]} {
    if {$x3dBbox != ""} {puts $x3dFile "\n<!-- Bounding box checkbox -->\n<p><input type='checkbox' onclick='togBbox(this.value)'/>$x3dBbox"}
    if {$viz(FEA)} {puts $x3dFile "<p>"}
  }

# axes checkbox
  set check "checked"
  if {$viz(SUPPGEOM) || $viz(COMPOSITES)} {set check ""}
  puts $x3dFile "\n<!-- Axes checkbox -->\n<p><input type='checkbox' $check onclick='togAxes(this.value)'/>Origin<p>"

# background color radio buttons
  puts $x3dFile "\n<!-- Background radio button -->\nBackground Color<br>"
  if {!$bgcss} {
    puts $x3dFile "<input type='radio' name='bgcolor' value='1 1 1' $bgcheck1 onclick='BGcolor(this.value)'/>White&nbsp;"
    puts $x3dFile "<input type='radio' name='bgcolor' value='$skyBlue' $bgcheck2 onclick='BGcolor(this.value)'/>Blue<br>"
    puts $x3dFile "<input type='radio' name='bgcolor' value='.8 .8 .8' $bgcheck3 onclick='BGcolor(this.value)'/>Gray&nbsp;"
    puts $x3dFile "<input type='radio' name='bgcolor' value='0 0 0' onclick='BGcolor(this.value)'/>Black"
  } else {
    puts $x3dFile "<input type='radio' name='bgcolor' value='white' $bgcheck1 onclick='BGcolor(this.value)'/>White&nbsp;"
    puts $x3dFile "<input type='radio' name='bgcolor' value='blue' $bgcheck2 onclick='BGcolor(this.value)'/>Blue<br>"
    puts $x3dFile "<input type='radio' name='bgcolor' value='gray' $bgcheck3 onclick='BGcolor(this.value)'/>Gray&nbsp;"
    puts $x3dFile "<input type='radio' name='bgcolor' value='black' onclick='BGcolor(this.value)'/>Black"
  }

# mouse message
  puts $x3dFile "\n<p>PageDown for Viewpoints.  Key 'r' to restore, 'a' to view all.  <a href=\"https://www.x3dom.org/documentation/interaction/\">Use the mouse</a> in 'Examine Mode' to rotate, pan, zoom."
  puts $x3dFile "</details>"
  puts $x3dFile "</td></tr></table>"

# -------------------------------------------------------------------------------
# function for PRT, sketch, EDG, part names
  if {$viz(PART)} {
    x3dSwitchScript PRT

    if {[info exists nsketch]} {
      if {$nsketch > -1} {puts $x3dFile "\n<!-- SKH switch -->\n<script>function togSKH\(choice\)\{"}
      for {set i 0} {$i <= $nsketch} {incr i} {
        puts $x3dFile " if (!document.getElementById('swSketch$i').checked) \{document.getElementById('swSketch$i').setAttribute('whichChoice', -1);\} else \{document.getElementById('swSketch$i').setAttribute('whichChoice', 0);\}"
        puts $x3dFile " document.getElementById('swSketch$i').checked = !document.getElementById('swSketch$i').checked;"
      }
      if {$nsketch > -1} {puts $x3dFile "\}</script>"}
    }

    if {$opt(partEdges)} {
      puts $x3dFile "\n<!-- EDG switch -->\n<script>function togEDG\(choice\)\{"
      if {![info exist edgeMatID]} {set edgeMatID "mat1"}
      puts $x3dFile " if \(!document.getElementById\('swEDG'\).checked\) \{document.getElementById\('$edgeMatID'\).setAttribute\('transparency', 1\);\} else \{document.getElementById\('$edgeMatID'\).setAttribute\('transparency', 0\);\}\n\}</script>"
    }
  }

# part names, bounding box
  if {$viz(PART)} {
    if {[info exists x3dParts]} {
      if {[llength [array names x3dParts]] > 1} {
        foreach item [array names x3dParts] {x3dSwitchScript Part$x3dParts($item)}
      }
      catch {unset x3dParts}
      if {[llength [array names parts]] > 2} {
        puts $x3dFile "\n<!-- All Parts Show/Hide switch -->\n<script>function togPartAll(choice)\{"
        foreach name [lsort -nocase [array names parts]] {
          puts $x3dFile " togPart[lindex $parts($name) 0](choice);"
        }
        puts $x3dFile "\}</script>"
      }
      catch {unset parts}
    }

# bounding box
    if {[info exists x3dBbox]} {if {$x3dBbox != ""} {x3dSwitchScript Bbox}}
  }

# switch functions for fem
  if {$viz(FEA)} {
    x3dSwitchScript Nodes
    if {[info exists entCount(surface_3d_element_representation)] || \
        [info exists entCount(volume_3d_element_representation)]}  {x3dSwitchScript Mesh}
    if {[info exists entCount(curve_3d_element_representation)]}   {x3dSwitchScript 1DElements}
    if {[info exists entCount(surface_3d_element_representation)]} {x3dSwitchScript 2DElements}
    if {[info exists entCount(volume_3d_element_representation)]}  {x3dSwitchScript 3DElements}
  }

# function for TPG
  if {$viz(TESSPART)} {
    if {[string first "occurrence" $ao] == -1} {
      x3dSwitchScript TPG
      if {$viz(TESSEDGE)} {x3dSwitchScript TED}

      if {[info exists x3dTessParts]} {
        if {$viz(TESSMESH)} {
          puts $x3dFile "\n<!-- Tessellated mesh switch -->\n<script>function togTPM\(choice)\{"
          foreach item [array names x3dTessParts] {x3dSwitchScript TessMesh$x3dTessParts($item)}
          puts $x3dFile "\}</script>"
        }
        if {[llength [array names x3dTessParts]] > 1} {
          foreach item [array names x3dTessParts] {x3dSwitchScript TessPart$x3dTessParts($item)}
        }
        catch {unset x3dTessParts}

# tessellated parts
        if {[llength [array names partstg]] > 2} {
          puts $x3dFile "\n<!-- All Tessellated Parts Show/Hide switch -->\n<script>function togTessPartAll(choice)\{"
          foreach name [lsort -nocase [array names partstg]] {
            puts $x3dFile " togTessPart[lindex $partstg($name) 0](choice);"
          }
          puts $x3dFile "\}</script>"
        }
      }
    }
  }

# more functions
  if {$viz(SUPPGEOM)} {x3dSwitchScript SMG}
  if {$viz(DTMTAR)} {x3dSwitchScript DTR}
  if {$viz(PLACE)} {x3dSwitchScript Placeholder}
  if {$viz(COMPOSITES)} {x3dSwitchScript Composites}
  if {$viz(POINTS)} {x3dSwitchScript Points}
  if {$viz(HOLE)} {x3dSwitchScript Hole}
  if {$viz(CLIPPING)} {x3dSwitchScript Clipping}

# onload
  set onload {}
  if {[info exists x3dPartClick]} {if {$x3dPartClick} {lappend onload " document.getElementById('clickedObject').innerHTML = 'click on a part';"}}

# background onload select checked background
  if {[llength $onload] > 0} {lappend onload " "}
  lappend onload " var items = document.getElementsByName('bgcolor');"
  lappend onload " for (var i=0; i<items.length; i++) {if (items\[i\].checked == true) {BGcolor(items\[i\].value);}}"
  lappend onload " "

# functions for viewpoint names and PMI
  if {[llength $savedViewButtons] > 0 || [info exists savedViewVP]} {
    puts $x3dFile " "
    if {$viz(PMI)} {foreach svn $savedViewButtons {x3dSwitchScript View[lsearch $savedViewNames $svn] $svMap($svn)}}

    if {[info exists savedViewVP]} {
      set id 0
      set lfront [list "Front (SFA)" "Front parallel (SFA)"]
      if {$opt(viewParallel) && [info exists savedViewVP]} {set lfront [list "Front (SFA)" "Front perspective (SFA)"]}
      foreach svn $lfront {
        lappend onload "\n var view$id = document.getElementById('$svn');\n view$id.addEventListener('outputchange', function(event) \{"
        lappend onload "  document.getElementById('clickedView').innerHTML = '$svn';"
        incr id
        if {$viz(PMI)} {
          foreach svn1 $savedViewButtons {
            if {[info exists viewsWithPMI($svn1)]} {
              lappend onload "  document.getElementById('swView$viewsWithPMI($svn1)').setAttribute('whichChoice', 0);"
              lappend onload "  document.getElementById('swView$viewsWithPMI($svn1)').checked = false;"
              lappend onload "  document.getElementById('cbView$viewsWithPMI($svn1)').checked = true;"
            }
          }
        }
        lappend onload " \}, false);"
      }

      set svb $savedViewButtons
      if {!$viz(PMI) || [llength $savedViewButtons] == 0} {set svb [array names savedViewpoint]}

      foreach svn $svb {
        lappend onload "\n var view$id = document.getElementById('$svn');\n view$id.addEventListener('outputchange', function(event) \{"
        lappend onload "  document.getElementById('clickedView').innerHTML = '$svn';"
        incr id
        if {$viz(PMI)} {
          foreach svn1 $savedViewButtons {
            if {[info exists viewsWithPMI($svn1)]} {
              set wc -1
              set ch1 "true"
              set ch2 "false"
              if {$svn == $svn1} {set wc 0; set ch1 "false"; set ch2 "true"}
              if {$svn == $svMap($svn) || $svn == $svn1} {
                lappend onload "  document.getElementById('swView$viewsWithPMI($svn1)').setAttribute('whichChoice', $wc);"
                lappend onload "  document.getElementById('swView$viewsWithPMI($svn1)').checked = $ch1;"
              }
              lappend onload "  document.getElementById('cbView$viewsWithPMI($svn1)').checked = $ch2;"
            }
          }
        }
        lappend onload " \}, false);"
      }
    }
  }

# functions for eventListener for viewpoint if no saved views
  if {![info exists savedViewVP]} {
    set id 0
    foreach svn [list "Front" "Side" "Top" "Front 2" "Side 2" "Top 2" "Isometric" "Front parallel"] {
      lappend onload " var view$id = document.getElementById('$svn');\n view$id.addEventListener('outputchange', function(event) \{document.getElementById('clickedView').innerHTML = '$svn';\}, false);"
      incr id
    }
  }
  catch {unset savedViewVP}

# functions for FEA buttons
  if {$viz(FEA)} {feaButtons 2}

# background function
  if {!$bgcss} {
    puts $x3dFile "\n<!-- Background function -->\n<script>function BGcolor(color){document.getElementById('BG').setAttribute('skyColor', color);}</script>"
  } else {
    puts $x3dFile "\n<!-- Background functions -->
<script>function BGcolor(color){
 if (color == 'blue') {
  document.getElementById('x3d').style.backgroundImage = 'linear-gradient(skyBlue, white)';
 } else if (color == 'gray') {
  document.getElementById('x3d').style.backgroundImage = 'linear-gradient(darkgray, lightgray)';
 } else {
  document.getElementById('x3d').style.background = color;
 }
}
</script>"
  }

# axes function
  x3dSwitchScript Axes

# transparency function
  set numTessColor 0
  if {$viz(TESSPART)} {set numTessColor [tessCountColors]}
  if {$transFunc} {
    puts $x3dFile "\n<!-- Transparency function -->\n<script>function matTrans(trans){"

# part transparency
    if {$viz(PART)} {
      if {[info exists x3dApps]} {
        set mats [lrmdups [lsort -integer $x3dApps]]
        if {$rosetteGeom == 1 || $rosetteGeom == 3} {set mats [lrange $mats 0 end-1]}
        set n1 1
        if {[info exists edgeMatID]} {set n1 [string range $edgeMatID 3 end]}
        foreach n $mats {
          if {!$opt(partEdges) || $n != $n1} {
            if {![info exists matTrans($n)]} {
              puts $x3dFile " document.getElementById('mat$n').setAttribute('transparency', trans);"
            } elseif {$matTrans($n) < 1.} {
              puts $x3dFile " if (trans > $matTrans($n)) {document.getElementById('mat$n').setAttribute('transparency', trans);} else {document.getElementById('mat$n').setAttribute('transparency', $matTrans($n));}"
            }
          }
        }
      }
    }

# tessellated geometry transparency
    for {set i 1} {$i <= $numTessColor} {incr i} {puts $x3dFile " try {document.getElementById('matTess$i').setAttribute('transparency', trans);} catch(err) {}"}

# finite element model transparency
    if {$viz(FEA)} {
      if {[info exists entCount(surface_3d_element_representation)]} {
        puts $x3dFile " document.getElementById('mat2Dfem').setAttribute('transparency', trans);"
      }
      if {[info exists entCount(volume_3d_element_representation)]}  {
        puts $x3dFile " document.getElementById('mat3Dfem').setAttribute('transparency', trans);"
        puts $x3dFile " if (trans > 0) {document.getElementById('faces').setAttribute('solid', true);} else {document.getElementById('faces').setAttribute('solid', false);}"
      }
    }
    puts $x3dFile "}</script>"
  }

# onload functions
  if {[llength $onload] > 0} {
    puts $x3dFile "\n<!-- onload functions -->\n<script>document.onload = function() \{\n document.getElementById('clickedView').innerHTML = 'Front$sfastr';"
    foreach line $onload {puts $x3dFile $line}
    puts $x3dFile "\}\n</script>"
  }

  puts $x3dFile "</font></body></html>"
  close $x3dFile
  update idletasks

# unset variables
  foreach var [list x3dCoord x3dFile x3dFiles x3dIndex x3dMax x3dMin x3dShape x3dStartFile] {catch {unset -- $var}}
}

# -------------------------------------------------------------------------------
# saved view viewpoints
proc x3dSavedViewpoint {name} {
  global delt maxxyz opt recPracNames savedViewpoint savedViewVP spaces x3dFiles x3dMsg xyzcen

# check for errors
  set msg ""
  set pp [lindex $savedViewpoint($name) 3]
  set pbaxis [lindex $savedViewpoint($name) 8]

  if {$pp != "0. 0. 0." || $pbaxis != "0.0 0.0 1.0"} {
    if {$pp != "0. 0. 0."} {append msg " The projection_point should be '0 0 0'."}
    if {$pbaxis != "0.0 0.0 1.0"} {append msg " The planar_box a2p3d axis should be '0 0 1'."}
  }
  set diff [expr {abs([lindex [lindex $savedViewpoint($name) 6] 2]-[lindex $savedViewpoint($name) 2])}]
  if {$diff > 1.} {append msg " The view_plane_distance and the planar_box a2p3d origin Z value should be equal."}
  if {$msg != ""} {
    append msg "$spaces\($recPracNames(pmi242), Sec. 9.4.2.6)"
    errorMsg "Syntax Error: Camera model viewpoint is not modeled correctly.$msg"
    set msg "Viewpoints are not modeled correctly"
    if {$opt(viewCorrect)} {set msg "Using corrected viewpoints (More tab)"}
    if {[lsearch $x3dMsg $msg] == -1} {lappend x3dMsg $msg}
    if {!$opt(viewCorrect)} {errorMsg " Use the option to correct the viewpoints (More tab).  The corrected viewpoints should fix the orientation but maybe not the position."}
  }

# default viewpoint with transform
  set n 0
  foreach xf $x3dFiles {
    incr n
    set fov [trimNum [expr {0.9*max($delt(x),$delt(z))}]]
    if {$n == 1} {

# perspective or parallel projection
      set parallel [lindex [lindex $savedViewpoint($name) 1] 0]
      set rotation [lindex [lindex $savedViewpoint($name) 1] 1]
      if {$parallel} {
        lappend savedViewVP "<OrthoViewpoint id='$name' position='[lindex $savedViewpoint($name) 0]' centerOfRotation='$xyzcen(x) $xyzcen(y) $xyzcen(z)' orientation='$rotation' fieldOfView='\[-$fov,-$fov,$fov,$fov\]'></OrthoViewpoint>"
      } else {
        lappend savedViewVP "<Transform translation='[lindex $savedViewpoint($name) 0]' rotation='$rotation'><Viewpoint id='$name' position='0 0 0' orientation='0 1 0 3.14156'/></Transform>"
      }
    }

# show camera model for debugging
    if {$opt(debugVP)} {
      set scale [trimNum [expr {$maxxyz*0.08}]]
      puts $xf "<Transform translation='[lindex $savedViewpoint($name) 0]' rotation='[lindex [lindex $savedViewpoint($name) 1] 1]' scale='$scale $scale $scale'>"
      puts $xf " <Shape><Appearance><Material emissiveColor='1 0 0'/></Appearance><IndexedLineSet coordIndex='0 1 -1'><Coordinate point='0. 0. 0. 1. 0. 0.'/></IndexedLineSet></Shape>"
      puts $xf " <Shape><Appearance><Material emissiveColor='0 1 0'/></Appearance><IndexedLineSet coordIndex='0 1 -1'><Coordinate point='0. 0. 0. 0. 1. 0.'/></IndexedLineSet></Shape>"

# line from to pp to vpd (pp2vpd)
      set pp2vpd "[lindex $savedViewpoint($name) 3] [lindex [lindex $savedViewpoint($name) 3] 0] [lindex [lindex $savedViewpoint($name) 3] 1] [trimNum [expr {[lindex [lindex $savedViewpoint($name) 3] 2]+[lindex $savedViewpoint($name) 2]}]]"
      puts $xf " <Shape><Appearance><Material emissiveColor='0 0 1'/></Appearance><IndexedLineSet coordIndex='0 1 -1'><Coordinate point='$pp2vpd'/></IndexedLineSet></Shape>"

# planar box a2p3d
      puts $xf " <Transform translation='[lindex $savedViewpoint($name) 6]' rotation='[lindex $savedViewpoint($name) 7]'>"
      puts $xf "  <Shape><Appearance><Material emissiveColor='0 0 0'/></Appearance><IndexedLineSet coordIndex='0 1 2 3 0 -1 0 2 -1 1 3 -1'><Coordinate point='0. 0. 0. [lindex $savedViewpoint($name) 4] 0. 0. [lindex $savedViewpoint($name) 4] [lindex $savedViewpoint($name) 5] 0. 0. [lindex $savedViewpoint($name) 5] 0.'/></IndexedLineSet></Shape>"
      puts $xf " </Transform>"
      puts $xf " <Shape><Appearance><Material emissiveColor='0 0 0'/></Appearance><IndexedLineSet coordIndex='0 1 -1'><Coordinate point='[lindex $savedViewpoint($name) 3] [lindex $savedViewpoint($name) 6]'/></IndexedLineSet></Shape>"
      puts $xf " <Transform scale='0.5 0.5 0.5'><Billboard axisOfRotation='0 0 0'><Shape><Text string='$name'><FontStyle family='SANS' justify='BEGIN'/></Text><Appearance><Material diffuseColor='0 0 0'/></Appearance></Shape></Billboard></Transform>"

# label
      set trans [vectrim [vecadd [lindex $savedViewpoint($name) 6] [list [expr {[lindex $savedViewpoint($name) 4]*0.5}] [lindex $savedViewpoint($name) 5] 0.]]]
      set scale [trimNum [expr {[lindex $savedViewpoint($name) 2]/36.}]]
      puts $xf " <Transform translation='$trans' scale='$scale $scale $scale'><Billboard axisOfRotation='0 0 0'><Shape><Text string='$name'><FontStyle family='SANS' justify='MIDDLE'/></Text><Appearance><Material diffuseColor='0 0 0'/></Appearance></Shape></Billboard></Transform>"
      puts $xf "</Transform>\n"
    }
  }
}

# -------------------------------------------------------------------------------
# datum targets
proc x3dDatumTarget {} {
  global datumTargetView dttype maxxyz recPracNames spaces viz x3dFile

  outputMsg " Processing datum targets" green
  puts $x3dFile "\n<!-- DATUM TARGETS -->\n<Switch whichChoice='0' id='swDTR'><Group>"

  foreach idx [array names datumTargetView] {
    set dttype [lindex $datumTargetView($idx) 0]
    set shape  [lindex $datumTargetView($idx) 1]
    set color "1 0 0"
    set feat ""
    if {[string first "feature" $idx] != -1} {
      set color "0 .5 0"
      set feat " feature"
    }
    set endTransform 0

# check for handle
    if {[string first "handle" $shape] == -1} {
      set e3 ""

# position and orientation
      set origin [lindex [lindex $datumTargetView($idx) 1] 0]
      set axis   [lindex [lindex $datumTargetView($idx) 1] 1]
      set refdir [lindex [lindex $datumTargetView($idx) 1] 2]
      set shape $dttype

# handle, then shape is with geometric entity (cartesian_point, line, and circle are supported)
    } else {
      set e3 [lindex $datumTargetView($idx) 1]
      set shape [$e3 Type]
      if {$shape == "trimmed_curve"} {
        set e3 [[[$e3 Attributes] Item [expr 2]] Value]
        if {[$e3 Type] == "line"}   {set shape [$e3 Type]}
        if {[$e3 Type] == "circle"} {set shape "circular curve"}
      } elseif {$shape == "circle"} {
        set shape "circular curve"
      }
    }

# text
    set textOrigin "0 0 0"
    set target [lindex $datumTargetView($idx) end]
    set len [string length $target]
    if {$len < 2 || $len > 5 || ![string is alpha [string index $target 0]]} {set target ""}
    set textJustify "BEGIN"
    if {$e3 != ""} {set textJustify "END"}
    if {$target != ""} {puts $x3dFile "<!-- $target -->"}

# process different shapes
    if {[catch {
      switch -- $shape {
        point -
        vertex_point -
        cartesian_point {
# generate point
          set rad [trimNum [expr {$maxxyz*0.00125}]]
          if {$e3 != ""} {
            if {$shape == "vertex_point"} {
              set e3 [[[$e3 Attributes] Item [expr 2]] Value]
              if {[$e3 Type] != "cartesian_point"} {errorMsg " Datum target vertex_point defined by '[$e3 Type]' is not supported."}
            }
            set origin [vectrim [[[$e3 Attributes] Item [expr 2]] Value]]
          }
          puts $x3dFile "<Transform translation='$origin'><Shape><Appearance><Material diffuseColor='$color' emissiveColor='$color'/></Appearance><Sphere radius='$rad'></Sphere></Shape>"
          set target " $target"
          set viz(DTMTAR) 1
          set endTransform 1
        }

        line -
        edge_curve {
# generate line
          if {$e3 == ""} {
            puts $x3dFile [x3dTransform $origin $axis $refdir "$shape datum target"]
            set x [trimNum [lindex [lindex $datumTargetView($idx) 2] 1]]
            puts $x3dFile " <Shape><Appearance><Material emissiveColor='$color'/></Appearance><IndexedLineSet coordIndex='0 1 -1'><Coordinate point='0 0 0 $x 0 0'/></IndexedLineSet></Shape>"
            set textOrigin "[trimNum [expr {$x*0.5}]] 0 0"
            set endTransform 1
          } else {
            if {$shape == "line"} {
              set e4 [[[$e3 Attributes] Item [expr 2]] Value]
              set coord1 [vectrim [[[$e4 Attributes] Item [expr 2]] Value]]
              set e5 [[[$e3 Attributes] Item [expr 3]] Value]
              set mag [[[$e5 Attributes] Item [expr 3]] Value]
              set e6 [[[$e5 Attributes] Item [expr 2]] Value]
              set dir [[[$e6 Attributes] Item [expr 2]] Value]
              set coord2 [vectrim [vecadd $coord1 [vecmult $dir $mag]]]
            } elseif {$shape == "edge_curve"} {
              set vp [[[$e3 Attributes] Item [expr 2]] Value]
              set cp [[[$vp Attributes] Item [expr 2]] Value]
              set coord1 [vectrim [[[$cp Attributes] Item [expr 2]] Value]]
              set vp [[[$e3 Attributes] Item [expr 3]] Value]
              set cp [[[$vp Attributes] Item [expr 2]] Value]
              set coord2 [vectrim [[[$cp Attributes] Item [expr 2]] Value]]
            }
            puts $x3dFile "<Shape><Appearance><Material emissiveColor='$color'/></Appearance><IndexedLineSet coordIndex='0 1 -1'><Coordinate point='$coord1 $coord2'/></IndexedLineSet></Shape>"
            set textOrigin [vectrim [vecmult [vecadd $coord1 $coord2] 0.5]]
          }
          set viz(DTMTAR) 1
        }

        rectangle {
# generate rectangle
          puts $x3dFile [x3dTransform $origin $axis $refdir "$shape datum target"]
          foreach i {2 3} {
            set type [lindex $datumTargetView($idx) $i]
            switch -- [lindex $type 0] {
              "target length" {set x [trimNum [expr {[lindex $type 1]*0.5}]]}
              "target width"  {set y [trimNum [expr {[lindex $type 1]*0.5}]]}
            }
          }
          puts $x3dFile " <Shape><Appearance><Material emissiveColor='$color'/></Appearance><IndexedLineSet coordIndex='0 1 2 3 0 -1'><Coordinate point='-$x -$y 0 $x -$y 0 $x $y 0 -$x $y 0'/></IndexedLineSet></Shape>"
          puts $x3dFile " <Shape><Appearance><Material diffuseColor='$color' transparency='0.8'/></Appearance><IndexedFaceSet solid='false' coordIndex='0 1 2 3 -1'><Coordinate point='-$x -$y 0 $x -$y 0 $x $y 0 -$x $y 0'/></IndexedFaceSet></Shape>"
          set endTransform 1
          set viz(DTMTAR) 1
        }

        circle -
        "circular curve" {
# generate circle
          if {$e3 == ""} {
            set rad [trimNum [expr {[lindex [lindex $datumTargetView($idx) 2] 1]*0.5}]]
          } else {
            set e4 [[[$e3 Attributes] Item [expr 2]] Value]
            set rad [[[$e3 Attributes] Item [expr 3]] Value]
            set a2p3d [x3dGetA2P3D $e4]
            set origin [lindex $a2p3d 0]
            set axis   [lindex $a2p3d 1]
            set refdir [lindex $a2p3d 2]
          }
          puts $x3dFile [x3dTransform $origin $axis $refdir "$shape datum target"]
          set ns 48
          set angle 0.
          set dlt [expr {6.28319/$ns}]
          set index ""
          for {set i 0} {$i < $ns} {incr i} {append index "$i "}
          set coord ""
          for {set i 0} {$i < $ns} {incr i} {
            append coord "[trimNum [expr {$rad*cos($angle)}]] "
            append coord "[trimNum [expr {$rad*sin($angle)}]] "
            append coord "0 "
            set angle [expr {$angle+$dlt}]
          }
          puts $x3dFile " <Shape><Appearance><Material emissiveColor='$color'/></Appearance><IndexedLineSet coordIndex='$index 0 -1'><Coordinate point='$coord'/></IndexedLineSet></Shape>"
          if {$shape == "circle"} {
            puts $x3dFile " <Shape><Appearance><Material diffuseColor='$color' transparency='0.8'/></Appearance><IndexedFaceSet solid='false' coordIndex='$index -1'><Coordinate point='$coord'/></IndexedFaceSet></Shape>"
          } else {
            set textOrigin "$rad 0 0"
          }
          set endTransform 1
          set viz(DTMTAR) 1
        }

        advanced_face {
# for advanced face, look for circles and lines
          set e1 $e3
          set e2 [[[$e1 Attributes] Item [expr 3]] Value]

# if in a plane, follow face_outer_bounds and face_bounds to ...
          if {[$e2 Type] == "plane"} {
            set e2s [[[$e1 Attributes] Item [expr 2]] Value]
            set igeom 0
            set coord ""
            set ncoord 0

# get number of face bounds
            set nbound 0
            ::tcom::foreach e2 $e2s {incr nbound}

            ::tcom::foreach e2 $e2s {
              set e3 [[[$e2 Attributes] Item [expr 2]] Value]
              set e4s [[[$e3 Attributes] Item [expr 2]] Value]

# get number and types of geometric entities defining the edges
              set ngeom 0
              set gtypes {}
              ::tcom::foreach e4 $e4s {
                incr ngeom
                set e5 [[[$e4 Attributes] Item [expr 4]] Value]
                set e6 [[[$e5 Attributes] Item [expr 4]] Value]
                if {[lsearch $gtypes [$e6 Type]] == -1} {lappend gtypes [$e6 Type]}
              }

# check for only multiple circles or ellipses
              set onlyCircle 0
              if {[llength $gtypes] == 1} {if {$gtypes == "circle" || $gtypes == "ellipse"} {set onlyCircle 1}}

              ::tcom::foreach e4 $e4s {
                set e5 [[[$e4 Attributes] Item [expr 4]] Value]
                set e6 [[[$e5 Attributes] Item [expr 4]] Value]
                incr igeom

# advanced face circle and ellipse edges
                if {[$e6 Type] == "circle" || [$e6 Type] == "ellipse"} {
                  if {$nbound == 1 && ($ngeom == 1 || $onlyCircle)} {
                    set rad [[[$e6 Attributes] Item [expr 3]] Value]
                    set scale ""

# check ellipse axes
                    if {[$e6 Type] == "ellipse"} {
                      set rad1 [[[$e6 Attributes] Item [expr 4]] Value]
                      set sy [expr {$rad1/$rad}]
                      set scale "1 $sy 1"
                      set dsy [trimNum [expr {abs($sy-1.)}]]
                      if {$dsy <= 0.05} {errorMsg " Datum target ($dttype) '[$e6 Type]' axes ($rad, $rad1) are almost identical."}
                    }

# transform for circle
                    if {!$onlyCircle || $igeom == 1} {
                      set a2p3d [x3dGetA2P3D [[[$e6 Attributes] Item [expr 2]] Value]]
                      puts $x3dFile [x3dTransform [lindex $a2p3d 0] [lindex $a2p3d 1] [lindex $a2p3d 2] "$shape circle datum target" $scale]
                    }

# generate coordinates
                    incr ncoord 48
                    set angle 0.
                    set dlt [expr {6.28319/$ncoord}]
                    for {set i 0} {$i < $ncoord} {incr i} {
                      append coord "[trimNum [expr {$rad*cos($angle)}]] "
                      append coord "[trimNum [expr {$rad*sin($angle)}]] "
                      append coord "0 "
                      set angle [expr {$angle+$dlt}]
                      if {$i == 0 && $igeom == 1} {set textOrigin $coord}
                    }
                    set endTransform 1
                  } else {
                    errorMsg " Datum target$feat edges defined by multiple 'circle' or 'ellipse' are not supported.  The datum target geometry will appear incomplete."
                  }

# advanced face line edges
                } elseif {[$e6 Type] == "line"} {

# get edge_curve that refers to the line and use the resulting vertex points
                  set e8s [$e6 GetUsedIn [string trim edge_curve] [string trim edge_geometry]]
                  ::tcom::foreach e8 $e8s {
                    foreach idx {2 3} {
                      set e9 [[[$e8 Attributes] Item [expr $idx]] Value]
                      set e10 [[[$e9 Attributes] Item [expr 2]] Value]
                      set pts($idx) [vectrim [[[$e10 Attributes] Item [expr 2]] Value]]
                    }
                    if {[string first $pts(2) $coord] == -1} {
                      set pt $pts(2)
                    } else {
                      set pt $pts(3)
                    }
                  }

                  append coord "$pt "
                  incr ncoord
                  if {$ncoord == 1 && $igeom == 1} {set textOrigin $pt}

# not a circle or line
                } else {
                  set target ""
                  errorMsg " Datum target$feat edges defined by '[$e2 Type]' are not supported.  The datum target geometry will appear incomplete."
                }
              }
            }

# shape for circles and lines
            if {$coord != ""} {
              set index ""
              for {set i 0} {$i < $ncoord} {incr i} {append index "$i "}
              puts $x3dFile " <Shape><Appearance><Material emissiveColor='$color'/></Appearance><IndexedLineSet coordIndex='$index 0 -1'><Coordinate point='$coord'/></IndexedLineSet></Shape>"
              puts $x3dFile " <Shape><Appearance><Material diffuseColor='$color' transparency='0.8'/></Appearance><IndexedFaceSet solid='false' coordIndex='$index -1'><Coordinate point='$coord'/></IndexedFaceSet></Shape>"
              set viz(DTMTAR) 1
            }

# non planes are not supported
          } else {
            set target ""
            errorMsg " [string totitle $dttype] datum target$feat face defined by '[$e2 Type]' is not supported."
          }
        }

        default {
          set target ""
          errorMsg "Syntax Error: [string totitle $dttype] datum target$feat defined by '$shape' should use an 'advanced_face'.$spaces\($recPracNames(pmi242), Sec. 6.6.2, Fig. 44)"
        }
      }

# small coordinate triad
      if {$shape != "point" && $shape != "cartesian_point" && $shape != "advanced_face" && [string first "feature" $idx] == -1} {
        set size [trimNum [expr {$maxxyz*0.005}]]
        puts $x3dFile " <Shape><Appearance><Material emissiveColor='1 0 0'/></Appearance><IndexedLineSet coordIndex='0 1 -1'><Coordinate point='0. 0. 0. $size 0. 0.'/></IndexedLineSet></Shape>"
        puts $x3dFile " <Shape><Appearance><Material emissiveColor='0 .5 0'/></Appearance><IndexedLineSet coordIndex='0 1 -1'><Coordinate point='0. 0. 0. 0. $size 0.'/></IndexedLineSet></Shape>"
        puts $x3dFile " <Shape><Appearance><Material emissiveColor='0 0 1'/></Appearance><IndexedLineSet coordIndex='0 1 -1'><Coordinate point='0. 0. 0. 0. 0. $size'/></IndexedLineSet></Shape>"
      }

# datum target label
      if {$target != ""} {
        set size [trimNum [expr {$maxxyz*0.01}]]
        set trans ""
        if {$textOrigin != "0 0 0"} {set trans " translation='$textOrigin'"}
        puts $x3dFile " <Transform$trans scale='$size $size $size'><Billboard axisOfRotation='0 0 0'><Shape><Text string='$target'><FontStyle family='SANS' justify='$textJustify'/></Text><Appearance><Material diffuseColor='$color'/></Appearance></Shape></Billboard></Transform>"
      }

# end transform
      if {$endTransform} {puts $x3dFile "</Transform>"}

    } emsg]} {
      errorMsg "Error viewing a '$dttype' datum target$feat ($target): $emsg"
    }
  }
  puts $x3dFile "</Group></Switch>"
  catch {unset datumTargetView}
}

# -------------------------------------------------------------------------------
# holes counter and spotface
proc x3dHoles {} {
  global dim DTR entCount gen holeDefinitions maxxyz opt recPracNames spaces syntaxErr viz x3dFile
  global objDesign

  set drillPoint [trimNum [expr {$maxxyz*0.02}]]
  set head 1
  set holeDEF {}

  set scale 1.
  if {$dim(unit) == "INCH"} {set scale 25.4}

  ::tcom::foreach e0 [$objDesign FindObjects [string trim item_identified_representation_usage]] {
    if {[catch {
      set e1 [[[$e0 Attributes] Item [expr 3]] Value]
      set e2 [[[$e0 Attributes] Item [expr 5]] Value]
      if {[catch {
        set e2type [$e2 Type]
      } emsg1]} {
        ::tcom::foreach e2a $e2 {set e2 $e2a; break}
      }
      if {[string first "occurrence" [$e1 Type]] != -1 && [$e2 Type] == "mapped_item"} {
        set defID   [[[[$e1 Attributes] Item [expr 5]] Value] P21ID]
        set defType [[[[$e1 Attributes] Item [expr 5]] Value] Type]

# hole name
        set holeName [split $defType "_"]
        foreach idx {0 1} {
          if {[string first "counter" [lindex $holeName $idx]] != -1 || [string first "spotface" [lindex $holeName $idx]] != -1} {set holeName [lindex $holeName $idx]}
        }
        if {$defType == "basic_round_hole"} {set holeName $defType}

# check if there is an a2p3d associated with a hole occurrence
        set e3 [[[$e2 Attributes] Item [expr 3]] Value]
        if {[$e3 Type] == "axis2_placement_3d"} {
          if {$head} {
            outputMsg " Processing hole geometry" green
            puts $x3dFile "\n<!-- HOLES -->\n<Switch whichChoice='0' id='swHole'><Group>"
            set head 0
            set viz(HOLE) 1
          }
          if {[lsearch $holeDEF $defID] == -1} {puts $x3dFile "<!-- $defType $defID -->"}

# hole geometry
          if {[info exists holeDefinitions($defID)]} {

# hole origin and axis transform
            set a2p3d [x3dGetA2P3D $e3]
            set transform [x3dTransform [lindex $a2p3d 0] [lindex $a2p3d 1] [lindex $a2p3d 2] $holeName]

# drilled hole dimensions
            set drill [lindex $holeDefinitions($defID) 0]
            set drillRad [trimNum [expr {[lindex $drill 1]*0.5*$scale}] 5]
            set drillPoint $drillRad
            catch {unset drillDep}
            if {[llength $drill] > 2} {set drillDep [expr {[lindex $drill 2]*$scale}]}

# through hole
            set holeTop "true"
            set thruHole [lindex $holeDefinitions($defID) end-1]
            if {$thruHole == 1} {set holeTop "false"}

# hole name
            set holeName [lindex $holeDefinitions($defID) end]

            catch {unset sink}
            catch {unset bore}
            set lhd [llength $holeDefinitions($defID)]
            if {$lhd > 1} {
              set holeType [lindex [lindex $holeDefinitions($defID) [expr {$lhd-3}]] 0]

# countersink hole (cylinder, cone)
              if {$holeType == "countersink"} {
                set sink [lindex $holeDefinitions($defID) 1]

# compute length of countersink from angle and radius
                set sinkRad [trimNum [expr {[lindex $sink 1]*0.5*$scale}] 5]
                set sinkAng [expr {[lindex $sink 2]*0.5}]
                set sinkDep [expr {($sinkRad-$drillRad)/tan($sinkAng*$DTR)}]

# check for bad radius and depth
                if {$sinkRad <= $drillRad} {
                  set msg "Syntax Error: $holeType diameter <= drill diameter"
                  errorMsg $msg
                  foreach ent [list $holeType\_hole_definition simplified_$holeType\_hole_definition] {
                    if {[info exists entCount($ent)]} {
                      lappend syntaxErr($ent) [list $defID "countersink_diameter" $msg]
                      lappend syntaxErr($ent) [list $defID "drilled_hole_diameter" $msg]
                    }
                  }
                }
                if {[info exists drillDep]} {
                  if {$sinkDep >= $drillDep} {
                    set msg "Syntax Error: $holeType computed 'depth' >= drill depth"
                    errorMsg $msg
                    foreach ent [list $holeType\_hole_definition simplified_$holeType\_hole_definition] {
                      if {[info exists entCount($ent)]} {lappend syntaxErr($ent) [list $defID "drilled_hole_depth" $msg]}
                    }
                  }
                }

                if {[lsearch $holeDEF $defID] == -1} {
                  puts $x3dFile "$transform<Group DEF='$holeName$defID'>"
                  if {[info exists drillDep]} {
                    puts $x3dFile " <Transform rotation='1 0 0 1.5708' translation='0 0 [trimNum [expr {($drillDep+$sinkDep)*0.5}] 5]'>"
                    puts $x3dFile "  <Shape><Cylinder radius='$drillRad' height='[trimNum [expr {$drillDep-$sinkDep}] 5]' top='$holeTop' bottom='false' solid='false'></Cylinder><Appearance><Material diffuseColor='0 1 1'/></Appearance></Shape></Transform>"
                  }
                  puts $x3dFile " <Transform rotation='1 0 0 1.5708' translation='0 0 [trimNum [expr {$sinkDep*0.5}] 5]'>"
                  puts $x3dFile "  <Shape><Cone bottomRadius='$sinkRad' topRadius='$drillRad' height='[trimNum $sinkDep 5]' top='false' bottom='false' solid='false'></Cone><Appearance><Material diffuseColor='0 1 1'/></Appearance></Shape></Transform>"
                  puts $x3dFile "</Group></Transform>"
                  lappend holeDEF $defID
                } else {
                  puts $x3dFile "$transform<Group USE='$holeName$defID'></Group></Transform>"
                }

# counterbore or spotface hole (2 cylinders, flat cone)
              } elseif {$holeType == "counterbore" || $holeType == "spotface"} {
                set bore [lindex $holeDefinitions($defID) 1]
                set boreRad [expr {[lindex $bore 1]*0.5*$scale}]
                set boreDep [expr {[lindex $bore 2]*$scale}]

# check for bad radius and depth
                if {$boreRad <= $drillRad} {
                  set msg "Syntax Error: $holeType diameter <= drill diameter"
                  errorMsg $msg
                  foreach ent [list $holeType\_hole_definition simplified_$holeType\_hole_definition] {
                    if {[info exists entCount($ent)]} {
                      lappend syntaxErr($ent) [list $defID "counterbore" $msg]
                      lappend syntaxErr($ent) [list $defID "drilled_hole_diameter" $msg]
                    }
                  }
                }
                if {[info exists drillDep]} {
                  if {$boreDep >= $drillDep} {
                    set msg "Syntax Error: $holeType depth >= drill depth"
                    errorMsg $msg
                    foreach ent [list $holeType\_hole_definition simplified_$holeType\_hole_definition] {
                      if {[info exists entCount($ent)]} {
                        lappend syntaxErr($ent) [list $defID "counterbore" $msg]
                        lappend syntaxErr($ent) [list $defID "drilled_hole_depth" $msg]
                      }
                    }
                  }
                }

                if {[lsearch $holeDEF $defID] == -1} {
                  puts $x3dFile "$transform<Group DEF='$holeName$defID'>"
                  if {[info exists drillDep]} {
                    puts $x3dFile " <Transform rotation='1 0 0 1.5708' translation='0 0 [trimNum [expr {($drillDep+$boreDep)*0.5}] 5]'>"
                    puts $x3dFile "  <Shape><Cylinder radius='$drillRad' height='[trimNum [expr {$drillDep-$boreDep}] 5]' top='$holeTop' bottom='false' solid='false'></Cylinder><Appearance><Material diffuseColor='0 1 0'/></Appearance></Shape></Transform>"
                  }
                  puts $x3dFile " <Transform rotation='1 0 0 1.5708' translation='0 0 [trimNum $boreDep 5]'>"
                  puts $x3dFile "  <Shape><Cone bottomRadius='$boreRad' topRadius='$drillRad' height='0.001' top='false' bottom='false' solid='false'></Cone><Appearance><Material diffuseColor='0 1 0'/></Appearance></Shape></Transform>"
                  puts $x3dFile " <Transform rotation='1 0 0 1.5708' translation='0 0 [trimNum [expr {$boreDep*0.5}] 5]'>"
                  puts $x3dFile "  <Shape><Cylinder radius='$boreRad' height='[trimNum $boreDep 5]' top='false' bottom='false' solid='false'></Cylinder><Appearance><Material diffuseColor='0 1 0'/></Appearance></Shape></Transform>"
                  puts $x3dFile "</Group></Transform>"
                  lappend holeDEF $defID
                } else {
                  puts $x3dFile "$transform<Group USE='$holeName$defID'></Group></Transform>"
                }

# basic round hole
              } elseif {$holeType == "round_hole"} {
                set hole [lindex $holeDefinitions($defID) 0]
                set holeRad [expr {[lindex $hole 1]*0.5*$scale}]
                if {[lindex $hole 2] != ""} {
                  set holeDep [expr {[lindex $hole 2]*$scale}]
                } else {
                  set holeDep [expr {[lindex $hole 1]*0.01*$scale}]
                }
                if {[lsearch $holeDEF $defID] == -1} {
                  puts $x3dFile "$transform<Group DEF='$holeName$defID'>"
                  if {!$thruHole && [lindex $hole 2] != ""} {
                    puts $x3dFile " <Transform rotation='1 0 0 1.5708' translation='0 0 [trimNum $holeDep 5]'>"
                    puts $x3dFile "  <Shape><Cone bottomRadius='$holeRad' topRadius='0' height='0.001' top='false' bottom='false' solid='false'></Cone><Appearance><Material diffuseColor='0 1 0'/></Appearance></Shape></Transform>"
                  }
                  puts $x3dFile " <Transform rotation='1 0 0 1.5708' translation='0 0 [trimNum [expr {$holeDep*0.5}] 5]'>"
                  puts $x3dFile "  <Shape><Cylinder radius='$holeRad' height='[trimNum $holeDep 5]' top='false' bottom='false' solid='false'></Cylinder><Appearance><Material diffuseColor='0 1 0'/></Appearance></Shape></Transform>"
                  puts $x3dFile "</Group></Transform>"
                  lappend holeDEF $defID
                } else {
                  puts $x3dFile "$transform<Group USE='$holeName$defID'></Group></Transform>"
                }
              }
            }
          } elseif {!$opt(PMISEM) || $gen(None)} {
            errorMsg " Only hole drill entry points are shown when the Analyzer report for Semantic PMI is not selected."
            if {[lsearch $holeDEF $defID] == -1} {lappend holeDEF $defID}
          }

# point at origin of hole
          set e4 [[[$e3 Attributes] Item [expr 2]] Value]
          if {![info exists thruHole]} {set thruHole 0}
          x3dSuppGeomPoint $e4 $drillPoint $thruHole $holeName
        }
      }
    } emsg]} {
      errorMsg "Error adding 'hole' geometry: $emsg"
    }
  }
  if {$viz(HOLE)} {puts $x3dFile "</Group></Switch>\n"}
  catch {unset holeDefinitions}

  set ok 0
  if {![info exists entCount(item_identified_representation_usage)]} {set ok 1} elseif {$entCount(item_identified_representation_usage) == 0} {set ok 1}
  if {$ok} {errorMsg "Syntax Error: Missing IIRU to link hole with explicit geometry.$spaces\($recPracNames(holes), Sec. 5.1.1.2)"}
}

# -------------------------------------------------------------------------------
# placeholder axes, coordinates, text, box, leader line
proc x3dPlaceholder {{aoname ""} {fname ""}} {
  global grayBackground leaderCoords maxxyz minview x3dFile
  global placeAxes placeAxesDef placeBox placeCoords placeNames placeSize placeSphereDef placeSymbol
  global savedPlaceFile savedPlaceFileName savedViewFile savedViewFileName

  if {$aoname == ""} {
    puts $x3dFile "\n<!-- PLACEHOLDER -->"
    puts $x3dFile "<Switch whichChoice='0' id='swPlaceholder'><Group>"
    set pcnames [array names placeCoords]
  } else {
    set pcnames [list $aoname]
  }

# no saved views
  if {$fname == ""} {
    set fname $x3dFile
    set nview -1
    set minview 0
  } else {

# get minimum view number for def and use below
    if {![info exists minview]} {
      set minview 10000
      foreach name [array names savedViewFile] {
        set fn $savedViewFileName($name)
        set n [string range $fn [string first "View" $fn]+4 [string first ".txt" $fn]-1]
        if {$n < $minview} {set minview $n}
      }
    }

# open file for placeholders per saved view
    foreach name [array names savedViewFile] {
      if {$savedViewFile($name) == $fname} {
        regsub "View" $savedViewFileName($name) "Place" fn
        set name2 [string range $fn [string first "Place" $fn] [string first ".txt" $fn]-1]
        if {![file exists $fn]} {
          set savedPlaceFile($name2) [open $fn w]
          set savedPlaceFileName($name2) $fn
          lappend placeNames $name2
        }
      }
    }
    set fname $savedPlaceFile($name2)
    set nview [string range $name2 5 end]
  }
  if {[info exists maxxyz] && $aoname == ""} {
    set size1 [trimNum [expr {$maxxyz/1000.}]]
    set size2 [trimNum [expr {$size1*6.}]]
    set size3 [trimNum [expr {$size2*0.67}]]
  } else {
    set size1 "placeSize1"
    set size2 "placeSize2"
    set size3 "placeSize3"
    set placeSize 1
  }

# placeholder coordinates
  foreach name $pcnames {
    if {[catch {
      foreach coord [lrmdups $placeCoords($name)] {
        puts $fname "<Transform id='PH $name' translation='$coord'><Group>"

# axes
        set transform [x3dTransform "0. 0. 0." $placeAxes($name,axis) $placeAxes($name,refdir) "placeholder"]
        if {[info exists placeAxesDef] || $nview > $minview} {
          puts $fname " $transform<Group USE='placeAxes'></Group></Transform>"
        } else {
          puts $fname " $transform<Group DEF='placeAxes'>"
          puts $fname "  <Shape><Appearance><Material emissiveColor='1 0 0'/></Appearance><IndexedLineSet coordIndex='0 1 -1'><Coordinate point='0. 0. 0. $size2 0. 0.'/></IndexedLineSet></Shape>"
          puts $fname "  <Shape><Appearance><Material emissiveColor='0 .5 0'/></Appearance><IndexedLineSet coordIndex='0 1 -1'><Coordinate point='0. 0. 0. 0. $size2 0.'/></IndexedLineSet></Shape>"
          puts $fname "  <Shape><Appearance><Material emissiveColor='0 0 1'/></Appearance><IndexedLineSet coordIndex='0 1 -1'><Coordinate point='0. 0. 0. 0. 0. $size2'/></IndexedLineSet></Shape>"
          puts $fname " </Group></Transform>"
          set placeAxesDef 1
        }

# coordinate sphere and text
        set bbtext "<Transform scale='$size2 $size2 $size2'><Billboard axisOfRotation='0 0 0'><Shape><Text string='$name'><FontStyle family='SANS' justify='BEGIN'/></Text><Appearance><Material diffuseColor='0 0 0'/></Appearance></Shape></Billboard></Transform>"
        if {[info exists placeSphereDef] || $nview > $minview} {
          puts $fname " <Shape USE='placeSphere'></Shape>$bbtext"
        } else {
          puts $fname " <Shape DEF='placeSphere'><Appearance><Material diffuseColor='0 0 0' emissiveColor='0 0 0' transparency='0.5'/></Appearance><Sphere radius='$size1'></Sphere></Shape>"
          puts $fname " $bbtext"
          set placeSphereDef 1
        }

# planar box
        if {[info exists placeBox($name,x)]} {
          set boxCoord "0 [expr {-0.5*$placeBox($name,y)}] 0 $placeBox($name,x) [expr {-0.5*$placeBox($name,y)}] 0 0 [expr {0.5*$placeBox($name,y)}] 0 $placeBox($name,x) [expr {0.5*$placeBox($name,y)}] 0"
          set boxIndex "0 1 3 2 0 -1"
          puts $fname " $transform"
          puts $fname "  <Shape><Appearance><Material emissiveColor='1 1 0'/></Appearance><IndexedLineSet coordIndex='$boxIndex'><Coordinate point='$boxCoord'/></IndexedLineSet></Shape>"
          puts $fname " </Transform>"
          set grayBackground 1
        }
        puts $fname "</Group></Transform>"
      }
    } emsg]} {
      errorMsg "Error adding PMI Placeholder geometry: $emsg"
    }
  }

# leader line coordinates and line
  if {[info exists leaderCoords]} {
    set grayBackground 1
    if {[catch {
      if {$aoname == ""} {
        if {![info exists placeCoords]} {
          puts $fname "\n<!-- PLACEHOLDER Leader Lines -->"
          puts $fname "<Switch whichChoice='0' id='swPlaceholder'><Group>"
        }
        set lcnames [array names leaderCoords]
      } else {
        set lcnames [list $aoname]
      }

# get coordinates for leader lines
      foreach name $lcnames {
        if {[info exists leaderCoords($name)]} {
          foreach crd $leaderCoords($name) {
            set coord [string range $crd 0 [string last " " $crd]-1]
            set leaderID [string range $crd [string last " " $crd]+1 end]
            lappend leaderLine($leaderID) $coord
            set leaderName($leaderID) $name
          }
        }
      }

# leader lines
      foreach id [array names leaderLine] {
        set name $leaderName($id)
        set index ""
        for {set i 0} {$i < [llength $leaderLine($id)]} {incr i} {append index "$i "}
        append index "-1"
        puts $fname "<Shape id='LL $name'><Appearance><Material emissiveColor='1 1 0'/></Appearance><IndexedLineSet coordIndex='$index'><Coordinate point='[join $leaderLine($id)]'/></IndexedLineSet></Shape>"

# text at first and last point
        foreach idx [list 0 [expr {[llength $leaderLine($id)]-1}]] {
          set coord [join [lindex $leaderLine($id) $idx]]
          puts $fname "<Transform translation='$coord' scale='$size2 $size2 $size2'><Billboard axisOfRotation='0 0 0'><Shape><Text string='$name'><FontStyle family='SANS' justify='BEGIN'/></Text><Appearance><Material diffuseColor='0 0 0'/></Appearance></Shape></Billboard></Transform>"
        }

# check for symbols
        foreach coord $leaderLine($id) {
          if {[info exists placeSymbol($coord)]} {
            set sym $placeSymbol($coord)
            if {[string first "internal" $sym] == 0} {set sym [string range $sym 14 end]}
            puts $fname "<Transform translation='$coord' scale='$size3 $size3 $size3'><Billboard axisOfRotation='0 0 0'><Shape><Text string='$sym'><FontStyle family='SANS' justify='END'/></Text><Appearance><Material diffuseColor='0 0 1'/></Appearance></Shape></Billboard></Transform>"
            unset placeSymbol($coord)
          }
        }
      }
    } emsg]} {
      errorMsg "Error adding PMI Placeholder leader lines: $emsg"
    }
  }

# end
  if {$aoname == ""} {
    puts $fname "</Group></Switch>"
  } else {
    catch {unset placeCoords($aoname)}
    catch {unset leaderCoords($aoname)}
  }
}

# -------------------------------------------------------------------------------
# composite rosette cartesian_11 (curve_11 is handled by stp2x3d and processed in sfa-part.tcl)
proc x3dComposites {} {
  global entCount grayBackground maxxyz rosetteGeom viz x3dFile
  global objDesign

  if {![info exists rosetteGeom]} {set rosetteGeom 0}
  set entType "axis2_placement_3d_and_cartesian_11"
  if {[info exists entCount($entType)]} {
    if {$entCount($entType) > 0} {
      set viz(COMPOSITES) 1
      set grayBackground 1

# rosetteGeom: 1=curve, 2=axis, 3=both
      set rosetteGeom [expr {$rosetteGeom+2}]
      puts $x3dFile "\n<!-- COMPOSITES cartesian_11 -->"
      puts $x3dFile "<Switch whichChoice='0' id='swComposites'><Group>"
      if {[catch {
        ::tcom::foreach ent [$objDesign FindObjects [join $entType]] {
          set a2p3d [x3dGetA2P3D $ent]
          set transform [x3dTransform [lindex $a2p3d 0] [lindex $a2p3d 1] [lindex $a2p3d 2] "composites rosette"]
          puts $x3dFile $transform
          set size [trimNum [expr {$maxxyz*0.03}]]
          set size1 [trimNum [expr {0.25*$size}]]
          set size2 [trimNum [expr {0.7*$size}]]
          set points "0. 0. 0. $size 0. 0. 0. $size 0. $size2 $size2 0. $size2 -$size2 0."
          puts $x3dFile " <Shape><Appearance><Material emissiveColor='1 1 1'/></Appearance><IndexedLineSet coordIndex='0 1 -1 0 2 -1 0 3 -1 0 4 -1'><Coordinate point='$points'/></IndexedLineSet></Shape>"
          puts $x3dFile " <Transform translation='$size 0. 0.' scale='$size1 $size1 $size1'><Billboard axisOfRotation='0 0 0'><Shape><Text string='0'><FontStyle family='SANS' justify='BEGIN'/></Text><Appearance><Material diffuseColor='1 1 1'/></Appearance></Shape></Billboard></Transform>"
          puts $x3dFile " <Transform translation='0. $size 0.' scale='$size1 $size1 $size1'><Billboard axisOfRotation='0 0 0'><Shape><Text string='90'><FontStyle family='SANS' justify='BEGIN'/></Text><Appearance><Material diffuseColor='1 1 1'/></Appearance></Shape></Billboard></Transform>"
          puts $x3dFile " <Transform translation='$size2 $size2 0.' scale='$size1 $size1 $size1'><Billboard axisOfRotation='0 0 0'><Shape><Text string='45'><FontStyle family='SANS' justify='BEGIN'/></Text><Appearance><Material diffuseColor='1 1 1'/></Appearance></Shape></Billboard></Transform>"
          puts $x3dFile " <Transform translation='$size2 -$size2 0.' scale='$size1 $size1 $size1'><Billboard axisOfRotation='0 0 0'><Shape><Text string='-45'><FontStyle family='SANS' justify='BEGIN'/></Text><Appearance><Material diffuseColor='1 1 1'/></Appearance></Shape></Billboard></Transform>"
          puts $x3dFile "</Transform>"
        }
      } emsg]} {
        errorMsg "Error adding Composite Rosette: $emsg"
      }
      puts $x3dFile "</Group></Switch>"
    }
  }
}

# -------------------------------------------------------------------------------
# write clipping plane
proc x3dClipPlane {shapeClipping cpname} {
  global clipPlaneName nclipPlane viz x3dFile

  if {[catch {
    if {[$shapeClipping Type] == "plane"} {

# get normal to the plane
      set e0 [[[$shapeClipping Attributes] Item [expr 2]] Value]
      set a2p3d [x3dGetA2P3D $e0]
      set clipplane [join [vectrim [vecmult [lindex $a2p3d 1] -1.] 8]]

# compute plane offset
      set dot [vecdot [lindex $a2p3d 0] [lindex $a2p3d 1]]
      set offset [trimNum [expr {$dot+0.002}] 8]
      append clipplane " $offset"

# write clipping plane
      incr nclipPlane
      if {$cpname == ""} {set cpname "Plane $nclipPlane"}
      set clipPlaneName($nclipPlane) $cpname

# ClipPlane does the clipping in x3d
      puts $x3dFile "<ClipPlane enabled='false' plane='$clipplane' id='swClipPlane$nclipPlane'></ClipPlane>"

# plane that represents the position and orientation of the plane
      puts $x3dFile "<Switch whichChoice='-1' id='swClipping$nclipPlane'><Group>"
      x3dSuppGeomPlane $shapeClipping 1. "clipping plane" $clipPlaneName($nclipPlane)
      puts $x3dFile "</Group></Switch>"
      set viz(CLIPPING) 1

    } else {
      errorMsg " Unknown type of Clipping Plane '[$shapeClipping Type]'"
    }
  } emsg]} {
    errorMsg "Error generating Clipping Plane: $emsg"
  }
}

# -------------------------------------------------------------------------------
# write coordinate axes
proc x3dCoordAxes {size} {
  global viz x3dAxes x3dFile

  set choice 0
  catch {if {$viz(SUPPGEOM)} {set choice -1}}
  catch {if {$viz(COMPOSITES)} {set choice -1}}

# axes
  if {$x3dAxes} {
    puts $x3dFile "\n<!-- COORDINATE AXIS -->\n<Switch whichChoice='$choice' id='swAxes'><Group>"
    puts $x3dFile "<Shape><Appearance><Material emissiveColor='1 0 0'/></Appearance><IndexedLineSet coordIndex='0 1 -1'><Coordinate point='0 0 0 $size 0 0'/></IndexedLineSet></Shape>"
    puts $x3dFile "<Shape><Appearance><Material emissiveColor='0 .5 0'/></Appearance><IndexedLineSet coordIndex='0 1 -1'><Coordinate point='0 0 0 0 $size 0'/></IndexedLineSet></Shape>"
    puts $x3dFile "<Shape><Appearance><Material emissiveColor='0 0 1'/></Appearance><IndexedLineSet coordIndex='0 1 -1'><Coordinate point='0 0 0 0 0 $size'/></IndexedLineSet></Shape>"

# xyz labels
    set tsize [trimNum [expr {$size*0.33}]]
    puts $x3dFile "<Transform translation='$size 0 0' scale='$tsize $tsize $tsize'><Billboard axisOfRotation='0 0 0'><Shape><Appearance><Material diffuseColor='1 0 0'/></Appearance><Text string='X'><FontStyle family='SANS'/></Text></Shape></Billboard></Transform>"
    puts $x3dFile "<Transform translation='0 $size 0' scale='$tsize $tsize $tsize'><Billboard axisOfRotation='0 0 0'><Shape><Appearance><Material diffuseColor='0 .5 0'/></Appearance><Text string='Y'><FontStyle family='SANS'/></Text></Shape></Billboard></Transform>"
    puts $x3dFile "<Transform translation='0 0 $size' scale='$tsize $tsize $tsize'><Billboard axisOfRotation='0 0 0'><Shape><Appearance><Material diffuseColor='0 0 1'/></Appearance><Text string='Z'><FontStyle family='SANS'/></Text></Shape></Billboard></Transform>"

# credits
    set tsize1 [trimNum [expr {$tsize*0.05}] 3]
    puts $x3dFile "<Transform scale='$tsize1 $tsize1 $tsize1'><Billboard axisOfRotation='0 0 0'><Shape><Text string='\"Generated by the\",\"NIST STEP File Analyzer and Viewer [getVersion]\"'><FontStyle family='SANS'/></Text><Appearance><Material diffuseColor='0 0 0'/></Appearance></Shape></Billboard></Transform>"

# marker for selection point
    puts $x3dFile "\n<!-- SELECTION POINT -->"
    puts $x3dFile "<Transform id='marker'><Shape><PointSet><Coordinate point='0 0 0'/></PointSet></Shape></Transform>"
    puts $x3dFile "</Group></Switch>"
    set x3dAxes 0
  }
}

# -------------------------------------------------------------------------------
# write wireframe mesh for tessellated geometry
proc x3dWireframeMesh {} {
  global npart meshlines x3dFile

  if {[catch {
    set m 0
    set shape ""
    set coord ""
    set index ""
    set group 1

# group indexes into one
    foreach mline $meshlines {
      incr m
      if {$m == 1} {
        append shape $mline
      } elseif {[expr {$m%2}] == 0} {
        set c1 [string first "'" $mline]
        set c2 [string first "'" $mline $c1+1]
        append index "[string range $mline $c1+1 $c2-1] "
        set str [string range $mline $c2+1 end]
        if {$coord == ""} {
          set coord $str
        } elseif {$str != $coord} {
          set group 0
          break
        }
      }
    }

    foreach xf $x3dFile {
      if {$group} {puts $xf "<!-- Wireframe mesh -->"}
      puts $xf "<Switch id='swTessMesh$npart(TESSPART)' whichChoice='0'><Group>"
      if {$group} {
        puts $xf "$shape\n <IndexedLineSet coordIndex='$index'$coord"
      } else {
        foreach mline $meshlines {puts $xf $mline}
      }
      puts $xf "</Group></Switch>"
    }
  } emsg]} {
    errorMsg "Error writing wireframe mesh: $emsg"
  }
}

# -------------------------------------------------------------------------------
# script for switch node
proc x3dSwitchScript {name {name1 ""}} {
  global clippingCap nclipPlane placeNames rosetteGeom savedViewNames viz x3dFile

# clipping planes
  if {$name == "Clipping"} {
    for {set i 1} {$i <= $nclipPlane} {incr i} {
      puts $x3dFile "\n<!-- Clipping$i switch -->\n<script>function togClipping$i\(choice)\{"
      puts $x3dFile " document.getElementById('swClipping$i').checked = !document.getElementById('swClipping$i').checked;"
      puts $x3dFile " if (!document.getElementById('swClipping$i').checked) \{"
      puts $x3dFile "  document.getElementById('swClipping$i').setAttribute('whichChoice', -1);"
      puts $x3dFile "  document.getElementById('swClipPlane$i').setAttribute('enabled', 'false');"
      if {$clippingCap} {puts $x3dFile "  try \{document.getElementById('swClippingCap$i').setAttribute('whichChoice', -1);\} catch \{\}"}
      puts $x3dFile " \} else \{"
      puts $x3dFile "  document.getElementById('swClipping$i').setAttribute('whichChoice', 0);"
      puts $x3dFile "  document.getElementById('swClipPlane$i').setAttribute('enabled', 'true');"
      if {$clippingCap} {puts $x3dFile "  try \{document.getElementById('swClippingCap$i').setAttribute('whichChoice', 0);\} catch \{\}"}
      puts $x3dFile " \}\n\}</script>"
    }
    unset clippingCap
    unset nclipPlane

# not parts
  } elseif {[string first "Part" $name] != 0 && [string first "TessPart" $name] != 0} {

# adjust for saved views
    if {$name1 == ""} {set name1 $name}
    set viewName ""
    if {[string first "View" $name] == 0} {
      set viewName " [lindex $savedViewNames [string range $name end end]]"
      if {$name1 != ""} {set name1 "View[lsearch $savedViewNames $name1]"}
    }

# controls if checking/unchecking box is before or after changing whichChoice
    set ok 1
    if {$name == "Axes"} {
      catch {if {$viz(SUPPGEOM)} {set ok 0}}
      catch {if {$viz(COMPOSITES)} {set ok 0}}
    }
    if {$name == "Bbox"} {set ok 0}

    if {($name != "Composites" || $rosetteGeom >= 2) && $name != "Placeholder"} {
      if {[string first "TessMesh" $name] == -1} {puts $x3dFile "\n<!-- $name$viewName switch -->\n<script>function tog$name\(choice)\{"}
      if {!$ok} {puts $x3dFile " document.getElementById('sw$name').checked = !document.getElementById('sw$name').checked;"}
      puts $x3dFile " if (!document.getElementById('sw$name').checked) \{document.getElementById('sw$name1').setAttribute('whichChoice', -1);\} else \{document.getElementById('sw$name1').setAttribute('whichChoice', 0);\}"
      if {$ok}  {puts $x3dFile " document.getElementById('sw$name').checked = !document.getElementById('sw$name').checked;"}
    }

    if {$name == "Placeholder"} {
      puts $x3dFile "\n<!-- $name$viewName switch -->\n<script>function tog$name\(choice)\{"
      if {![info exists placeNames]} {
        puts $x3dFile " if (!document.getElementById('sw$name').checked) \{document.getElementById('sw$name1').setAttribute('whichChoice', -1);\} else \{document.getElementById('sw$name1').setAttribute('whichChoice', 0);\}"
        puts $x3dFile " document.getElementById('sw$name').checked = !document.getElementById('sw$name').checked;"
      } else {
        foreach pname $placeNames {
          puts $x3dFile " if (!document.getElementById('sw$pname').checked) \{document.getElementById('sw$pname').setAttribute('whichChoice', -1);\} else \{document.getElementById('sw$pname').setAttribute('whichChoice', 0);\}"
          puts $x3dFile " document.getElementById('sw$pname').checked = !document.getElementById('sw$pname').checked;"
        }
        unset placeNames
      }
    }

# composite rosettes (rosetteGeom: 1=curve, 2=axis, 3=both)
    if {$name == "Composites" && ($rosetteGeom == 1 || $rosetteGeom == 3)} {
      if {$rosetteGeom == 1} {puts $x3dFile "\n<!-- $name$viewName switch -->\n<script>function tog$name\(choice)\{"}
      if {!$ok} {puts $x3dFile " document.getElementById('swComposites1').checked = !document.getElementById('swComposites1').checked;"}
      puts $x3dFile " if (!document.getElementById('swComposites1').checked) \{document.getElementById('swComposites1').setAttribute('whichChoice', -1);\} else \{document.getElementById('swComposites1').setAttribute('whichChoice', 0);\}"
      if {$ok}  {puts $x3dFile " document.getElementById('swComposites1').checked = !document.getElementById('swComposites1').checked;"}
    }
    if {[string first "TessMesh" $name] == -1} {puts $x3dFile "\}</script>"}

# parts
  } else {
    set c1 [string first "Part" $name]
    set ids [string range $name $c1+4 end]
    set name1 [string range $name 0 $c1+3]

    puts $x3dFile "\n<!-- $name switch -->\n<script>function tog$name1[lindex $ids 0]\(choice)\{"
    if {[llength $ids] == 1} {
      puts $x3dFile " if (!document.getElementById('sw$name').checked) \{document.getElementById('sw$name').setAttribute('whichChoice', -1);\} else \{document.getElementById('sw$name').setAttribute('whichChoice', 0);\}"
      puts $x3dFile " document.getElementById('sw$name').checked = !document.getElementById('sw$name').checked;"
      puts $x3dFile " document.getElementById('cb$name').checked = !document.getElementById('sw$name').checked;\n\}</script>"
    } else {
      puts $x3dFile " if (!document.getElementById('sw$name1[lindex $ids 0]').checked) \{"
      foreach id $ids {puts $x3dFile "  document.getElementById('sw$name1$id').setAttribute('whichChoice', -1);"}
      puts $x3dFile " \} else \{"
      foreach id $ids {puts $x3dFile "  document.getElementById('sw$name1$id').setAttribute('whichChoice', 0);"}
      puts $x3dFile " \}"
      puts $x3dFile " document.getElementById('sw$name1[lindex $ids 0]').checked = !document.getElementById('sw$name1[lindex $ids 0]').checked;"
      puts $x3dFile " document.getElementById('cb$name1[lindex $ids 0]').checked = !document.getElementById('sw$name1[lindex $ids 0]').checked;\n\}</script>"
    }
  }
}

# -------------------------------------------------------------------------------
# part checkboxes
proc x3dPartCheckbox {type} {
  global parts partstg x3dFile x3dHeight x3dParts x3dTessParts x3dWidth

  switch -- $type {
    Part {
      set name "Assembly/Part"
      set tog "togPart"
      catch {unset parts}
      foreach idx [array names x3dParts] {set parts($idx) $x3dParts($idx)}
      set arparts [array names parts]
    }
    Tess {
      set name "Tessellated Parts"
      set tog "togTessPart"
      catch {unset partstg}
      foreach idx [array names x3dTessParts] {set partstg($idx) $x3dTessParts($idx)}
      set arparts [array names partstg]
    }
  }

  set txt ""
  set nparts [llength $arparts]
  if {$nparts > 2} {set txt "&nbsp;&nbsp;<button onclick='$tog\All\(this.value)'>Show/Hide</button>"}
  puts $x3dFile "\n<!-- $name checkboxes -->\n<p>$name$txt\n<br><font size='-1'>"

  set lenname 0
  foreach name $arparts {if {[string length $name] > $lenname} {set lenname [string length $name]}}
  set div ""
  set max 30
  if {$nparts > $max || $lenname > $max} {
    append div "<style>div.$type \{overflow: scroll;"
    if {$lenname > $max} {append div " width: [expr {int($x3dWidth*.15)}]px;"}
    if {$nparts > $max} {append div " height: [expr {int($x3dHeight*.6)}]px;"}
    append div "\}</style>"
  }
  if {$div != ""} {puts $x3dFile "$div\n<div class='$type'>"}
  foreach name [lsort -nocase $arparts] {
    switch -- $type {
      Part {set pname [lindex $parts($name) 0]}
      Tess {set pname [lindex $partstg($name) 0]}
    }
    puts $x3dFile "<nobr><input id='cb[string range $tog 3 end]$pname' type='checkbox' checked onclick='$tog$pname\(this.value)'/>$name </nobr><br>"
  }
  if {$div != ""} {puts $x3dFile "</div>"}
  puts $x3dFile "</font>"
}

# -------------------------------------------------------------------------------
# set predefined color
proc x3dPreDefinedColor {name} {
  global defaultColor recPracNames spaces

  switch -- $name {
    black   {set color "0 0 0"}
    white   {set color "1 1 1"}
    red     {set color "1 0 0"}
    yellow  {set color "1 1 0"}
    green   {set color "0 1 0"}
    cyan    {set color "0 1 1"}
    blue    {set color "0 0 1"}
    magenta {set color "1 0 1"}
    default {
      set color $defaultColor
      errorMsg "Syntax Error: draughting_pre_defined_colour name '$name' is not supported$spaces\($recPracNames(model), Sec. 4.2.3, Table 2)"
    }
  }
  return $color
}

# -------------------------------------------------------------------------------
# get A2P3D origin, axis, refdir
proc x3dGetA2P3D {e0 {type ""}} {

  set origin "0 0 0"
  set axis   "0 0 1"
  set refdir "1 0 0"
  set debug 0
  set prec 4
  if {[string first "clipping" $type] != -1} {set prec 8}

# a2p3d origin
  set a2 [[$e0 Attributes] Item [expr 2]]
  set e2 [$a2 Value]
  if {$e2 != ""} {
    set origin [vectrim [[[$e2 Attributes] Item [expr 2]] Value] $prec]
    if {$debug} {errorMsg "      [$e2 Type] [$e2 P21ID] ([$a2 Name]) $origin" red}
  }

# a2p3d axis
  set a3 [[$e0 Attributes] Item [expr 3]]
  set e3 [$a3 Value]
  if {$e3 != ""} {
    set axis [[[$e3 Attributes] Item [expr 2]] Value]
    if {$debug} {errorMsg "      [$e3 Type] [$e3 P21ID] ([$a3 Name]) $axis" red}
  }

# a2p3d reference direction
  set a4 [[$e0 Attributes] Item [expr 4]]
  set e4 [$a4 Value]
  if {$e4 != ""} {
    set refdir [[[$e4 Attributes] Item [expr 2]] Value]
    if {$debug} {errorMsg "      [$e4 Type] [$e4 P21ID] ([$a4 Name]) $refdir" red}

# if refdir not specified, do not use default 1 0 0 if axis is 1 0 0
  } elseif {$axis == "1.0 0.0 0.0"} {
    set refdir "0 0 1"
  }
  return [list $origin $axis $refdir]
}

# -------------------------------------------------------------------------------
# generate transform
proc x3dTransform {origin axis refdir {text ""} {scale ""} {id ""}} {

  set transform "<Transform"
  if {$id != ""} {append transform " id='$id'"}
  if {$origin != "0. 0. 0."} {append transform " translation='$origin'"}

# get rotation from axis and refdir
  set rot [x3dGetRotation $axis $refdir $text]
  if {[lindex $rot 3] != 0} {append transform " rotation='$rot'"}
  if {$scale != ""} {append transform " scale='$scale'"}
  append transform ">"
  return $transform
}

# -------------------------------------------------------------------------------
# generate x3d rotation (axis angle format) from axis2_placement_3d, OR directly from rotation matrix
proc x3dGetRotation {axis refdir {type ""} {rotmat ""}} {

  set rprec 4
  if {[string first "clipping" $type] != -1} {set rprec 8}

  if {$rotmat == ""} {
# specified with axis and refdir, check if one of the vectors is zero length, i.e., '0 0 0'
    set msg ""
    if {[veclen $axis] == 0 || [veclen $refdir] == 0} {
      set msg "Syntax Error: The axis2_placement_3d axis or ref_direction vector is '0 0 0'"
      if {$type != ""} {append msg " for a $type"}
      append msg "."

# check if axis and refdir are parallel
    } elseif {[veclen [veccross $axis $refdir]] == 0} {
      set msg "Syntax Error: The axis2_placement_3d axis and ref_direction vectors '$refdir' are parallel"
      if {$type != ""} {append msg " for a $type"}
      append msg "."
    }
    if {$msg != "" && [string first "counter" $msg] == -1 && [string first "hole" $msg] == -1} {errorMsg $msg}

# construct rotation matrix u, must normalize to use with quaternion
    set u3 [vecnorm $axis]
    set u1 [vecnorm [vecsub $refdir [vecmult $u3 [vecdot $refdir $u3]]]]
    set u2 [vecnorm [veccross $u3 $u1]]

# specified with rotation matrix (list of 9 values)
  } else {
    set u1 [vecnorm [join [lrange $rotmat 0 2]]]
    set u2 [vecnorm [join [lrange $rotmat 3 5]]]
    set u3 [vecnorm [join [lrange $rotmat 6 8]]]
  }

# extract quaternion
  if {[lindex $u1 0] >= 0.0} {
    set tmp [expr {[lindex $u2 1] + [lindex $u3 2]}]
    if {$tmp >=  0.0} {
      set q(0) [expr {[lindex $u1 0] + $tmp + 1.}]
      set q(1) [expr {[lindex $u3 1] - [lindex $u2 2]}]
      set q(2) [expr {[lindex $u1 2] - [lindex $u3 0]}]
      set q(3) [expr {[lindex $u2 0] - [lindex $u1 1]}]
    } else {
      set q(0) [expr {[lindex $u3 1] - [lindex $u2 2]}]
      set q(1) [expr {[lindex $u1 0] - $tmp + 1.}]
      set q(2) [expr {[lindex $u2 0] + [lindex $u1 1]}]
      set q(3) [expr {[lindex $u1 2] + [lindex $u3 0]}]
    }
  } else {
    set tmp [expr {[lindex $u2 1] - [lindex $u3 2]}]
    if {$tmp >= 0.0} {
      set q(0) [expr {[lindex $u1 2] - [lindex $u3 0]}]
      set q(1) [expr {[lindex $u2 0] + [lindex $u1 1]}]
      set q(2) [expr {1. - [lindex $u1 0] + $tmp}]
      set q(3) [expr {[lindex $u3 1] + [lindex $u2 2]}]
    } else {
      set q(0) [expr {[lindex $u2 0] - [lindex $u1 1]}]
      set q(1) [expr {[lindex $u1 2] + [lindex $u3 0]}]
      set q(2) [expr {[lindex $u3 1] + [lindex $u2 2]}]
      set q(3) [expr {1. - [lindex $u1 0] - $tmp}]
    }
  }

# normalize quaternion
  set lenq [expr {sqrt($q(0)*$q(0) + $q(1)*$q(1) + $q(2)*$q(2) + $q(3)*$q(3))}]
  if {$lenq != 0.} {
    foreach i {0 1 2 3} {set q($i) [expr {$q($i) / $lenq}]}
  } else {
    foreach i {0 1 2 3} {set q($i) 0.}
  }

# convert from quaterion to x3d rotation
  set rotation_changed {0 1 0 0}
  set angle [expr {acos($q(0))*2.0}]
  if {$angle != 0.} {
    set sina [expr {sin($angle*0.5)}]
    set axm 0.
    foreach i {0 1 2} {
      set i1 [expr {$i+1}]
      set ax [expr {-$q($i1) / $sina}]
      lset rotation_changed $i $ax
      set axa [expr {abs($ax)}]
      if {$axa > $axm} {set axm $axa}
    }
    if {$axm > 0. && $axm < 1.} {
      foreach i {0 1 2} {lset rotation_changed $i [expr {[lindex $rotation_changed $i]/$axm}]}
    }
    lset rotation_changed 3 $angle
    foreach i {0 1 2 3} {lset rotation_changed $i [trimNum [lindex $rotation_changed $i] $rprec]}
  }
  return $rotation_changed
}
