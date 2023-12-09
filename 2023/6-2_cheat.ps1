$Data = Get-Content .\6-1_input.txt

$times=@([int64]($data[0] -replace '\D+'))
$distances=@([int64]($data[1] -replace '\D+'))
$skip=3000
$Skipped="No"
$race=0
foreach($time in $times) {

    for($hold=0;$hold -le $time;$hold++) {

        $DistanceCovered = ($time-$hold)*($hold)

        if($DistanceCovered -gt $distances[$race]) {
            
            if($skipped -eq "no") {
                $hold=$hold-$skip
                $skipped="Yes"
            }
            else{Break}
        } else {
            if($skipped="No"){$hold=$hold+$skip}
        }
    }
}
$totalsuccess = ($time+1)-($hold*2)
$totalsuccess