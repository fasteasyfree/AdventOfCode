<#
    The pipes are arranged in a two-dimensional grid of tiles:

    | is a vertical pipe connecting north and south.
    - is a horizontal pipe connecting east and west.
    L is a 90-degree bend connecting north and east.
    J is a 90-degree bend connecting north and west.
    7 is a 90-degree bend connecting south and west.
    F is a 90-degree bend connecting south and east.
    . is ground; there is no pipe in this tile.
    S is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.
#>

<#
function NextDirection {
    Param(
        # The direction we're approaching from:
        # N (above/north), E (right/east), S (below/south), W (left/west)
        [Char]$Approach,
        # The next location along
        [char]$NextLocation
    )

    $ValidPaths = @{
        N = "|","J","L" # down from the north, can go down, Left, Right
        E = "-","L","F"
        S = "|","F","7"
        W = "-","7","J" # across from the west, can go right, down, up
    }

    if ($NextLocation -in $ValidPaths.$Approach) {
        switch ($Approach) {
            "N" { return @{x=0;y=-1} } # If the next path is valid, and coming from north, next coord is down on the Y axis
            "E" { return @{x=-1;y=0} }
            "S" { return @{x=0;y=1} }
            "W" { return @{x=1;y=0} }
        }
    } else {
        # If we're not in the approved list, then we report not to move.
        return @{x=0;y=0}
    }
}
#>
function NextDirection {
    Param(
        # The direction we're approaching from:
        # N (above/north), E (right/east), S (below/south), W (left/west)
        [Char]$Approach,
        # The next location along
        [char]$NextLocation
    )

    $ValidPaths = @{
        N = "|","J","L" # down from the north, can go down, Left, Right
        E = "-","L","F"
        S = "|","F","7"
        W = "-","7","J" # across from the west, can go right, down, up
    }

    if ($NextLocation -in $ValidPaths.$Approach) {
        switch ($Approach) {
            "N" { return @{x=0;y=1} } # If the next path is valid, and coming from north, next coord is down on the Y axis
            "E" { return @{x=1;y=0} }
            "S" { return @{x=0;y=-1} }
            "W" { return @{x=-1;y=0} }
        }
    } else {
        # If we're not in the approved list, then we report not to move.
        return @{x=0;y=0}
    }
}

#$Map = Get-Content $PSScriptRoot\10-1_input.txt
$Map = Get-Content $PSScriptRoot\10-1_input_EXAMPLE.txt

# Z,Y coords for our starting location
$Start = $Map | Select-String -Pattern "S"
$Start = $Current = @{
    X = $Start.Matches.Index
    Y = $Start.LineNumber
}

$Routes = [System.Collections.Generic.List[hashtable]]@()
$Routes.add((NextDirection -Approach "N" -NextLocation $Map[$Start.Y+1][$Start.X]))
$Routes.add((NextDirection -Approach "E" -NextLocation $Map[$Start.Y][$Start.X-1]))
$Routes.add((NextDirection -Approach "S" -NextLocation $Map[$Start.Y-1][$Start.X]))
$Routes.add((NextDirection -Approach "W" -NextLocation $Map[$Start.Y][$Start.X+1]))
#$Routes = $Routes | Where-Object {($_.X -ne 0) -and $_.Y -ne 0}
