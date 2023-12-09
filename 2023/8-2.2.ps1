Function Factorise {
    Param (
        [uint]$Number
    )

    $MaxFactor = [math]::Sqrt($Number)

    #take care of 2 as a factor
    $Factor=2
    while ( ($Number % $Factor) -eq 0) {
        $Factor
        $Number=$Number/$Factor
    }

    #then brute force all odd numbers as factors up to max prime
    #while $Number remains greater than max prime
    $Factor=3
    while ($Factor -le $MaxFactor -and $number -ge $MaxFactor) {
        while ( ($Number % $Factor) -eq 0) {
            $Factor
            $Number=$Number/$Factor
        }
        $Factor+=2
    }
    $Number
}

function LeastCommonMultiple {
    param (
        [uint[]]$NumberArray
    )
    # Convert to a hashset to remove duplicates. To work out the LCM, we only multiply
    # one copy of each number
    $NoRepeats = [System.Collections.Generic.HashSet[int]]($NumberArray | Group-Object).Name

    Invoke-Expression -Command ($NoRepeats -join "*")
}

$InputData = Get-Content $PSScriptRoot\8-1_input.txt

# Get all the directions
$Directions = $InputData[0].ToCharArray()

# Left/right hashtable lookup 'might' be faster than a switch/if statement
$LeftRight  = @{L=0;R=1}

# Build up our hashtable of nodes.
$Nodes = [System.Collections.Specialized.OrderedDictionary]@{}
for ($i = 2; $i -lt $InputData.count; $i++) {

    # Key is first element after splitting line on spaces
    # Values are the regex lookup of "three letters - comma & space - three letters", split on that comma-space
    $Nodes."$(($InputData[$i] -split "\ ")[0])" = [regex]::Match($InputData[$i],"\w{3}\,\ \w{3}").Value -split ", "
}

# Start and end conditions
$Start  = "*A"
$End    = "*Z"

# Get the starting points, or 'threads'
$CountList = ($Nodes.GetEnumerator() | Where-Object Name -like $Start).Name | Foreach-Object {

    $Count      = $DirectionIndex = 0
    $Current    = $_

    # Keep going until the $current variable reaches the ZZZ we're expecting.
    while ($Current -notlike $End) {
        $Count++

        # Set the new location to whatever the left/right value of $Current is.
        $Direction = $LeftRight."$($Directions[$DirectionIndex])"
        $Current = $Nodes["$Current"][$Direction]
        
        # If the left/right directions DirectionIndex reaches the end, reset.
        if($DirectionIndex -eq ($Directions.count - 1)) { 
            $DirectionIndex = 0 
        }
        else { $DirectionIndex++ }
    }

    $Count
}

$AllFactors = $CountList.foreach({Factorise -Number $_})

LeastCommonMultiple -NumberArray $AllFactors