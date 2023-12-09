$Games = Get-Content -Path .\2-1_input.txt #| select -First 3

$Results = foreach ($Game in $Games) {
    $Colours         = @{}
    $Colours.red     = 1
    $Colours.green   = 1
    $Colours.blue    = 1

    $Index = 0
    # Break each game down into sets
    $Sets = $Game -split ';'

    foreach ($Set in $Sets) {
        #Write-Host "Index is $($Index)"
        $Index++
        #Write-Host $Set
        foreach ($Colour in $Colours.GetEnumerator().Name) {
            #Write-Host "Looking for colour: $Colour"
            $Pattern = "\d+\ $Colour"
            $Result = Select-String -InputObject $Set -Pattern $Pattern
            if($Result) {
                $ValueArray = $Result.Matches.Value -split " "
                
                #Write-Host "$Colour is $([int]$ValueArray[0])"

                if ([int]$ValueArray[0] -gt $Colours.($ValueArray[1]) ) {
                    $Colours.($ValueArray[1]) = [int]$ValueArray[0]
                }
            }
        }
    }

    Invoke-Expression -Command ($Colours.GetEnumerator().foreach({$_.Value}) -join "*")
}

($Results | Measure-Object -Sum).Sum