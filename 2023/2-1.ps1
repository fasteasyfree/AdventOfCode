$Games = Get-Content -Path .\2-1_input.txt #| select -First 3

$Colours         = @{}
$Colours.red     = 12
$Colours.green   = 13
$Colours.blue    = 14

$Results = foreach ($Game in $Games) {
    $Impossible = $false

    # Break each game down into sets
    $Sets = $Game -split ';'

    foreach ($Set in $Sets) {
        $Colours.GetEnumerator().foreach({ 
            $Pattern = "\d+\ $($_.Name)"
            $ValueArray = (Select-String -InputObject $Set -Pattern $Pattern).Matches.Value -split " "

            if([int]$ValueArray[0] -gt $Colours."$($_.Name)") {
                $Impossible = $true
            }
        })
    }

    if(-not $Impossible) {
        [int](($Sets[0] | Select-String -Pattern "^Game\ \d+:").Matches.Value -replace ":" -split "\ ")[1]
    }
}

($Results | Measure-Object -Sum).Sum