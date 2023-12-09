$InputData = Get-Content -Path .\4-1_input.txt #| select -First 5

$Result = foreach ($Line in $InputData) {
    $AllNumbers = ($Line -split ":")[1].Trim()
    $Winning    = ($AllNumbers -split "\|")[0].Trim() -split "\ +"
    $Chosen     = ($AllNumbers -split "\|")[1].Trim() -split "\ +"

    $Count = 0

    $Chosen.foreach({
        if($_ -in $Winning) {
            $Count++
        }

    })

    if ($Count -gt 0) {
        [Math]::Pow(2,$Count-1)
    }
}

($Result | Measure-Object -Sum).Sum