# NOT WORKING - see 8-2.2

$InputData = Get-Content .\8-1_input.txt
#$InputData = Get-Content .\8-1_input_EXAMPLE.txt

$Directions = $InputData[0].ToCharArray()

# Build up our hashtable of nodes.
$Nodes = [System.Collections.Specialized.OrderedDictionary]@{}
#$Nodes = [hashtable]::Synchronized(@{})
for ($i = 2; $i -lt $InputData.count; $i++) {

    # Key is first element after splitting line on spaces
    # Values are the regex lookup of "three letters - comma & space - three letters", split on that comma-space
    $Nodes."$(($InputData[$i] -split "\ ")[0])" = [regex]::Match($InputData[$i],"\w{3}\,\ \w{3}").Value -split ", "
}

# Left/right hashtable lookup 'might' be faster than a switch/if statement
$LeftRight  = @{L=0;R=1}
# Get all the nodes ending in A as our starting point
$Current        = $Nodes.GetEnumerator() | Where-Object Name -like "*A" | Select-Object -ExpandProperty Name
$StartingNumber = $Current.Count
$End            = "*Z"
$Count = $DirectionIndex = 0
$Finished       = $false

# Keep going until the $current variable reaches the ZZZ we're expecting.
while (-not $Finished) {
    $Count++

    $Direction = $LeftRight."$($Directions[$DirectionIndex])"

    # Set the new location to whatever the left/right value of $Current is.
    $Current = $Current | Foreach-Object -Parallel {        
        ($Using:Nodes)["$_"][$Using:Direction]
    }
    
    $EndsWithZ = ($Current | Where-Object {$_ -like $End}).Count
    if($EndsWithZ -eq $StartingNumber){
        $finished = $true
    } else {# If the left/right directions DirectionIndex reaches the end, reset.

        

        if($DirectionIndex -eq ($Directions.count - 1)) { 
            $DirectionIndex = 0 
        }
        else { $DirectionIndex++ }
    }
}

$Count