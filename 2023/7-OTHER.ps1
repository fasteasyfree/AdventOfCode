function Import-PuzzleInput {
    param (
        $Path
    )
    $puzzleInput = Get-Content $Path
    $puzzleInput | ForEach-Object {
        $hand, $bid = $_ -split ' '
        [PSCustomObject]@{
            Hand = $hand
            Bid  = $bid
        }
    }
}

function Get-KindRank {
    param (
        $Hand,
        [switch]
        $Joker
    )
    $hand = $Hand -split '' | Where-Object { $_ }
    $cardGroup = $hand | 
        Group-Object -NoElement | 
        Select-Object Name, @{n = 'CardCount'; e = { $_.Count } }
    $cardWithHighestCount = $cardGroup | Sort-Object CardCount -Descending -Top 1
    if ($Joker.IsPresent -and $hand -contains 'J' -and $cardGroup.Count -ne 1) {
        $jokerCard, $cardGroup = $cardGroup | Sort-Object { $_.Name -eq 'J' } -Descending
        $cardWithHighestCount = $cardGroup | Sort-Object CardCount -Descending -Top 1
        $cardWithHighestCount.CardCount += $jokerCard.CardCount
    }
    $numberOfDistinctCards = $cardGroup.Count
    switch ($cardWithHighestCount.CardCount) {
        1 { 1 <# HighCard #> }
        2 { ($numberOfDistinctCards -eq 4) ? 2 <# OnePair #> : <# TwoPair #> 3 }
        3 { ($numberOfDistinctCards -eq 3) ? 4 <# ThreeOfKind #> : <# FullHouse #> 5 }
        4 { 6 <# FourOfKind #> } 
        5 { 7 <# FiveOfKind #> } 
    }
}

function Get-HandLexicalSortString {

    param (
        $Hand,
        [switch]
        $Joker
    )

    $valueMap = @{
        T = 'A'
        J = $Joker.IsPresent? 1 : 'B'
        Q = 'C'
        K = 'D'
        A = 'E'
    }
    $hand = $Hand -split '' | Where-Object { $_ }

    $sortString = @()
    foreach ($card in $hand) {
        if ($valueMap.ContainsKey($card)) {
            $card = $valueMap[$card]
        } 
        $sortString += $card
    }
    Write-Output ($sortString -join '' )
}

$puzzleInput = Import-PuzzleInput .\7-1_input.txt

$sortedHandsPart1 = $puzzleInput | 
    Sort-Object { Get-KindRank -Hand $_.Hand }, { Get-HandLexicalSortString -Hand $_.Hand }

$sortedHandsPart2 = $puzzleInput | 
    Sort-Object { Get-KindRank -Hand $_.Hand -Joker }, { Get-HandLexicalSortString -Hand $_.Hand -Joker }

$sumPart1 = 0
$sumPart2 = 0
for ($i = 1; $i -le $sortedHandsPart1.Count; $i++) {
    $sumPart1 += [int]$sortedHandsPart1[$i - 1].Bid * $i
    $sumPart2 += [int]$sortedHandsPart2[$i - 1].Bid * $i
}
Write-Host "
Part1: $sumPart1
Part2: $sumPart2
"