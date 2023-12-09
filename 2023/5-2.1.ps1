$InputData  = Get-Content .\5-1_input.txt
#$InputData  = Get-Content .\5-1_input_EXAMPLE.txt

# The parent array containing the groupings
# The first element is the Seeds list, and subsequent ones are the maps
$Maps       = [system.collections.generic.list[object]]@()

# Use this to build up the content of $Maps
$TempMap    = [system.collections.generic.list[array]]@()

# This will hold the seeds. Each element is an array: Start and End
$SeedBank   = [system.collections.generic.list[uint64[]]]@()

# Final result for the seeds
$FinalSeeds = [system.collections.generic.list[UInt64]]@()

foreach ($Line in $InputData) {
    
    # Find the boundaries with blank line
    if($Line.trim() -eq ""){

        # Only applicable to the first Seeds: line
        if($TempMap.count -eq 1) {
            # If we added the Seeds line, get rid of the description.
            $TempMap[0] = ($TempMap[0].trim() -split ":")[1].trim()
        }

        # Add another element to the parent array, and reset temp.
        $Maps.Add($TempMap)
        $TempMap = [system.collections.generic.list[array]]@()
    } 
    else {
        # We don't want to add the description as we'll be going down through each set of maps
        if (($Line -notmatch "^\w+-\w+-\w+\ map:$")) {
            
            if ($Line -match "^seeds:(\ |\d)+") {
                $SeedsLine = ($Line -split ":")[1].trim()
                $TempMap.Add( $SeedsLine )
            } else {
                $Line = $Line.Trim()
                $TempMap.Add( [uint64[]]($Line -split "\ ") )
            }
        }
    }
}

# Get our seed ranges, store them in the seed bank
# First value is start of range
# Second value is end of range
# Third value is map level at which the seed range was added
$SeedRanges = $Maps[0][1].trim() -split "\ "
for($SeedRange = 0; $SeedRange -lt $SeedRanges.count; $SeedRange += 2) {
    $SeedBank.Add(@(
        [uint64]$SeedRanges[$SeedRange],
        ([UInt64]$SeedRanges[$SeedRange] + [uint64]$SeedRanges[($SeedRange+1)]),
        1
    ))
}

$Count = 0
while ($Count -lt $SeedBank.count) {
    $SeedMapLevel   = $SeedBank[$Count][2]


    # Go through each map - start at the level where the map was 'dropped off'
    for ($Map = $SeedMapLevel; $Map -lt $Maps.Count; $Map++) {
        
        $SeedBank[$Count][2] = $Map
        
        # Let's get the start and end of the seeds
        $SeedStart      = $SeedBank[$Count][0]
        $SeedEnd        = $SeedBank[$Count][1]

        for ($MapLine = 1; $MapLine -lt $Maps[$Map].Count; $MapLine++) {
            
            # Lay out some obviously namd variables so I don't go crazy
            $MapDest    = $Maps[$Map][$Mapline][0]
            $MapStart   = $Maps[$Map][$Mapline][1]
            $MapEnd     = $MapStart + $Maps[$Map][$Mapline][2]
            
            # If the seedbank range is straddling the mapped start range
            if (($SeedStart -lt $MapStart) -and ($SeedEnd -ge $MapStart)) {
                # Create a new seedbank entry with the chopped-off start
                $SeedBank.Add(@(
                    $SeedStart,
                    ($MapStart-1),
                    $Map
                ))
                $SeedStart              = $MapStart
                $SeedBank[$Count][0]    = $MapStart
            }

            # If the seedbank range is straddling the mapped end range
            if (($SeedStart -le $MapEnd) -and ($SeedEnd -gt $MapEnd)) {
                # Create a new seedbank entry with the chopped-off end
                $SeedBank.Add(@(
                    ($MapEnd+1),
                    $SeedEnd,
                    $Map
                ))
                $SeedEnd                = $MapEnd
                $SeedBank[$Count][1]    = $MapEnd
            }

            # If we're between ranges we'll translate, otherwise we'll leave alone.
            if (($SeedStart -ge $MapStart) -and ($SeedEnd -le $MapEnd)) {
                $SeedBank[$Count][0] = $MapDest + ($SeedStart - $MapStart)
                $SeedBank[$Count][1] = $MapDest + ($SeedEnd - $MapStart)
                break # no point doing the rest of the lines if we've fallen into a match
            }
        }
    }

    $Count++
}

# Sort and find the lowest number
($SeedBank | ForEach-Object {$_[0]} | Sort-Object)[0]

# 51399228