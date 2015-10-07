<?php
$exec = exec("hostname"); //the "hostname" is a valid command in both windows and linux
$hostname = trim($exec); //remove any spaces before and afterhost
//$ip = gethostbyname($hostname);

$cmd="ifconfig eth0 | grep 'inet ' | awk '{print $2}'";
$ip=shell_exec($cmd);
//$time = strtotime(date('Y-m-d', time()). '00:00:00');
$time=date("Y-m-d H:i:s");


// display it back
echo "<h2>Apache web server test complete</h2>";
echo "<h3> Ip Address of this machine :</h3> " . $ip;
echo "<br><h3>Name of this machine :</h3> " . $hostname;
echo "<br><h3>Time :</h3> " . $time;
?>

