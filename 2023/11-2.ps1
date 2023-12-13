Param(
    [UInt64]$ExpansionAmount=1
)

function Distance {
    Param(
        #Obejcts with x,y properties
        $P1,
        $P2
    )
    return ([math]::Abs($P1.x - $P2.x) + [math]::Abs($P1.y - $P2.y))
}

function GetAllPairs {
    param (
        [array]$List
    )

    $AllPairs = [System.Collections.Generic.List[object]]@()
    for ($i = 0; $i -lt $List.Count; $i++) {
        for ($j = $i + 1; $j -lt $List.Count; $j++) {

            $Distance = Distance -P1 $List[$i] -P2 $List[$J]
            $AllPairs.Add(@($List[$i], $List[$j], $Distance))
        }
    }

    return $AllPairs
}

$InputData = Get-Content $PSScriptRoot\11-1_input.txt
<#
$InputData = @(
    "...#......",
    ".......#..",
    "#.........",
    "..........",
    "......#...",
    ".#........",
    ".........#",
    "..........",
    ".......#..",
    "#...#....."
)
#>


# Galaxy map will be a list of lists, containing chars
# Lists makes inserting easier
$GalaxyMap = [System.Collections.Generic.List[System.Collections.Generic.List[char]]]@()

# The rows and columns that will be expanded
$ExpansionRows = [System.Collections.Generic.List[int]]@()
$ExpansionCols = [System.Collections.Generic.List[int]]@()

# Take the initial input lines and add them to the list.
$InputData.Foreach({
    $GalaxyMap.Add( ($_.ToCharArray()) )
})

# Add in the horizontal entries
for ($Row = 0; $Row -lt $GalaxyMap.count; $Row++) {

    # if all there are no hash characters in the current row, add a new one
    if ( $GalaxyMap[$Row].Contains([char]"#") ) {} 
    else {
        $ExpansionRows.Add($Row + 1) # Increment for the maths
    }
}

# Add in the vertical entries. Use the first row to count
for ($Col = 0; $Col -lt $GalaxyMap[0].count; $Col++) {

    # Create a list of all the characters in the current column
    $CurrentCol = for ($Row = 0; $Row -lt $GalaxyMap.Count; $Row++) {
        $GalaxyMap[$Row][$Col]
    }

    # Check if that list contains a hash character
    if ($CurrentCol.contains([char]"#")) {}
    else {
        $ExpansionCols.Add($Col + 1) # Increment for the maths
    }
}

# Now we can find our galaxies
$GalaxyLocations = [System.Collections.Generic.List[object]]@()

$Count = 1
# Map, one line at a time.
for ($Line = 0; $Line -lt $GalaxyMap.count; $Line++) {
    # Join the chars up, and search for all instances of '#'. 
    ((-join $GalaxyMap[$Line]) | Select-String -Pattern "#" -AllMatches).matches.foreach({
        # Loop through any discoveries and add them.
        $GalaxyLocations.Add([pscustomobject]@{
            Galaxy = $Count++
            X = ($_.Index + 1)  # Need to increment the coords as otherwise the maths doesn't work for distance calculation
            Y = ($Line + 1)
        })
    })
}

# Gets the pairs and the 'default' distance between
$AllPairs = GetAllPairs -List $GalaxyLocations

$Distances = Foreach ($Pair in $AllPairs) {
    # Get the columns/rows which fall inbetween the coordinates
    $NumCols = ($ExpansionCols | Where-Object {$_ -in (($Pair[0].x)..($Pair[1].x))}).Count
    $NumRows = ($ExpansionRows | Where-Object {$_ -in (($Pair[0].y)..($Pair[1].y))}).Count

    # Add the numbers up, an mulitply them by the number of gaps between
    $Pair[2] + [UInt64]($NumRows * $ExpansionAmount) + [uint64]($NumCols * $ExpansionAmount)
}

($Distances | Measure-Object -Sum).Sum