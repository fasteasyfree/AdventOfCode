$InputData = Get-Content .\8-1_input.txt
#$InputData = Get-Content .\8-1_input_EXAMPLE.txt

$Directions = $InputData[0].ToCharArray()

# Build up our hashtable of nodes.
$Nodes = [System.Collections.Specialized.OrderedDictionary]@{}
for ($i = 2; $i -lt $InputData.count; $i++) {

    # Key is first element after splitting line on spaces
    # Values are the regex lookup of "three letters - comma & space - three letters", split on that comma-space
    $Nodes."$(($InputData[$i] -split "\ ")[0])" = [regex]::Match($InputData[$i],"[A-Z]{3}\,\ [A-Z]{3}").Value -split ", "
}

# Left/right hashtable lookup 'might' be faster than a switch/if statement
$LeftRight  = @{L=0;R=1}
$Current    = "AAA"
$End        = "ZZZ"
$Count = $DirectionIndex = 0

# Keep going until the $current variable reaches the ZZZ we're expecting.
while ($Current -ne $End) {
    $Count++

    # Set the new location to whatever the left/right value of $Current is.
    $Current = $Nodes."$Current"[$LeftRight."$($Directions[$DirectionIndex])"]
    
    # If the left/right directions DirectionIndex reaches the end, reset.
    if($DirectionIndex -eq ($Directions.count - 1)) { 
        $DirectionIndex = 0 
    }
    else { $DirectionIndex++ }
}

$Count