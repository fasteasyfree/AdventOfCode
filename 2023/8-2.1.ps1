# NOT WORKING - see 8-2.2

function NodeLoop {
    Param(
        [int]$ThreadsIndex=0,
        [uint]$AimFor=0
    )
    
    $Finished = $false
    $CurrentNodeName = $Global:Threads[$ThreadsIndex].Name

    Write-Host "Starting index " $ThreadsIndex " and aiming for " $AimFor

    # While the cou
    while (-not $Finished) {
        # If we're already at the end of list of threads, break out and return zero
        if ($ThreadsIndex -ge $global:Threads.Count) {break}
        
        # Work out the direction, and then get the node name for that direction.
        $Direction = $Global:LeftRight."$($Global:Directions[$Global:Threads[$ThreadsIndex].DirectionIndex])"
        $CurrentNodeName = $Global:Nodes."$CurrentNodeName"[$Direction]

        # If the Node name we found matches an end goal
        if ($CurrentNodeName -like $Global:End) {
            # Set the name for the thread index
            $Global:Threads[$ThreadsIndex].Name = $CurrentNodeName

            if ($ThreadsIndex -eq 0) {
                $AimFor = $Global:Threads[$ThreadsIndex].Counter
            }

            Write-Host "Found " $Global:End
            # Check if the counter is more than what we're aiming for - if it is, return that we're too high
            if ($Global:Threads[$ThreadsIndex].Counter -gt $AimFor) {
                Write-Host "Too high at " $Global:Threads[$ThreadsIndex].Counter ". Going back to index " $ThreadsIndex-1
                $Finished = $true
                $ReturnValue = 1
            }
            # if the numbers match, then we're at the same level or higher. Call the next iteration along.
            if ($Global:Threads[$ThreadsIndex].Counter -eq $AimFor) {
                Write-Host "On the money, kicking off new thread!"
                $Result = NodeLoop -ThreadsIndex ($ThreadsIndex+1) -AimFor $Global:Threads[$ThreadsIndex].Counter

                # if the result is zero, then we've either hit the end, or
                if ($Result -eq 0) {
                    $Finished = $true
                    $ReturnValue = 0
                }
                if ($Result -eq 1) {Write-Host "returned to index " $ThreadsIndex}
            }

            # Otherwise we're below the number we're aiming for, and need to keep going.
        }

        # Increment the counter of the current thread
        $Global:Threads[$ThreadsIndex].Counter++

        if($Global:Threads[$ThreadsIndex].DirectionIndex -eq ($Global:Directions.count - 1)) { 
            $Global:Threads[$ThreadsIndex].DirectionIndex = 0 
        }
        else { $Global:Threads[$ThreadsIndex].DirectionIndex++ }
    }
    
    return $ReturnValue
}

$InputData = Get-Content .\8-1_input.txt
#$InputData = Get-Content .\8-1_input_EXAMPLE.txt

# Get all the directions
$Global:Directions = $InputData[0].ToCharArray()

# Left/right hashtable lookup 'might' be faster than a switch/if statement
$Global:LeftRight  = @{L=0;R=1}

# Build up our hashtable of nodes.
$Global:Nodes = [System.Collections.Specialized.OrderedDictionary]@{}
#$Nodes = [hashtable]::Synchronized(@{})
for ($i = 2; $i -lt $InputData.count; $i++) {

    # Key is first element after splitting line on spaces
    # Values are the regex lookup of "three letters - comma & space - three letters", split on that comma-space
    $Nodes."$(($InputData[$i] -split "\ ")[0])" = [regex]::Match($InputData[$i],"\w{3}\,\ \w{3}").Value -split ", "
}

$Start   = "*A"
$Global:End     = "*Z"

# Get all the nodes ending in A as our starting point
$global:Threads = $Nodes.GetEnumerator() | Where-Object Name -like $Start | Foreach-Object {
    [pscustomobject]@{
        Name            = $_.Name
        DirectionIndex  = 0
        Counter         = 0
    }
}

NodeLoop | Out-Null
$Global:Threads[0].Counter