#$InputData = Get-Content $PSScriptRoot\11-1_input.txt
$InputData = Get-Content $PSScriptRoot\11-1_input_EXAMPLE.txt

$GalaxyMapTemp  = [System.Collections.Generic.List[string]]@()
$GalaxyMap      = [System.Collections.Generic.List[string]]@()

# Add the horizontal Cols
foreach ($Horizontal in $InputData) {
    $GalaxyMapTemp.Add($Horizontal)
    if (([System.Collections.Generic.HashSet[char]]($Horizontal.ToCharArray())).count -eq 1) {
        $GalaxyMapTemp.Add($Horizontal)
    }
}

$GalaxyMap = $GalaxyMapTemp

# Add the vertical columns
for ($Col = 0; $Col -lt $GalaxyMapTemp[0].Length; $Col++) {

    $Vertical = for ($Row=0; $Row -lt $GalaxyMapTemp.count; $Row++) {$GalaxyMapTemp[$Row][$Col]}
    $Vertical = $Vertical -join ""
    if (([System.Collections.Generic.HashSet[char]]($Vertical.ToCharArray())).count -eq 1) {
        $NewCol
        # One row at a time
        for ($Row = 0; $Row -lt $GalaxyMapTemp.count; $Row++) {
            $GalaxyMap[$Row].Insert($Col,".")
        }
    }
}