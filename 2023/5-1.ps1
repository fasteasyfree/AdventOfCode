$InputData  = Get-Content .\5-1_input.txt

# The parent array containing the groupings
# The first element is the Seeds list, and subsequent ones are the maps
$Maps       = [system.collections.generic.list[object]]@()

# Use this to build up the content of $Maps
$TempArray  = [system.collections.generic.list[string]]@()

# Final result for the seeds
$FinalSeeds = [system.collections.generic.list[double]]@()

foreach ($Line in $InputData) {
    
    # Find the boundaries with blank line
    if($Line.trim() -eq ""){

        # Only applicable to the first Seeds: line
        if($TempArray.count -eq 1) {
            # If we added the Seeds line, get rid of the description.
            $TempArray[0] = ($TempArray[0] -split ":")[1].trim()
        }

        # Add another element to the parent array, and reset temp.
        $Maps.Add($TempArray)
        $TempArray = [system.collections.generic.list[string]]@()
    } 
    else {
        # We don't want to add the description as we'll be going down through each set of maps
        if ($Line -notmatch "^\w+-\w+-\w+\ map:$") {
            $TempArray.Add($Line)
        }
    }
}

# Go through each seed in turn
foreach ($Seed in ($Maps[0] -split "\ ")) {
    # Save the current seed start, make it a number
    $SeedLocation = [double]$Seed

    # Go through each map - start at index 1 to miss the seeds list
    for ($Map = 1; $Map -lt $Maps.Count; $Map++) {
        
        # Each line within a map
        foreach ($MapLine in $Maps[$Map]) {
            # Let's break the line, and make it easier to read
            $SrcDestRng     = $Mapline -split "\ "
            $Source         = [double]$SrcDestRng[1]
            $Destination    = [double]$SrcDestRng[0]
            $Range          = [double]$SrcDestRng[2]

            # Find out if the seed is within the range provided
            if (($SeedLocation -ge $Source) -and ($SeedLocation -le ($Source + $Range)) ) {
                # If within range, get the difference between the seed and source, then add that to the destination
                $SeedLocation = ($SeedLocation - $Source) + $Destination

                # If we found it, break the loop
                break
            }
        }
        # If we didn't find a matching range, then the seedlocation variable stays the same.
    }

    $FinalSeeds.Add($SeedLocation)
}

# Sort and find the lowest number
($FinalSeeds | Sort-Object)[0]