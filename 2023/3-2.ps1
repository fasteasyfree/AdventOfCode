# Do the maths to see if a number is within spitting distance of a symbol
function Get-AdjacentMatch {
    Param(
        [int]$SymbolIndex,
        [int]$NumberIndex,
        [int]$Length
    )
    if (($SymbolIndex -ge ($NumberIndex-1)) -and ($SymbolIndex -le ($NumberIndex + $Length))) {
        return $true
    } else {
        return $false
    }
}

$InputFile = ".\3-1_input.txt"

$SymbolPattern = "\*"       # Matches any asterisk
$NumberPattern = "\d+"      # Matches any series of numbers

# Get all matches for symbols and numbers. We'll use their location to work out adjacent 
$SymbolLocations = Select-String -Path $InputFile -Pattern $SymbolPattern -AllMatches
$NumberLocations = Select-String -Path $InputFile -Pattern $NumberPattern -AllMatches

# We'll use Line+Index as key/name
$ValidNumbers = @{}

$MatchedNumbers = [System.Collections.Generic.List[object]]@()

# Go through the list of symbol locations, one line at a time
foreach ($SymbolLine in $SymbolLocations) {
    $CurrentLine = $SymbolLine.LineNumber

    # Iterate through the matches for the line
    foreach($SymbolMatch in $SymbolLine.Matches) {

        # Get the three lines with numbers wrapping the symbol line, and iterate through them
        $NumberLocationSubset = $NumberLocations | Where-Object LineNumber -in (($CurrentLine-1)..($CurrentLine+1))
        foreach ($NumberLine in $NumberLocationSubset) {

            # Iterate through each number in the line
            Foreach ($NumberMatch in $NumberLine.Matches) {

                # Check if that number has a symbol next to it, with an index between one before and one after the number
                if (Get-AdjacentMatch -SymbolIndex $SymbolMatch.Index -NumberIndex $NumberMatch.Index -Length $NumberMatch.Length) {

                    # Add to the list as an object
                    $Line   = $(([string]$CurrentLine).PadLeft(3,'0'))
                    $Index  = $(([string]$SymbolMatch.Index).PadLeft(3,'0'))
                    
                    $MatchedNumbers.Add([PSCustomObject]@{
                        SymbolLocation = "$Line-$Index"
                        Number = $NumberMatch.Value
                    })
                }
            }
        }
    }
}

# Group up by the symbol location - make sure we only grab the doubles (and thus the ratios)
$Grouped = $MatchedNumbers | Group-Object -Property SymbolLocation | Where-Object Count -ge 2

# Multiply the gears
$Added = foreach ($Group in $Grouped) {
    Invoke-Expression -Command (($Group.Group.Number) -join "*")
}

($Added | Measure-Object -Sum).Sum