Param(
    [UInt64]$ExpansionAmount=2
)

function GetAllPairs {
    param (
        [array]$List
    )

    $AllPairs = [System.Collections.Generic.List[object]]@()
    for ($i = 0; $i -lt $List.Count; $i++) {
        for ($j = $i + 1; $j -lt $List.Count; $j++) {

            $AllPairs.Add([pscustomobject]@{
                First = $List[$i]
                Second = $List[$j]
                XDistance = [math]::Abs($List[$i].x - $List[$j].x)
                YDistance = [math]::Abs($List[$i].y - $List[$j].y)
            })
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
    $NumX = ($ExpansionCols | Where-Object {$_ -in (($Pair.First.x)..($Pair.Second.x))}).Count
    $NumY = ($ExpansionRows | Where-Object {$_ -in (($Pair.First.y)..($Pair.Second.y))}).Count

    # Add the numbers up, an mulitply them by the number of gaps between
    ($Pair.XDistance - $NumX) + ($NumX * $ExpansionAmount) + ($Pair.YDistance - $NumY) + ($NumY * $ExpansionAmount)
}

($Distances | Measure-Object -Sum).Sum