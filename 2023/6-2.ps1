$InputData = Get-Content .\6-1_input.txt

function solve {
    Param(
        [uint64]$Time,
        [UInt64]$Distance
    )

    $Delta = [Math]::Sqrt($Time * $Time - 4 * $Distance)

    $Upper = [math]::Ceiling(($Time - $Delta) / 2)
    $Lower = [math]::Floor(($Time + $Delta) / 2)

    $Lower - $Upper + 1
}


$Time       = $InputData[0] -replace "[^\d]"
$Distance   = $InputData[1] -replace "[^\d]"

solve -Time $Time -Distance $Distance

# 23632299