<#
    Your calculation isn't quite right. It looks like some of the digits are actually spelled out with letters: one, two, three, four, five, six, seven, eight, and nine also count as valid "digits".

    Equipped with this new information, you now need to find the real first and last digit on each line. For example:

    two1nine
    eightwothree
    abcone2threexyz
    xtwone3four
    4nineeightseven2
    zoneight234
    7pqrstsixteen
    In this example, the calibration values are 29, 83, 13, 24, 42, 14, and 76. Adding these together produces 281.

    What is the sum of all of the calibration values?
#>

$Lines = Get-Content -Path .\1-1_input.txt #| Select-Object -first 10

function Get-Index {
    Param(
        [string]$String,
        [string]$SubString,
        [int]$StartIndex=0
    )

    # Get the index of the number we're looking for
    $Result = $String.IndexOf($SubString,$StartIndex)

    # If we're successful, recurse.
    if ($Result -ne -1) {
        # Start the next IndexOf further along the string than the one we found
        $StartIndex = $Result + 1

        # Return the result as array, Combining the original result and the recurse'd one.
        return @($Result) + @((Get-Index -String $String -SubString $SubString -StartIndex $StartIndex ))
    }
}

# Get our text array of number words. Wanted a more elegant way...
$Numbers = @("zero","one","two","three","four","five","six","seven","eight","nine")

# Iterate through each line
$Values = foreach ($Line in $Lines) {

    # Hash of numbers in each line.
    # The Index of the substring will be the key, and the number (in numeric format) will be the value
    $ResultHash = @{}

    # Think it's all lower case, but you never can be careful....
    $Line = $Line.ToLower()

    # Loop through the array of numbers
    for ($i = 0; $i -lt $Numbers.Count; $i++) {

        # Get the index results. Call the function twice, with number digit, and then word. Combine into array
        $IndexResults = @(Get-Index -String $Line -SubString "$i") + @(Get-Index -String $Line -SubString $Numbers[$i])

        # Build the hash mentioned
        foreach ($Index in $IndexResults ) {
            $ResultHash[$Index] = $i
        }
    }

    $LineNumbers = [System.Collections.Generic.List[int]]@()

    # Enumerate the hash. Sort by Name/key (the index location) and then add the numbers to the generic list 
    $ResultHash.GetEnumerator() | Sort-Object Name | ForEach-Object {$LineNumbers.Add($_.Value)}

    # Concatenate the first and last numbers, turn into integer
    [int]"$($LineNumbers[0])$($LineNumbers[-1])"
}

# Sum all the numbers.
($Values | Measure-Object -Sum).Sum

# 54504