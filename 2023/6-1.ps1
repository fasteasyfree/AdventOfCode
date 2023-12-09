$InputData = Get-Content .\6-1_input.txt

$Lines = [System.Collections.Generic.list[object]]@()
$Races = [System.Collections.Generic.list[object]]@()

$InputData.foreach({ $Lines.Add(@($_ -split "\ +")) })

1..($Lines[0].Count -1) | ForEach-Object {
    $Races.Add([PSCustomObject]@{
        Time        = $Lines[0][$_]
        Distance    = $Lines[1][$_]
        Results     = @()
    })
}

$CountTotals = foreach ($Race in $Races) {

    $Race.Results = for ($HoldTime = 1; $HoldTime -lt $Race.Time; $HoldTime++ ) {
        $HoldTime * ($Race.Time - $HoldTime) | Where-Object {$_ -gt $Race.Distance}
    }

    $Race.Results.Count
}

Invoke-Expression -Command ($CountTotals -join "*")

# 505494