<#
Using the example data, these are the values for the hierarchy working out.

AAAAA 5/1 = 5		Five of a kind
AA8AA 4/2 = 2		Four of a kind
23332 3/2 = 1.5		Full House
TTT98 3/3 = 1		Three of a kind
23432 2/3 = 0.67	Two Pair
A23A4 2/4 = 0.5		One Pair		
12345 1/5 = 0.2		High card

Put the hand into the hierarchy (five of a kind all the way down to high card) by
grouping the hand by each card in it. Divide the number in the largest grouping of 
cards, with the number of groupings. Seems to be a cheap way of doing it    
#>

$InputData = Get-Content .\7-1_input.txt

$ValueList = @("A", "K", "Q", "T", "9", "8", "7", "6", "5", "4", "3", "2", "J")
[array]::Reverse($ValueList)

# Create our hash for card-to-value conversion. Will aid in ordering.
$ValueHash = @{}
for($i = 0; $i -lt $ValueList.count; $i++) {
    $ValueHash[$ValueList[$i]] = "$i".PadLeft(2,"0") # padding left so alphabetical ordering makes sense.
}

$Hands = $InputData.ForEach({
    $HandBid = $_ -split "\ "

    # Create a 'value' from the hand.
    # As the challenge states, card ordering is what's important
    [Int64]$Value = $HandBid[0].ToCharArray().ForEach({
        $ValueHash["$_"]
    }) -join ""

    # Number of jokers
    $NoJokerString  = $Handbid[0] -replace "J"
    $NumJokers      = $HandBid[0].Length - $NoJokerString.Length 

    # Group the hand up, with each type of card in a group
    # Sorted so the largest grouping is first
    # First we do the Part 1 solution....
    $Grouped    = @($Handbid[0].ToCharArray() | Group-Object | Sort-Object -Property Count -Descending)
    $Hierarchy  = [double]($Grouped[0].Count / $Grouped.count) # divide the largest grouping by the number of groups.

    # ...and then the part 2 solution.
    $Grouped    = @($NoJokerString.ToCharArray() | Group-Object | Sort-Object -Property Count -Descending)
    if ($Grouped.Count -eq 0) {$NumGroups = 1} else {$NumGroups = $Grouped.Count} # Stupid divide by zero...
    $JokerHierarchy  = [double]( ($Grouped[0].Count + $NumJokers) / $NumGroups) # divide the largest grouping by the number of groups.

    [pscustomobject]@{
        Hand            = $HandBid[0]
        Bid             = [int]$HandBid[1]
        Value           = $Value
        Hierarchy       = $Hierarchy
        JokerHierarchy  = $JokerHierarchy
    }
})

# Sort the hands by their value, lowest to highest
$Hands = $Hands | Sort-Object -Property @{Expression={$_.Hierarchy}; Descending=$false}, @{Expression={$_.Value} ;Descending=$false}

# Calculate the value
$RunningTotal = 0
for ($i = 0; $i -lt $Hands.Count; $i++) {
    $RunningTotal += $Hands[$i].Bid * ($i+1)
}

# And then do the same again to get the Part 2 value
$Hands = $Hands | Sort-Object -Property @{Expression={$_.JokerHierarchy}; Descending=$false}, @{Expression={$_.Value} ;Descending=$false}
$RunningTotalJoker = 0
for ($i = 0; $i -lt $Hands.Count; $i++) {
    $RunningTotalJoker += $Hands[$i].Bid * ($i+1)
}

[pscustomobject]@{
    Part1 = $RunningTotal
    Part2 = $RunningTotalJoker
}