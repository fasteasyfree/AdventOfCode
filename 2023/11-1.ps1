#$InputData = Get-Content $PSScriptRoot\11-1_input.txt
#$InputData = Get-Content $PSScriptRoot\11-1_input_EXAMPLE.txt
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

# Galaxy map will be a list of lists, containing chars
# Lists makes inserting easier
$GalaxyMap = [System.Collections.Generic.List[System.Collections.Generic.List[char]]]@()

# Take the initial input lines and add them to the list.
$InputData.Foreach({
    $GalaxyMap.Add( ($_.ToCharArray()) )
})

# Create a new row of dots to add
$NewRow = @((1..10).foreach({[char]'.'}))
# Add in the horizontal entries
for ($Row = 0; $Row -lt $GalaxyMap.count; $Row++) {

    # if all there are no hash characters in the current row, add a new one
    if ( $GalaxyMap[$Row].Contains([char]"#") ) {} 
    else {
        # Increment the row number by one to push it to the next line
        $Row++
        $GalaxyMap.insert(($Row), $NewRow)
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
        # If it doesn't, push the columns along by one so 
        # we're adding subsequent ones in the right place
        $Col++
        for ($Row = 0; $Row -lt $GalaxyMap.Count; $Row++) {
            $GalaxyMap[$Row].Insert($Col,'.')
        }
    }
}

# Now we can find our galaxies
$GalaxyLocations = [System.Collections.Generic.List[object]]@()

# Map, one line at a time.
for ($Line = 0; $Line -lt $GalaxyMap.count; $Line++) {
    # Join the chars up, and search for all instances of '#'. 
    ((-join $GalaxyMap[$Line]) | Select-String -Pattern "#" -AllMatches).matches.foreach({
        # Loop through any discoveries and add them.
        $GalaxyLocations.Add([pscustomobject]@{
            X = $_.Index
            Y = $Line
        })
    })
}